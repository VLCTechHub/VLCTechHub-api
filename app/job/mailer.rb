require 'mail'

module VLCTechHub
  module Job
    class Mailer
      class << self
        def publish(job)
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

        def broadcast job
          return false if ENV['EMAIL_FOR_BROADCAST'].to_s.empty?

          Mail.deliver do
            to ENV['EMAIL_FOR_BROADCAST']
            from 'VLCTechHub <vlctechhub@gmail.com>'
            subject "Nueva oferta: #{job['title']}"

            html_part do
              content_type 'text/html; charset=UTF-8'
              body "<h1>#{job['title']}</h1>" +
                "<h3>#{job['company']}</h3>" +
                "<pre>#{job['description']}</pre>" +
                "<p>Link: <a href='#{job['link']}'>#{job['link']}</a></p>"
            end
          end
        end
      end
    end
  end
end
