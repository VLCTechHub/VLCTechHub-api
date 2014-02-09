module VLCTechHub
  class API < Grape::API
    class V0 < Grape::API
      version 'v0', using: :path

      ## Events
      resource 'events' do
        desc 'Retrieve future scheduled events'
        get do
          events = db['events'].find( { sentMail: true, date: { :$gt => Time.now.utc } } )
          events.to_a
        end

        desc 'Retrieve a specific event'
        get ':id' do
          event = db['events'].find_one( {_id: BSON::ObjectId(params[:id])} )
          event
        end
      end
    end
  end
end
