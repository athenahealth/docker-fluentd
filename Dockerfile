FROM fluent/fluentd:v0.14.20-debian-onbuild

MAINTAINER Stas Alekseev <salekseev@athenahealth.com>

RUN buildDeps="sudo make gcc g++ libc-dev ruby-dev libsystemd-dev" \
 && apt-get update \
 && apt-get install -y --no-install-recommends libsystemd0 $buildDeps \
 && sudo gem install \
        fluent-plugin-systemd:0.3.0 \
        fluent-plugin-prometheus:0.3.0 \
        fluent-plugin-kafka:0.6.0 \
 && sudo gem sources --clear-all \
 && SUDO_FORCE_REMOVE=yes \
    apt-get purge -y --auto-remove \
                  -o APT::AutoRemove::RecommendsImportant=false \
                  $buildDeps \
 && rm -rf /var/lib/apt/lists/* \
           /home/fluent/.gem/ruby/2.3.0/cache/*.gem

EXPOSE 24231
