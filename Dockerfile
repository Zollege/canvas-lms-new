# Use Ubuntu as a parent image
FROM ubuntu:20.04

# Set environment variables
ENV LANG C.UTF-8
ENV RUBY_MAJOR 2.7
ENV RUBY_VERSION 2.7.4
ENV RUBY_DOWNLOAD_SHA256 3043099089608859fc8cce7f9fdccaa1f53a462457e3838ec3b25a7d609fbc5b
ENV RUBYGEMS_VERSION 3.2.22
ENV BUNDLER_VERSION 2.2.22

# Install dependencies
RUN apt-get update && apt-get install -y curl gnupg build-essential libssl-dev libreadline-dev zlib1g-dev

# Install Ruby
RUN curl -sSL https://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.gz | tar -xz \
    && cd ruby-$RUBY_VERSION \
    && ./configure --disable-install-doc \
    && make \
    && make install \
    && gem update --system "$RUBYGEMS_VERSION" \
    && gem install bundler --version "$BUNDLER_VERSION" --force

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs

# Set the working directory in the container to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in Gemfile and package.json
RUN bundle plugin install bundler-multilock
RUN bundle install
RUN npm install

# Make port 80 available to the world outside this container
EXPOSE 80

# Define environment variable
ENV NAME World

# Run app.rb when the container launches
CMD ["ruby", "app.rb"]
