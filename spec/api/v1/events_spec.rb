# frozen_string_literal: true

require 'spec_helper'

describe VLCTechHub::API::V1::Routes do
  def app
    VLCTechHub::API::Boot
  end

  let(:request_time) { Time.now.utc }

  describe 'GET /v1/events' do
    subject(:events) { JSON.parse(last_response.body)['events'] }

    it 'returns a list of all next events' do
      get '/v1/events?category=next'

      expect(last_response).to be_ok

      expect(past_events).to be_empty
    end

    it 'returns a list of past events' do
      get '/v1/events?category=recent'

      expect(last_response).to be_ok

      expect(future_events).to be_empty
    end

    it 'returns a list of events for that year and month' do
      get '/v1/events?year=2016&month=02'

      expect(last_response).to be_ok

      expect(events_for_year_month(2_016, 2)).not_to be_empty
    end

    it 'returns not found if year or month are bad formatted' do
      get '/v1/events?year=20140&month=01'

      expect(last_response).to be_bad_request

      get '/v1/events?year=2014&month=001'

      expect(last_response).to be_bad_request
    end
  end

  describe 'GET /v1/events/:slug' do
    subject(:event) { JSON.parse(last_response.body)['event'] }

    let(:some_existing_event_slug) { VLCTechHub::Event::Repository.new.all.first['slug'] }

    it 'returns the event for the given slug' do
      get "/v1/events/#{some_existing_event_slug}"

      expect(last_response).to be_ok

      expect(event['slug']).to eq(some_existing_event_slug)
    end
  end

  describe 'POST /v1/events' do
    subject(:event) { JSON.parse(last_response.body)['event'] }

    let(:some_event_data) do
      { title: 'Title', description: 'Description', link: 'Link', hashtag: 'hashtag', date: '20010101T12:00:00Z' }
    end

    before do
      Mail::TestMailer.deliveries.clear
      stub_const(
        'ENV',
        ENV.to_hash.merge('EMAIL_FOR_PUBLICATION' => 'some@email.com', 'EMAIL_FOR_BROADCAST' => 'some@email.com')
      )
    end

    it 'creates an event' do
      post '/v1/events', event: some_event_data

      expect(last_response).to be_created

      expect(event['id']).not_to be_nil
    end

    it 'sends the publish email' do
      expect { post '/v1/events', event: some_event_data }.to change { number_of_mail_deliveries }.by(1)
    end

    it 'returns an error if event data is invalid' do
      post '/v1/events', event: {}

      expect(last_response).to be_bad_request
    end
  end

  describe 'GET /v1/events/publish/:uuid' do
    subject(:event) { JSON.parse(last_response.body)['event'] }

    let(:some_unpublished_event) do
      VLCTechHub::Event::Repository.new.insert(
        title: 'Title', description: 'Description', link: 'Link', hashtag: 'hashtag', date: DateTime.now
      )
    end

    before do
      Mail::TestMailer.deliveries.clear
      allow(VLCTechHub::Event::Twitter).to receive(:new_event)
      stub_const(
        'ENV',
        ENV.to_hash.merge('EMAIL_FOR_PUBLICATION' => 'some@email.com', 'EMAIL_FOR_BROADCAST' => 'some@email.com')
      )
    end

    it 'publishes the event' do
      get "/v1/events/publish/#{some_unpublished_event['publish_id']}"

      expect(event['id']).to eq(some_unpublished_event['publish_id'])
    end

    it 'tweets and emails the publication' do
      expect { get "/v1/events/publish/#{some_unpublished_event['publish_id']}" }.to change {
        number_of_mail_deliveries
      }.by(1)

      expect(VLCTechHub::Event::Twitter).to have_received(:new_event).with(
        hash_including(publish_id: some_unpublished_event['publish_id'])
      )
    end

    it 'returns a not found error if publish id does not exist' do
      get '/v1/events/publish/invalid_publish_id'

      expect(last_response).to be_not_found
    end
  end

  def past_events
    events.select { |e| past_event? e }
  end

  def future_events
    events.select { |e| future_event? e }
  end

  def events_for_year_month(year, month)
    current_month = DateTime.new(year, month)
    events.select { |e| current_month? e, current_month }
  end

  def past_event?(event)
    event['date'] < request_time
  end

  def future_event?(event)
    event['date'] >= request_time
  end

  def current_month?(event, current_month)
    (event['date'] >= current_month) || (event['date'] < current_month.next_month)
  end

  def number_of_mail_deliveries
    Mail::TestMailer.deliveries.length
  end
end
