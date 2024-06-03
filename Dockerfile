FROM ruby:3.1.6

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install -y nodejs

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN gem install bundler:2.5.10
RUN bundle plugin install bundler-multilock --path vendor/bundle
RUN bundle install
RUN npm install

COPY . .

# Make port 80 available to the world outside this container
EXPOSE 80

RUN mkdir ./hello/ && echo 'Hello, World!' >> ./hello/index.html

# Run app.rb when the container launches
CMD ["ruby", "-run -e httpd -- ./hello -p $PORT"]
