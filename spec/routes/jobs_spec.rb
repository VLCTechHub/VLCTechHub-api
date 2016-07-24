require 'spec_helper'

describe VLCTechHub::API::V1::Routes do
  def app
    VLCTechHub::API::Boot
  end

  let(:any_job) { {'publish_id' => 123} }

  let(:jobs_repo) { double(:jobs) }

  before(:each) do
    allow(VLCTechHub::Jobs).to receive(:new).and_return(jobs_repo)
  end

  describe 'GET /v1/jobs' do
    subject(:jobs) { JSON.parse(last_response.body)['jobs'] }

    it 'returns all jobs in the last month' do
      expect(jobs_repo).to receive(:find_latest_jobs).
        and_return([any_job])

      get '/v1/jobs/'

      expect(last_response).to be_ok
      expect(jobs.first['id']).to eql('123')
    end
  end

  describe "POST /v1/jobs" do
    subject(:response_job) { JSON.parse(last_response.body)['job'] }

    let(:payload) {
      {
        title: 'Title',
        description: 'Description',
        link: 'Link',
        company: { name: 'the name', link: 'a link' },
        tags: ['a_tag', 'another_tag'],
        how_to_apply: 'more text',
        salary: '123 euros'
      }
    }

    it "creates a job offer and returns the created job" do
      allow(VLCTechHub::Job::Mailer).to receive(:publish)

      expect(jobs_repo).to receive(:insert).
        with(payload).
        and_return(any_job)

      post "/v1/jobs", {job: payload}
      expect(last_response).to be_created
      expect(response_job['id']).to eql('123')
    end

    it "calls the mailer" do
      allow(jobs_repo).to receive(:insert).and_return(any_job)

      expect(VLCTechHub::Job::Mailer).to receive(:publish).
        with(any_job)

      post "/v1/jobs", {job: payload}
    end
  end

  describe 'GET /v1/events/publish' do
    context 'Job is not found' do
      it 'returns 404 if not found' do
        expect(jobs_repo).to receive(:publish).
          and_return(false)

        get '/v1/jobs/publish/not-found-id'
        expect(last_response).to be_not_found
      end
    end

    context 'Job is found' do
      it 'updates the record' do
        allow(VLCTechHub::Job::Twitter).to receive(:tweet)
        allow(VLCTechHub::Job::Mailer).to receive(:broadcast)

        expect(jobs_repo).to receive(:publish).
          with('found-id').
          and_return(true)
        expect(jobs_repo).to receive(:find_by_uuid).
          with('found-id').
          and_return(any_job)

        get "/v1/jobs/publish/found-id"
        expect(last_response).to be_ok
      end

      it 'notifies to external services' do
        allow(jobs_repo).to receive(:publish).
          and_return(true)
        allow(jobs_repo).to receive(:find_by_uuid).
          and_return(any_job)

        expect(VLCTechHub::Job::Twitter).to receive(:tweet).
          with(any_job)
        expect(VLCTechHub::Job::Mailer).to receive(:broadcast).
          with(any_job)

        get "/v1/jobs/publish/found-id"
      end
    end

  end
end
