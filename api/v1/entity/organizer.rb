module VLCTechHub
  module API
    module V1
      class Organizer < Grape::Entity
        expose :id, :hashtag, :is_handle,
               :name, :description,
               :profile_image_small_url, :profile_image_big_url

        private

        def id
          return @object['_id'].to_s unless  @object['publish_id']
          @object['publish_id'].to_s
        end

        def hashtag
          @object['hashtag']
        end

        def name
          @object['name']
        end

        def description
          @object['description']
        end

        def profile_image_big_url
          @object['profile_image_big_url']
        end

        def profile_image_small_url
          @object['profile_image_small_url']
        end

        def is_handle
          return true if @object['hashtag'][0] == '@'
          false
        end
      end
    end
  end
end
