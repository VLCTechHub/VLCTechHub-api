require 'mail'

module VLCTechHub
  	def self.send_mail_for_publication event

  		date = event[:date].utc - Time.zone_offset("+01:00")

  		Mail.deliver do
    		to ENV['EMAIL_FOR_PUBLICATION']
    		from 'VLCTechHub <vlctechhub@gmail.com>'
    		subject "[VLCTECHHUB] Publicar: #{event[:title]}"

		  	html_part do
		    	content_type 'text/html; charset=UTF-8'
		    	body "<h1>#{event[:title]}</h1>" +
		    		  "<pre>#{event[:description]}</pre>" +
		    		  "<h3>#{date.strftime "%Y-%m-%d %H:%M:%S"}</h3>" +
		    		  "<p>Link: <a href='#{event[:link]}'>#{event[:link]}</a></p>" +
		    		  "<p>Publicar: <a href='http://api.vlctechhub.org/v0/publish/#{event[:publish_id]}'>http://api.vlctechhub.org/v0/publish/#{event[:publish_id]}</a></p>"
		  	end
  		end
  	end
end
