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
          present events.to_a, with: Event
        end

        desc 'Retrieve a specific event'
        get ':id' do
          event = db['events'].find_one( {_id: BSON::ObjectId(params[:id])} )
          present event, with: Event
        end
      end

      class Event < Grape::Entity
        expose :id, :title, :description, :date, :link

        private

        def id
          @object['_id'].to_s
        end

        def title
          @object['title']
        end

        def description
          @object['description']
        end

        def date
          @object["date"].iso8601
        end

        def link
          @object['link']
        end
      end
    end
  end
end
