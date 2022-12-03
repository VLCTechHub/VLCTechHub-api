FROM ruby:3.1.3

RUN set set -ex \
  && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
  && apt-get update -qq && apt-get install -y -qq --no-install-recommends \
       nodejs \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN gem update --system 3.3.26

ENV app /app
RUN mkdir $app
WORKDIR $app

COPY Gemfile Gemfile.lock $app/
RUN bundle install

COPY . $app/

ENV RACK_ENV=production
ENV PORT=8080

EXPOSE $PORT

CMD bundle exec puma -C '-' -e $RACK_ENV -p $PORT
