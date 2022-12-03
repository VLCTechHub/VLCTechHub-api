# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.6.5'

gem 'dotenv', '~> 2.7.5'
gem 'grape', '~> 1.2.4'
gem 'grape-entity', '~> 0.7.1'
gem 'mail', '~> 2.7.1'
gem 'mongo', '~> 2.10.2'
gem 'rack', '~> 2.0.7'
gem 'rack-cors', '~> 1.0.3'
gem 'rake', '~> 13.0.0'
gem 'ruby-clock', '~> 1.0.0'
gem 'twitter', '~> 6.2.0'

group :development, :test do
  gem 'prettier', '~> 0.15.0', require: false
  gem 'pry', '~> 0.12.2'
  gem 'rack-test', '~> 1.1.0'
  gem 'rerun', '~> 0.13.0'
  gem 'rspec', '~> 3.9.0'
  gem 'rubocop', '~> 0.75.0', require: false
  gem 'rubocop-rspec', '~> 1.36.0', require: false
end

group :production do
  gem 'newrelic_rpm', '~> 6.7.0.359'
  gem 'puma', '~> 4.2.1'
end
