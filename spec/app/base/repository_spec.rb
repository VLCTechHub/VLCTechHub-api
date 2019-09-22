# frozen_string_literal: true

require 'spec_helper'

describe VLCTechHub::Base::Repository do
  subject(:some_child_repository) do
    Class.new(described_class) do
      def collection
        db['jobs']
      end
    end
  end

  let(:repo) { some_child_repository.new }

  describe '#publish' do
    it 'flags as published the record' do
      job = { published: false, publish_id: 123 }
      id = repo.db['jobs'].insert_one(job).inserted_id

      repo.publish(123)

      updated = repo.db['jobs'].find(_id: id).first
      expect(updated['published']).to be(true)
      expect(updated['published_at']).not_to be_nil
    end
  end

  describe '#unpublish' do
    it 'fail to unpublish when secret is wrong' do
      job = { published: true, publish_id: 456, secret: 'the_secret' }
      id = repo.db['jobs'].insert_one(job).inserted_id

      repo.unpublish(456, 'wrong_secret')

      updated = repo.db['jobs'].find(_id: id).first
      expect(updated['published']).to be(true)
    end

    it 'flags the record as not published' do
      job = { published: true, publish_id: 678, secret: 'the_secret', published_at: DateTime.now }
      id = repo.db['jobs'].insert_one(job).inserted_id

      repo.unpublish(678, 'the_secret')

      updated = repo.db['jobs'].find(_id: id).first
      expect(updated['published_at']).to be_nil
    end
  end
end
