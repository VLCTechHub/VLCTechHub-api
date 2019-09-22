# frozen_string_literal: true

module VLCTechHub
  module Job
    class Twitter
      include VLCTechHub::TwitterClient

      def self.new_job(attrs)
        new.tweet(attrs)
      end

      def tweet(attrs)
        company = attrs['company']['twitter'] || attrs['company']['name']
        super(
          "Nueva #ofertaDeEmpleo: #{attrs['title']} por #{company} " \
            "#{jobs_endpoint}/#{attrs['publish_id']}"
        )
      end

      private

      def jobs_endpoint
        'https://vlctechhub.org/job/board'
      end
    end
  end
end
