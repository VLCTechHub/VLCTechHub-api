module VLCTechHub
  class Repository
    def db
      Mongo::Logger.logger.level = ::Logger::FATAL unless ::VLCTechHub.development?
      @db ||= Mongo::Client.new(ENV['MONGODB_URI'])
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

    def insert(newEvent)
      id = db['events'].insert_one(newEvent).inserted_id
      db['events'].find( {_id: id} ).first
    end

    def publish(uuid)
      result = db['events'].update({ published: false, publish_id: uuid },
                          { "$set" => { published: true } } )
      was_updated = (result['n'] == 1)
    end
  end
end
