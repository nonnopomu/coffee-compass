FROM ruby:3.3-bookworm

RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev postgresql-client curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn

RUN gem install rails -v "~> 7.2"

WORKDIR /app
