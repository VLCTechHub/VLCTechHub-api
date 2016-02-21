require 'spec_helper'
require 'time'

describe VLCTechHub::Event::Twitter do
  let(:event) do
    {
      'title' => 'a title',
      'date' => DateTime.new(2001,12,01),
      'hashtag' => '#awesome'
    }
  end

  describe '#tweet' do
    it 'sends a tweet with date, hashtag and title' do
      api = double(:twitter_api)
      expect(api).to receive(:update)
        .with(string_that_includes(['a title', '#awesome', '01/12/2001']))
      twitter = described_class.new(api)

      twitter.tweet(event)
    end

    it 'sends a link back to vlctechhub' do
      api = double(:twitter_api)
      expect(api).to receive(:update)
        .with(string_that_includes(['http://vlctechhub.org']))
      twitter = described_class.new(api)

      twitter.tweet(event)
        end

    xit 'supports long title' do
    end
  end
end