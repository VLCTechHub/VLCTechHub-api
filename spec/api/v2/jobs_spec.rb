# frozen_string_literal: true

require 'spec_helper'

describe VLCTechHub::API::V2::Routes do
  def app
    VLCTechHub::API::Boot
  end

  describe 'GET /v2/jobs' do
    subject(:jobs) { JSON.parse(last_response.body) }

    it 'returns the list of job offers published in the last month' do
      get '/v2/jobs/'

      expect(last_response).to be_ok

      expect(jobs).not_to be_empty
    end
  end

  describe 'POST /v2/jobs' do
    subject(:job) { JSON.parse(last_response.body) }

    let(:some_job_data) do
      {
        title: 'Title',
        description: 'Description',
        link: 'Link',
        company: { name: 'Name', link: 'Link' },
        tags: %w[a_tag another_tag],
        how_to_apply: 'mMre text',
        contact_email: 'Any email',
        salary: '123 euros'
      }
    end

    before do
      Mail::TestMailer.deliveries.clear
      stub_const(
        'ENV',
        ENV.to_hash.merge('EMAIL_FOR_PUBLICATION' => 'some@email.com', 'EMAIL_FOR_BROADCAST' => 'some@email.com')
      )
    end

    it 'creates a job offer' do
      post '/v2/jobs', some_job_data

      expect(last_response).to be_created

      expect(job['id']).not_to be_nil
    end

    it 'sends the approval request email' do
      expect { post '/v2/jobs', some_job_data }.to change { number_of_mail_deliveries }.by(1)
    end

    it 'returns an error if job offer data is invalid' do
      post '/v2/jobs', {}

      expect(last_response).to be_bad_request
    end
  end

  describe 'GET /v2/jobs/approve/:uuid' do
    subject(:job) { JSON.parse(last_response.body) }

    let(:some_job_offer_pending_approval) { VLCTechHub::Jobs.new.insert(text: 'javascript rockstar') }

    it 'approves the job offer' do
      get "/v2/jobs/approve/#{some_job_offer_pending_approval['publish_id']}"

      expect(job['id']).to eq(some_job_offer_pending_approval['publish_id'])
    end

    it 'returns an error if publish id is invalid' do
      get '/v2/jobs/approve/invalid_publish_id'

      expect(last_response).to be_bad_request
    end

    it 'returns a not found error if publish id has an unmatched value' do
      some_unmatched_publish_id = '00000000-0000-4000-a000-000000000000'

      get "/v2/jobs/approve/#{some_unmatched_publish_id}"

      expect(last_response).to be_not_found
    end
  end

  describe 'GET /v2/jobs/unlist/:uuid/secret/:secret' do
    subject(:response) { JSON.parse(last_response.body) }

    let(:some_published_job_offer) do
      VLCTechHub::Jobs.new.insert(published: true, text: 'javascript rockstar', published_at: DateTime.now)
    end

    it 'unpublishes the job offer' do
      get "/v2/jobs/unlist/#{some_published_job_offer['publish_id']}/secret/#{some_published_job_offer['secret']}"

      expect(last_response).to be_ok

      expect(response['status']).not_to be_nil
    end

    it 'returns an error if publish id is invalid' do
      get "/v2/jobs/unlist/invalid_publish_id/secret/#{some_published_job_offer['secret']}"

      expect(last_response).to be_bad_request
    end

    it 'returns an error if secret is invalid' do
      get "/v2/jobs/unlist/#{some_published_job_offer['publish_id']}/secret/invalid_secret"

      expect(last_response).to be_bad_request
    end

    it 'returns a not found error if secret has an unmatched value' do
      some_unmatched_secret = '00000000-0000-4000-a000-000000000000'

      get "/v2/jobs/unlist/#{some_published_job_offer['publish_id']}/secret/#{some_unmatched_secret}"

      expect(last_response).to be_not_found
    end
  end

  def number_of_mail_deliveries
    Mail::TestMailer.deliveries.length
  end
end
