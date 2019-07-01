#!/bin/bash

if [[ ! -d /var/www/html/mod ]]; then
	echo "Elgg is missing, installing now."
	cp -R /usr/src/elgg/* /var/www/html
fi

sed -i "s/ELGG_DOMAIN/$ELGG_DOMAIN/g" /etc/nginx/nginx.conf

find /var/www/html -type d -print0 | xargs -0 chmod 0755
find /var/www/html -type f -print0 | xargs -0 chmod 0644
chown -R www-data:www-data /var/www/html

php-fpm -D
nginx -g 'daemon off;'
