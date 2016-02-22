require 'grape'
require 'grape-entity'
require 'json/ext'
require 'mongo'

require_relative 'config/environment'

require_relative 'api/v1/event_routes'
require_relative 'api/v1/job_routes'
require_relative 'services/event/repository'
require_relative 'services/event/twitter'
require_relative 'services/event/mailer'
require_relative 'services/job/repository'

module VLCTechHub
  module API
    class Boot < Grape::API
      format :json

      get do
        [{ version: "v1" }]
      end

      mount VLCTechHub::API::V1::Routes

      route :any, '*path' do
        error!('404 Not found', 404)
      end
    end
  end
end
