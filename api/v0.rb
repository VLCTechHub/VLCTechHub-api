require 'time'

module VLCTechHub
  class API < Grape::API
    class V0 < Grape::API
      version 'v0', using: :path

      ## Events
      resource 'events' do
        desc 'Retrieve future scheduled events'
        get do
          events = db['events'].find( { sentMail: true, date: { :$gt => Time.now.utc } } )
          events.to_a.map do |event|
            event["id"] = event["_id"].to_s
            event["date"] = event["date"].iso8601
            event.slice("id", "title", "description", "date", "link")
          end
        end

        desc 'Retrieve a specific event'
        get ':id' do
          event = db['events'].find_one( {_id: BSON::ObjectId(params[:id])} )
          event["id"] = event["_id"].to_s
          event["date"] = event["date"].iso8601
          event.slice("id", "title", "description", "date", "link")
        end
      end
    end
  end
end
