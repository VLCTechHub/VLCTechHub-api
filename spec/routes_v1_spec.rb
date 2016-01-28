require 'spec_helper'
require 'time'
require_relative '../boot'

describe VLCTechHub::API::V1::Routes do
  def app
    VLCTechHub::API::Boot
  end

  let(:request_time) { Time.now.utc }
  subject(:events) { JSON.parse(last_response.body) }

  describe "GET /v1/events/upcoming" do
    it "returns a list of future (non past) events" do
      get "/v1/events/upcoming"
      expect(last_response).to be_ok
      expect(past_events).to be_empty
    end
  end

  describe "GET /v1/events/past" do
    it "returns a list of past (non future) events" do
      get "/v1/events/past"
      expect(last_response).to be_ok
      expect(future_events).to be_empty
    end
  end

  describe "GET /v1/events/year/month" do
    it "returns a list of events for that year and month" do
      get "/v1/events/2014/02"
      expect(last_response).to be_ok
      expect(events_for_year_month(2014,02)).not_to be_empty
    end
    it "returns error if invalid year or month" do
      get "/v1/events/0014/01"
      expect(last_response).to be_bad_request
      get "/v1/events/2014/00"
      expect(last_response).to be_bad_request
    end
    it "returns not found if year or month are bad formatted" do
      get "/v1/events/20140/01"
      expect(last_response).to be_not_found
      get "/v1/events/2014/001"
      expect(last_response).to be_not_found
    end
  end

  describe "GET /v1/events/:id" do
    it "returns an event by id" do
      get "/v1/events/52efbf75a1aac70200000001"
      expect(last_response).to be_ok
      expect(events).not_to be_empty
    end
  end

  def past_events
    events.select { |e| past_event? e }
  end

  def future_events
    events.select { |e| future_event? e }
  end

  def events_for_year_month year, month
    current_month = DateTime.new(year, month)
    events.select { |e| current_month? e, current_month }
  end

  def past_event? event
    event['date'] < request_time
  end

  def future_event? event
    event['date'] >= request_time
  end

  def current_month? event, current_month
    event['date'] >= current_month or event['date'] < current_month.next_month
  end
end
