# frozen_string_literal: true

module VLCTechHub
  module Job
    class Repository < VLCTechHub::Base::Repository
      def find_latest_jobs
        month = DateTime.now
        previous_month = month.prev_month
        collection.find(published: true, published_at: { '$gte' => previous_month.to_time.utc }).sort(date: 1)
      end

      def find_twitter_pending_jobs
        month = DateTime.now
        previous_month = month.prev_month
        collection.find(
          published: true,
          posted: true,
          tweeted: false,
          published_at: {
            '$gte' => previous_month.to_time.utc
          }
        ).sort(date: 1)
      end

      def insert(job)
        job = correct(job)
        id = collection.insert_one(with_defaults(job)).inserted_id
        collection.find(_id: id).first
      end

      def all
        collection.find(published: true).sort(published_at: 1)
      end

      private

      def collection
        db['jobs']
      end

      def correct(job)
        return job if job[:link].nil? || job[:link].empty?

        link_misses_protocol = !job[:link].match(%r{^https?://})
        job[:link] = "http://#{job[:link]}" if link_misses_protocol

        job
      end

      def with_defaults(job)
        job.dup.tap do |j|
          j['published'] = false
          j['publish_id'] = SecureRandom.uuid
          j['created_at'] = DateTime.now
          j['secret'] = SecureRandom.uuid
          j['posted'] = false
          j['tweeted'] = false
        end
      end
    end
  end
end
