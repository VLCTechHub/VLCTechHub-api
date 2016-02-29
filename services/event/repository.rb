module VLCTechHub
  module Event
    class Repository

      def initialize
        @uri =  VLCTechHub.test? ? ENV['TEST_MONGODB_URI'] : ENV['MONGODB_URI']
        Mongo::Logger.logger.level = ::Logger::FATAL unless ::VLCTechHub.development?

      end
      def db
        @db ||= Mongo::Client.new(@uri)
      end

      def find_by_id(id)
        db['events'].find( {_id: BSON::ObjectId(id)} ).first
      end

      def find_by_uuid(uuid)
        db['events'].find( {publish_id: uuid} ).first
      end

      def find_future_events
        db['events'].find( { published: true, date: { :$gte => Time.now.utc } } ).sort( { date: 1 } )
      end

      def find_latest_events
         events = db['events'].find( { published: true, date: { :$lt => Time.now.utc } }).sort( {date: -1} ).limit(10)
      end

      def find_today_events
        db['events'].find( { published: true, date: { :$gte => Time.now.utc, :$lte => 1.day.from_now.utc.midnight } } )
      end

      def find_by_month(year, month)
        month = DateTime.new(year, month, 1)
        next_month = (month >> 1)
        events = db['events'].find( { published: true, date: { :$gte => month.to_time.utc , :$lt => next_month.to_time.utc } }).sort( {date: 1} )
      end

      def insert(new_event)
        id = BSON::ObjectId.new
        created_at = id.generation_time
        new_event[:_id] = id
        new_event[:published] = false
        new_event[:publish_id] = SecureRandom.uuid
        new_event[:created_at] = created_at
        new_event[:slug] = "#{new_event[:title].downcase.strip.gsub(/[^\w-]/, '-')}-#{created_at.to_i.to_s(16)}".squeeze('-')
        db['events'].insert_one(new_event)
        new_event
      end

      def publish(uuid)
        result = db['events'].update_one({ published: false, publish_id: uuid },
                            { "$set" => { published: true } } )
        was_updated = (result.n == 1)
      end

      def publishAll
        db['events'].update_many({ published: false }, { "$set" => { published: true } } )
        true
      end

      def removeAll
        db['events'].drop
        true
      end
    end
  end
end
