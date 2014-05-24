require 'grape'
require 'grape-entity'
require 'json'
require 'mongo'
require 'twitter'

require_relative 'api/v0'

module VLCTechHub
  class API < Grape::API
    format :json

    helpers do
      def db
        @db ||= Mongo::MongoClient.from_uri(ENV['MONGODB_URI']).db
        @db
      end

      def twitter
        @twitter ||= Twitter::REST::Client.new do |config|
          config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
          config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
          config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
          config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
        end
        @twitter
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
