# frozen_string_literal: true

require 'rack/cors'

require_relative 'boot'

use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: :any
  end
end

run VLCTechHub::API::Boot
