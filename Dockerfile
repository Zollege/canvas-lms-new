FROM ruby:3.1.6

WORKDIR /usr/src/app

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install -y nodejs

COPY Gemfile Gemfile.lock package.json yarn.lock ./
COPY vendor ./vendor
COPY config ./config

RUN gem install bundler:2.5.10
RUN bundle install
RUN npx yarn@1.19.1 install -y

COPY . .

# Make port 80 available to the world outside this container
# Expose port 3000 to the outside world
EXPOSE 3000

# The command to run the application when the Docker container starts
CMD ["rails", "server", "-b", "0.0.0.0"]
