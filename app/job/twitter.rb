module VLCTechHub
  module Job
    class Twitter
      include VLCTechHub::TwitterClient

      def self.new_job(attrs)
        new.tweet(attrs)
      end

      def tweet(attrs)
        super("Nueva #ofertaDeEmpleo: #{attrs['title']} por #{attrs['company']}  http://vlctechhub.org/job/board/#{attrs['publish_id']}")
      end
    end
  end
end
