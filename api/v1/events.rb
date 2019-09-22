# frozen_string_literal: true

require 'time'
require 'date'
require 'securerandom'

require_relative 'entity/event'
require_relative '../../helpers/hashtag'

module VLCTechHub
  module API
    module V1
      class Routes < Grape::API
        version 'v1', using: :path

        resource 'events' do
          helpers do
            def events
              @events ||= VLCTechHub::Event::Repository.new
            end
          end

          desc 'Retrieve events by category or year and month'
          params do
            optional :year, type: String, regexp: /^20\d\d$/, desc: 'Year'
            given :year do
              requires :month, type: String, regexp: /^0[1-9]|1[012]$/, desc: 'Month'
            end
            optional :category, type: String, values: %w[recent next]
            mutually_exclusive :year, :category
          end
          get do
            result = []
            if params[:category] == 'recent'
              result = events.find_latest_events
            elsif params[:category] == 'next'
              result = events.find_future_events
            elsif params[:year]
              result = events.find_by_month(params[:year].to_i, params[:month].to_i)
            end
            present :events, result.to_a, with: Event
          end

          desc 'Retrieves an event'
          params do
            requires :slug, type: String, regexp: /^\w[\w-]*-[0-9a-f]{12}$/, desc: 'The slug assigned to the event.'
          end
          get '/:slug' do
            result = events.find_by_slug(params[:slug])
            present :event, result, with: Event
          end

          desc 'Create a  new event'
          params do
            group :event, type: Hash do
              requires :title, type: String, regexp: /.+/, desc: 'The title of the event.'
              requires :description, type: String, regexp: /.+/, desc: 'The description of the event.'
              requires :link, type: String, regexp: /.+/, desc: 'The link to the published post outside VLCTechHub.'
              requires :date, type: Time, regexp: /.+/, desc: 'Starting date and time of the event.'
            end
          end
          post do
            event = {
              title: params[:event][:title],
              description: params[:event][:description],
              link: params[:event][:link],
              date: params[:event][:date].utc,
              hashtag: Helper::Hashtag.clean(params[:event][:hashtag])
            }
            created_event = events.insert event
            VLCTechHub::Event::Mailer.publish created_event
            present :event, created_event, with: Event
          end

          resource 'publish' do
            desc 'Activate publication from a link in a mail and broadcast it'
            get '/:uuid' do
              was_updated = events.publish params[:uuid]
              error!('404 Not found', 404) unless was_updated

              event = events.find_by_uuid params[:uuid]
              VLCTechHub::Event::Mailer.broadcast event
              VLCTechHub::Event::Twitter.new_event event
              present :event, event, with: Event
            end
          end
        end
      end
    end
  end
end
