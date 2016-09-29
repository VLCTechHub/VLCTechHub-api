require 'spec_helper'

describe VLCTechHub::API::V1::Routes do
  def app
    VLCTechHub::API::Boot
  end

  let(:any_job) { {'publish_id' => 123} }

  subject(:response_job) { JSON.parse(last_response.body)['job'] }

  def mock_repo
    jobs_repo = double(:jobs)
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
      expect(jobs_repo).to receive(:find_latest_jobs).
        and_return([any_job])

      get '/v1/jobs/'
    end
  end

  describe "POST /v1/jobs" do
    let(:payload) {
      {
        title: 'Title',
        description: 'Description',
        link: 'Link',
        company: { name: 'the name', link: 'a link' },
        tags: ['a_tag', 'another_tag'],
        how_to_apply: 'more text',
        contact_email: 'any email',
        salary: '123 euros'
      }
    }

    it "creates a job offer and returns the created job" do
      allow(VLCTechHub::Job::Mailer).to receive(:publish)

      post "/v1/jobs", {job: payload}

      expect(last_response).to be_created
      expect(response_job['id']).to_not be_nil
    end

    it "calls the mailer" do
      jobs_repo = mock_repo
      allow(jobs_repo).to receive(:insert).and_return(any_job)

      expect(VLCTechHub::Job::Mailer).to receive(:publish).
        with(any_job)

      post "/v1/jobs", {job: payload}
    end
  end

  describe 'GET /v1/events/publish' do
    context 'Job is not found' do
      it 'returns 404 if not found' do
        get '/v1/jobs/publish/not-found-id'

        expect(last_response).to be_not_found
      end
    end

    context 'Job is found' do
      it 'updates the record' do
        allow(VLCTechHub::Job::Twitter).to receive(:new_job)
        allow(VLCTechHub::Job::Mailer).to receive(:broadcast)
        job = VLCTechHub::Jobs.new.insert({text: 'javascript rockstar'})

        get "/v1/jobs/publish/#{job['publish_id'].to_s}"

        expect(response_job['published_at']).not_to be_nil
      end

      it 'notifies to external services' do
        jobs_repo = mock_repo
        allow(jobs_repo).to receive(:publish).
          and_return(true)
        allow(jobs_repo).to receive(:find_by_uuid).
          and_return(any_job)

        expect(VLCTechHub::Job::Twitter).to receive(:new_job).
          with(any_job)
        expect(VLCTechHub::Job::Mailer).to receive(:broadcast).
          with(any_job)

        get "/v1/jobs/publish/found-id"
      end
    end
  end
end
