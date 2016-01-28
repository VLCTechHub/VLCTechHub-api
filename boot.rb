require 'grape'
require 'grape-entity'
require 'json/ext'
require 'mongo'

require_relative 'config/environment'

require_relative 'api/v0/routes'
require_relative 'api/v1/routes'
require_relative 'services/repository'
require_relative 'services/twitter'
require_relative 'services/mailer'

module VLCTechHub
  module API 
    class Boot < Grape::API
      format :json

      helpers do
        def repo
          @repo ||= VLCTechHub::Repository.new
        end
        def mailer
          VLCTechHub::Mailer
        end
        def twitter
          @twitter ||= VLCTechHub::Twitter.new
        end
      end

      get do
        [{ version: "v0" }, { version: "v1" }]
      end

      mount VLCTechHub::API::V0::Routes
      mount VLCTechHub::API::V1::Routes

      route :any, '*path' do
        error!('404 Not found', 404)
      end
    end
  end
end
