require 'time'
require 'date'
require 'securerandom'

require_relative './event'
require_relative './mail'

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
        params do
          requires :year, type: String, regexp: /20\d\d/, desc: "Year"
          requires :month, type: String, regexp: /0[1-9]|1[012]/, desc: "Month"
        end
        get ':year/:month', requirements: { year: /\d{4}/, month: /\d{2}/ } do
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
          requires :date, type: Time, regexp: /.+/, desc: "Starting date and time of the event."
        end
        post 'new' do
          newEvent = {
            title: params[:title],
            description: params[:description],
            link: params[:link],
            date: params[:date].utc,
            published: false,
            publish_id: SecureRandom.uuid
          }

          id = db['events'].insert(newEvent)
          event = db['events'].find_one( {_id: id} )
          VLCTechHub.send_mail_for_publication event
          present event, with: Event
        end
      end

      resource 'publish' do
        desc 'Activate publication from a link in a mail and broadcast it'
        get ':uuid' do
            result = db['events'].update(  { published: false, publish_id: params[:uuid] },
                                          { "$set" => { published: true } } )
            was_updated = (result['n'] == 1)
            error!('404 Not found', 404) unless was_updated

            event = db['events'].find_one( {publish_id: params[:uuid]} )
            VLCTechHub.send_mail_to_broadcast_list event
            twitter.update("Nuevo Evento: #{event['title']} #{event['date'].strftime "%d/%m/%Y"} http://vlctechhub.org")
            present event, with: Event
        end
      end
    end
  end
end
