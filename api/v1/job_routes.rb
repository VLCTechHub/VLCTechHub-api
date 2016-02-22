#$:.unshift File.dirname(__FILE__)
require 'time'
require 'date'
require 'securerandom'

require_relative 'entity/joboffer'

module VLCTechHub
  module API
    module V1
      class Routes < Grape::API
        version 'v1', using: :path

        helpers do
          def jobs
            @jobs ||= VLCTechHub::Job::Repository.new
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
