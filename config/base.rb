# frozen_string_literal: true

require 'dotenv/load'
require 'mongo'

module VLCTechHub
  class << self
    def environment
      (ENV['RACK_ENV'] || :development).to_sym
    end

    def environment=(env)
      ENV['RACK_ENV'] = env.to_s
    end

    def development?
      environment == :development
    end

    def production?
      environment == :production
    end

    def test?
      environment == :test
    end

    def db_client
      @db_client ||= Mongo::Client.new(VLCTechHub.test? ? ENV['TEST_MONGODB_URI'] : ENV['MONGODB_URI'])
    end
  end
end

Mongo::Logger.logger.level = ::Logger::FATAL unless VLCTechHub.development?
