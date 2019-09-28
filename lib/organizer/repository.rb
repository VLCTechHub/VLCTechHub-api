# frozen_string_literal: true

module VLCTechHub
  module Organizer
    class Repository < VLCTechHub::Base::Repository
      def collection
        db['organizers']
      end

      def find_with_handle
        collection.find(hashtag: { '$regex' => /^@/i })
      end

      def find_with_hashtag
        collection.find(hashtag: { '$regex' => /^#/i })
      end

      def insert(organizer)
        id = collection.insert_one(with_defaults(organizer)).inserted_id
        collection.find(_id: id).first
      end

      def all
        collection.find(published: true).sort(created_at: 1)
      end

      private

      def with_defaults(organizer)
        organizer.dup.tap do |o|
          o['published'] = true
          o['publish_id'] = SecureRandom.uuid
          o['created_at'] = DateTime.now
        end
      end
    end
  end
end
