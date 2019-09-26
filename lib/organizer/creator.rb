# frozen_string_literal: true

require 'twitter'

module VLCTechHub
  module Organizer
    class Creator
      def initialize(client = nil)
        @client =
          client ||
            ::Twitter::REST::Client.new do |config|
              config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
              config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
              config.access_token = ENV['TWITTER_ACCESS_TOKEN']
              config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
            end
      end

      def create(handle)
        organizer = { hashtag: handle }
        organizer.merge!(fetch_social_profile(handle))
        organizer.merge!(fetch_stats(handle))
        organizer
      end

      private

      def fetch_social_profile(handle)
        user = @client.user(handle)
        profile = {
          name: user.name,
          description: user.description.nil? ? '' : user.description,
          profile_image_small_url: user.profile_image_url.to_s,
          profile_image_big_url: user.profile_image_url('400x400').to_s,
          website: user.website? ? user.website.to_s : ''
        }
        profile
      rescue ::Twitter::Error::NotFound
        {}
      end

      def fetch_stats(_handle)
        { stats: { events: [] } }
      end
    end
  end
end
