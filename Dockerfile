FROM ubuntu:trusty

RUN apt-get update
RUN apt-get install -y build-essential curl git libssl-dev
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN curl -sSL https://get.rvm.io | bash -s stable
ENV PATH /usr/local/rvm/gems/ruby-1.9.3-p551/wrappers:/usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN rvm requirements
RUN rvm install ruby-1.9.3
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
