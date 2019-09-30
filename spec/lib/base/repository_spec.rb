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

  let(:some_record) { create(:job) }
  let(:some_published_record) do
    record = some_record
    repo.publish(some_record['publish_id'])
    record
  end
  let(:some_posted_record) do
    record = some_published_record
    repo.mark_as_posted(some_published_record['publish_id'])
    record
  end

  before { repo.remove_all }

  describe '#publish' do
    it 'flags the record as published' do
      repo.publish(some_record['publish_id'])

      updated_record = repo.find_by_id(some_record['_id'])

      expect(updated_record['published']).to be(true)
      expect(updated_record['published_at']).not_to be_nil
    end
  end

  describe '#mark_as_posted' do
    it 'flags the record as posted in the website' do
      repo.mark_as_posted(some_published_record['publish_id'])

      updated_record = repo.find_by_id(some_published_record['_id'])

      expect(updated_record['posted']).to be(true)
      expect(updated_record['posted_at']).not_to be_nil
    end
  end

  describe '#mark_as_tweeted' do
    it 'flags the record as posted in twitter' do
      repo.mark_as_tweeted(some_posted_record['publish_id'])

      updated_record = repo.find_by_id(some_posted_record['_id'])

      expect(updated_record['tweeted']).to be(true)
      expect(updated_record['tweeted_at']).not_to be_nil
    end
  end

  describe '#unpublish' do
    it 'fails to unpublish when secret is wrong' do
      repo.unpublish(some_published_record['publish_id'], 'wrong_secret')

      record = repo.find_by_id(some_published_record['_id'])

      expect(record['published']).to be(true)
    end

    it 'flags the record as not published' do
      repo.unpublish(some_published_record['publish_id'], some_published_record['secret'])

      record = repo.find_by_id(some_published_record['_id'])

      expect(record['published']).to be(false)
      expect(record['published_at']).to be_nil
    end
  end
end
