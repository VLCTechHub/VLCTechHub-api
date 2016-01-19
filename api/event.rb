module VLCTechHub
  class API < Grape::API
    class V0 < Grape::API

      class Event < Grape::Entity
        expose :id, :title, :description, :date, :link, :hashtag

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

        def hashtag
          @object['hashtag']
        end
      end
    end
  end
end
