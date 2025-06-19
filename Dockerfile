FROM ruby:3.3

LABEL maintainer="tantrungse@gmail.com"

# Install Node.js and npm for TailwindCSS
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get update -yqq && apt-get install -yqq --no-install-recommends \
       nodejs

COPY Gemfile* /usr/src/app/
WORKDIR /usr/src/app

ENV BUNDLE_PATH=/gems

RUN bundle install

COPY . /usr/src/app/

CMD ["bin/rails", "s", "-b", "0.0.0.0"]
