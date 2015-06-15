FROM ubuntu:trusty

RUN apt-get update
RUN apt-get install -y build-essential curl git libssl-dev ruby-full
RUN gem install bundler --no-rdoc --no-ri
RUN mkdir /txgh
COPY Gemfile* /txgh/
RUN cd txgh; bundle install; cd -
COPY . /txgh
ENV RACK_ENV production

RUN mkdir /log
VOLUME [ "/log" ]
EXPOSE 8000
CMD cd txgh; bundle exec rackup -p 8000 config.ru >>/log/stdout.log 2>>/log/stderr.log
