# frozen_string_literal: true

require 'bundler/setup'

require 'rspec/core/rake_task'

require_relative 'config/environment'
require_relative 'lib/base/repository'
require_relative 'lib/twitter_client'
require_relative 'lib/event/repository'
require_relative 'lib/event/twitter'
require_relative 'lib/jobs'
require_relative 'lib/organizers'
require_relative 'lib/organizer_creator'

task default: :'server:up'

desc 'Set up the project environment'
task :setenv do
  puts 'Creating .env file...'
  cp '.env.example', '.env'
  puts 'Set up done!'
end

desc 'Start API server'
task up: :'server:up'

desc 'Stop API server'
task down: :'server:down'

desc 'Connect to database console'
task mongo: :'mongo:connect'

desc 'Tweet events scheduled today'
task tweet: :'twitter:tweet'

desc 'Run spec tests'
task test: :'test:run'

desc 'List API routes'
task :routes do
  require './boot'
  VLCTechHub::API::Boot.routes.each do |endpoint|
    next if endpoint.request_method.nil?

    method = endpoint.request_method.ljust(10)
    path = endpoint.path
    path.sub!(':version', endpoint.version) if endpoint.version
    puts "\t#{method} #{path}"
  end
end

namespace :server do
  def running_in_docker?
    system '[ -f /.dockerenv ]'
  end

  desc 'Start API server'
  task :up do
    unless running_in_docker?
      trap 'SIGINT' do
        puts "\r\e[0KStopping ..."
        Rake::Task['server:down'].execute
      end
    end
    system "bundle exec rerun --background 'rackup -p $PORT -E $RACK_ENV -o 0.0.0.0'"
  end

  desc 'Stop API server'
  task :down do
    system 'pkill -9 -f rackup'
  end
end

namespace :mongo do
  desc 'Connect to database shell'
  task :connect do
    require 'uri'
    uri = URI.parse(ENV['MONGODB_URI'])
    username = uri.user ? "-u #{uri.user}" : ''
    password = uri.password ? "-p #{uri.password}" : ''
    system "mongo #{username} #{password} #{uri.host}:#{uri.port}#{uri.path}"
  end

  desc 'Prepare database'
  task :prepare do
    require 'multi_json'
    require 'time'

    file = File.read('config/data/events.json')
    events = MultiJson.load(file)

    event_repo = VLCTechHub::Event::Repository.new
    puts 'Filling events collection...'
    event_repo.remove_all
    events.each do |event|
      event['date'] = DateTime.parse(event['date'] || DateTime.now.next_day.to_s)
      event_repo.insert(event)
    end
    event_repo.publish_all

    file = File.read('config/data/jobs.json')
    job_lines = MultiJson.load(file)

    jobs = VLCTechHub::Jobs.new
    puts 'Filling jobs collection...'
    jobs.remove_all
    job_lines.each do |job|
      job['date'] = DateTime.parse(job['date'] || DateTime.now.prev_month.next_day.to_s)
      jobs.insert(job)
    end
    jobs.publish_all

    file = File.read('config/data/organizers.json')
    lines = MultiJson.load(file)

    organizers = VLCTechHub::Organizers.new
    puts 'Filling organizers collection...'
    organizers.remove_all
    lines.each { |line| organizers.insert(line) }

    puts 'Finished!'
  end
end

namespace :twitter do
  desc 'Tweet events scheduled today'
  task :tweet do
    repo = VLCTechHub::Event::Repository.new
    twitter = VLCTechHub::Event::Twitter.new
    today_events = repo.find_today_events
    twitter.today(today_events)
  end
end

namespace :organizers do
  task :create do
    require 'multi_json'

    file = File.read('config/data/hashtag.json')
    handles = MultiJson.load(file)

    organizers = VLCTechHub::Organizers.new
    organizer_creator = VLCTechHub::OrganizerCreator.new

    organizers.remove_all
    handles.each do |handle|
      next unless handle.start_with?('@')

      organizer = organizer_creator.create(handle)
      organizers.insert organizer
    end
  end
end

namespace :test do
  VLCTechHub.environment = :test

  desc 'Prepare test environment'
  task :prepare do
    Rake::Task['mongo:prepare'].execute
  end

  desc 'Run spec tests'
  task :run, [:file] do |_t, _args|
    RSpec::Core::RakeTask.new(:spec) { |t| t.rspec_opts = '--color --format progress' }

    Rake::Task['spec'].execute
  end
end
