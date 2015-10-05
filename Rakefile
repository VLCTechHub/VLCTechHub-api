require 'bundler/setup'
require 'dotenv/tasks'

require_relative 'config/environment'
require_relative 'api/repository'
require_relative 'api/twitter'

task :default => :'server:up'

desc "Start API server"
task :start => :'server:up'

desc "Stop API server"
task :stop => :'server:down'

desc "Connect to database console"
task :mongo => :'mongo:connect'

desc "Tweet events scheduled today"
task :tweet => :'twitter:tweet'

desc "Run spec tests"
task :test => :'test:spec'

desc "List API routes"
task :routes do
  require './api'
  VLCTechHub::API.routes.each do |endpoint|
    method = endpoint.route_method.ljust(10)
    path = endpoint.route_path
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
    system "bundle exec rerun 'rackup -p $PORT -E $RACK_ENV'"
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

  desc "Update data from master database"
  task :update => :dotenv do
    abort "Not to be run in production!!" if VLCTechHub.production?
    require 'mongo'
    # connect to source and target instances
    source = Mongo::Client.new(ENV['MASTER_MONGODB_URI'])
    target = Mongo::Client.new(ENV['MONGODB_URI'])
    # drop existing collections in target
    target['events'].drop
    # copy source into target, transforming data if necessary
    source['events'].find.each do |event|
      target['events'].insert_one(event)
    end
    # ensure indexes
    target['events'].indexes.create_many([
      { :key => { date: 1 }},
      { :key => { date: -1 }}
    ])
  end
end

namespace :twitter do
  #dec "Tweet events scheduled today"
  task :tweet => :dotenv do
    repo = VLCTechHub::Repository.new
    twitter = VLCTechHub::Twitter.new
    today_events = repo.find_today_events
    twitter.tweet_today_events(today_events)
  end
end

namespace :test do
  #desc "Prepare test environment"
  task :prepare => :dotenv do
    VLCTechHub.environment = :test
    puts "Ensure the target database is up and running ..."
  end

  #desc "Run spec tests"
  task :spec => :'test:prepare' do
    system "bundle exec rspec --color --format progress"
  end
end
