# Use Heroku's official Ruby buildpack image as a parent image
FROM heroku/heroku:18-build

# Set environment variables
ENV LANG C.UTF-8
ENV RUBY_MAJOR 2.7
ENV RUBY_VERSION 2.7.4
ENV RUBY_DOWNLOAD_SHA256 3043099089608859fc8cce7f9fdccaa1f53a462457e3838ec3b25a7d609fbc5b
ENV RUBYGEMS_VERSION 3.2.22
ENV BUNDLER_VERSION 2.2.22

# Install Ruby
RUN set -ex \
    && buildDeps=' \
        bison \
        dpkg-dev \
        libgdbm-dev \
        ruby \
    ' \
    && apt-get update \
    && apt-get install -y --no-install-recommends $buildDeps \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fSL -o ruby.tar.gz "https://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.gz" \
    && echo "$RUBY_DOWNLOAD_SHA256 ruby.tar.gz" | sha256sum -c - \
    && mkdir -p /usr/src/ruby \
    && tar -xzf ruby.tar.gz -C /usr/src/ruby --strip-components=1 \
    && rm ruby.tar.gz \
    && cd /usr/src/ruby \
    && { echo '#define ENABLE_PATH_CHECK 0'; echo; cat file.c; } > file.c.new && mv file.c.new file.c \
    && autoconf \
    && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
    && ./configure --build="$gnuArch" --disable-install-doc --enable-shared \
    && make -j "$(nproc)" \
    && make install \
    && apt-get purge -y --auto-remove $buildDeps \
    && gem update --system "$RUBYGEMS_VERSION" \
    && gem install bundler --version "$BUNDLER_VERSION" --force \
    && rm -r /usr/src/ruby

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y nodejs

# Install app dependencies
COPY package.json ./
RUN npm install

# Install bundler-multilock plugin
RUN bundle plugin install bundler-multilock

# Set the working directory in the container to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in Gemfile
RUN bundle install

# Make port 80 available to the world outside this container
EXPOSE 80

# Define environment variable
ENV NAME World

# Run app.rb when the container launches
CMD ["ruby", "app.rb"]
