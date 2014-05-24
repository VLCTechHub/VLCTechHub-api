VLCTechHub API
==============

Public API for VLCTechHub


Env variables
-------------

Create a .env file and fill this variables with propiate values:

 - RACK_ENV=development
 - PORT=5000
 - MONGODB_URI=mongo uri for the development db (heroku will have the production uri)
 - MASTER_MONGODB_URI=uri for the master db to populate the development one from (useful for testing purposes)
 - SENDGRID_PASSWORD=password for sendgrid
 - SENDGRID_USERNAME=user of sendgrid (created from heroku)
 - EMAIL_FOR_PUBLICATION=email address of the person responsible for publication (admin)
 - EMAIL_FOR_BROADCAST=email address of the broadcasting list (googlegroups). Leave empty if you don't want to broadcast it after publication
 - TWITTER_CONSUMER_KEY=API key for the twitter app used to interact with the twitter API
 - TWITTER_CONSUMER_SECRET=API secret for the twitter app used to interact with the twitter API
 - TWITTER_ACCESS_TOKEN=access token needed to make requests on your twitter account behalf
 - TWITTER_ACCESS_SECRET=access token secret needed to make requests on your twitter account behalf
