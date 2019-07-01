FROM node:alpine

LABEL sh.demyx.image demyx/browsersync
LABEL sh.demyx.maintainer Demyx <info@demyx.sh>
LABEL sh.demyx.url https://demyx.sh
LABEL sh.demyx.github https://github.com/demyxco/demyx
LABEL sh.demyx.registry https://hub.docker.com/u/demyx

RUN set -ex; \
    apk add --update --no-cache dumb-init; \
    npm -g install browser-sync; \
    mkdir -p /var/www/html

WORKDIR /var/www/html

EXPOSE 3000

ENTRYPOINT ["dumb-init", "browser-sync"]
