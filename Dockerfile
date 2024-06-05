FROM ruby:3.1.6

RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get update -qq && apt-get install -y \
  nodejs \
  npm \
  postgresql-client \
  libpq-dev \
  curl \
  gnupg2 \
  build-essential \
  libxml2-dev \
  libxslt1-dev \
  libcurl4-openssl-dev \
  software-properties-common \
  imagemagick \
  libxmlsec1-dev \
  libidn11-dev \
  python \
  python2.7 && \
  npm install -g yarn@1.19.1

# Set working directory
WORKDIR /var/canvas

# Copy the application code
COPY . /var/canvas

# Set environment variables
ENV RAILS_ENV=production

COPY Gemfile Gemfile.lock package.json yarn.lock ./
COPY vendor ./vendor
COPY config ./config

RUN gem install bundler:2.5.10
RUN bundle install
RUN yarn install
RUN bundle exec rake canvas:compile_assets

# Copy configuration files
RUN cp config/dynamic_settings.yml.example config/dynamic_settings.yml && \
    cp config/database.yml.example config/database.yml && \
    cp config/domain.yml.example config/domain.yml && \
    cp config/outgoing_mail.yml.example config/outgoing_mail.yml && \
    cp config/security.yml.example config/security.yml

# Set up the database
RUN bundle exec rake db:initial_setup

# Expose port 3000 to the Docker host
EXPOSE 3000

# Start the application
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

