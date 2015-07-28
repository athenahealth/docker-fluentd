FROM quay.io/athenahealth/ruby:2.1.6

# install things globally, for great justice
ENV GEM_HOME /usr/local/bundle
ENV PATH /root/bin:$GEM_HOME/bin:$PATH

ENV BUNDLER_VERSION 1.10.6
# don't create ".bundle" in all our apps
ENV BUNDLE_APP_CONFIG $GEM_HOME

WORKDIR /root
ADD Gemfile /root/Gemfile
ADD Gemfile.lock /root/Gemfile.lock

RUN yum -y --color=never install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
    && yum -y --color=never clean all
    
RUN yum -y --color=never clean all \
    && yum -y --color=never --enablerepo ol7_optional_latest install \
         gcc \
         gcc-c++ \
         make \
         patch \
         file \
         libicu-devel \
         zlib-devel \
         libyaml-devel \
         libxml2 \
         libxml2-devel \
         libxslt \
         libxslt-devel \
         git \
         tar \
         bzip2 \
         jemalloc \
         jemalloc-devel \
         GeoIP \
         GeoIP-devel \
    && gem install bundler --version "$BUNDLER_VERSION" \
    && bundle config --global path "$GEM_HOME" \
    && bundle config --global bin "$GEM_HOME/bin" \
    && bundle config build.nokogiri --use-system-libraries \
    && bundle install --jobs 2 --system --binstubs --clean \
    && find $GEM_HOME -type f | xargs file | grep 'not stripped' | awk '{ print $1 }' | cut -d: -f1 | xargs strip -g -S -d --strip-debug \
    && fluentd --setup /etc/fluent \
    && yum -y --color=never autoremove \
         gcc \
         gcc-c++ \
         patch \
         file \
         libicu-devel \
         libyaml-devel \
         zlib-devel \
         libxml2-devel \
         libxslt-devel \
         git \
         tar \
         bzip2 \
         jemalloc-devel \
         GeoIP-devel \
    && yum -y --color=never clean all

ENV LD_PRELOAD /usr/lib64/libjemalloc.so.1

VOLUME /etc/fluent
VOLUME /log

EXPOSE 514 1463 24220 24224

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["fluentd", "-c", "/etc/fluent/fluent.conf"]
