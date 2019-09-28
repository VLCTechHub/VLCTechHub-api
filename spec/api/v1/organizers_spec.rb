# frozen_string_literal: true

require 'spec_helper'

describe VLCTechHub::API::V1::Routes do
  def app
    VLCTechHub::API::Boot
  end

  let(:repo) { VLCTechHub::Organizer::Repository.new }

  before do
    repo.collection.drop
    create_list(:organizer, 2)
  end

  describe 'GET /v1/organizers' do
    subject(:organizers) { JSON.parse(last_response.body)['organizers'] }

    it 'returns all organizers' do
      get '/v1/organizers/'

      expect(last_response).to be_ok

      expect(organizers.size).to eq(2)
    end
  end
end
