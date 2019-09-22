# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.6.4'

gem 'dotenv', '~> 2.7.5'
gem 'grape', '~> 1.2.4'
gem 'grape-entity', '~> 0.7.1'
gem 'mail', '~> 2.7.1'
gem 'mongo', '~> 2.10.1'
gem 'rack', '~> 2.0.7'
gem 'rack-cors', '~> 1.0.3'
gem 'rake', '~> 12.3.3'
gem 'twitter', '~> 6.2.0'

group :development, :test do
  gem 'prettier', '~> 0.13.0', require: false
  gem 'pry', '~> 0.12.2'
  gem 'rack-test', '~> 1.1.0'
  gem 'rerun', '~> 0.13.0'
  gem 'rspec', '~> 3.8.0'
  gem 'rubocop', '~> 0.74.0', require: false
  gem 'rubocop-rspec', '~> 1.35.0', require: false
end

group :production do
  gem 'newrelic_rpm', '~> 6.5.0.357'
  gem 'puma', '~> 4.1.0'
end
