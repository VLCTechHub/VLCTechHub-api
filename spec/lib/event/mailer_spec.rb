# frozen_string_literal: true

require 'spec_helper'

describe VLCTechHub::Event::Mailer do
  before do
    Mail::TestMailer.deliveries.clear
    stub_const('ENV', ENV.to_hash.merge('EMAIL_FOR_BROADCAST' => 'broadcast@email.any'))
  end

  describe '.broadcast' do
    let(:event) do
      {
        'title' => 'a title',
        'description' => 'a description',
        'date' => DateTime.new(2_001, 12, 1),
        'link' => 'http://anywhere.org'
      }
    end

    it 'delivers a formatted new event mail' do
      described_class.broadcast event

      mail = Mail::TestMailer.deliveries.first

      expect(mail.from).to eq(%w[vlctechhub@gmail.com])
      expect(mail.to).to eq(%w[broadcast@email.any])
      expect(mail.subject).to include(event['title'])
      html_body = mail.body.parts.first.body.raw_source
      expect(html_body).to include(event['link'])
    end
  end
end
