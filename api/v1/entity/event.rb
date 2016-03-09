module VLCTechHub
  module API
    module V1
      class Event < Grape::Entity
        expose :id, :title, :description, :date, :link, :hashtag

        private

        def id
          return @object['_id'].to_s unless  @object['publish_id']
          @object['publish_id'].to_s
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

        def slug
          @object['slug']
        end
      end
    end
  end
end
