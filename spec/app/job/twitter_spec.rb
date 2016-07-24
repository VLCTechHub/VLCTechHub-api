require 'spec_helper'

describe VLCTechHub::Job::Twitter do
  let(:job) do
    {
      'title' => 'rockstar ninja node developer',
      'company' => 'acme inc.',
      'publish_id' => 'abc'
    }
  end

  let(:twitter_api) { double(:twitter_api) }
  let(:subject) { described_class.new(twitter_api) }

  describe '#tweet' do
    it 'sends a tweet with title ans company' do
      expect(twitter_api).to receive(:update)
        .with(string_that_includes(['#ofertaDeEmpleo', job['title'], job['company']]))

      subject.tweet(job)
    end

    it 'sends a link back to vlctechhub' do
      expect(twitter_api).to receive(:update)
        .with(string_that_includes(['http://vlctechhub.org/job/board/abc']))

      subject.tweet(job)
    end
  end
end
