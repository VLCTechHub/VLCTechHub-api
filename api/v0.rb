require 'time'
require 'date'

require_relative './mail'
require_relative './event'

module VLCTechHub
  class API < Grape::API
    class V0 < Grape::API
      version 'v0', using: :path

      ## Events
      resource 'events' do
        desc 'Retrieve future scheduled events'
        get 'upcoming' do
          events = db['events'].find( { published: true, date: { :$gte => Time.now.utc } } ).sort( { date: 1 } )
          present events.to_a, with: Event
        end

        desc 'Retrieve latest 10 past events'
        get 'past' do
          events = db['events'].find( { published: true, date: { :$lt => Time.now.utc } }).sort( {date: -1} ).limit(10)
          present events.to_a, with: Event
        end

        desc 'Retrieve events by year and month'
        get ':year/:month' do
          month = DateTime.new(params[:year].to_i, params[:month].to_i, 1)
          next_month = (month >> 1)
          events = db['events'].find( { published: true, date: { :$gte => month.to_time.utc , :$lt => next_month.to_time.utc } }).sort( {date: -1} )
          present events.to_a, with: Event
        end

        desc 'Retrieve a specific event'
        get ':id' do
          event = db['events'].find_one( {_id: BSON::ObjectId(params[:id])} )
          present event, with: Event
        end

        desc 'Create new event'
        params do
          requires :title, type: String,  regexp: /.+/, desc: "The title of the event."
          requires :description, type: String, regexp: /.+/, desc: "The description of the event."
          requires :link, type: String, regexp: /.+/, desc: "The link to the published post outside VLCTechHub."
          requires :date, type: DateTime, regexp: /.+/, desc: "Starting date and time of the event."
        end
        post 'new' do
          newEvent = {
            title: params[:title],
            description: params[:description],
            link: params[:link],
            date: params[:date].iso8601,
            published: false
          }

          puts newEvent
          ##db['events'].insert(newEvent)

        end
      end
    end
  end
end
