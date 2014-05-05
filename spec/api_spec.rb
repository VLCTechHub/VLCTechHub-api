require 'spec_helper'
require 'time'
require_relative '../api'

describe VLCTechHub::API do
  def app
    VLCTechHub::API
  end

  describe "GET /v0/events/upcoming" do
    it "returns a list of future events" do
      request_time = Time.now.utc
      get "/v0/events/upcoming"
      last_response.status.should == 200
      JSON.parse(last_response.body).select { |e| e['date'] < request_time }.should == [] if  JSON.parse(last_response.body) != []
    end
  end
  describe "GET /v0/events/past" do
    it "returns a list of past events" do
      request_time = Time.now.utc
      get "/v0/events/past"
      last_response.status.should == 200
      JSON.parse(last_response.body).select { |e| e['date'] >= request_time }.should == [] if  JSON.parse(last_response.body) != []
    end
  end
  describe "GET /v0/events/year/month" do
    it "returns a list of events for that year and month" do
      month = DateTime.new(2014, 02, 01)
      next_month = DateTime.new(2014, 03, 01)
      get "/v0/events/2014/02"
      last_response.status.should == 200
      JSON.parse(last_response.body).should_not == []
      JSON.parse(last_response.body).select { |e| (e['date'] < month  || e['date'] > next_month) }.should == []
    end
    it "returns error if invalid year or month" do
      get "/v0/events/0014/01"
      last_response.status.should == 400
      last_response.body =~ /invalid/
      get "/v0/events/2014/00"
      last_response.status.should == 400
    end
    it "returns not found if year or month are bad formatted" do
      get "/v0/events/20140/01"
      last_response.status.should == 404
      get "/v0/events/2014/001"
      last_response.status.should == 404
    end
  end
  describe "GET /v0/events/:id" do
    it "returns an event by id" do
      get "/v0/events/52efbf75a1aac70200000001"
      last_response.status.should == 200
      last_response.body.should_not == {}
    end
  end
end
