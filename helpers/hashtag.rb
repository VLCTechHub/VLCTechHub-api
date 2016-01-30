module VLCTechHub
  module Helper
    module Hashtag
      def self.clean(word)
        hashtag = word || ''
        hashtag = hashtag.strip.split[0] || ''
        return hashtag if hashtag.empty?
        if !hashtag.start_with?('#') && !hashtag.start_with?('@')
          hashtag = '#' << hashtag
        end
        hashtag
      end
    end
  end
end
