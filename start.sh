#!/bin/bash

cd /app

# Installs the missing gems.
bundle install

cp .env.docker .env

bundle exec rake up
