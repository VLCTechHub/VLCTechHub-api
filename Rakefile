require 'dotenv/tasks'

task :default => :'server:up'

task :start => :'server:up'
task :stop => :'server:down'

task :test => :'test:spec'

namespace :server do
  desc "Run API server"
  task :up => :dotenv do
    trap ("SIGINT") do
      puts "\r\e[0KStopping ..."
      Rake::Task['server:down'].execute
    end
    system "bundle exec rackup -p $PORT -E $RACK_ENV"
  end

  desc "Stop API server"
  task :down do
    system "pkill -9 -f rackup"
  end
end

namespace :mongo do
  desc "Update data from master database"
  task :update => :dotenv do
    require 'uri'
    require 'time'
    require 'mongo'
    # connect to source and target instances
    source = Mongo::MongoClient.from_uri(ENV['MASTER_MONGODB_URI'])
    target = Mongo::MongoClient.from_uri(ENV['MONGODB_URI'])
    # drop existing target
    target.db['events'].drop
    # copy the source into the target and update event dates to include event times
    source.db['events'].find.each do |event|
      date = event['date'].to_s[0..9]
      time = event['time']
      event['date'] = Time.parse("#{date} #{time} +0100").utc
      target.db['events'].insert(event)
    end
  end
end

namespace :test do
  desc "Prepare test environment"
  task :prepare => :dotenv do
    ENV['RACK_ENV'] = 'test'
    puts "Ensure the target database is up and running ..."
  end
  desc "Run spec tests"
  task :spec => :'test:prepare' do
    system "bundle exec rspec --color --format progress"
  end
end
