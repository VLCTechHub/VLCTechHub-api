#!/bin/bash

cd /app

# Check if all the gems are installed. If not, installs the missing gems.
bundle check || bundle install

cp .env.docker .env

bundle exec rake build
bundle exec rake up
