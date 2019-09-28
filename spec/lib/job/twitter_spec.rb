# frozen_string_literal: true

require 'spec_helper'

describe VLCTechHub::Job::Twitter do
  subject(:twitter) { described_class.new(twitter_api) }

  let(:job) { create(:job) }

  let(:twitter_api) { instance_spy(::Twitter::REST::Client, credentials: { some: 'credentials' }) }

  describe '#new_job' do
    it 'sends a tweet with title and company' do
      twitter.new_job(job)

      expect(twitter_api).to have_received(:update).with(
        string_that_includes(['#ofertaDeEmpleo', job['title'], job['company']['name']])
      )
    end

    it 'sends a link back to vlctechhub' do
      twitter.new_job(job)

      expect(twitter_api).to have_received(:update).with(
        string_that_includes(["https://vlctechhub.org/job/board/#{job['publish_id']}"])
      )
    end
  end
end
