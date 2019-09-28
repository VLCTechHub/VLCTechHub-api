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

# rubocop:disable Metrics/MethodLength
def build(type, attrs = {})
  case type
  when :event
    {
      title: 'Title',
      description: 'Description',
      link: 'https://some.url/event',
      hashtag: '#hashtag',
      date: DateTime.now + 1
    }
  when :job
    {
      title: 'Title',
      description: 'Description',
      link: 'https://some.url/job',
      company: { name: 'Name', link: 'https://some.url' },
      tags: %w[a_tag another_tag],
      how_to_apply: 'Apply',
      contact_email: 'some@email.com',
      salary: '123 €'
    }
  when :organizer
    {
      hashtag: '@organizer',
      name: 'organizer',
      description: 'Description',
      profile_image_small_url: 'https://some.url/small.png',
      profile_image_big_url: 'https://some.url/big.png',
      website: 'https://some.url'
    }
  else
    raise ArgumentError, "Unrecognized type '#{type}'"
  end
    .merge(attrs)
end
# rubocop:enable Metrics/MethodLength

def create(type, attrs = {})
  case type
  when :event
    VLCTechHub::Event::Repository
  when :job
    VLCTechHub::Job::Repository
  when :organizer
    VLCTechHub::Organizer::Repository
  else
    raise ArgumentError, "Unrecognized type '#{type}'"
  end
    .new
    .insert(build(type, attrs))
end

def build_list(type, size, attrs = {})
  size.times.map { |_| build(type, attrs) }
end

def create_list(type, size, attrs = {})
  size.times.map { |_| create(type, attrs) }
end
