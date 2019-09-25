# frozen_string_literal: true

module VLCTechHub
  module API
    module V2
      class Event < Grape::Entity
        expose :id, :title, :description, :date, :link, :hashtag, :slug

        private

        def id
          return @object['publish_id'].to_s if @object['publish_id']

          @object['_id'].to_s
        end

        def title
          @object['title']
        end

        def description
          @object['description']
        end

        def date
          @object['date'].iso8601
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
