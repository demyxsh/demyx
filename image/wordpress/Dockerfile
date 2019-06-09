FROM wordpress:php7.3-fpm-alpine

LABEL image="demyx/wordpress"
LABEL maintainer="Demyx <info@demyx.sh>"
LABEL url="https://demyx.sh"
LABEL github="https://github.com/demyxco/demyx"
LABEL registry="https://hub.docker.com/u/demyx"

RUN set -ex \
    && apk add --no-cache --update --virtual .phpize-deps $PHPIZE_DEPS imagemagick-dev libtool \
    && export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" \
    && docker-php-ext-install exif sockets \
    && apk add --no-cache imagemagick dumb-init \
    && apk del .phpize-deps

ENTRYPOINT ["dumb-init"]

CMD ["docker-entrypoint.sh", "php-fpm"]
