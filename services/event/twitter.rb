require 'mongo'
require 'twitter'
require 'active_support'
require 'active_support/core_ext'

module VLCTechHub
  module Event
    class Twitter

      def self.tweet(event)
        Twitter.new.tweet(event)
      end

      def initialize(client)
        @client = client || ::Twitter::REST::Client.new do |config|
          config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
          config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
          config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
          config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
        end
      end

      def tweet(event)
        tweet = "Nuevo Evento: #{hashtag event} #{event['title']} #{datetime event} http://vlctechhub.org"
        send(tweet)
      end

      def tweet_today_events(today_events)
        today_events.each do |event|
          tweet = "Hoy #{hashtag event}a las #{time event}: #{event['title']} http://vlctechhub.org"
          send(tweet)
        end
      end

      private

      def send(tweet)
        @client.update(tweet)
      end

      def hashtag(event)
        hashtag = event['hashtag'] || ''
        hashtag += ' ' unless hashtag.empty?
        hashtag
      end

      def datetime(event)
        event['date'].strftime "%d/%m/%Y"
      end

      def time(event)
        event['date'].in_time_zone("Madrid").strftime "%H:%M"
      end
    end
  end
end
