require 'grape'
require 'grape-entity'
require 'json'
require 'mongo'

require_relative 'api/v0'
require_relative 'api/repository'
require_relative 'api/twitter'
require_relative 'api/mail'

module VLCTechHub
  class API < Grape::API
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
      { version: "v0" }
    end

    mount VLCTechHub::API::V0

    route :any, '*path' do
      error!('404 Not found', 404)
    end
  end
end
