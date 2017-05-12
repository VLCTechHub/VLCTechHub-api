require 'spec_helper'

describe VLCTechHub::Jobs do
  describe '#insert' do
    it 'creates a new job in the database' do
      result = subject.insert({text: 'javascript rockstar'})

      saved = subject.db['jobs'].find({ _id: result['_id'] }).first

      expect(result['text']).to eql(saved['text'])
    end

    it 'adds some calculated fields' do
      result = subject.insert({text: 'javascript rockstar'})

      expect(result['published']).to eql(false)
      expect(result['publish_id']).not_to be_nil
      expect(result['created_at']).not_to be_nil
      expect(result['secret']).not_to be_nil
    end

    it 'adds protocol to link when missing' do
      result = subject.insert({link: 'www.vlcjob.es'})
      expect(result['link']).to eql('http://www.vlcjob.es')

      result = subject.insert({link: 'http://www.vlcjob.es'})
      expect(result['link']).to eql('http://www.vlcjob.es')
    end
  end
end
