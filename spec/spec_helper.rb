# frozen_string_literal: true

require 'rspec'
require 'rack/test'

require_relative '../boot'

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
    mocks.verify_doubled_constant_names = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = 'spec/examples.txt'

  config.order = :random
  Kernel.srand config.seed
end

RSpec::Matchers.define :string_that_includes do |strings|
  match { |actual| strings.all? { |s| actual.include? s } }
end

Mail.defaults { delivery_method :test }
