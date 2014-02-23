require 'dotenv/tasks'

task :default => :'server:up'

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
