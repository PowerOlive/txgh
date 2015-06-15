FROM ubuntu:trusty

RUN apt-get update
RUN apt-get install -y build-essential curl git libssl-dev
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN curl -sSL https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "source /etc/profile.d/rvm.sh && rvm install 1.9.3 && gem install bundler --no-rdoc --no-ri"
RUN mkdir /txgh
COPY Gemfile* /txgh/
RUN /bin/bash -l -c "cd txgh; bundle install; cd -"
COPY . /txgh
ENV RACK_ENV production

RUN mkdir /log
VOLUME [ "/log" ]
EXPOSE 8000
CMD cd txgh; bundle exec rackup -p 8000 config.ru >>/log/stdout.log 2>>/log/stderr.log
