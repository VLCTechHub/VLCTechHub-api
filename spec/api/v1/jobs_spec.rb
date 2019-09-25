# frozen_string_literal: true

require 'spec_helper'

describe VLCTechHub::API::V1::Routes do
  def app
    VLCTechHub::API::Boot
  end

  describe 'GET /v1/jobs' do
    subject(:jobs) { JSON.parse(last_response.body)['jobs'] }

    it 'returns a list of active job offers' do
      get '/v1/jobs/'

      expect(last_response).to be_ok

      expect(jobs).not_to be_empty
    end
  end

  describe 'POST /v1/jobs' do
    subject(:job) { JSON.parse(last_response.body)['job'] }

    let(:some_job_data) do
      {
        title: 'Title',
        description: 'Description',
        link: 'Link',
        company: { name: 'the name', link: 'a link' },
        tags: %w[a_tag another_tag],
        how_to_apply: 'more text',
        contact_email: 'any email',
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
      post '/v1/jobs', job: some_job_data

      expect(last_response).to be_created

      expect(job['id']).not_to be_nil
    end

    it 'sends the publish email' do
      expect { post '/v1/jobs', job: some_job_data }.to change { number_of_mail_deliveries }.by(1)
    end

    it 'returns an error if job offer data is invalid' do
      post '/v1/jobs', job: {}

      expect(last_response).to be_bad_request
    end
  end

  describe 'GET /v1/jobs/publish/:uuid' do
    subject(:job) { JSON.parse(last_response.body)['job'] }

    let(:some_unpublished_job_offer) do
      VLCTechHub::Jobs.new.insert(
        title: 'javascript rockstar',
        company: { name: 'the name', link: 'a link' },
        description: 'the description',
        contact_email: 'some@email.com'
      )
    end

    before do
      Mail::TestMailer.deliveries.clear
      allow(VLCTechHub::Job::Twitter).to receive(:new_job)
      stub_const(
        'ENV',
        ENV.to_hash.merge('EMAIL_FOR_PUBLICATION' => 'some@email.com', 'EMAIL_FOR_BROADCAST' => 'some@email.com')
      )
    end

    it 'publishes the job offer' do
      get "/v1/jobs/publish/#{some_unpublished_job_offer['publish_id']}"

      expect(job['published_at']).not_to be_nil
    end

    it 'tweets and emails the publication' do
      expect { get "/v1/jobs/publish/#{some_unpublished_job_offer['publish_id']}" }.to change {
        number_of_mail_deliveries
      }.by(2)

      expect(VLCTechHub::Job::Twitter).to have_received(:new_job).with(
        hash_including(publish_id: some_unpublished_job_offer['publish_id'])
      )
    end

    it 'returns a not found error if publish id does not exist' do
      get '/v1/jobs/publish/invalid_publish_id'

      expect(last_response).to be_not_found
    end
  end

  describe 'GET /v1/jobs/unpublish/:uuid/secret/:secret' do
    subject(:response) { JSON.parse(last_response.body) }

    let(:some_published_job_offer) do
      VLCTechHub::Jobs.new.insert(
        published: true,
        title: 'javascript rockstar',
        company: { name: 'the name', link: 'a link' },
        description: 'the description',
        contact_email: 'some@email.com',
        published_at: DateTime.now
      )
    end

    it 'unpublishes the job offer' do
      get "/v1/jobs/unpublish/#{some_published_job_offer['publish_id']}/secret/#{some_published_job_offer['secret']}"

      expect(last_response).to be_ok

      expect(response['status']).to eq('Job unpublished successfully.')
    end

    context 'when job is found' do
      it 'returns a not found error if the secret has a wrong value' do
        get "/v1/jobs/unpublish/#{some_published_job_offer['publish_id']}/secret/invalid_secret"

        expect(last_response).to be_not_found
      end
    end
  end

  def number_of_mail_deliveries
    Mail::TestMailer.deliveries.length
  end
end
