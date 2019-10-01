# frozen_string_literal: true

require 'spec_helper'

describe VLCTechHub::API::V2::Routes do
  def app
    VLCTechHub::API::Boot
  end

  let(:request_time) { Time.now.utc }
  let(:repo) { VLCTechHub::Event::Repository.new }

  before do
    repo.remove_all
    create_list(:event, 7, date: DateTime.now - 1).each { |e| repo.publish(e['publish_id']) }
    create_list(:event, 5, date: DateTime.now + 1).each { |e| repo.publish(e['publish_id']) }
  end

  describe 'PATCH /v2/events/posted' do
    let(:some_approved_events) do
      events = create_list(:event, 3)
      events.each { |e| repo.publish(e['publish_id']) }
      events
    end
    let(:some_posted_event_ids) { some_approved_events.map { |event| { id: event['publish_id'] } } }

    it 'flags the events as posted in the website' do
      patch '/v2/events/posted', events: some_posted_event_ids

      expect(last_response).to be_no_content

      some_approved_events.each do |approved_event|
        uuid = approved_event['publish_id']
        event = repo.find_by_uuid(uuid)
        expect(event['posted']).to be(true)
      end
    end
  end

  describe 'GET /v2/events' do
    subject(:events) { JSON.parse(last_response.body) }

    it 'returns the list of all published events' do
      get '/v2/events'

      expect(last_response).to be_ok

      expect(past_events.size).to eq(7)
      expect(future_events.size).to eq(5)
    end
  end

  describe 'GET /v2/events/past' do
    subject(:events) { JSON.parse(last_response.body) }

    it 'returns the list of all past published events' do
      get '/v2/events/past'

      expect(last_response).to be_ok

      expect(past_events.size).to eq(7)
      expect(future_events).to be_empty
    end
  end

  describe 'GET /v2/events/upcoming' do
    subject(:events) { JSON.parse(last_response.body) }

    it 'returns the list of all upcoming published events' do
      get '/v2/events/upcoming'

      expect(last_response).to be_ok

      expect(past_events).to be_empty
      expect(future_events.size).to eq(5)
    end
  end

  describe 'GET /v2/events/today' do
    subject(:events) { JSON.parse(last_response.body) }

    before do
      create_list(:event, 3, date: DateTime.parse('2019-10-01T17:00:00Z')).each { |e| repo.publish(e['publish_id']) }
      allow(DateTime).to receive(:now).and_return(DateTime.parse('2019-10-01T12:00:00Z'))
    end

    it 'returns the list of all published events taking place today' do
      get '/v2/events/today'

      expect(last_response).to be_ok

      expect(events.size).to eq(3)
    end
  end

  describe 'GET /v2/events/:year' do
    subject(:events) { JSON.parse(last_response.body) }

    before do
      create_list(:event, 3, date: DateTime.parse('2016-06-06T17:00:00Z')).each { |e| repo.publish(e['publish_id']) }
    end

    it 'returns the list of all published events taking place in the given year' do
      get '/v2/events/2016'

      expect(last_response).to be_ok

      expect(events.size).to eq(3)
      expect(events_for_year(2_016).size).to eq(3)
    end
  end

  describe 'GET /v2/events/:year/:month' do
    subject(:events) { JSON.parse(last_response.body) }

    before do
      repo.publish(create(:event, date: DateTime.parse('2016-06-06T17:00:00Z'))['publish_id'])
      repo.publish(create(:event, date: DateTime.parse('2016-09-09T17:00:00Z'))['publish_id'])
      repo.publish(create(:event, date: DateTime.parse('2016-12-12T17:00:00Z'))['publish_id'])
    end

    it 'returns the list of all published events taking place in the given year and month' do
      get '/v2/events/2016/12'

      expect(last_response).to be_ok

      expect(events.size).to eq(1)
      expect(events_for_year_month(2_016, 12).size).to eq(1)
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

    let(:some_unpublished_event_slug) { create(:event)['slug'] }
    let(:some_published_event_slug) do
      event = create(:event)
      repo.publish(event['publish_id'])
      event['slug']
    end

    it 'returns the published event for the given slug' do
      get "/v2/events/#{some_published_event_slug}"

      expect(last_response).to be_ok

      expect(event['slug']).to eq(some_published_event_slug)
    end

    it 'returns a not found error if the event is unpublished' do
      get "/v2/events/#{some_unpublished_event_slug}"

      expect(last_response).to be_not_found
    end

    it 'returns an error if the slug is invalid' do
      get '/v2/events/not_a_slug'

      expect(last_response).to be_bad_request
    end
  end

  describe 'POST /v2/events' do
    subject(:event) { JSON.parse(last_response.body) }

    let(:some_event_data) do
      { title: 'Title', description: 'Description', link: 'Link', hashtag: 'hashtag', date: '20160202T12:00:00Z' }
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

    let(:some_event_pending_approval) { create(:event) }

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
    (event['date'] >= current_year) && (event['date'] < current_year.next_year)
  end

  def current_month?(event, current_month)
    (event['date'] >= current_month) && (event['date'] < current_month.next_month)
  end

  def number_of_mail_deliveries
    Mail::TestMailer.deliveries.length
  end
end
