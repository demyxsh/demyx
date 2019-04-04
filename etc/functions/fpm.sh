#!/bin/bash
# Demyx
# https://github.com/demyxco/demyx

CONTAINER_PATH=$1
DOMAIN=$2
FORCE=$3

if [ -f "$CONTAINER_PATH"/conf/fpm-php.conf ]; then
	NO_UPDATE=$(grep -r "AUTO GENERATED" "$CONTAINER_PATH"/conf/php-fpm.conf)
	[[ -z "$NO_UPDATE" ]] && [[ -z "$FORCE" ]] && echo -e "\e[33m[WARNING] Skipped php-fpm.conf\e[39m" && exit 1
fi

cat > "$CONTAINER_PATH"/conf/php-fpm.conf <<-EOF
; AUTO GENERATED
; To override, see demyx -h

error_log = /var/log/demyx/$DOMAIN.error.log
log_level = warning

[$DOMAIN]
user = www-data
group = www-data
listen = 9000

pm = ondemand
pm.max_children = 75
pm.process_idle_timeout = 10s
pm.max_requests = 500
chdir = /var/www/html
php_admin_value[openssl.cafile] = /etc/ssl/certs/ca-certificates.crt
php_admin_value[openssl.capath] = /etc/ssl/certs
php_admin_value[max_input_nesting_level] = 256
catch_workers_output = yes
EOF

echo -e "\e[32m[SUCCESS] Generated php-fpm.conf\e[39m"