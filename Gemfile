# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.1.3'

gem 'dotenv', '~> 2.8.1'
gem 'grape', '~> 1.6.2'
gem 'grape-entity', '~> 0.10.2'
gem 'mail', '~> 2.8.0'
gem 'mongo', '~> 2.18.1'
gem 'rack', '~> 3.0.1'
gem 'rack-cors', '~> 1.1.1'
gem 'rake', '~> 13.0.6'
gem 'ruby-clock', '~> 1.0.0'
gem 'twitter', '~> 7.0.0'

group :development, :test do
  gem 'pry', '~> 0.14.1'
  gem 'rack-test', '~> 2.0.2'
  gem 'rackup', '~> 0.2.3'
  gem 'rerun', '~> 0.13.1'
  gem 'rspec', '~> 3.12.0'
  gem 'rubocop', '~> 1.39.0', require: false
  gem 'rubocop-rspec', '~> 2.15.0', require: false
  gem 'syntax_tree', '~> 5.0.1', require: false
end

group :production do
  gem 'newrelic_rpm', '~> 8.13.1'
  gem 'puma', '~> 6.0.0'
end
