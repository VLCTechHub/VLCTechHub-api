require 'securerandom'

require_relative 'entity/job_offer'

module VLCTechHub
  module API
    module V1
      class Routes < Grape::API
        version 'v1', using: :path

        helpers do
          def jobs
            @jobs ||= VLCTechHub::Jobs.new
          end
        end

        ## Jobs
        resource 'jobs' do
          get do
            result = jobs.find_latest_jobs
            present :jobs, result.to_a, with: JobOffer
          end
        end
      end
    end
  end
end
