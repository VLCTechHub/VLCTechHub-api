require 'spec_helper'
require 'time'
require_relative '../api'

describe VLCTechHub::API do
  def app
    VLCTechHub::API
  end

  let(:request_time) { Time.now.utc }

  describe "GET /v0/events/upcoming" do
    it "returns a list of future events" do
      get "/v0/events/upcoming"
      expect(last_response).to be_ok
      expect(past_events).to be_empty
    end
  end
  describe "GET /v0/events/past" do
    it "returns a list of past events" do
      get "/v0/events/past"
      expect(last_response).to be_ok
      expect(future_events).to be_empty
    end
  end
  describe "GET /v0/events/year/month" do
    it "returns a list of events for that year and month" do
      get "/v0/events/2014/02"
      expect(last_response).to be_ok
      expect(last_response.body).not_to be_empty
      expect(non_2014_02_events).to be_empty
    end
    it "returns error if invalid year or month" do
      get "/v0/events/0014/01"
      expect(last_response).to be_bad_request
      get "/v0/events/2014/00"
      expect(last_response).to be_bad_request
    end
    it "returns not found if year or month are bad formatted" do
      get "/v0/events/20140/01"
      expect(last_response).to be_not_found
      get "/v0/events/2014/001"
      expect(last_response).to be_not_found
    end
  end
  describe "GET /v0/events/:id" do
    it "returns an event by id" do
      get "/v0/events/52efbf75a1aac70200000001"
      expect(last_response).to be_ok
      expect(last_response.body).not_to be_empty
    end
  end

  private

  def events
    JSON.parse(last_response.body)
  end

  def past_events
    events.select { |e| past_event? e }
  end

  def future_events
   events.select { |e| future_event? e }
  end

  def past_event? event
    event['date'] < request_time
  end

  def future_event? event
    event['date'] >= request_time
  end

  def non_2014_02_events
    month_start = DateTime.new(2014, 02, 01)
    month_end = DateTime.new(2014, 03, 01)
    events.select { |e| (e['date'] < month_start  || e['date'] > month_end) }
  end
end
