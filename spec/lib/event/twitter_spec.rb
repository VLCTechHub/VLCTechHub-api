# frozen_string_literal: true

require 'spec_helper'

describe VLCTechHub::Event::Twitter do
  subject(:twitter) { described_class.new(twitter_api) }

  let(:event) { create(:event) }

  let(:twitter_api) { instance_spy(::Twitter::REST::Client, credentials: { some: 'credentials' }) }

  describe '#new_event' do
    it 'sends a tweet with date, hashtag and title' do
      twitter.new_event(event)

      expect(twitter_api).to have_received(:update).with(
        string_that_includes([event['title'], event['hashtag'], event['date'].strftime('%d/%m/%Y')])
      )
    end

    it 'sends a link back to vlctechhub' do
      twitter.new_event(event)

      expect(twitter_api).to have_received(:update).with(
        string_that_includes(["https://vlctechhub.org/events/#{event['slug']}"])
      )
    end
  end

  describe '#today' do
    it 'sends tweets with time and title' do
      twitter.today([event])

      expect(twitter_api).to have_received(:update).with(
        string_that_includes(
          [
            'Hoy',
            event['title'],
            event['hashtag'],
            event['date'].in_time_zone('Madrid').strftime('%H:%M'),
            "https://vlctechhub.org/events/#{event['slug']}"
          ]
        )
      )
    end
  end
end
