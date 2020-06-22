# Demyx
# https://demyx.sh

if [[ "$DEMYX_APP_SSL" = true ]]; then
    DEMYX_YML_OLS_LABEL_HTTP='- "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-http.rule='"$DEMYX_YML_HOST_RULE"'"
      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-http.entrypoints=http"
      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-http.service=${DEMYX_APP_COMPOSE_PROJECT}-http-port"
      - "traefik.http.services.${DEMYX_APP_COMPOSE_PROJECT}-http-port.loadbalancer.server.port=80"
      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-http.middlewares=${DEMYX_APP_COMPOSE_PROJECT}-redirect"
      - "traefik.http.middlewares.${DEMYX_APP_COMPOSE_PROJECT}-redirect.redirectregex.regex=^https?:\/\/(?:www\\.)?(.+)"
      - "traefik.http.middlewares.${DEMYX_APP_COMPOSE_PROJECT}-redirect.redirectregex.replacement=https://'"$DEMYX_YML_REGEX"'$${1}"
      - "traefik.http.middlewares.${DEMYX_APP_COMPOSE_PROJECT}-redirect.redirectregex.permanent=true"
      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-https.rule='"$DEMYX_YML_HOST_RULE"'"
      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-https.entrypoints=https"
      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-https.tls.certresolver='$(demyx_certificate_challenge)'"
      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-https.service=${DEMYX_APP_COMPOSE_PROJECT}-https-port"
      - "traefik.http.services.${DEMYX_APP_COMPOSE_PROJECT}-https-port.loadbalancer.server.port=80"'
    DEMYX_YML_OLS_LABEL_ADMIN='- "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-ols.entrypoints=https"
      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-ols.tls.certresolver='$(demyx_certificate_challenge)'"'
    DEMYX_YML_OLS_LABEL_ASSETS='- "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-ols-assets.entrypoints=https"
      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-ols-assets.tls.certresolver='$(demyx_certificate_challenge)'"'
    DEMYX_YML_OLS_LABEL_AUTH_PROTO=https
else
    DEMYX_YML_OLS_LABEL_HTTP='- "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-http.rule='"$DEMYX_YML_HOST_RULE"'"
      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-http.entrypoints=http"
      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-http.service=${DEMYX_APP_COMPOSE_PROJECT}-http-port"
      - "traefik.http.services.${DEMYX_APP_COMPOSE_PROJECT}-http-port.loadbalancer.server.port=80"
      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-http.middlewares=${DEMYX_APP_COMPOSE_PROJECT}-redirect"
      - "traefik.http.middlewares.${DEMYX_APP_COMPOSE_PROJECT}-redirect.redirectregex.regex=^https?:\/\/(?:www\\.)?(.+)"
      - "traefik.http.middlewares.${DEMYX_APP_COMPOSE_PROJECT}-redirect.redirectregex.replacement=http://'"$DEMYX_YML_REGEX"'$${1}"
      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-https.rule='"$DEMYX_YML_HOST_RULE"'"
      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-https.entrypoints=https"
      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-https.tls.certresolver='$(demyx_certificate_challenge)'"
      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-https.service=${DEMYX_APP_COMPOSE_PROJECT}-https-port"
      - "traefik.http.services.${DEMYX_APP_COMPOSE_PROJECT}-https-port.loadbalancer.server.port=80"'
    DEMYX_YML_OLS_LABEL_ADMIN='- "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-ols.entrypoints=http"'
    DEMYX_YML_OLS_LABEL_ASSETS='- "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-ols-assets.entrypoints=http"'
    DEMYX_YML_OLS_LABEL_AUTH_PROTO=http
fi

if [[ "$DEMYX_APP_AUTH" = true || -n "$DEMYX_RUN_AUTH" ]]; then
    DEMYX_YML_OLS_LABEL_AUTH="- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-${DEMYX_YML_OLS_LABEL_AUTH_PROTO}.middlewares=\${DEMYX_APP_COMPOSE_PROJECT}-auth\"
      - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-auth.basicauth.users=\${DEMYX_APP_AUTH_HTPASSWD}\""
fi

echo "# AUTO GENERATED
networks:
  demyx:
    name: demyx
