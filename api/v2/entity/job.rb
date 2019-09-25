# frozen_string_literal: true

module VLCTechHub
  module API
    module V2
      class Job < Grape::Entity
        expose :id, :title, :description, :tags, :company, :link, :how_to_apply, :salary, :published_at

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

        def tags
          @object['tags'].to_a
        end

        def company
          company = @object['company'] || {}
          { name: company['name'], link: company['link'] }
        end

        def link
          @object['link']
        end

        def how_to_apply
          @object['how_to_apply']
        end

        def salary
          @object['salary']
        end

        def published_at
          @object['published_at']
        end
      end
    end
  end
end
