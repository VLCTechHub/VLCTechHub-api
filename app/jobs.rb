module VLCTechHub
  class Jobs < VLCTechHub::Base::Repository
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
  end
end
