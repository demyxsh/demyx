#!/bin/bash
# Demyx
# https://github.com/demyxco/demyx

source /srv/demyx/etc/.env
CONTAINER_PATH=$1
FORCE=$2
SSL=$3
DEV=$4

if [ -f "$CONTAINER_PATH"/docker-compose.yml ]; then
  NO_UPDATE=$(grep -r "AUTO GENERATED" "$CONTAINER_PATH"/docker-compose.yml)
  [[ -z "$NO_UPDATE" ]] && [[ -z "$FORCE" ]] && echo -e "\e[33m[WARNING]\e[39m Skipped docker-compose.yml" && exit 1
fi

source "$CONTAINER_PATH"/.env

if [ "$SSL" = "on" ]; then
  SERVER_IP=$(curl -s https://ipecho.net/plain)
  SUBDOMAIN_CHECK=$(/usr/bin/dig +short "$DOMAIN" | sed -e '1d')  
  if [ -n "$SUBDOMAIN_CHECK" ]; then
    DOMAIN_IP=$SUBDOMAIN_CHECK
  else
    DOMAIN_IP=$(/usr/bin/dig +short "$DOMAIN")
  fi

  if [ "$SERVER_IP" != "$DOMAIN_IP" ]; then
    echo -e "\e[33m[WARNING]\e[39m $DOMAIN does not point to server's IP! Proceeding without SSL..."
  else
    PROTOCOL="- \"traefik.frontend.redirect.entryPoint=https\"
      - \"traefik.frontend.headers.forceSTSHeader=\${FORCE_STS_HEADER}\"
      - \"traefik.frontend.headers.STSSeconds=\${STS_SECONDS}\"
      - \"traefik.frontend.headers.STSIncludeSubdomains=\${STS_INCLUDE_SUBDOMAINS}\"
      - \"traefik.frontend.headers.STSPreload=\${STS_PRELOAD}\""
  fi
fi

#if [ "$DEV" = on ]; then
#  WP_MOUNT="./data"
#  WP_DISABLE_OPCACHE="- /dev/null:/usr/local/etc/php/conf.d/docker-php-ext-opcache.ini"
#else
  WP_MOUNT="wp_${WP_ID}"
  WP_VOLUME="wp_${WP_ID}:
    name: wp_${WP_ID}"
#fi

cat > "$CONTAINER_PATH"/docker-compose.yml <<-EOF
# AUTO GENERATED
# To override, see demyx -h

version: "$DOCKER_COMPOSE_VERSION"

services:
  db_${WP_ID}:
    image: demyx/mariadb
    restart: unless-stopped
    networks:
      - traefik
    volumes:
      - db_${WP_ID}:/var/lib/mysql
    environment:
      MARIADB_DATABASE: \${WORDPRESS_DB_NAME}
      MARIADB_USERNAME: \${WORDPRESS_DB_USER}
      MARIADB_PASSWORD: \${WORDPRESS_DB_PASSWORD}
      MARIADB_ROOT_PASSWORD: \${MARIADB_ROOT_PASSWORD}
      MARIADB_DEFAULT_CHARACTER_SET: \${MARIADB_DEFAULT_CHARACTER_SET}
      MARIADB_CHARACTER_SET_SERVER: \${MARIADB_CHARACTER_SET_SERVER}
      MARIADB_COLLATION_SERVER: \${MARIADB_COLLATION_SERVER}
      MARIADB_KEY_BUFFER_SIZE: \${MARIADB_KEY_BUFFER_SIZE}
      MARIADB_MAX_ALLOWED_PACKET: \${MARIADB_MAX_ALLOWED_PACKET}
      MARIADB_TABLE_OPEN_CACHE: \${MARIADB_TABLE_OPEN_CACHE}
      MARIADB_SORT_BUFFER_SIZE: \${MARIADB_SORT_BUFFER_SIZE}
      MARIADB_NET_BUFFER_SIZE: \${MARIADB_NET_BUFFER_SIZE}
      MARIADB_READ_BUFFER_SIZE: \${MARIADB_READ_BUFFER_SIZE}
      MARIADB_READ_RND_BUFFER_SIZE: \${MARIADB_READ_RND_BUFFER_SIZE}
      MARIADB_MYISAM_SORT_BUFFER_SIZE: \${MARIADB_MYISAM_SORT_BUFFER_SIZE}
      MARIADB_LOG_BIN: \${MARIADB_LOG_BIN}
      MARIADB_BINLOG_FORMAT: \${MARIADB_BINLOG_FORMAT}
      MARIADB_SERVER_ID: \${MARIADB_SERVER_ID}
      MARIADB_INNODB_DATA_FILE_PATH: \${MARIADB_INNODB_DATA_FILE_PATH}
      MARIADB_INNODB_BUFFER_POOL_SIZE: \${MARIADB_INNODB_BUFFER_POOL_SIZE}
      MARIADB_INNODB_LOG_FILE_SIZE: \${MARIADB_INNODB_LOG_FILE_SIZE}
      MARIADB_INNODB_LOG_BUFFER_SIZE: \${MARIADB_INNODB_LOG_BUFFER_SIZE}
      MARIADB_INNODB_FLUSH_LOG_AT_TRX_COMMIT: \${MARIADB_INNODB_FLUSH_LOG_AT_TRX_COMMIT}
      MARIADB_INNODB_LOCK_WAIT_TIMEOUT: \${MARIADB_INNODB_LOCK_WAIT_TIMEOUT}
      MARIADB_INNODB_USE_NATIVE_AIO: \${MARIADB_INNODB_USE_NATIVE_AIO}
      MARIADB_MAX_ALLOWED_PACKET: \${MARIADB_MAX_ALLOWED_PACKET}
      MARIADB_KEY_BUFFER_SIZE: \${MARIADB_KEY_BUFFER_SIZE}
      MARIADB_SORT_BUFFER_SIZE: \${MARIADB_SORT_BUFFER_SIZE}
      MARIADB_READ_BUFFER: \${MARIADB_READ_BUFFER}
      MARIADB_WRITE_BUFFER: \${MARIADB_WRITE_BUFFER}
      MARIADB_MAX_CONNECTIONS: \${MARIADB_MAX_CONNECTIONS}
      TZ: America/Los_Angeles
  wp_${WP_ID}:
    image: demyx/nginx-php-wordpress
    restart: unless-stopped
    networks:
      - traefik
    environment:
      WORDPRESS_DB_HOST: \${WORDPRESS_DB_HOST}
      WORDPRESS_DB_NAME: \${WORDPRESS_DB_NAME}
      WORDPRESS_DB_USER: \${WORDPRESS_DB_USER}
      WORDPRESS_DB_PASSWORD: \${WORDPRESS_DB_PASSWORD}
      TZ: America/Los_Angeles
    volumes:
      - ./conf/nginx.conf:/etc/nginx/nginx.conf
      - ./conf/php.ini:/usr/local/etc/php/php.ini
      - ./conf/php-fpm.conf:/usr/local/etc/php-fpm.conf
      - ${WP_MOUNT}:/var/www/html
      - \${ACCESS_LOG}:/var/log/demyx/${DOMAIN}.access.log
      - \${ERROR_LOG}:/var/log/demyx/${DOMAIN}.error.log
    labels:
      - "traefik.enable=true"
      - "traefik.frontend.rule=Host:\${DOMAIN},www.\${DOMAIN}"
      - "traefik.port=80"
      - "traefik.frontend.redirect.regex=^www.\${DOMAIN}/(.*)"
      - "traefik.frontend.redirect.replacement=\${DOMAIN}/\$\$1"
      $PROTOCOL
volumes:
  db_${WP_ID}:
    name: db_${WP_ID}
  $WP_VOLUME
networks:
  traefik:
    name: traefik
EOF

echo -e "\e[32m[SUCCESS]\e[39m Generated .yml"