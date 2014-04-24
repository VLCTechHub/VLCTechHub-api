VLCTechHub API
==============

Public API for VLCTechHub


Env variables
-------------

Create a .env file and fill this variables with propiate values:

 - RACK_ENV=development
 - PORT=5000
 - MONGODB_URI=mongo uri for testing db (heroku will have the production uri)
 - MASTER_MONGODB_URI=used for migrating to new version of database. Not used anymore.
 - SENDGRID_PASSWORD=password for sendgrid
 - SENDGRID_USERNAME=user of sendgrid (created from heroku)
 - EMAIL_FOR_PUBLICATION=email address of the person responsible for publication (admin)
 - EMAIL_FOR_BROADCAST=email address of the broadcasting list (googlegroups). Leave empty if you don't want to broadcast it after publication