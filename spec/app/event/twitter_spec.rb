# frozen_string_literal: true

require 'spec_helper'

describe VLCTechHub::Event::Twitter do
  subject(:twitter) { described_class.new(twitter_api) }

  let(:event) do
    { 'title' => 'a title', 'date' => DateTime.new(2_001, 12, 1), 'hashtag' => '#awesome', 'slug' => 'a-title' }
  end

  let(:twitter_api) { instance_spy(::Twitter::REST::Client, credentials: { a: 'b' }) }

  describe '#tweet' do
    it 'sends a tweet with date, hashtag and title' do
      twitter.new_event(event)

      expect(twitter_api).to have_received(:update).with(string_that_includes(['a title', '#awesome', '01/12/2001']))
    end

    it 'sends a link back to vlctechhub' do
      twitter.new_event(event)

      expect(twitter_api).to have_received(:update).with(
        string_that_includes(%w[https://vlctechhub.org/events/a-title])
      )
    end
  end

  describe '#tweet_today_events' do
    it 'sends tweets with time and title' do
      twitter.today([event])

      expect(twitter_api).to have_received(:update).with(
        string_that_includes(['Hoy', 'a title', '#awesome', '01:00', 'https://vlctechhub.org/events/a-title'])
      )
    end
  end
end
