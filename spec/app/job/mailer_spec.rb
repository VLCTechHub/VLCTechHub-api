require 'spec_helper'

describe VLCTechHub::Job::Mailer do
  before do
    Mail::TestMailer.deliveries.clear
  end

  let(:job) { {
    'title' => 'a title',
    'description' => 'a description',
    'company' => { 'name' => 'canal cocina'},
    'link' => 'http://anywhere.org',
    'contact_email' => 'pub@email.any'}
  }

  describe '#publish' do
    before do
      ENV['EMAIL_FOR_PUBLICATION'] = 'pub@email.any'
    end
    after do
      ENV['EMAIL_FOR_PUBLICATION'] = ''
    end

    it 'delivers a formatted mail' do
      described_class.publish job

      mail = Mail::TestMailer.deliveries.first
      expect(mail.from).to eq(['vlctechhub@gmail.com'])
      expect(mail.to).to eq(['pub@email.any'])
      expect(mail.subject).to include(job['title'])
      html_body = mail.body.parts.first.body.raw_source
      expect(html_body).to include(job['link'])
    end
  end

  describe '#broadcast' do
    before do
      ENV['EMAIL_FOR_BROADCAST'] = 'cast@email.any'
    end
    after do
      ENV['EMAIL_FOR_BROADCAST'] = ''
    end

    it 'delivers a formatted mail' do
      described_class.broadcast(job)

      mail = Mail::TestMailer.deliveries.first
      expect(mail.from).to eq(['vlctechhub@gmail.com'])
      expect(mail.to).to eq(['cast@email.any'])
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
      expect(mail.from).to eq(['vlctechhub@gmail.com'])
      expect(mail.to).to eq(['pub@email.any'])
      expect(mail.subject).to include(job['title'])
      html_body = mail.body.parts.first.body.raw_source
      expect(html_body).to include(job['link'])
      expect(html_body).to include('unpublish')
    end
  end
end
