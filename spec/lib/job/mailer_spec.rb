# frozen_string_literal: true

require 'spec_helper'

describe VLCTechHub::Job::Mailer do
  before { Mail::TestMailer.deliveries.clear }

  let(:job) do
    {
      'title' => 'a title',
      'description' => 'a description',
      'company' => { 'name' => 'canal cocina' },
      'link' => 'http://anywhere.org',
      'contact_email' => 'pub@email.any'
    }
  end

  describe '.publish' do
    before { stub_const('ENV', ENV.to_hash.merge('EMAIL_FOR_PUBLICATION' => 'pub@email.any')) }

    it 'delivers a formatted mail' do
      described_class.publish job

      mail = Mail::TestMailer.deliveries.first
      expect(mail.from).to eq(%w[vlctechhub@gmail.com])
      expect(mail.to).to eq(%w[pub@email.any])
      expect(mail.subject).to include(job['title'])
      html_body = mail.body.parts.first.body.raw_source
      expect(html_body).to include(job['link'])
    end
  end

  describe '.broadcast' do
    before { stub_const('ENV', ENV.to_hash.merge('EMAIL_FOR_BROADCAST' => 'cast@email.any')) }

    it 'delivers a formatted mail' do
      described_class.broadcast(job)

      mail = Mail::TestMailer.deliveries.first
      expect(mail.from).to eq(%w[vlctechhub@gmail.com])
      expect(mail.to).to eq(%w[cast@email.any])
      expect(mail.subject).to include(job['title'])
      html_body = mail.body.parts.first.body.raw_source
      expect(html_body).to include(job['link'])
      expect(html_body).to include(job['company']['name'])
    end
  end

  describe '#published' do
    it 'delivers a formatted mail with unpublish link' do
      described_class.published job

      mail = Mail::TestMailer.deliveries.first
      expect(mail.from).to eq(%w[vlctechhub@gmail.com])
      expect(mail.to).to eq(%w[pub@email.any])
      expect(mail.subject).to include(job['title'])
      html_body = mail.body.parts.first.body.raw_source
      expect(html_body).to include(job['link'])
      expect(html_body).to include('unpublish')
    end
  end
end
