# frozen_string_literal: true

require 'spec_helper'

describe VLCTechHub::API::V1::Routes do
  def app
    VLCTechHub::API::Boot
  end

  subject(:response_job) { JSON.parse(last_response.body)['job'] }

  let(:any_job) { { 'publish_id' => 123 } }

  def mock_repo
    jobs_repo = instance_double(VLCTechHub::Jobs)
    allow(VLCTechHub::Jobs).to receive(:new).and_return(jobs_repo)
    jobs_repo
  end

  describe 'GET /v1/jobs' do
    it 'returns a list of jobs' do
      get '/v1/jobs/'

      expect(last_response).to be_ok
      jobs = JSON.parse(last_response.body)['jobs']
      expect(jobs.first['id']).not_to be_nil
    end

    it 'returns latest jobs' do
      jobs_repo = mock_repo
      allow(jobs_repo).to receive(:find_latest_jobs).and_return([any_job])

      get '/v1/jobs/'

      expect(jobs_repo).to have_received(:find_latest_jobs)
    end
  end

  describe 'POST /v1/jobs' do
    let(:payload) do
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

    it 'creates a job offer and returns the created job' do
      allow(VLCTechHub::Job::Mailer).to receive(:publish)

      post '/v1/jobs', job: payload

      expect(last_response).to be_created
      expect(response_job['id']).not_to be_nil
    end

    it 'calls the mailer' do
      jobs_repo = mock_repo
      allow(jobs_repo).to receive(:insert).and_return(any_job)
      allow(VLCTechHub::Job::Mailer).to receive(:publish)

      post '/v1/jobs', job: payload

      expect(VLCTechHub::Job::Mailer).to have_received(:publish).with(any_job)
    end
  end

  describe 'GET /v1/jobs/publish' do
    context 'when job is not found' do
      it 'returns 404 if not found' do
        get '/v1/jobs/publish/not-found-id'

        expect(last_response).to be_not_found
      end
    end

    context 'when job is found' do
      before do
        allow(VLCTechHub::Job::Twitter).to receive(:new_job)
        allow(VLCTechHub::Job::Mailer).to receive(:broadcast)
        allow(VLCTechHub::Job::Mailer).to receive(:published)
      end

      it 'updates the record' do
        job = VLCTechHub::Jobs.new.insert(text: 'javascript rockstar')

        get "/v1/jobs/publish/#{job['publish_id']}"

        expect(response_job['published_at']).not_to be_nil
      end

      it 'notifies to external services' do
        jobs_repo = mock_repo
        allow(jobs_repo).to receive(:publish).and_return(true)
        allow(jobs_repo).to receive(:find_by_uuid).and_return(any_job)

        get '/v1/jobs/publish/found-id'

        expect(VLCTechHub::Job::Twitter).to have_received(:new_job).with(any_job)
        expect(VLCTechHub::Job::Mailer).to have_received(:broadcast).with(any_job)
        expect(VLCTechHub::Job::Mailer).to have_received(:published).with(any_job)
      end
    end
  end

  describe 'GET /v1/jobs/unpublish' do
    context 'when job is found' do
      it 'returns 404 if found but wrong secret' do
        job = VLCTechHub::Jobs.new.insert(text: 'javascript rockstar')
        get "/v1/jobs/unpublish/#{job['publish_id']}/secret/wrong_secret"
        expect(last_response).to be_not_found
      end
    end

    context 'when job is found' do
      job = VLCTechHub::Jobs.new.insert(published: true, text: 'javascript rockstar', published_at: DateTime.now)
      it 'flags the job as not published' do
        get "/v1/jobs/unpublish/#{job['publish_id']}/secret/#{job['secret']}"

        expect(last_response).to be_ok
        message = JSON.parse(last_response.body)['status']
        expect(message).to eql 'Job unpublished successfully.'
      end
    end
  end
end
