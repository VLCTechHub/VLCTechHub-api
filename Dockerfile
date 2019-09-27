FROM ruby:2.6.4

RUN set set -ex \
  && curl -sL https://deb.nodesource.com/setup_10.x | bash - \
  && apt-get update -qq && apt-get install -qq --no-install-recommends \
       nodejs \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN gem update --system 3.0.6

ENV app /app
RUN mkdir $app
WORKDIR $app

COPY Gemfile Gemfile.lock $app/
RUN bundle install

COPY . $app/

ENV RACK_ENV=production
ENV PORT=80

EXPOSE $PORT

CMD bundle exec puma -C '-' -e $RACK_ENV -p $PORT
