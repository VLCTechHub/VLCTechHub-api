require 'spec_helper'

describe VLCTechHub::Base::Repository do
  class Repo < described_class
    def collection
      db['jobs']
    end
  end

  let(:subject) { Repo.new }

  describe '#publish' do
    it 'flags as published the record' do
      job = { published: false, publish_id: 123 }
      id = subject.db['jobs'].insert_one(job).inserted_id

      subject.publish(123)

      updated = subject.db['jobs'].find({ _id: id }).first
      expect(updated['published']).to eql(true)
      expect(updated['published_at']).not_to be_nil
    end
  end
end
