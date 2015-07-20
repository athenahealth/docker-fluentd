FROM ruby:2.2.2

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.4
RUN apt-get update \
    && apt-get install -y \
        curl \
    && gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
  	&& curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
  	&& gpg --verify /usr/local/bin/gosu.asc \
  	&& rm /usr/local/bin/gosu.asc \
  	&& chmod +x /usr/local/bin/gosu \
    && apt-get clean \
    && apt-get autoremove -y \
        curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root
ADD Gemfile* /root/

RUN apt-get update \
    && apt-get install -y \
        libcurl4-openssl-dev \
        libjemalloc-dev \
    && echo "gem: --no-document --no-ri --no-rdoc\n" >> ~/.gemrc \
    && BUNDLE_GEMFILE=~/Gemfile bundle install --jobs 2 --system --binstubs --clean \
    && fluentd --setup /etc/fluent \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

ENV LD_PRELOAD /usr/lib/x86_64-linux-gnu/libjemalloc.so

VOLUME /etc/fluent
VOLUME /log

EXPOSE 514 1463 24220 24224

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["fluentd", "-c", "/etc/fluent/fluent.conf"]
