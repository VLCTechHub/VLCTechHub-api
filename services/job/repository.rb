module VLCTechHub
  module Job
    class Repository

      def initialize
        @uri =  VLCTechHub.test? ? ENV['TEST_MONGODB_URI'] : ENV['MONGODB_URI']
        Mongo::Logger.logger.level = ::Logger::FATAL unless ::VLCTechHub.development?
      end

      def db
        @db ||= Mongo::Client.new(@uri)
      end

      def collection
        db['jobs']
      end

      def find_latest_jobs
        month = DateTime.now
        previous_month = (month << 1)
        collection.find( { published: true,
                           date: { :$gte => previous_month.to_time.utc}}).sort( {date: 1} )
      end

      def insert(job_offer)
        job_offer['published'] = false
        job_offer['publish_id'] = SecureRandom.uuid
        job_offer['created_at'] = DateTime.now
        id = collection.insert_one(job_offer).inserted_id
        collection.find( {_id: id} ).first
      end

      def publish(uuid)
        result = collection.update_one({ published: false, publish_id: uuid },
                                       { "$set" => { published: true, published_at: DateTime.now } } )
        was_updated = (result.n == 1)
      end

      def publishAll
        collection.update_many({ published: false },
                               { "$set" => { published: true, published_at: DateTime.now } } )
        true
      end

      def removeAll
        collection.drop
        true
      end
    end
  end
end
