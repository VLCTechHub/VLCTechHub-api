# frozen_string_literal: true

require 'spec_helper'

describe VLCTechHub::Organizer::Repository do
  subject(:organizers) { described_class.new }

  describe '#insert' do
    it 'creates a new organizer in the database' do
      result = organizers.insert(name: 'javascripters')

      saved = organizers.db['organizers'].find(_id: result['_id']).first

      expect(result['name']).to eql(saved['name'])
    end

    it 'adds some calculated fields' do
      result = organizers.insert(title: 'javascript the good parts')

      expect(result['published']).to be(true)
      expect(result['publish_id']).not_to be_nil
      expect(result['created_at']).not_to be_nil
    end
  end
end
