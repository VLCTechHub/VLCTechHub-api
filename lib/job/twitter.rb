# frozen_string_literal: true

module VLCTechHub
  module Job
    class Twitter
      include VLCTechHub::Twitter::RestClient

      def self.new_job(job)
        new.new_job(job)
      end

      def new_job(job)
        company = job['company']['twitter'] || job['company']['name']
        tweet(
          "Nueva #ofertaDeEmpleo: #{job['title']} por #{company} " \
            "#{jobs_endpoint}/#{job['publish_id']}"
        )
      end

      private

      def jobs_endpoint
        'https://vlctechhub.org/job/board'
      end
    end
  end
end
