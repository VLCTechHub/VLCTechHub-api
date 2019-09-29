# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'

module VLCTechHub
  module Event
    class Repository < VLCTechHub::Base::Repository
      def collection
        db['events']
      end

      def find_by_slug(slug)
        collection.find(published: true, slug: slug).first
      end

      def find_past_events
        collection.find(published: true, date: { '$lt' => Time.now.utc }).sort(date: -1)
      end

      def find_future_events
        collection.find(published: true, date: { '$gte' => Time.now.utc }).sort(date: 1)
      end

      def find_latest_events
        collection.find(published: true, date: { '$lt' => Time.now.utc }).sort(date: -1).limit(10)
      end

      def find_today_events
        collection.find(published: true, date: { '$gte' => Time.now.utc, '$lte' => 1.day.from_now.utc.midnight })
      end

      def find_by_year(year)
        year = DateTime.new(year, 1, 1)
        next_year = year.next_year
        collection.find(published: true, date: { '$gte' => year.to_time.utc, '$lt' => next_year.to_time.utc }).sort(
          date: 1
        )
      end

      def find_by_month(year, month)
        month = DateTime.new(year, month, 1)
        next_month = month.next_month
        collection.find(published: true, date: { '$gte' => month.to_time.utc, '$lt' => next_month.to_time.utc }).sort(
          date: 1
        )
      end

      def insert(event)
        id = collection.insert_one(with_defaults(event)).inserted_id
        collection.find(_id: id).first
      end

      def all
        collection.find(published: true).sort(date: 1)
      end

      private

      def slug_for(title, id)
        id = id.to_s.chars
        suffix = id.first(8).join + id.last(4).join
        slug = ActiveSupport::Inflector.transliterate(title)
        slug = "#{slug.downcase.strip.gsub(/[^\w-]/, '-')}-#{suffix}".squeeze('-')
        slug.sub(/^-/, '')
      end

      def with_defaults(event)
        id = BSON::ObjectId.new
        event.stringify_keys!
        event.dup.tap do |e|
          e['_id'] = id
          e['published'] = false
          e['publish_id'] = SecureRandom.uuid
          e['created_at'] = id.generation_time
          e['slug'] = slug_for(e['title'], id)
          e['posted'] = false
        end
      end
    end
  end
end
