VLCTechHub API
==============

Public API for VLCTechHub

How to use it
-------------

 - Clone the project `git clone git@github.com:VLCTechHub/VLCTechHub-api.git`
 - Install ruby 2.3.0 (you might want to install it with [rbenv](https://www.digitalocean.com/community/tutorials/how-to-install-ruby-on-rails-with-rbenv-on-ubuntu-14-04))
 - Install mongo (optional, you can use a remote service)
 - Install bundle & run `bundle install`
 - Build the project with `bundle exec rake build`
 - Configure your mongo connection uris in `.env` (not necesary if you use local mongo with default values)
 - Run `bundle exec rake up`
 - Visit `http://localhost:5000`

How to restore dev database
----------------------------

 - Run `bundle exec rake mongo:prepare`


How to run the tests
---------------------

 - Run `bundle exec rake test`


How to use Docker containers for development
---------------------------------------------

 - Install [Docker Engine](https://docs.docker.com/engine/installation/) and [Docker Compose](https://docs.docker.com/compose/install/).
 - `cp .env.docker .env`
 - The first time you use it, you will need to build the containers: `docker-compose up`
 - To start the container, just use `docker-compose start`
 - Visit `http://localhost:5000`

How to run tests on Docker
--------------------------

`docker exec -it vlctechhubapi_web_1 bundle exec rake test`


--

[![Build Status](https://travis-ci.org/VLCTechHub/VLCTechHub-api.svg?branch=master)](https://travis-ci.org/VLCTechHub/VLCTechHub-api)


