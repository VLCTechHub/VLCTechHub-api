#$:.unshift File.dirname(__FILE__)
require 'time'
require 'date'
require 'securerandom'

require_relative 'event'

module VLCTechHub
  module API
    module V1
      class Routes < Grape::API
        version 'v1', using: :path

        ## Events
        resource 'events' do
          desc 'Retrieve events by category or year and month'
          params do
            optional :year, type: String, regexp: /^20\d\d$/, desc: "Year"
            given :year do
              requires :month, type: String, regexp: /^0[1-9]|1[012]$/, desc: "Month"
            end
            optional :category, type: String,  values: ['recent', 'next']
            mutually_exclusive :year, :category
          end
          get do
            events = []
            if params[:category] == 'recent'
              events = repo.find_latest_events
            elsif params[:category] == 'next'
              events = repo.find_future_events
            elsif params[:year]
              events = repo.find_by_month(params[:year].to_i, params[:month].to_i)
            end
            present :events, events.to_a, with: Event
          end

          desc 'Create a  new event'
          params do
            group :event, type: Hash do
              requires :title, type: String,  regexp: /.+/, desc: "The title of the event."
              requires :description, type: String, regexp: /.+/, desc: "The description of the event."
              requires :link, type: String, regexp: /.+/, desc: "The link to the published post outside VLCTechHub."
              requires :date, type: Time, regexp: /.+/, desc: "Starting date and time of the event."
            end
          end
          post do
            newEvent = {
              title: params[:event][:title],
              description: params[:event][:description],
              link: params[:event][:link],
              date: params[:event][:date].utc,
              hashtag: Helper::Hashtag.clean(params[:event][:hashtag]),
              # mover a repo.insert
              published: false,
              publish_id: SecureRandom.uuid
            }
            event = repo.insert newEvent
            mailer.publish event
            present :event, event, with: Event
          end
        end

        resource 'publish' do
          desc 'Activate publication from a link in a mail and broadcast it'
          get ':uuid' do
              was_updated = repo.publish params[:uuid]
              error!('404 Not found', 404) unless was_updated

              event = repo.find_by_uuid params[:uuid]
              mailer.broadcast event
              twitter.tweet event
              present :event, event, with: Event
          end
        end
      end
    end
  end
end
