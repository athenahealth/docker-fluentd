FROM fluent/fluentd:v0.12.31

MAINTAINER Stas Alekseev <salekseev@athenahealth.com>

WORKDIR /home/fluent

ENV PATH /home/fluent/.gem/ruby/2.3.0/bin:$PATH

# Run as root for backwards compatibility
USER root

# Do not split this into multiple RUN!
# Docker creates a layer for every RUN-Statement
# therefore an 'apk delete build*' has no effect
RUN apk --no-cache --update add \
                            build-base \
                            geoip \
                            geoip-dev \
                            snappy \
                            snappy-dev \
                            ruby-dev && \
    gem install snappy && \
    gem install ruby-kafka -v 0.3.15 && \
    gem install fluent-plugin-rewrite-tag-filter -v 1.5.5 && \
    gem install fluent-plugin-string-scrub -v 0.1.0 && \
    gem install fluent-plugin-forest -v 0.3.0 && \
    gem install fluent-plugin-flatten-hash -v 0.4.0 && \
    gem install fluent-plugin-record-modifier -v 0.4.1 && \
    gem install fluent-plugin-kafka -v 0.4.1 && \
    gem install fluent-plugin-elasticsearch -v 1.5.0 && \
    gem install fluent-plugin-geoip -v 0.6.1 && \
    gem install fluent-plugin-flowcounter -v 0.4.1 && \
    gem install fluent-plugin-flowcounter-simple -v 0.0.4 && \
    gem install fluent-plugin-graphite -v 0.0.6 && \
    gem install fluent-plugin-multiprocess -v 0.2.0 && \
    apk del build-base ruby-dev geoip-dev snappy-dev && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /usr/lib/ruby/gems/*/cache/*.gem && \
    chown -R fluent:fluent /fluentd

EXPOSE 24220 24224

CMD fluentd -c /fluentd/etc/$FLUENTD_CONF -p /fluentd/plugins $FLUENTD_OPT
