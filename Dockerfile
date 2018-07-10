FROM ruby:2.6.4

RUN gem update --system 3.0.6

ENV app /app
RUN mkdir $app
WORKDIR $app

ADD . $app

EXPOSE 5000
