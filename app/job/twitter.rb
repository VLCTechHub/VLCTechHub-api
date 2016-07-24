module VLCTechHub
  module Job
    class Twitter
      include VLCTechHub::TwitterClient

      def self.tweet(attrs)
        new.tweet(attrs)
      end

      def update(attrs)
        tweet("Nueva #ofertaDeEmpleo: #{attrs['title']} #{attrs['company']}  http://vlctechhub.org/job/board/#{attrs['publish_id']}")
      end
    end
  end
end
