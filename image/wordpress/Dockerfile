FROM alpine:3.10.1

LABEL sh.demyx.image demyx/wordpress
LABEL sh.demyx.maintainer Demyx <info@demyx.sh>
LABEL sh.demyx.url https://demyx.sh
LABEL sh.demyx.github https://github.com/demyxco/demyx
LABEL sh.demyx.registry https://hub.docker.com/u/demyx

RUN set -ex; \
    addgroup -g 82 -S www-data; \
    adduser -u 82 -D -S -G www-data www-data; \
    apk add --no-cache php7 \
    php7-bcmath \
    php7-ctype \
	php7-curl \
	php7-dom \
	php7-exif \
    php7-fileinfo \
    php7-fpm \
	php7-ftp \
	php7-gd \
	php7-iconv \
	php7-imagick \
	php7-json \
	php7-mbstring \
	php7-mysqli \
    php7-opcache \
	php7-openssl \
    php7-pecl-ssh2 \
    php7-phar \
	php7-posix \
    php7-session \
	php7-simplexml \
    php7-soap \
    php7-sodium \
	php7-sockets \
	php7-tokenizer \
	php7-xml \
	php7-xmlreader \
    php7-xmlwriter \
    php7-zip \
	php7-zlib

RUN set -ex; \
	apk add --no-cache ed dumb-init bash tzdata libsodium; \
    ln -s /usr/sbin/php-fpm7 /usr/local/bin/php-fpm; \
    mkdir -p /var/log/demyx

ENV WORDPRESS_VERSION 5.2.2
ENV WORDPRESS_SHA1 3605bcbe9ea48d714efa59b0eb2d251657e7d5b0

RUN set -ex; \
	apk add --no-cache --virtual .wp-deps curl; \
	mkdir -p /usr/src; \
	mkdir -p /var/www/html; \
	curl -o wordpress.tar.gz -fSL "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz"; \
	echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c -; \
	tar -xzf wordpress.tar.gz -C /usr/src/; \
	rm wordpress.tar.gz; \
	chown -R www-data:www-data /usr/src/wordpress; \
	apk del .wp-deps && rm -rf /var/cache/apk/*

COPY demyx-entrypoint.sh /usr/local/bin/demyx-entrypoint
COPY php.ini /etc/php7/php.ini
COPY www.conf /etc/php7/php-fpm.d/www.conf
COPY docker.conf /etc/php7/php-fpm.d/docker.conf

RUN chmod +x /usr/local/bin/demyx-entrypoint

EXPOSE 9000

WORKDIR /var/www/html

ENTRYPOINT ["dumb-init", "demyx-entrypoint"]
