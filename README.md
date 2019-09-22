[![Build Status](https://travis-ci.org/VLCTechHub/VLCTechHub-api.svg?branch=master)](https://travis-ci.org/VLCTechHub/VLCTechHub-api)

# VLCTechHub API

Public API for VLCTechHub

## How to use it

- Clone the project `git clone git@github.com:VLCTechHub/VLCTechHub-api.git`
- Install Ruby 2.6.4 (you might want to install it with [rbenv](https://github.com/rbenv/rbenv))
- Install MongoDB (optional, you can use a remote service)
- Install dependencies by running `bundle install`
- Create a local `.env` file from the included `.env.example` file
- Configure your mongo connection uris (not necesary if you use local mongo with default values) and optionally the rest of environment values in the `.env` file
- Run `bundle exec rake up`
- Visit `http://localhost:5000`

### How to restore the dev database

- Run `bundle exec rake mongo:prepare`

### How to run the tests

- Run `bundle exec rake test`

### How to run the linters

The project is configured to use Rubocop checks and Prettier for Ruby autoformatter.

- For Rubocop linting run `bundle exec rubocop`
- For Prettier for Ruby format check run `bundle exec rbprettier -c '**/*.rb'`

To simplify the linting checks it is advisable to configure both linters extensions in your code editor of choice.

## How to use Docker containers for development

- Install [Docker Engine](https://docs.docker.com/install/) and [Docker Compose](https://docs.docker.com/compose/install/).
- The first time you use it, you will need to build the app containers: `docker-compose build`
- Optionally, create a local `.env` file for the environment values without default values in the `docker-compose.yml` file
- To start the containers, just use `docker-compose up`
- Visit `http://localhost:5000`

### How to restore the dev database on Docker

- With the containers running, execute `docker-compose exec api bundle exec rake mongo:prepare`

### How to run the tests on Docker

- With the containers running, execute `docker-compose exec api bundle exec rake test`

### How to run the linters

The project is configured to use Rubocop checks and Prettier for Ruby autoformatter.

- For Rubocop, with the containers running, execute `docker-compose exec api bundle exec rubocop`
- For Prettier for Ruby, with the containers running, execute `docker-compose exec api bundle exec rbprettier -c '**/*.rb'`
