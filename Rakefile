require 'dotenv/tasks'
require './config/environment'

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

namespace :server do
  #desc "Start API server"
  task :up => :dotenv do
    trap ("SIGINT") do
      puts "\r\e[0KStopping ..."
      Rake::Task['server:down'].execute
    end
    system "bundle exec rackup -p $PORT -E $RACK_ENV"
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
    require 'mongo'
    # connect to source and target instances
    source = Mongo::MongoClient.from_uri(ENV['MASTER_MONGODB_URI'])
    target = Mongo::MongoClient.from_uri(ENV['MONGODB_URI'])
    # drop existing collections in target
    target.db['events'].drop
    # copy source into target, transforming data if necessary
    source.db['events'].find.each do |event|
      target.db['events'].insert(event)
    end
    # ensure indexes
    target.db['events'].ensure_index( { date: 1 } )
    target.db['events'].ensure_index( { date: -1 } )
  end
end

namespace :twitter do
  #dec "Tweet events scheduled today"
  task :tweet => :dotenv do
    require 'mongo'
    require 'twitter'
    require 'active_support/core_ext'
    db = Mongo::MongoClient.from_uri(ENV['MONGODB_URI']).db
    twitter = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
    end
    today_events = db['events'].find( { published: true, date: { :$gte => Time.now.utc, :$lte => 1.day.from_now.utc.midnight } } )
    today_tweets = today_events.map { |event| "Recordatorio: #{event['title']} hoy a las #{event['date'].in_time_zone("Madrid").strftime "%H:%M"} http://vlctechhub.org" }
    today_tweets.each { |tweet| twitter.update(tweet) }
  end
end

namespace :test do
  #desc "Prepare test environment"
  task :prepare => :dotenv do
    ENV['RACK_ENV'] = 'test'
    puts "Ensure the target database is up and running ..."
  end

  #desc "Run spec tests"
  task :spec => :'test:prepare' do
    system "bundle exec rspec --color --format progress"
  end
end
