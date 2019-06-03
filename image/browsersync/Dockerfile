FROM node:alpine

LABEL image="demyx/browsersyc"
LABEL maintainer="Demyx <info@demyx.sh>"
LABEL url="https://demyx.sh"
LABEL github="https://github.com/demyxco/demyx"
LABEL registry="https://hub.docker.com/u/demyx"

RUN npm -g install browser-sync; mkdir -p /var/www/html

WORKDIR /var/www/html

EXPOSE 3000

ENTRYPOINT ["browser-sync"]
