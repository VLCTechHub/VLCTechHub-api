# frozen_string_literal: true

require 'spec_helper'

describe VLCTechHub::API::V1::Routes do
  def app
    VLCTechHub::API::Boot
  end

  describe 'GET /v1/organizers' do
    subject(:organizers) { JSON.parse(last_response.body)['organizers'] }

    it 'returns all organizers' do
      total_organizers_in_current_month_from_fixtures = 2

      get '/v1/organizers/'

      expect(last_response).to be_ok
      expect(organizers.size).to eq(total_organizers_in_current_month_from_fixtures)
      organizer = organizers.first
      expect(organizer['hashtag']).to eq('@decharlas')
      expect(organizer['name']).to eq('decharlas')
      expect(organizer['description']).not_to be_nil
      expect(organizer['profile_image_small_url']).not_to be_nil
      expect(organizer['profile_image_big_url']).not_to be_nil
    end
  end
end
