require 'spec_helper'

describe VLCTechHub::Event::Mailer do

  before do
    Mail::TestMailer.deliveries.clear
    ENV['EMAIL_FOR_BROADCAST'] = 'broadcast@email.any'
  end

  after do
    ENV['EMAIL_FOR_BROADCAST'] = ''
  end

  describe '.broadcast' do

    it 'delivers a formatted new event mail' do
      event = {
        'title' => 'a title',
        'description' => 'a description',
        'date' => DateTime.new(2001,12,01),
        'link' => 'http://anywhere.org'
      }

      described_class.broadcast event
      mail = Mail::TestMailer.deliveries.first
      expect(mail.from).to eq(['vlctechhub@gmail.com'])
      expect(mail.to).to eq(['broadcast@email.any'])
      expect(mail.subject).to include(event['title'])
      html_body = mail.body.parts.first.body.raw_source
      expect(html_body).to include(event['link'])
    end
  end
end
