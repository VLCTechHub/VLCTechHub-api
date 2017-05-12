require 'bundler/setup'
require 'dotenv/tasks'
require 'rspec/core/rake_task'

require_relative 'config/environment'
require_relative 'app/base/repository'
require_relative 'app/twitter_client'
require_relative 'app/event/repository'
require_relative 'app/event/twitter'
require_relative 'app/jobs'
require_relative 'app/organizers'
require_relative 'app/organizer_creator'

task :default => :'server:up'

desc "Build the project"
task :build do
  puts 'Creating .env file...'
  cp '.env.example', '.env'
  puts 'Build done!'
end

desc "Start API server"
task :up => :'server:up'

desc "Stop API server"
task :down => :'server:down'

desc "Connect to database console"
task :mongo => :'mongo:connect'

desc "Tweet events scheduled today"
task :tweet => :'twitter:tweet'

desc "Run spec tests"
task :test => :'spec:run'

desc "List API routes"
task :routes do
  require './boot'
  VLCTechHub::API::Boot.routes.each do |endpoint|
    next if endpoint.route_method.nil?
    method = endpoint.route_method.ljust(10)
    path = endpoint.route_path
    if endpoint.route_version
      path.sub!(":version", endpoint.route_version)
    end
    puts "\t#{method} #{path}"
  end
end

namespace :server do
  #desc "Start API server"
  task :up => :dotenv do
    trap ("SIGINT") do
      puts "\r\e[0KStopping ..."
      Rake::Task['server:down'].execute
    end
    system "bundle exec rerun 'rackup -p $PORT -E $RACK_ENV -o 0.0.0.0'"
  end
  #desc "Stop API server"
  task :down do
    system "pkill -9 -f rackup"
  end
end

namespace :mongo do
  #desc "Connect to database shell"
  task :connect => :dotenv do
    require 'uri'
    uri = URI.parse(ENV['MONGODB_URI'])
    username = uri.user ? "-u #{uri.user}" : ""
    password = uri.password ? "-p #{uri.password}" : ""
    system "mongo #{username} #{password} #{uri.host}:#{uri.port}#{uri.path}"
  end

  desc "Prepare database"
  task :prepare => :dotenv do
    require 'multi_json'
    require 'time'

    file = File.read('config/data/events.json')
    events = MultiJson.load(file)

    event_repo = VLCTechHub::Event::Repository.new
    puts 'Filling events collection...'
    event_repo.remove_all
    events.each do |event|
      event["date"] = DateTime.parse(event["date"] || DateTime.now.next_day.to_s)
      event_repo.insert(event)
    end
    event_repo.publish_all

    file = File.read('config/data/jobs.json')
    job_lines = MultiJson.load(file)

    jobs = VLCTechHub::Jobs.new
    puts 'Filling jobs collection...'
    jobs.remove_all
    job_lines.each do |job|
      job["date"] = DateTime.parse(job['date'] || DateTime.now.prev_month.next_day.to_s)
      jobs.insert(job)
    end
    jobs.publish_all

    file = File.read('config/data/organizers.json')
    lines = MultiJson.load(file)

    organizers = VLCTechHub::Organizers.new
    puts 'Filling organizers collection...'
    organizers.remove_all
    lines.each do |line|
      organizers.insert(line)
    end

    puts 'Finished!'
  end
end

namespace :twitter do
  #dec "Tweet events scheduled today"
  task :tweet => :dotenv do
    repo = VLCTechHub::Event::Repository.new
    twitter = VLCTechHub::Event::Twitter.new
    today_events = repo.find_today_events
    twitter.today(today_events)
  end
end


namespace :organizers do
  task :create => :dotenv do
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


namespace :spec do
  desc "Prepare test environment"
  task :prepare => :dotenv do
    VLCTechHub.environment = :test
    puts "Ensure the target database is up and running ..."
  end

  desc "Run spec tests"
  task :run, [:file] => [:prepare, 'mongo:prepare'] do |t, args|
    RSpec::Core::RakeTask.new(:spec) do |t|
      t.rspec_opts = "--color --format progress"
    end

    Rake::Task['spec'].execute
  end
end
