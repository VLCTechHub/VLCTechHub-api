module VLCTechHub
  class Organizers < VLCTechHub::Base::Repository
    def collection
      db['organizers']
    end

    def find_with_handle
      collection.find({ hashtag:  {  :$regex => /^@/i } })
    end

    def find_with_hashtag
      collection.find({ hashtag:  {  :$regex => /^#/i } })
    end

    def insert(organizer)
      organizer.stringify_keys!
      organizer['published'] = true
      organizer['publish_id'] = SecureRandom.uuid
      organizer['created_at'] = DateTime.now
      collection.insert_one(organizer)
    end
  end
end
