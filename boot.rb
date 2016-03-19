require 'grape'
require 'grape-entity'
require 'json/ext'


require_relative 'config/environment'

require_relative 'api/v1/routes'
require_relative 'app/base/repository'
require_relative 'app/event/repository'
require_relative 'app/event/twitter'
require_relative 'app/event/mailer'
require_relative 'app/jobs'
require_relative 'app/organizers'
require_relative 'app/organizer_creator'

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
