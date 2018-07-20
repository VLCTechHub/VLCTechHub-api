require_relative 'base'
require 'dotenv/load'

require 'newrelic_rpm' if VLCTechHub.production?

require 'i18n'
I18n.enforce_available_locales = false

require 'mail'
Mail.defaults do
    delivery_method :smtp, {
      :address => 'smtp.sendgrid.net',
      :port => '587',
      :domain => 'heroku.com',
      :user_name => ENV['SENDGRID_USERNAME'],
      :password => ENV['SENDGRID_PASSWORD'],
      :authentication => :plain,
      :enable_starttls_auto => true
    }
end

require 'mongo'
Mongo::Logger.logger.level = ::Logger::FATAL unless VLCTechHub.development?
VLCTechHub.db_client = Mongo::Client.new(VLCTechHub.test? ? ENV['TEST_MONGODB_URI'] : ENV['MONGODB_URI'])
