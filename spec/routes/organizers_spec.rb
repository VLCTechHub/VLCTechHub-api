require 'spec_helper'

describe VLCTechHub::API::V1::Routes do
  def app
    VLCTechHub::API::Boot
  end

  describe 'GET /v1/organizers' do
    subject(:organizers) { JSON.parse(last_response.body)['organizers'] }
    TOTAL_ORGANIZERS_IN_CURRENT_MONTH_FROM_FIXTURES = 2

    it 'returns all organizers' do
      get '/v1/organizers/'

      expect(last_response).to be_ok
      expect(organizers.size).to eq(TOTAL_ORGANIZERS_IN_CURRENT_MONTH_FROM_FIXTURES)
      organizer = organizers.first
      expect(organizer['hashtag']).to eq('@decharlas')
      expect(organizer['name']).to eq('decharlas')
      expect(organizer['description']).to_not be_nil
      expect(organizer['profile_image_small_url']).to_not be_nil
      expect(organizer['profile_image_big_url']).to_not be_nil
    end
  end
end
