module VLCTechHub
  class Jobs < VLCTechHub::Base::Repository

    def find_latest_jobs
      month = DateTime.now
      previous_month = (month << 1)
      collection.find( { published: true,
                         published_at: { :$gte => previous_month.to_time.utc}}).sort( {date: 1} )
    end

    def insert(job)
      job = correct(job)
      id = collection.insert_one(hydrate(job)).inserted_id
      collection.find( {_id: id} ).first
    end

    def find_by_uuid(uuid)
      collection.find( {publish_id: uuid} ).first
    end

    private

    def collection
      db['jobs']
    end

    def correct(job)
      return job if job[:link].nil?

      link_misses_protocol = !job[:link].match(/^https?:\/\//)
      if link_misses_protocol
        job[:link] = "http://#{job[:link]}"
      end

      job
    end

    def hydrate(job)
     job.dup.tap { |j|
        j['published'] = false
        j['publish_id'] = SecureRandom.uuid
        j['created_at'] = DateTime.now
        j['secret'] = SecureRandom.uuid
      }
    end
  end
end