services:
  db_${DEMYX_APP_ID}:
    cpus: \${DEMYX_APP_DB_CPU}
    environment:
      - MARIADB_DOMAIN=\${DEMYX_APP_DOMAIN}
      - MARIADB_DATABASE=\${WORDPRESS_DB_NAME}
      - MARIADB_USERNAME=\${WORDPRESS_DB_USER}
      - MARIADB_PASSWORD=\${WORDPRESS_DB_PASSWORD}
      - MARIADB_ROOT_PASSWORD=\${MARIADB_ROOT_PASSWORD}
      - MARIADB_DEFAULT_CHARACTER_SET=\${MARIADB_DEFAULT_CHARACTER_SET}
      - MARIADB_CHARACTER_SET_SERVER=\${MARIADB_CHARACTER_SET_SERVER}
      - MARIADB_COLLATION_SERVER=\${MARIADB_COLLATION_SERVER}
      - MARIADB_KEY_BUFFER_SIZE=\${MARIADB_KEY_BUFFER_SIZE}
      - MARIADB_MAX_ALLOWED_PACKET=\${MARIADB_MAX_ALLOWED_PACKET}
      - MARIADB_TABLE_OPEN_CACHE=\${MARIADB_TABLE_OPEN_CACHE}
      - MARIADB_SORT_BUFFER_SIZE=\${MARIADB_SORT_BUFFER_SIZE}
      - MARIADB_NET_BUFFER_SIZE=\${MARIADB_NET_BUFFER_SIZE}
      - MARIADB_READ_BUFFER_SIZE=\${MARIADB_READ_BUFFER_SIZE}
      - MARIADB_READ_RND_BUFFER_SIZE=\${MARIADB_READ_RND_BUFFER_SIZE}
      - MARIADB_MYISAM_SORT_BUFFER_SIZE=\${MARIADB_MYISAM_SORT_BUFFER_SIZE}
      - MARIADB_SERVER_ID=\${MARIADB_SERVER_ID}
      - MARIADB_INNODB_DATA_FILE_PATH=\${MARIADB_INNODB_DATA_FILE_PATH}
      - MARIADB_INNODB_BUFFER_POOL_SIZE=\${MARIADB_INNODB_BUFFER_POOL_SIZE}
      - MARIADB_INNODB_LOG_FILE_SIZE=\${MARIADB_INNODB_LOG_FILE_SIZE}
      - MARIADB_INNODB_LOG_BUFFER_SIZE=\${MARIADB_INNODB_LOG_BUFFER_SIZE}
      - MARIADB_INNODB_FLUSH_LOG_AT_TRX_COMMIT=\${MARIADB_INNODB_FLUSH_LOG_AT_TRX_COMMIT}
      - MARIADB_INNODB_LOCK_WAIT_TIMEOUT=\${MARIADB_INNODB_LOCK_WAIT_TIMEOUT}
      - MARIADB_INNODB_USE_NATIVE_AIO=\${MARIADB_INNODB_USE_NATIVE_AIO}
      - MARIADB_READ_BUFFER=\${MARIADB_READ_BUFFER}
      - MARIADB_WRITE_BUFFER=\${MARIADB_WRITE_BUFFER}
      - MARIADB_MAX_CONNECTIONS=\${MARIADB_MAX_CONNECTIONS}
      - TZ=$TZ
    image: demyx/mariadb
    mem_limit: \${DEMYX_APP_DB_MEM}
    networks:
      - demyx
    restart: unless-stopped
    volumes:
      - wp_${DEMYX_APP_ID}_db:/demyx
      - wp_${DEMYX_APP_ID}_log:/var/log/demyx
  wp_${DEMYX_APP_ID}:
    cpus: \${DEMYX_APP_WP_CPU}
    depends_on:
      - db_${DEMYX_APP_ID}
    environment:
      - OPENLITESPEED_ADMIN_IP=\${DEMYX_APP_OLS_ADMIN_IP}
      - OPENLITESPEED_ADMIN_USERNAME=\${DEMYX_APP_OLS_ADMIN_USERNAME}
      - OPENLITESPEED_ADMIN_PASSWORD=\${DEMYX_APP_OLS_ADMIN_PASSWORD}
      - OPENLITESPEED_BASIC_AUTH_USERNAME=\${DEMYX_APP_AUTH_USERNAME}
      - OPENLITESPEED_BASIC_AUTH_PASSWORD=\${DEMYX_APP_AUTH_PASSWORD}
      - OPENLITESPEED_BASIC_AUTH_WP=\${DEMYX_APP_AUTH_WP}
      - OPENLITESPEED_CACHE=\${DEMYX_APP_CACHE}
      - OPENLITESPEED_CLIENT_THROTTLE_STATIC=\${DEMYX_APP_OLS_CLIENT_THROTTLE_STATIC}
      - OPENLITESPEED_CLIENT_THROTTLE_DYNAMIC=\${DEMYX_APP_OLS_CLIENT_THROTTLE_DYNAMIC}
      - OPENLITESPEED_CLIENT_THROTTLE_BANDWIDTH_OUT=\${DEMYX_APP_OLS_CLIENT_THROTTLE_BANDWIDTH_OUT}
      - OPENLITESPEED_CLIENT_THROTTLE_BANDWIDTH_IN=\${DEMYX_APP_OLS_CLIENT_THROTTLE_BANDWIDTH_IN}
      - OPENLITESPEED_CLIENT_THROTTLE_SOFT_LIMIT=\${DEMYX_APP_OLS_CLIENT_THROTTLE_SOFT_LIMIT}
      - OPENLITESPEED_CLIENT_THROTTLE_HARD_LIMIT=\${DEMYX_APP_OLS_CLIENT_THROTTLE_HARD_LIMIT}
      - OPENLITESPEED_CLIENT_THROTTLE_BLOCK_BAD_REQUEST=\${DEMYX_APP_OLS_CLIENT_THROTTLE_BLOCK_BAD_REQUEST}
      - OPENLITESPEED_CLIENT_THROTTLE_GRACE_PERIOD=\${DEMYX_APP_OLS_CLIENT_THROTTLE_GRACE_PERIOD}
      - OPENLITESPEED_CLIENT_THROTTLE_BAN_PERIOD=\${DEMYX_APP_OLS_CLIENT_THROTTLE_BAN_PERIOD}
      - OPENLITESPEED_DOMAIN=\${DEMYX_APP_DOMAIN}
      - OPENLITESPEED_TUNING_MAX_CONNECTIONS=\${DEMYX_APP_OLS_TUNING_MAX_CONNECTIONS}
      - OPENLITESPEED_TUNING_CONNECTION_TIMEOUT=\${DEMYX_APP_OLS_TUNING_CONNECTION_TIMEOUT}
      - OPENLITESPEED_TUNING_MAX_KEEP_ALIVE=\${DEMYX_APP_OLS_TUNING_MAX_KEEP_ALIVE}
      - OPENLITESPEED_TUNING_SMART_KEEP_ALIVE=\${DEMYX_APP_OLS_TUNING_SMART_KEEP_ALIVE}
      - OPENLITESPEED_TUNING_KEEP_ALIVE_TIMEOUT=\${DEMYX_APP_OLS_TUNING_KEEP_ALIVE_TIMEOUT}
      - OPENLITESPEED_PHP_LSAPI_CHILDREN=\${DEMYX_APP_OLS_PHP_LSAPI_CHILDREN}
      - OPENLITESPEED_PHP_OPCACHE=\${DEMYX_APP_PHP_OPCACHE}
      - OPENLITESPEED_PHP_MAX_EXECUTION_TIME=\${DEMYX_APP_PHP_MAX_EXECUTION_TIME}
      - OPENLITESPEED_PHP_MEMORY=\${DEMYX_APP_PHP_MEMORY}
      - OPENLITESPEED_PHP_UPLOAD_LIMIT=\${DEMYX_APP_UPLOAD_LIMIT}
      - OPENLITESPEED_RECAPTCHA_ENABLE=\${DEMYX_APP_OLS_RECAPTCHA_ENABLE}
      - OPENLITESPEED_RECAPTCHA_TYPE=\${DEMYX_APP_OLS_RECAPTCHA_TYPE}
      - OPENLITESPEED_RECAPTCHA_CONNECTION_LIMIT=\${DEMYX_APP_OLS_RECAPTCHA_CONNECTION_LIMIT}
      - OPENLITESPEED_XMLRPC=\${DEMYX_APP_XMLRPC}
      - TZ=$TZ
      $DEMYX_YML_RUN_CREDENTIALS
    image: demyx/openlitespeed
    labels:
      - \"traefik.enable=true\"
      $DEMYX_YML_OLS_LABEL_HTTP
      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols.rule=Host(\`\${DEMYX_APP_DOMAIN}\`) && PathPrefix(\`/demyx/ols/\`)\"
      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols.middlewares=\${DEMYX_APP_COMPOSE_PROJECT}-ols-prefix\"
      - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-ols-prefix.stripprefix.prefixes=/demyx/ols/\"
      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols.service=\${DEMYX_APP_COMPOSE_PROJECT}-ols-port\"
      - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-ols-port.loadbalancer.server.port=8080\"
      $DEMYX_YML_OLS_LABEL_ADMIN
      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols.priority=99\"
      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols-assets.rule=Host(\`\${DEMYX_APP_DOMAIN}\`) && PathPrefix(\`/res/\`)\"
      - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-ols-assets-prefix.stripprefix.prefixes=/demyx/ols/\"
      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols-assets.service=\${DEMYX_APP_COMPOSE_PROJECT}-ols-assets-port\"
      - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-ols-assets-port.loadbalancer.server.port=8080\"
      $DEMYX_YML_OLS_LABEL_ASSETS
      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols-assets.priority=99\"
      $DEMYX_YML_OLS_LABEL_AUTH
    mem_limit: \${DEMYX_APP_WP_MEM}
    networks:
      - demyx
    restart: unless-stopped
    volumes:
      - wp_${DEMYX_APP_ID}:/demyx
      - wp_${DEMYX_APP_ID}_log:/var/log/demyx
version: \"$DEMYX_DOCKER_COMPOSE\"
volumes:
  wp_${DEMYX_APP_ID}:
    name: wp_${DEMYX_APP_ID}
  wp_${DEMYX_APP_ID}_db:
    name: wp_${DEMYX_APP_ID}_db
  wp_${DEMYX_APP_ID}_log:
    name: wp_${DEMYX_APP_ID}_log
" > "$DEMYX_APP_PATH"/docker-compose.yml
