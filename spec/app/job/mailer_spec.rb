require 'spec_helper'

describe VLCTechHub::Job::Mailer do
  before do
    Mail::TestMailer.deliveries.clear
    ENV['EMAIL_FOR_PUBLICATION'] = 'pub@email.any'
  end

  after do
    ENV['EMAIL_FOR_PUBLICATION'] = ''
  end

  describe '#publish' do
    it 'delivers a formatted mail' do
      job = {
        'title' => 'a title',
        'description' => 'a description',
        'company' => 'canal cocina',
        'link' => 'http://anywhere.org'
      }

      described_class.publish job

      mail = Mail::TestMailer.deliveries.first
      expect(mail.from).to eq(['vlctechhub@gmail.com'])
      expect(mail.to).to eq(['pub@email.any'])
      expect(mail.subject).to include(job['title'])
      html_body = mail.body.parts.first.body.raw_source
      expect(html_body).to include(job['link'])
    end
  end
end
