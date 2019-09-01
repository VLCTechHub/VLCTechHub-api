FROM ruby:2.6.4

RUN gem update --system 3.0.6

ENV app /app
RUN mkdir $app
WORKDIR $app

COPY Gemfile Gemfile.lock $app/
RUN bundle install

COPY . $app/

ENV HOST=0.0.0.0
ENV RACK_ENV=production
ENV PORT=80

EXPOSE $PORT

CMD bundle exec puma -e $RACK_ENV -p $PORT
