# frozen_string_literal: true

require 'spec_helper'

describe VLCTechHub::Job::Repository do
  subject(:repo) { described_class.new }

  before { repo.remove_all }

  describe '#insert' do
    it 'creates a new job in the database' do
      job = repo.insert(text: 'javascript rockstar')
      repo.publish(job['publish_id'])

      expect(repo.all.count).to eq(1)
    end

    it 'adds some calculated fields' do
      result = repo.insert(text: 'javascript rockstar')

      expect(result['published']).to be(false)
      expect(result['publish_id']).not_to be_nil
      expect(result['created_at']).not_to be_nil
      expect(result['secret']).not_to be_nil
      expect(result['posted']).to be(false)
      expect(result['tweeted']).to be(false)
    end

    it 'adds protocol to link when missing' do
      result = repo.insert(link: 'www.vlcjob.es')
      expect(result['link']).to eql('http://www.vlcjob.es')

      result = repo.insert(link: 'http://www.vlcjob.es')
      expect(result['link']).to eql('http://www.vlcjob.es')
    end
  end

  describe '#find_twitter_pending_jobs' do
    before do
      some_approved_jobs = create_list(:job, 7)
      some_approved_jobs.each { |e| repo.publish(e['publish_id']) }

      some_posted_jobs = some_approved_jobs.take(5)
      some_posted_jobs.each { |e| repo.mark_as_posted(e['publish_id']) }

      some_twitted_jobs = some_posted_jobs.take(3)
      some_twitted_jobs.each { |e| repo.mark_as_tweeted(e['publish_id']) }
    end

    it 'returns the list of jobs not yet twitted' do
      twitter_pending_jobs = repo.find_twitter_pending_jobs

      expect(twitter_pending_jobs.count).to eq(2)
    end
  end

  describe '#all' do
    before do
      jobs = create_list(:job, 5)

      approved_jobs = jobs.take(3)
      approved_jobs.each { |e| repo.publish(e['publish_id']) }
    end

    it 'returns all approved job offers' do
      expect(repo.all.count).to eq(3)
    end
  end
end
