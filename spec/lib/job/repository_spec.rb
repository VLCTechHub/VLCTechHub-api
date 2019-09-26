# frozen_string_literal: true

require 'spec_helper'

describe VLCTechHub::Job::Repository do
  subject(:jobs) { described_class.new }

  describe '#insert' do
    it 'creates a new job in the database' do
      result = jobs.insert(text: 'javascript rockstar')

      saved = jobs.db['jobs'].find(_id: result['_id']).first

      expect(result['text']).to eql(saved['text'])
    end

    it 'adds some calculated fields' do
      result = jobs.insert(text: 'javascript rockstar')

      expect(result['published']).to be(false)
      expect(result['publish_id']).not_to be_nil
      expect(result['created_at']).not_to be_nil
      expect(result['secret']).not_to be_nil
    end

    it 'adds protocol to link when missing' do
      result = jobs.insert(link: 'www.vlcjob.es')
      expect(result['link']).to eql('http://www.vlcjob.es')

      result = jobs.insert(link: 'http://www.vlcjob.es')
      expect(result['link']).to eql('http://www.vlcjob.es')
    end
  end
end
