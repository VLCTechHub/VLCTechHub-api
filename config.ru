require 'rack/cors'

require_relative 'config/environment'
require_relative 'api'

use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: :any
  end
end

run VLCTechHub::API
