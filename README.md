To build it run:
```
docker build --tag=athenahealth/fluentd:latest .
```

To start it run (where /etc/fluent is config location and /var/log is
log destination on the host):
```
docker run -it -v /etc/fluent:/etc/fluent -v /var/log:/log athenahealth/fluentd:latest
```

[![Docker Repository on Quay.io](https://quay.io/repository/athenahealth/fluentd/status "Docker Repository on Quay.io")](https://quay.io/repository/athenahealth/fluentd)