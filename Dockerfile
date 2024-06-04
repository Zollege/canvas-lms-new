FROM ruby:3.1.6

WORKDIR /usr/src/app

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install -y nodejs

COPY Gemfile Gemfile.lock package.json yarn.lock ./
COPY vendors ./vendors

RUN gem install bundler:2.5.10
RUN bundle install
RUN npx yarn@1.19.1 install -y

COPY . .

# Make port 80 available to the world outside this container
EXPOSE 80

RUN mkdir ./hello/ && echo 'Hello, World!' >> ./hello/index.html

# Run app.rb when the container launches
CMD ["ruby", "-run -e httpd -- ./hello -p $PORT"]
