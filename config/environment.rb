# default to Mongolab instance is explicit URI is not provided
ENV['MONGODB_URI'] ||= ENV['MONGOLAB_URI']

