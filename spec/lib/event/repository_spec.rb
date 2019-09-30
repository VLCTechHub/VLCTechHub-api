# frozen_string_literal: true

require 'spec_helper'

describe VLCTechHub::Event::Repository do
  subject(:repo) { described_class.new }

  before { repo.remove_all }

  describe '#insert' do
    it 'creates a new event in the database' do
      event = repo.insert(title: 'javascript the good parts')
      repo.publish(event['publish_id'])

      expect(repo.all.count).to eq(1)
    end

    it 'adds some calculated fields' do
      result = repo.insert(title: 'javascript the good parts')

      expect(result['published']).to be(false)
      expect(result['publish_id']).not_to be_nil
      expect(result['created_at']).not_to be_nil
      expect(result['slug']).not_to be_nil
      expect(result['posted']).to be(false)
      expect(result['tweeted']).to be(false)
    end
  end

  describe '#find_twitter_pending_events' do
    before do
      some_approved_events = create_list(:event, 7)
      some_approved_events.each { |e| repo.publish(e['publish_id']) }

      some_posted_events = some_approved_events.take(5)
      some_posted_events.each { |e| repo.mark_as_posted(e['publish_id']) }

      some_twitted_events = some_posted_events.take(3)
      some_twitted_events.each { |e| repo.mark_as_tweeted(e['publish_id']) }
    end

    it 'returns the list of events not yet twitted' do
      twitter_pending_events = repo.find_twitter_pending_events

      expect(twitter_pending_events.count).to eq(2)
    end
  end

  describe '#all' do
    before do
      events = create_list(:event, 5)

      approved_events = events.take(3)
      approved_events.each { |e| repo.publish(e['publish_id']) }
    end

    it 'returns all approved events' do
      expect(repo.all.count).to eq(3)
    end
  end
end
