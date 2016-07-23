module VLCTechHub
  module API
    module V1
      class JobOffer < Grape::Entity
        expose  :id, :title, :description,
                :tags, :company, :link,
                :how_to_apply, :published_at, :salary

        private

        def id
          @object['publish_id'].to_s
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
          return {} unless @object['company']

          {
            name: @object['company']['name'],
            link: @object['company']['link']
          }
        end

        def link
          @object['link']
        end

        def how_to_apply
          @object['how_to_apply']
        end

        def published_at
          @object['published_at']
        end

        def salary
          @object['salary']
        end
      end
    end
  end
end
