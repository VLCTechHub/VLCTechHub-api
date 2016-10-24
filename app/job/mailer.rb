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
                "<p>Keywords: #{job['tags']}</p>" +
                "<p>Company Name: #{job['company']['name']}</p>" +
                "<p>Company Link: #{job['company']['link']}</p>" +
                "<p>Company Twitter: #{job['company']['twitter']}</p>" +
                "<p>Salary: #{job['salary']}</p>" +
                "<p>How to apply: #{job['how_to_apply']}</p>" +
                "<p>Contact: #{job['contact_email']}</p>" +
                "<p>Link: <a href='#{job['link']}'>#{job['link']}</a></p>" +
                "<p><a href='http://api.vlctechhub.org/v1/jobs/publish/#{job['publish_id']}'>Publicar Oferta</a></p>"
            end
          end
        end

        def broadcast(job)
          return false if ENV['EMAIL_FOR_BROADCAST'].to_s.empty?

          Mail.deliver do
            to ENV['EMAIL_FOR_BROADCAST']
            from 'VLCTechHub <vlctechhub@gmail.com>'
            subject "Nueva oferta: #{job['title']}"

            html_part do
              content_type 'text/html; charset=UTF-8'
              body "<h1>#{job['title']}</h1>" +
                "<h3>#{job['company']['name']}</h3>" +
                "<pre>#{job['description']}</pre>" +
                "<p>Link: <a href='#{job['link']}'>#{job['link']}</a></p>"
            end
          end
        end

        def published(job)

          return false if job['contact_email'].to_s.empty?

          Mail.deliver do
            to job['contact_email']
            from 'VLCTechHub <vlctechhub@gmail.com>'
            subject "[VLCTECHHUB] Publicado: #{job['title']}"

            html_part do
              content_type 'text/html; charset=UTF-8'
              body "<h1>#{job['title']}</h1>" +
                "<pre>#{job['description']}</pre>" +
                "<p>Keywords: #{job['tags']}</p>" +
                "<p>Company Name: #{job['company']['name']}</p>" +
                "<p>Company Link: #{job['company']['link']}</p>" +
                "<p>Company Twitter: #{job['company']['twitter']}</p>" +
                "<p>Salary: #{job['salary']}</p>" +
                "<p>How to apply: #{job['how_to_apply']}</p>" +
                "<p>Contact: #{job['contact_email']}</p>" +
                "<p>Link: <a href='#{job['link']}'>#{job['link']}</a></p>" +
                "<p><a href='http://api.vlctechhub.org/v1/jobs/unpublish/#{job['publish_id']}/secret/#{job['secret']}'>Retirar Oferta</a></p>"
            end
          end
        end
      end
    end
  end
end
