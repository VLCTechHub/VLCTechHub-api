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

        resource 'jobs' do
          get do
            result = jobs.find_latest_jobs
            present :jobs, result.to_a, with: JobOffer
          end

          params do
            requires :job, type: Hash do
              requires :title, type: String
              requires :description, type: String
              requires :link, type: String
              requires :company, type: Hash do
                requires :name, type: String
                requires :link, type: String
              end
              requires :tags, type: Array
              requires :how_to_apply, type: String
              requires :salary, type: String
            end
          end
          post do
            job = jobs.insert(declared(params)[:job])
            VLCTechHub::Job::Mailer.publish(job)

            present :job, job, with: JobOffer
          end
        end
      end
    end
  end
end
