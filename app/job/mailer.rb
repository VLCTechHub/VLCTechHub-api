require 'mail'

module VLCTechHub
  module Job
    class Mailer
      def self.publish(job)
        return false if ENV['EMAIL_FOR_PUBLICATION'].to_s.empty?

        Mail.deliver do
          to ENV['EMAIL_FOR_PUBLICATION']
          from 'VLCTechHub <vlctechhub@gmail.com>'
          subject "[VLCTECHHUB] Publicar: #{job['title']}"

          html_part do
            content_type 'text/html; charset=UTF-8'
            body "<h1>#{job['title']}</h1>" +
                "<pre>#{job['description']}</pre>" +
                "<p>Company: #{job['company']}</p>" +
                "<p>Link: <a href='#{job['link']}'>#{job['link']}</a></p>" +
                "<p><a href='http://api.vlctechhub.org/v1/events/publish/#{job['publish_id']}'>Publicar Oferta</a></p>"
          end
        end
      end
    end
  end
end
