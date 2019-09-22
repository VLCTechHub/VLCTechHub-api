# frozen_string_literal: true

require 'mongo'

module VLCTechHub
  module Base
    class Repository
      def db
        VLCTechHub.db_client
      end

      def collection
        # Implement in child classes
      end

      def publish(uuid)
        result =
          collection.update_one(
            { published: false, publish_id: uuid },
            '$set' => { published: true, published_at: DateTime.now }
          )

        was_updated = (result.n == 1)

        was_updated
      end

      def publish_all
        collection.update_many({ published: false }, '$set' => { published: true, published_at: DateTime.now })
        true
      end

      def unpublish(uuid, secret)
        result =
          collection.update_one(
            { published: true, publish_id: uuid, secret: secret },
            '$set' => { published: false, published_at: nil }
          )

        was_updated = (result.n == 1)

        was_updated
      end

      def remove_all
        collection.drop

        true
      end
    end
  end
end
