require 'spec_helper'

describe VLCTechHub::API::V1::Routes do
  def app
    VLCTechHub::API::Boot
  end

  describe 'GET /v1/jobs' do
    subject(:jobs) { JSON.parse(last_response.body)['jobs'] }
    TOTAL_JOBS_IN_CURRENT_MONTH_FROM_FIXTURES = 2

    it 'returns all jobs in the last month' do
      get '/v1/jobs/'

      expect(last_response).to be_ok
      expect(jobs.size).to eq(TOTAL_JOBS_IN_CURRENT_MONTH_FROM_FIXTURES)
    end
  end
end
