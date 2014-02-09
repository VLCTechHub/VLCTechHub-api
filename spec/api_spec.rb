require 'spec_helper'
require_relative '../api'

describe VLCTechHub::API do
  def app
    VLCTechHub::API
  end

  describe "GET /v0/events" do
    it "returns a list of events" do
      get "/v0/events"
      last_response.status.should == 200
      JSON.parse(last_response.body).should_not == []
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
