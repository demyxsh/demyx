#!/bin/bash

if [[ ! -d /var/www/html/wp-admin ]]; then
	echo "WordPress is missing, installing now."
	cp -R /usr/src/wordpress/* /var/www/html

	if [ "$WORDPRESS_DB_NAME" ] && [ "$WORDPRESS_DB_USER" ] && [ "$WORDPRESS_DB_PASSWORD" ] && [ "$WORDPRESS_DB_HOST" ]; then
		mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
		sed -i "s/database_name_here/$WORDPRESS_DB_NAME/g" /var/www/html/wp-config.php
		sed -i "s/username_here/$WORDPRESS_DB_USER/g" /var/www/html/wp-config.php
		sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/g" /var/www/html/wp-config.php
		sed -i "s/localhost/$WORDPRESS_DB_HOST/g" /var/www/html/wp-config.php 
		SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
		printf '%s\n' "g/put your unique phrase here/d" a "$SALT" . w | ed -s /var/www/html/wp-config.php
		sed -i "s/$table_prefix = 'wp_';/$table_prefix = 'wp_';\n\n\/\/ If we're behind a proxy server and using HTTPS, we need to alert Wordpress of that fact\n\/\/ see also http:\/\/codex.wordpress.org\/Administration_Over_SSL#Using_a_Reverse_Proxy\nif (isset($\_SERVER['HTTP_X_FORWARDED_PROTO']) \&\& $\_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {\n\t$\_SERVER['HTTPS'] = 'on';\n}\n/g" /var/www/html/wp-config.php
	fi
fi

if [[ -d /demyx ]]; then
    rm /etc/php7/php.ini
    rm /etc/php7/php-fpm.d/www.conf
    ln -s /demyx/php.ini /etc/php7
    ln -s /demyx/php-fpm.conf /etc/php7/php-fpm.d
fi

find /var/www/html -type d -print0 | xargs -0 chmod 0755
find /var/www/html -type f -print0 | xargs -0 chmod 0644
chown -R www-data:www-data /var/www/html

php-fpm -F
