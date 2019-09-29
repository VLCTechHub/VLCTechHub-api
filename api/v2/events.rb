# frozen_string_literal: true

require 'time'
require 'date'
require 'securerandom'

require_relative 'entity/event'
require_relative '../../helpers/hashtag'

module VLCTechHub
  module API
    module V2
      class Routes < Grape::API
        version 'v2', using: :path

        resource 'events' do
          helpers do
            def events
              @events ||= VLCTechHub::Event::Repository.new
            end
          end

          desc 'Flag events as posted in the website'
          params do
            requires :events, type: Array[JSON] do
              requires :id,
                       type: String,
                       regexp: /^[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$/i,
                       desc: 'The publish id for the event'
            end
          end
          patch 'posted' do
            params[:events].each { |event| events.mark_as_posted(event['id']) }

            status :no_content
          end

          desc 'Retrieve all events'
          get do
            result = events.all
            present result.to_a, with: Event
          end

          desc 'Retrieve past events'
          get 'past' do
            result = events.find_past_events
            present result.to_a, with: Event
          end

          desc 'Retrieve upcoming events'
          get 'upcoming' do
            result = events.find_future_events
            present result.to_a, with: Event
          end

          desc 'Retrieve events by year'
          params { requires :year, type: Integer, desc: 'Year' }
          get ':year', requirements: { year: /[0-9]*/ } do
            result = events.find_by_year(params[:year])
            present result.to_a, with: Event
          end

          desc 'Retrieve events by year and month'
          params do
            requires :year, type: Integer, desc: 'Year'
            requires :month, type: Integer, values: 1..12, desc: 'Month'
          end
          get ':year/:month', requirements: { year: /[0-9]*/ } do
            result = events.find_by_month(params[:year], params[:month])
            present result.to_a, with: Event
          end

          desc 'Retrieve an event by slug'
          params { requires :slug, type: String, regexp: /^\w[\w-]*-[0-9a-f]{12}$/, desc: 'Slug' }
          get ':slug' do
            result = events.find_by_slug(params[:slug])

            error!('404 Not found', 404) unless result

            present result, with: Event
          end

          desc 'Create a new event'
          params do
            requires :title, type: String, allow_blank: false, desc: 'The event headline'
            requires :description, type: String, allow_blank: false, desc: 'The event description'
            requires :link, type: String, allow_blank: false, desc: 'The link to the published post outside VLCTechHub'
            requires :date, type: Time, allow_blank: false, desc: 'Starting date and time of the event'
            optional :hashtag, type: String, desc: 'The twitter handle of the event organizer or the event hashtag'
          end
          post do
            created_event =
              events.insert(
                title: params[:title],
                description: params[:description],
                link: params[:link],
                date: params[:date].utc,
                hashtag: Helper::Hashtag.clean(params[:hashtag])
              )
            VLCTechHub::Event::Mailer.approve(created_event)
            present created_event, with: Event
          end

          desc 'Approve publication from the link in the approval email'
          params do
            requires :uuid,
                     type: String,
                     regexp: /^[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$/i,
                     desc: 'The publish id for the event'
          end
          get 'approve/:uuid' do
            was_approved = events.publish(params[:uuid])

            error!('404 Not found', 404) unless was_approved

            approved_event = events.find_by_uuid(params[:uuid])
            present approved_event, with: Event
          end
        end
      end
    end
  end
end
