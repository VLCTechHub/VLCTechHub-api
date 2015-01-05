require 'mongo'
require 'twitter'
require 'active_support'
require 'active_support/core_ext'

module VLCTechHub
  class Twitter

    def initialize
      @client = ::Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
        config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
        config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
        config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
      end
    end

    def tweet(event)
      tweet = "Nuevo Evento: #{self.hashtag event} #{event['title']} #{self.datetime event} http://vlctechhub.io"
      @client.update(tweet)
    end

    def tweet_today_events(today_events)
      today_events.each do |event|
        tweet = "Hoy #{self.hashtag event}a las #{self.time event}: #{event['title']} http://vlctechhub.io"
        @client.update(tweet)
      end
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
