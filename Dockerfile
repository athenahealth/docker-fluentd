FROM fluent/fluentd:v0.12.28-onbuild

MAINTAINER your_name <...>

USER fluent

WORKDIR /home/fluent

ENV PATH /home/fluent/.gem/ruby/2.3.0/bin:$PATH

# Do not split this into multiple RUN!
# Docker creates a layer for every RUN-Statement
# therefore an 'apk delete build*' has no effect
RUN apk --no-cache --update add \
                            build-base \
                            geoip \
                            ruby-dev && \
    gem install oj -v 2.17.1 && \
    gem install snappy -v 0.0.15 && \
    gem install string-scrub -v 0.0.5 && \
    gem install fluent-plugin-forest -v 0.3.0 && \
    gem install fluent-plugin-flatten-hash -v 0.4.0 && \
    gem install fluent-plugin-record-modifier -v 0.4.1 && \
    gem install fluent-plugin-kafka -v 0.3.0.rc1 && \
    gem install fluent-plugin-elasticsearch -v 1.5.0 && \
    gem install fluent-plugin-geoip -v 0.6.1 && \
    gem install fluent-plugin-flowcounter -v 0.4.1 && \
    gem install fluent-plugin-flowcounter-simple -v 0.0.4 && \
    gem install fluent-plugin-graphite -v 0.0.6 && \
    gem install fluent-plugin-multiprocess -v 0.2.0 && \
    apk del build-base ruby-dev && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

EXPOSE 24284

CMD fluentd -c /fluentd/etc/$FLUENTD_CONF -p /fluentd/plugins $FLUENTD_OPT
