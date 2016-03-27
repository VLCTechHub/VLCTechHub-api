module VLCTechHub
  module Event
    class Repository < VLCTechHub::Base::Repository
      def collection
        db['events']
      end

      def find_by_id(id)
        collection.find( {_id: BSON::ObjectId(id)} ).first
      end

      def find_by_uuid(uuid)
        collection.find( {publish_id: uuid} ).first
      end

      def find_by_slug(slug)
        collection.find( {slug: slug} ).first
      end

      def find_future_events
        collection.find( { published: true, date: { :$gte => Time.now.utc } } ).sort( { date: 1 } )
      end

      def find_latest_events
        collection.find( { published: true, date: { :$lt => Time.now.utc } }).sort( {date: -1} ).limit(10)
      end

      def find_today_events
        collection.find( { published: true, date: { :$gte => Time.now.utc, :$lte => 1.day.from_now.utc.midnight } } )
      end

      def find_by_month(year, month)
        month = DateTime.new(year, month, 1)
        next_month = (month >> 1)
        collection.find( { published: true, date: { :$gte => month.to_time.utc , :$lt => next_month.to_time.utc } }).sort( {date: 1} )
      end

      def insert(new_event)
        new_event.stringify_keys!
        id = BSON::ObjectId.new
        created_at = id.generation_time
        new_event['_id'] = id
        new_event['published'] = false
        new_event['publish_id'] = SecureRandom.uuid
        new_event['created_at'] = created_at
        new_event['slug'] = slug_for(new_event['title'], id)
        collection.insert_one(new_event)
        new_event
      end

      private

      def slug_for(title, id)
        id = id.to_s.chars
        suffix = id.first(8).join + id.last(4).join
        slug = ActiveSupport::Inflector.transliterate(title)
        slug = "#{slug.downcase.strip.gsub(/[^\w-]/, '-')}-#{suffix}".squeeze('-')
        slug.sub(/^-/, '')
      end
    end
  end
end
