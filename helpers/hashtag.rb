# frozen_string_literal: true

module VLCTechHub
  module Helper
    module Hashtag
      def self.clean(word)
        hashtag = word || ''
        hashtag = hashtag.strip.split[0] || ''
        return hashtag if hashtag.empty?

        hashtag = '#' + hashtag if !hashtag.start_with?('#') && !hashtag.start_with?('@')
        hashtag
      end
    end
  end
end
