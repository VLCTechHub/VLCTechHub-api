FROM ruby:2.4.1

RUN gem update --system 2.6.12 \
    && gem install bundler --version $BUNDLER_VERSION

ENV app /app
RUN mkdir $app
WORKDIR $app

ADD . $app

EXPOSE 5000
