FROM alpine:3.10.0

LABEL image="demyx/docker-compose"
LABEL maintainer="Demyx <info@demyx.sh>"
LABEL url="https://demyx.sh"
LABEL github="https://github.com/demyxco/demyx"
LABEL registry="https://hub.docker.com/u/demyx"

RUN echo 'http://dl-cdn.alpinelinux.org/alpine/latest-stable/community' >> /etc/apk/repositories; \
    apk --update --no-cache add py-pip dumb-init

RUN apk --no-cache add --virtual .build-deps python-dev libffi-dev openssl-dev gcc libc-dev make; \
	pip install docker-compose; \
	apk del .build-deps

ENTRYPOINT ["dumb-init", "docker-compose"]
