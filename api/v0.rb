$:.unshift File.dirname(__FILE__)
require 'time'
require 'date'
require 'securerandom'

require 'event'

module VLCTechHub
  class API < Grape::API
    class V0 < Grape::API
      version 'v0', using: :path

      helpers do
        def get_hashtag
          hashtag = params[:hashtag] || ''
          hashtag = hashtag.strip.split[0] || ''
          return hashtag if hashtag.empty?
          if !hashtag.start_with?('#') && !hashtag.start_with?('@')
            hashtag = '#' << hashtag
          end
          hashtag
        end
      end

      ## Events
      resource 'events' do
        desc 'Retrieve future scheduled events'
        get 'upcoming' do
          events = repo.find_future_events
          present events.to_a, with: Event
        end

        desc 'Retrieve latest 10 past events'
        get 'past' do
          events = repo.find_latest_events
          present events.to_a, with: Event
        end

        desc 'Retrieve events by year and month'
        params do
          requires :year, type: String, regexp: /20\d\d/, desc: "Year"
          requires :month, type: String, regexp: /0[1-9]|1[012]/, desc: "Month"
        end
        get ':year/:month', requirements: { year: /\d{4}/, month: /\d{2}/ } do
          events = repo.find_by_month(params[:year].to_i, params[:month].to_i)
          present events.to_a, with: Event
        end

        desc 'Retrieve a specific event'
        get ':id' do
          event = repo.find_by_id params[:id]
          present event, with: Event
        end

        desc 'Create new event'
        params do
          requires :title, type: String,  regexp: /.+/, desc: "The title of the event."
          requires :description, type: String, regexp: /.+/, desc: "The description of the event."
          requires :link, type: String, regexp: /.+/, desc: "The link to the published post outside VLCTechHub."
          requires :date, type: Time, regexp: /.+/, desc: "Starting date and time of the event."
        end
        post 'new' do
          newEvent = {
            title: params[:title],
            description: params[:description],
            link: params[:link],
            date: params[:date].utc,
            hashtag: get_hashtag,
            published: false,
            publish_id: SecureRandom.uuid
          }
          event = repo.insert newEvent
          mailer.publish event
          present event, with: Event
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
            present event, with: Event
        end
      end
    end
  end
end
