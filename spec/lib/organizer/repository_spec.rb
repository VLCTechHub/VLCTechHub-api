# frozen_string_literal: true

require 'spec_helper'

describe VLCTechHub::Organizer::Repository do
  subject(:repo) { described_class.new }

  before { repo.remove_all }

  describe '#insert' do
    it 'creates a new organizer in the database' do
      repo.insert(name: 'javascripters')

      expect(repo.all.count).to eq(1)
    end

    it 'adds some calculated fields' do
      result = repo.insert(title: 'javascript the good parts')

      expect(result['published']).to be(true)
      expect(result['publish_id']).not_to be_nil
      expect(result['created_at']).not_to be_nil
    end
  end

  describe '#all' do
    before { create_list(:organizer, 5) }

    it 'returns all organizers' do
      expect(repo.all.count).to eq(5)
    end
  end
end
