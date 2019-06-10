FROM node:alpine

LABEL image="demyx/browsersyc"
LABEL maintainer="Demyx <info@demyx.sh>"
LABEL url="https://demyx.sh"
LABEL github="https://github.com/demyxco/demyx"
LABEL registry="https://hub.docker.com/u/demyx"

RUN set -ex; \
    apk add --update --no-cache dumb-init; \
    npm -g install browser-sync; \
    mkdir -p /var/www/html

WORKDIR /var/www/html

EXPOSE 3000

ENTRYPOINT ["dumb-init", "browser-sync"]
