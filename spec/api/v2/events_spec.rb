# frozen_string_literal: true

require 'spec_helper'

describe VLCTechHub::API::V2::Routes do
  def app
    VLCTechHub::API::Boot
  end

  let(:request_time) { Time.now.utc }

  describe 'GET /v2/events' do
    subject(:events) { JSON.parse(last_response.body) }

    it 'returns the list of all events' do
      get '/v2/events'

      expect(last_response).to be_ok

      expect(past_events).not_to be_empty
      expect(future_events).not_to be_empty
    end
  end

  describe 'GET /v2/events/past' do
    subject(:events) { JSON.parse(last_response.body) }

    it 'returns the list of past events' do
      get '/v2/events/past'

      expect(last_response).to be_ok

      expect(past_events).not_to be_empty
      expect(future_events).to be_empty
    end
  end

  describe 'GET /v2/events/upcoming' do
    subject(:events) { JSON.parse(last_response.body) }

    it 'returns the list of upcoming events' do
      get '/v2/events/upcoming'

      expect(last_response).to be_ok

      expect(past_events).to be_empty
      expect(future_events).not_to be_empty
    end
  end

  describe 'GET /v2/events/:year' do
    subject(:events) { JSON.parse(last_response.body) }

    it 'returns the list of all events for the given year' do
      get '/v2/events/2016'

      expect(last_response).to be_ok

      expect(events_for_year(2_016)).not_to be_empty
    end
  end

  describe 'GET /v2/events/:year/:month' do
    subject(:events) { JSON.parse(last_response.body) }

    it 'returns the list of all events for the given year and month' do
      get '/v2/events/2016/2'

      expect(last_response).to be_ok

      expect(events_for_year_month(2_016, 2)).not_to be_empty
    end

    it 'returns an error if month has an invalid value' do
      get '/v2/events/2016/13'

      expect(last_response).to be_bad_request
    end

    it 'returns an error if month is bad formatted' do
      get '/v2/events/2016/not_a_month'

      expect(last_response).to be_bad_request
    end
  end

  describe 'GET /v2/events/:slug' do
    subject(:event) { JSON.parse(last_response.body) }

    let(:some_existing_event_slug) { VLCTechHub::Event::Repository.new.all.first['slug'] }

    it 'returns the event with the given slug' do
      get "/v2/events/#{some_existing_event_slug}"

      expect(last_response).to be_ok

      expect(event['slug']).to eq(some_existing_event_slug)
    end

    it 'returns an error if the slug is invalid' do
      get '/v2/events/not_a_slug'

      expect(last_response).to be_bad_request
    end
  end

  describe 'POST /v2/events' do
    subject(:event) { JSON.parse(last_response.body) }

    let(:some_event_data) do
      { title: 'Title', description: 'Description', link: 'Link', hashtag: 'hashtag', date: '20010101T12:00:00Z' }
    end

    before do
      stub_const(
        'ENV',
        ENV.to_hash.merge('EMAIL_FOR_PUBLICATION' => 'some@email.com', 'EMAIL_FOR_BROADCAST' => 'some@email.com')
      )
      Mail::TestMailer.deliveries.clear
    end

    it 'creates an event' do
      post '/v2/events', some_event_data

      expect(last_response).to be_created

      expect(event['id']).not_to be_nil
    end

    it 'sends the approval request email' do
      expect { post '/v2/events', some_event_data }.to change { number_of_mail_deliveries }.by(1)
    end

    it 'returns an error if event data is invalid' do
      post '/v2/events', {}

      expect(last_response).to be_bad_request
    end
  end

  describe 'GET /v2/events/approve/:uuid' do
    subject(:event) { JSON.parse(last_response.body) }

    let(:some_event_pending_approval) { VLCTechHub::Event::Repository.new.insert(title: 'Title', date: DateTime.now) }

    it 'approves the event' do
      get "/v2/events/approve/#{some_event_pending_approval['publish_id']}"

      expect(last_response).to be_ok

      expect(event['id']).to eq(some_event_pending_approval['publish_id'])
    end

    it 'returns an error if publish id is invalid' do
      get '/v2/events/approve/invalid_publish_id'

      expect(last_response).to be_bad_request
    end

    it 'returns a not found error if publish id has an unmatched value' do
      some_unmatched_publish_id = '00000000-0000-4000-a000-000000000000'

      get "/v2/events/approve/#{some_unmatched_publish_id}"

      expect(last_response).to be_not_found
    end
  end

  def past_events
    events.select { |event| past_event?(event) }
  end

  def future_events
    events.select { |event| future_event?(event) }
  end

  def events_for_year(year)
    current_year = DateTime.new(year)
    events.select { |event| current_year?(event, current_year) }
  end

  def events_for_year_month(year, month)
    current_month = DateTime.new(year, month)
    events.select { |event| current_month?(event, current_month) }
  end

  def past_event?(event)
    event['date'] < request_time
  end

  def future_event?(event)
    event['date'] >= request_time
  end

  def current_year?(event, current_year)
    (event['date'] >= current_year) || (event['date'] < current_year.next_year)
  end

  def current_month?(event, current_month)
    (event['date'] >= current_month) || (event['date'] < current_month.next_month)
  end

  def number_of_mail_deliveries
    Mail::TestMailer.deliveries.length
  end
end