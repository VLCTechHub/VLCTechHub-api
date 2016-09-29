require 'twitter'

module VLCTechHub
  module TwitterClient
    def initialize(client = nil)
      @client = client || ::Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
        config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
        config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
        config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
      end
    end

    def tweet(text)
      return unless credentials?

      @client.update(text)
    end

    private

    def credentials?
      @client.credentials.values.none?{ |v| blank?(v) }
    end

    def blank?(s)
      s.respond_to?(:empty?) ? s.empty? : !s
    end
  end
end
