require 'grape'
require 'json'
require 'mongo'

require_relative 'api/v0'

module VLCTechHub
  class API < Grape::API
    format :json

    helpers do
      def db
        @db ||= Mongo::MongoClient.from_uri(ENV['MONGODB_URI']).db
        @db
      end
    end

    get do
      { version: "v0" }
    end

    mount VLCTechHub::API::V0
  end
end
