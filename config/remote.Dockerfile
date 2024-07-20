FROM ruby:3.0.0

ENV RAILS_ENV=production
RUN mkdir /tarnishedcore-1
RUN bundle config mirror.https://rubygems.org https://gems.ruby-china.com
WORKDIR /tarnishedcore-1
ADD Gemfile /tarnishedcore-1
ADD Gemfile.lock /tarnishedcore-1
ADD vendor/cache /tarnishedcore-1/vendor/cache
RUN bundle config set --local without 'development test'
RUN bundle install --local

ADD tarnishedcore-*.tar.gz ./
ENTRYPOINT bundle exec puma