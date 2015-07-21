FROM ruby:2.2.2

WORKDIR /root
ADD Gemfile /root/Gemfile
ADD Gemfile.lock /root/Gemfile.lock

RUN apt-get update \
    && apt-get install -y \
        libcurl4-openssl-dev \
        libjemalloc-dev \
    && echo "gem: --no-document --no-ri --no-rdoc\n" >> ~/.gemrc \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

RUN bundle install --jobs 2 --system --binstubs --clean \
    && fluentd --setup /etc/fluent

ENV LD_PRELOAD /usr/lib/x86_64-linux-gnu/libjemalloc.so

VOLUME /etc/fluent
VOLUME /log

EXPOSE 514 1463 24220 24224

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["fluentd", "-c", "/etc/fluent/fluent.conf"]
