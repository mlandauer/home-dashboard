FROM ruby:2.7

RUN apt-get update
RUN apt-get install -y nodejs

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

CMD ["dotenv", "smashing", "start"]

EXPOSE 3030
