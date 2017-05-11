FROM ruby:2.3.1

RUN gem update --system 2.6.1 \
    && gem install bundler --version $BUNDLER_VERSION \

ENV app /app
RUN mkdir $app
WORKDIR $app

ADD . $app

EXPOSE 5000
