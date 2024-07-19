FROM ruby:3.0.0

ENV RAILS_ENV production
RUN mkdir /tarnishedcore-1
RUN bundle config mirror.https://rubygems.org https://gems.ruby-china.com
WORKDIR /tarnishedcore-1
ADD tarnishedcore-*.tar.gz ./
RUN bundle config set --local without 'development test'
RUN bundle install
ENTRYPOINT bundle exec puma
