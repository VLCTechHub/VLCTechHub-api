# frozen_string_literal: true

require 'grape'
require 'grape-entity'
require 'json/ext'

require_relative 'config/environment'

require_relative 'api/v1/routes'
require_relative 'api/v2/routes'

require_relative 'lib/base/repository'
require_relative 'lib/twitter_client'
require_relative 'lib/event/repository'
require_relative 'lib/event/twitter'
require_relative 'lib/event/mailer'
require_relative 'lib/job/mailer'
require_relative 'lib/job/twitter'
require_relative 'lib/jobs'
require_relative 'lib/organizers'
require_relative 'lib/organizer_creator'

module VLCTechHub
  module API
    class Boot < Grape::API
      format :json

      get { [{ version: 'v1' }] }

      mount VLCTechHub::API::V1::Routes
      mount VLCTechHub::API::V2::Routes

      route :any, '*path' do
        error!('404 Not found', 404)
      end
    end
  end
end
