FROM alpine:3.10.0

LABEL image="demyx/logrotate"
LABEL maintainer="Demyx <info@demyx.sh>"
LABEL url="https://demyx.sh"
LABEL github="https://github.com/demyxco/demyx"
LABEL registry="https://hub.docker.com/u/demyx"

RUN set -ex; \
	apk add --no-cache --update logrotate tzdata dumb-init
    
COPY demyx.conf /etc/logrotate.d

COPY demyx-entrypoint.sh /usr/local/bin/demyx-entrypoint

RUN chmod +x /usr/local/bin/demyx-entrypoint

WORKDIR /var/log/demyx

ENTRYPOINT ["dumb-init", "demyx-entrypoint"]

