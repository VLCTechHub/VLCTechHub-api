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
    end

    it 'adds protocol to link when missing' do
      result = repo.insert(link: 'www.vlcjob.es')
      expect(result['link']).to eql('http://www.vlcjob.es')

      result = repo.insert(link: 'http://www.vlcjob.es')
      expect(result['link']).to eql('http://www.vlcjob.es')
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
