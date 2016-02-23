VLCTechHub API
==============

Public API for VLCTechHub

How to use it
-------------

 - Clone the project `git clone git@github.com:VLCTechHub/VLCTechHub-api.git`
 - Install ruby 2.2.3 (you might want to install it with [rbenv](https://www.digitalocean.com/community/tutorials/how-to-install-ruby-on-rails-with-rbenv-on-ubuntu-14-04))
 - Install mongo (optional, you can use a remote service)
 - Install bundle & run `bundle install`
 - Build the project with `bundle exec rake build`
 - Configure your mongo connection uris in `.env` (not necesary if you use local mongo with default values)
 - Run `bundle exec rake up`
 - Visit `http://localhost:5000`

How to restore dev database
----------------------------

 - Run `rake mongo:prepare`


How to run the tests
---------------------

 - Run `rake test`


--

[![Build Status](https://travis-ci.org/VLCTechHub/VLCTechHub-api.svg?branch=master)](https://travis-ci.org/VLCTechHub/VLCTechHub-api)


