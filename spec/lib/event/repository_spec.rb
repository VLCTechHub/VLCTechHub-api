# frozen_string_literal: true

require 'spec_helper'

describe VLCTechHub::Event::Repository do
  subject(:events) { described_class.new }

  describe '#insert' do
    it 'creates a new event in the database' do
      result = events.insert(title: 'javascript the good parts')

      saved = events.db['events'].find(_id: result['_id']).first

      expect(result['title']).to eql(saved['title'])
    end

    it 'adds some calculated fields' do
      result = events.insert(title: 'javascript the good parts')

      expect(result['published']).to be(false)
      expect(result['publish_id']).not_to be_nil
      expect(result['created_at']).not_to be_nil
      expect(result['slug']).not_to be_nil
    end
  end
end
