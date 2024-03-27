# Demyx
# https://demyx.sh
# shellcheck shell=bash

#
#   Main function for yml generation.
#
demyx_yml() {
    demyx_event
    local DEMYX_YML="${1:-}"
    local DEMYX_YML_RESOLVER=

    demyx_source utility

    case "$DEMYX_YML" in
        bedrock)
            demyx_yml_bedrock
        ;;
        code)
            demyx_yml_code
        ;;
        nginx-php)
            demyx_yml_nginx_php
        ;;
        ols)
            demyx_yml_ols
        ;;
        ols-bedrock)
            demyx_yml_ols_bedrock
        ;;
        traefik)
            demyx_yml_traefik
        ;;
        *)
            demyx_error args
        ;;
    esac
}
#
#   Basic auth label.
#
demyx_yml_auth_label() {
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_AUTH
        DEMYX_APP_AUTH_PASSWORD
        DEMYX_APP_AUTH_USERNAME
    "

    if [[ "$DEMYX_APP_AUTH" = true ]]; then
        echo "- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-$(demyx_app_proto).middlewares=\${DEMYX_APP_COMPOSE_PROJECT}-auth\"
              - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-auth.basicauth.users=$(demyx_utility htpasswd -r "$DEMYX_APP_AUTH_USERNAME" "$DEMYX_APP_AUTH_PASSWORD" | sed "s|\\$|\$$|g")\""
    fi
}
#
#   YAML template for the bedrock stack.
#
demyx_yml_bedrock() {
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_DOMAIN
        DEMYX_APP_DEV
        DEMYX_APP_ID
        DEMYX_APP_PATH
        DEMYX_APP_TYPE
    "

    local DEMYX_YML_BEDROCK_DEV_CPU="\${DEMYX_APP_WP_CPU}"
    local DEMYX_YML_BEDROCK_DEV_ENTRYPOINTS=
    local DEMYX_YML_BEDROCK_DEV_LABELS=
    local DEMYX_YML_BEDROCK_DEV_MEM="\${DEMYX_APP_WP_MEM}"
    local DEMYX_YML_BEDROCK_DEV_PASSWORD=
    local DEMYX_YML_BEDROCK_DEV_VOLUME=
    local DEMYX_YML_BEDROCK_IMAGE=demyx/wordpress:bedrock

    if [[ "$DEMYX_APP_DEV" = true ]]; then
        DEMYX_YML_BEDROCK_DEV_CPU=".80"
        DEMYX_YML_BEDROCK_DEV_MEM="$(demyx_yml_memory)"
        DEMYX_YML_BEDROCK_DEV_PASSWORD="- DEMYX_CODE_PASSWORD=\${DEMYX_APP_DEV_PASSWORD}"
        DEMYX_YML_BEDROCK_DEV_VOLUME="- \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_code:/home/demyx"
        DEMYX_YML_BEDROCK_IMAGE=demyx/code-server:bedrock

        if [[ "$(demyx_app_proto)" = https ]]; then
            DEMYX_YML_BEDROCK_DEV_ENTRYPOINTS="- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.entrypoints=https\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.tls.certresolver=$(demyx_yml_resolver)\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js.entrypoints=https\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js.tls.certresolver=$(demyx_yml_resolver)\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json.entrypoints=https\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json.tls.certresolver=$(demyx_yml_resolver)\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-webpack.entrypoints=https\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-webpack.tls.certresolver=$(demyx_yml_resolver)\""
        else
            DEMYX_YML_BEDROCK_DEV_ENTRYPOINTS="- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.entrypoints=http\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js.entrypoints=http\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json.entrypoints=http\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-webpack.entrypoints=http\""
        fi

        DEMYX_YML_BEDROCK_DEV_LABELS="labels:
              - \"traefik.enable=true\"
              - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-cs-prefix.stripprefix.prefixes=/demyx/cs/\"
              - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js-prefix.stripprefix.prefixes=/app.[a-z0-9].hot-update.js\"
              - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json-prefix.stripprefix.prefixes=/app.[a-z0-9].hot-update.json\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.middlewares=\${DEMYX_APP_COMPOSE_PROJECT}-cs-prefix\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.priority=99\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.rule=Host(\`$(demyx_app_domain)\`) && PathPrefix(\`/demyx/cs/\`)\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.service=\${DEMYX_APP_COMPOSE_PROJECT}-cs-port\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js.middlewares=\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js-prefix\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js.priority=99\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js.rule=(Host(\`$(demyx_app_domain)\`) && PathPrefix(\`/app.{hash:[a-z.0-9]+}.hot-update.js\`))\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js.service=\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json.middlewares=\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json-prefix\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json.priority=99\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json.rule=(Host(\`$(demyx_app_domain)\`) && PathPrefix(\`/app.{hash:[a-z.0-9]+}.hot-update.json\`))\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json.service=\${DEMYX_APP_COMPOSE_PROJECT}-json\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-webpack.priority=99\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-webpack.rule=(Host(\`$(demyx_app_domain)\`) && PathPrefix(\`/__bud/hmr\`))\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-webpack.service=\${DEMYX_APP_COMPOSE_PROJECT}-webpack\"
              - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-cs-port.loadbalancer.server.port=8080\"
              - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js.loadbalancer.server.port=3000\"
              - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-json.loadbalancer.server.port=3000\"
              - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-webpack.loadbalancer.server.port=3000\"
              $DEMYX_YML_BEDROCK_DEV_ENTRYPOINTS"
    fi

    echo "# DEMYX $DEMYX_VERSION
        networks:
          demyx:
            external: true
            name: demyx
        services:
          $(demyx_yml_service_mariadb)
          nx_${DEMYX_APP_ID}:
            cpus: \${DEMYX_APP_WP_CPU}
            depends_on:
              - \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}
            environment:
              $(demyx_yml_nginx_basic_auth)
              $(demyx_yml_nginx_whitelist)
              - DEMYX_CACHE_TYPE=\${DEMYX_APP_CACHE_TYPE}
              - NGINX_CACHE=\${DEMYX_APP_CACHE}
              - NGINX_DOMAIN=\${DEMYX_APP_DOMAIN}
              - NGINX_RATE_LIMIT=\${DEMYX_APP_RATE_LIMIT}
              - NGINX_UPLOAD_LIMIT=\${DEMYX_APP_UPLOAD_LIMIT}
              - NGINX_XMLRPC=\${DEMYX_APP_XMLRPC}
              - TZ=$TZ
              - WORDPRESS=true
              - WORDPRESS_BEDROCK=true
              - WORDPRESS_CONTAINER=\${DEMYX_APP_WP_CONTAINER}
            image: demyx/nginx
            labels:
              - \"traefik.enable=true\"
              $(demyx_yml_auth_label)
              $(demyx_yml_http_labels)
            mem_limit: \${DEMYX_APP_WP_MEM}
            networks:
              - demyx
            restart: unless-stopped
            volumes:
              - \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}:/demyx
              - \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_custom:/etc/demyx/custom
              - \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_log:/var/log/demyx
          $(demyx_yml_service_pma)
          $(demyx_yml_service_redis)
          $(demyx_yml_service_sftp)
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}:
            cpus: $DEMYX_YML_BEDROCK_DEV_CPU
            depends_on:
              - db_\${DEMYX_APP_ID}
            environment:
              - DEMYX_BEDROCK_MODE=\${DEMYX_APP_BEDROCK_MODE}
              - DEMYX_CRON=\${DEMYX_APP_CRON}
              - DEMYX_CRON_LOGROTATE_INTERVAL=\"\${DEMYX_APP_CRON_LOGROTATE_INTERVAL}\"
              - DEMYX_CRON_WP_INTERVAL=\"\${DEMYX_APP_CRON_WP_INTERVAL}\"
              - DEMYX_DB_HOST=\${WORDPRESS_DB_HOST}
              - DEMYX_DB_NAME=\${WORDPRESS_DB_NAME}
              - DEMYX_DB_PASSWORD=\${WORDPRESS_DB_PASSWORD}
              - DEMYX_DB_USERNAME=\${WORDPRESS_DB_USER}
              - DEMYX_DOMAIN=$(demyx_app_domain)
              - DEMYX_LOGROTATE=\${DEMYX_APP_LOGROTATE}
              - DEMYX_LOGROTATE_INTERVAL=\${DEMYX_APP_LOGROTATE_INTERVAL}
              - DEMYX_LOGROTATE_SIZE=\${DEMYX_APP_LOGROTATE_SIZE}
              - DEMYX_EMERGENCY_RESTART_INTERVAL=\${DEMYX_APP_PHP_EMERGENCY_RESTART_INTERVAL}
              - DEMYX_EMERGENCY_RESTART_THRESHOLD=\${DEMYX_APP_PHP_EMERGENCY_RESTART_THRESHOLD}
              - DEMYX_MAX_EXECUTION_TIME=\${DEMYX_APP_PHP_MAX_EXECUTION_TIME}
              - DEMYX_MEMORY=\${DEMYX_APP_PHP_MEMORY}
              - DEMYX_OPCACHE=\${DEMYX_APP_PHP_OPCACHE}
              - DEMYX_OPCACHE_ENABLE=\${DEMYX_APP_PHP_OPCACHE_ENABLE}
              - DEMYX_OPCACHE_ENABLE_CLI=\${DEMYX_APP_PHP_OPCACHE_ENABLE_CLI}
              - DEMYX_PHP=\${DEMYX_APP_PHP}
              - DEMYX_PM=\${DEMYX_APP_PHP_PM}
              - DEMYX_PM_MAX_CHILDREN=\${DEMYX_APP_PHP_PM_MAX_CHILDREN}
              - DEMYX_PM_MAX_REQUESTS=\${DEMYX_APP_PHP_PM_MAX_REQUESTS}
              - DEMYX_PM_MAX_SPARE_SERVERS=\${DEMYX_APP_PHP_PM_MAX_SPARE_SERVERS}
              - DEMYX_PM_MIN_SPARE_SERVERS=\${DEMYX_APP_PHP_PM_MIN_SPARE_SERVERS}
              - DEMYX_PM_PROCESS_IDLE_TIMEOUT=\${DEMYX_APP_PHP_PM_PROCESS_IDLE_TIMEOUT}
              - DEMYX_PM_START_SERVERS=\${DEMYX_APP_PHP_PM_START_SERVERS}
              - DEMYX_PROCESS_CONTROL_TIMEOUT=\${DEMYX_APP_PHP_PROCESS_CONTROL_TIMEOUT}
              - DEMYX_PROTO=$(demyx_app_proto)
              - DEMYX_PROXY=\${DEMYX_APP_NX_CONTAINER}
              - DEMYX_SSL=\${DEMYX_APP_SSL}
              - DEMYX_UPLOAD_LIMIT=\${DEMYX_APP_UPLOAD_LIMIT}
              - DEMYX_WP_EMAIL=\${WORDPRESS_USER_EMAIL}
              - DEMYX_WP_PASSWORD=\${WORDPRESS_USER_PASSWORD}
              - DEMYX_WP_USERNAME=\${WORDPRESS_USER}
              - TZ=$TZ
              $DEMYX_YML_BEDROCK_DEV_PASSWORD
            hostname: \${DEMYX_APP_COMPOSE_PROJECT}
            image: $DEMYX_YML_BEDROCK_IMAGE
            $DEMYX_YML_BEDROCK_DEV_LABELS
            mem_limit: $DEMYX_YML_BEDROCK_DEV_MEM
            networks:
              - demyx
            restart: unless-stopped
            volumes:
              - \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}:/demyx
              - \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_custom:/etc/demyx/custom
              - \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_log:/var/log/demyx
              $DEMYX_YML_BEDROCK_DEV_VOLUME
        volumes:
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}:
            external: true
            name: \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_code:
            external: true
            name: \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_code
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_custom:
            external: true
            name: \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_custom
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_db:
            external: true
            name: \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_db
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_log:
            external: true
            name: \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_log
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_sftp:
            external: true
            name: \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_sftp
        " | sed "s|        ||g" > "$DEMYX_APP_PATH"/docker-compose.yml
}
#
#   YAML template for code-server.
#
demyx_yml_code() {
    demyx_event
    local DEMYX_YML_CODE_LABELS=
    local DEMYX_YML_CODE_WHITELIST=

    if [[ "$DEMYX_IP" != false ]]; then
        DEMYX_YML_CODE_WHITELIST="- \"traefik.http.routers.demyx-code-https.middlewares=demyx-code-whitelist\"
              - \"traefik.http.middlewares.demyx-code-whitelist.ipwhitelist.sourcerange=${DEMYX_IP}\""
    fi

    if [[ "$DEMYX_CODE_SSL" = true ]]; then
        DEMYX_YML_CODE_LABELS="- \"traefik.http.routers.demyx-code-http.middlewares=demyx-code-redirect\"
              - \"traefik.http.middlewares.demyx-code-redirect.redirectscheme.scheme=https\"
              - \"traefik.http.routers.demyx-code-https.rule=Host(\`${DEMYX_CODE_DOMAIN}.${DEMYX_DOMAIN}\`)\"
              - \"traefik.http.routers.demyx-code-https.entrypoints=https\"
              - \"traefik.http.routers.demyx-code-https.tls.certresolver=$(demyx_yml_resolver)\"
              - \"traefik.http.routers.demyx-code-https.service=demyx-code-https-port\"
              - \"traefik.http.services.demyx-code-https-port.loadbalancer.server.port=8080\""
    fi

    echo "# DEMYX $DEMYX_VERSION
        networks:
          demyx:
            external: true
            name: demyx
          demyx_socket:
            external: true
            name: demyx_socket
        services:
          code:
            container_name: demyx_code
            cpus: .80
            environment:
              - PASSWORD=$DEMYX_CODE_PASSWORD
              - TZ=$TZ
            hostname: code-${DEMYX_HOSTNAME}
            image: demyx/code-server:browse
            labels:
              - \"traefik.enable=true\"
              - \"traefik.http.routers.demyx-code-http.rule=Host(\`${DEMYX_CODE_DOMAIN}.${DEMYX_DOMAIN}\`)\"
              - \"traefik.http.routers.demyx-code-http.entrypoints=http\"
              - \"traefik.http.routers.demyx-code-http.service=demyx-code-http-port\"
              - \"traefik.http.services.demyx-code-http-port.loadbalancer.server.port=8080\"
              $DEMYX_YML_CODE_LABELS
              $DEMYX_YML_CODE_WHITELIST
            mem_limit: $(demyx_yml_memory)
            networks:
              - demyx
              - demyx_socket
            restart: unless-stopped
            volumes:
              - demyx:/demyx
              - demyx_user:/home/demyx
              - demyx_log:/var/log/demyx
        volumes:
          demyx:
            external: true
            name: demyx
          demyx_log:
            external: true
            name: demyx_log
          demyx_user:
            external: true
            name: demyx_user" | sed "s|        ||g" > "$DEMYX_CODE"/docker-compose.yml
}
#
#   YAML template for traefik http labels.
#
demyx_yml_http_labels() {
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_DOMAIN
        DEMYX_APP_SSL_WILDCARD
    "

    local DEMYX_YML_HTTP_LABELS_RULES=

    if [[ -n "$(demyx_subdomain "$DEMYX_APP_DOMAIN")" ]]; then
        DEMYX_YML_HTTP_LABELS_RULES="Host(\`\${DEMYX_APP_DOMAIN}\`)"
    else
        DEMYX_YML_HTTP_LABELS_RULES="Host(\`\${DEMYX_APP_DOMAIN}\`) || Host(\`www.\${DEMYX_APP_DOMAIN}\`)"
    fi

    if [[ "$(demyx_app_proto)" = https ]]; then
        echo "- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-http.rule=${DEMYX_YML_HTTP_LABELS_RULES}\"
      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-http.entrypoints=http\"
      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-http.service=\${DEMYX_APP_COMPOSE_PROJECT}-http-port\"
      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-http.priority=10\"
      - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-http-port.loadbalancer.server.port=80\"
      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-http.middlewares=\${DEMYX_APP_COMPOSE_PROJECT}-redirect\"
      - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-redirect.redirectregex.regex="'^https?:\\/\\/(?:www\\.)?(.+)'"\"
      - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-redirect.redirectregex.replacement=https://\$\${1}\"
      - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-redirect.redirectregex.permanent=true\"
      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-https.rule=${DEMYX_YML_HTTP_LABELS_RULES}\"
      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-https.entrypoints=https\"
      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-https.tls.certresolver=$(demyx_yml_resolver)\"
      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-https.service=\${DEMYX_APP_COMPOSE_PROJECT}-https-port\"
      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-https.priority=10\"
      - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-https-port.loadbalancer.server.port=80\""

        if [[ "$DEMYX_APP_SSL_WILDCARD" = true ]]; then
            echo "      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-https.tls.domains[0].main=\${DEMYX_APP_DOMAIN}\"
      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-https.tls.domains[0].sans=*.\${DEMYX_APP_DOMAIN}\""
        fi
    else
        echo "- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-http.rule=${DEMYX_YML_HTTP_LABELS_RULES}\"
      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-http.entrypoints=http\"
      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-http.service=\${DEMYX_APP_COMPOSE_PROJECT}-http-port\"
      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-http.priority=10\"
      - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-http-port.loadbalancer.server.port=80\""
    fi
}
#
#   Calculates half the total memory for code-server services.
#
demyx_yml_memory() {
    local DEMYX_YML_MEMORY=
    DEMYX_YML_MEMORY="$(grep MemTotal /proc/meminfo | awk -F ' ' '{print $2}')"
    echo "$(( DEMYX_YML_MEMORY / 2 ))k"
}
#
#   YAML template for the nginx-php stack.
#
demyx_yml_nginx_php() {
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_DOMAIN
        DEMYX_APP_DEV
        DEMYX_APP_ID
        DEMYX_APP_PATH
        DEMYX_APP_TYPE
    "

    local DEMYX_YML_NGINX_PHP_DEV_CPU="\${DEMYX_APP_WP_CPU}"
    local DEMYX_YML_NGINX_PHP_DEV_ENTRYPOINTS=
    local DEMYX_YML_NGINX_PHP_DEV_LABELS=
    local DEMYX_YML_NGINX_PHP_DEV_MEM="\${DEMYX_APP_WP_MEM}"
    local DEMYX_YML_NGINX_PHP_DEV_PASSWORD=
    local DEMYX_YML_NGINX_PHP_DEV_VOLUME=
    local DEMYX_YML_NGINX_PHP_IMAGE=demyx/wordpress

    if [[ "$DEMYX_APP_DEV" = true ]]; then
        DEMYX_YML_NGINX_PHP_DEV_CPU=".80"
        DEMYX_YML_NGINX_PHP_DEV_MEM="$(demyx_yml_memory)"
        DEMYX_YML_NGINX_PHP_DEV_PASSWORD="- DEMYX_CODE_PASSWORD=\${DEMYX_APP_DEV_PASSWORD}"
        DEMYX_YML_NGINX_PHP_DEV_VOLUME="- \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_code:/home/demyx"
        DEMYX_YML_NGINX_PHP_IMAGE=demyx/code-server:wp

        if [[ "$(demyx_app_proto)" = https ]]; then
            DEMYX_YML_NGINX_PHP_DEV_ENTRYPOINTS="- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.entrypoints=https\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.tls.certresolver=$(demyx_yml_resolver)\""
        else
            DEMYX_YML_NGINX_PHP_DEV_ENTRYPOINTS="- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.entrypoints=http\""
        fi

        DEMYX_YML_NGINX_PHP_DEV_LABELS="labels:
              - \"traefik.enable=true\"
              $DEMYX_YML_NGINX_PHP_DEV_ENTRYPOINTS
              - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-cs-prefix.stripprefix.prefixes=/demyx/cs/\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.middlewares=\${DEMYX_APP_COMPOSE_PROJECT}-cs-prefix\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.priority=99\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.rule=Host(\`$(demyx_app_domain)\`) && PathPrefix(\`/demyx/cs/\`)\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.service=\${DEMYX_APP_COMPOSE_PROJECT}-cs-port\"
              - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-cs-port.loadbalancer.server.port=8080\""
    fi

    echo "# DEMYX $DEMYX_VERSION
        networks:
          demyx:
            external: true
            name: demyx
        services:
          $(demyx_yml_service_bs)
          $(demyx_yml_service_mariadb)
          nx_${DEMYX_APP_ID}:
            cpus: \${DEMYX_APP_WP_CPU}
            depends_on:
              - \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}
            environment:
              $(demyx_yml_nginx_basic_auth)
              $(demyx_yml_nginx_whitelist)
              - DEMYX_CACHE_TYPE=\${DEMYX_APP_CACHE_TYPE}
              - NGINX_CACHE=\${DEMYX_APP_CACHE}
              - NGINX_DOMAIN=\${DEMYX_APP_DOMAIN}
              - NGINX_RATE_LIMIT=\${DEMYX_APP_RATE_LIMIT}
              - NGINX_UPLOAD_LIMIT=\${DEMYX_APP_UPLOAD_LIMIT}
              - NGINX_XMLRPC=\${DEMYX_APP_XMLRPC}
              - TZ=$TZ
              - WORDPRESS=true
              - WORDPRESS_CONTAINER=\${DEMYX_APP_WP_CONTAINER}
            image: demyx/nginx
            labels:
              - \"traefik.enable=true\"
              $(demyx_yml_auth_label)
              $(demyx_yml_http_labels)
            mem_limit: \${DEMYX_APP_WP_MEM}
            networks:
              - demyx
            restart: unless-stopped
            volumes:
              - \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}:/demyx
              - \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_custom:/etc/demyx/custom
              - \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_log:/var/log/demyx
          $(demyx_yml_service_pma)
          $(demyx_yml_service_redis)
          $(demyx_yml_service_sftp)
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}:
            cpus: $DEMYX_YML_NGINX_PHP_DEV_CPU
            depends_on:
              - db_\${DEMYX_APP_ID}
            environment:
              - DEMYX_CRON=\${DEMYX_APP_CRON}
              - DEMYX_CRON_LOGROTATE_INTERVAL=\"\${DEMYX_APP_CRON_LOGROTATE_INTERVAL}\"
              - DEMYX_CRON_WP_INTERVAL=\"\${DEMYX_APP_CRON_WP_INTERVAL}\"
              - DEMYX_DB_HOST=\${WORDPRESS_DB_HOST}
              - DEMYX_DB_NAME=\${WORDPRESS_DB_NAME}
              - DEMYX_DB_PASSWORD=\${WORDPRESS_DB_PASSWORD}
              - DEMYX_DB_USERNAME=\${WORDPRESS_DB_USER}
              - DEMYX_DOMAIN=$(demyx_app_domain)
              - DEMYX_LOGROTATE=\${DEMYX_APP_LOGROTATE}
              - DEMYX_LOGROTATE_INTERVAL=\${DEMYX_APP_LOGROTATE_INTERVAL}
              - DEMYX_LOGROTATE_SIZE=\${DEMYX_APP_LOGROTATE_SIZE}
              - DEMYX_EMERGENCY_RESTART_INTERVAL=\${DEMYX_APP_PHP_EMERGENCY_RESTART_INTERVAL}
              - DEMYX_EMERGENCY_RESTART_THRESHOLD=\${DEMYX_APP_PHP_EMERGENCY_RESTART_THRESHOLD}
              - DEMYX_MAX_EXECUTION_TIME=\${DEMYX_APP_PHP_MAX_EXECUTION_TIME}
              - DEMYX_MEMORY=\${DEMYX_APP_PHP_MEMORY}
              - DEMYX_OPCACHE=\${DEMYX_APP_PHP_OPCACHE}
              - DEMYX_OPCACHE_ENABLE=\${DEMYX_APP_PHP_OPCACHE_ENABLE}
              - DEMYX_OPCACHE_ENABLE_CLI=\${DEMYX_APP_PHP_OPCACHE_ENABLE_CLI}
              - DEMYX_PHP=\${DEMYX_APP_PHP}
              - DEMYX_PM=\${DEMYX_APP_PHP_PM}
              - DEMYX_PM_MAX_CHILDREN=\${DEMYX_APP_PHP_PM_MAX_CHILDREN}
              - DEMYX_PM_MAX_REQUESTS=\${DEMYX_APP_PHP_PM_MAX_REQUESTS}
              - DEMYX_PM_MAX_SPARE_SERVERS=\${DEMYX_APP_PHP_PM_MAX_SPARE_SERVERS}
              - DEMYX_PM_MIN_SPARE_SERVERS=\${DEMYX_APP_PHP_PM_MIN_SPARE_SERVERS}
              - DEMYX_PM_PROCESS_IDLE_TIMEOUT=\${DEMYX_APP_PHP_PM_PROCESS_IDLE_TIMEOUT}
              - DEMYX_PM_START_SERVERS=\${DEMYX_APP_PHP_PM_START_SERVERS}
              - DEMYX_PROCESS_CONTROL_TIMEOUT=\${DEMYX_APP_PHP_PROCESS_CONTROL_TIMEOUT}
              - DEMYX_PROTO=$(demyx_app_proto)
              - DEMYX_UPLOAD_LIMIT=\${DEMYX_APP_UPLOAD_LIMIT}
              - DEMYX_WP_EMAIL=\${WORDPRESS_USER_EMAIL}
              - DEMYX_WP_PASSWORD=\${WORDPRESS_USER_PASSWORD}
              - DEMYX_WP_USERNAME=\${WORDPRESS_USER}
              - TZ=$TZ
              $DEMYX_YML_NGINX_PHP_DEV_PASSWORD
            hostname: \${DEMYX_APP_COMPOSE_PROJECT}
            image: $DEMYX_YML_NGINX_PHP_IMAGE
            $DEMYX_YML_NGINX_PHP_DEV_LABELS
            mem_limit: $DEMYX_YML_NGINX_PHP_DEV_MEM
            networks:
              - demyx
            restart: unless-stopped
            volumes:
              - \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}:/demyx
              - \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_custom:/etc/demyx/custom
              - \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_log:/var/log/demyx
              $DEMYX_YML_NGINX_PHP_DEV_VOLUME
        volumes:
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}:
            external: true
            name: \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_code:
            external: true
            name: \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_code
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_custom:
            external: true
            name: \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_custom
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_db:
            external: true
            name: \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_db
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_log:
            external: true
            name: \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_log
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_sftp:
            external: true
            name: \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_sftp
        " | sed "s|        ||g" > "$DEMYX_APP_PATH"/docker-compose.yml
}
#
#   NGINX basic auth environment variables.
#
demyx_yml_nginx_basic_auth() {
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_AUTH_WP
        DEMYX_APP_AUTH_PASSWORD
        DEMYX_APP_AUTH_USERNAME
    "

    if [[ "$DEMYX_APP_AUTH_WP" = true ]]; then
        echo "- NGINX_BASIC_AUTH=\${DEMYX_APP_AUTH_WP}
              - NGINX_BASIC_AUTH_HTPASSWD=$(demyx_utility htpasswd -r "$DEMYX_APP_AUTH_USERNAME" "$DEMYX_APP_AUTH_PASSWORD" | sed "s|\\$|\$$|g")"
    fi
}
#
#   NGINX whitelist environment variables.
#
demyx_yml_nginx_whitelist() {
    demyx_event
    demyx_app_env wp DEMYX_APP_IP_WHITELIST

    if [[ "$DEMYX_APP_IP_WHITELIST" != false ]]; then
        echo "- NGINX_WHITELIST=\${DEMYX_APP_IP_WHITELIST}
              - NGINX_WHITELIST_IP=$DEMYX_IP"
    fi
}
#
#   YAML template for the ols stack.
#
demyx_yml_ols() {
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_DOMAIN
        DEMYX_APP_DEV
        DEMYX_APP_ID
        DEMYX_APP_PATH
        DEMYX_APP_TYPE
    "

    local DEMYX_YML_OLS_DEV_CPU="\${DEMYX_APP_WP_CPU}"
    local DEMYX_YML_OLS_DEV_ENTRYPOINTS=
    local DEMYX_YML_OLS_DEV_LABELS=
    local DEMYX_YML_OLS_DEV_MEM="\${DEMYX_APP_WP_MEM}"
    local DEMYX_YML_OLS_DEV_PASSWORD=
    local DEMYX_YML_OLS_DEV_VOLUME=
    local DEMYX_YML_OLS_IMAGE=demyx/openlitespeed
    local DEMYX_YML_OLS_LABEL_ADMIN=
    local DEMYX_YML_OLS_LABEL_ASSETS=
    local DEMYX_YML_OLS_PORT=8080

    if [[ "$DEMYX_APP_DEV" = true ]]; then
        DEMYX_YML_OLS_DEV_CPU=".80"
        DEMYX_YML_OLS_DEV_MEM="$(demyx_yml_memory)"
        DEMYX_YML_OLS_DEV_PASSWORD="- DEMYX_CODE_PASSWORD=\${DEMYX_APP_DEV_PASSWORD}"
        DEMYX_YML_OLS_DEV_VOLUME="- \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_code:/home/demyx"
        DEMYX_YML_OLS_IMAGE=demyx/code-server:openlitespeed
        DEMYX_YML_OLS_PORT=8081

        if [[ "$(demyx_app_proto)" = https ]]; then
            DEMYX_YML_OLS_DEV_ENTRYPOINTS="- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.entrypoints=https\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.tls.certresolver=$(demyx_yml_resolver)\""
        else
            DEMYX_YML_OLS_DEV_ENTRYPOINTS="- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.entrypoints=http\""
        fi

        DEMYX_YML_OLS_DEV_LABELS="- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.rule=Host(\`$(demyx_app_domain)\`) && PathPrefix(\`/demyx/cs/\`)\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.middlewares=\${DEMYX_APP_COMPOSE_PROJECT}-cs-prefix\"
              - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-cs-prefix.stripprefix.prefixes=/demyx/cs/\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.service=\${DEMYX_APP_COMPOSE_PROJECT}-cs-port\"
              - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-cs-port.loadbalancer.server.port=8080\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.priority=99\"
              $DEMYX_YML_OLS_DEV_ENTRYPOINTS"
    fi

    if [[ "$(demyx_app_proto)" = https ]]; then
        DEMYX_YML_OLS_LABEL_ADMIN="- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols.entrypoints=https\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols.tls.certresolver=$(demyx_yml_resolver)\""
        DEMYX_YML_OLS_LABEL_ASSETS="- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols-assets.entrypoints=https\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols-assets.tls.certresolver=$(demyx_yml_resolver)\""
    else
        DEMYX_YML_OLS_LABEL_ADMIN="- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols.entrypoints=http\""
        DEMYX_YML_OLS_LABEL_ASSETS="- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols-assets.entrypoints=http\""
    fi

    echo "# DEMYX $DEMYX_VERSION
        networks:
          demyx:
            external: true
            name: demyx
        services:
          $(demyx_yml_service_bs)
          $(demyx_yml_service_mariadb)
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}:
            cpus: $DEMYX_YML_OLS_DEV_CPU
            depends_on:
              - db_\${DEMYX_APP_ID}
            environment:
              - DEMYX_ADMIN_IP=\${DEMYX_APP_OLS_ADMIN_IP}
              - DEMYX_ADMIN_PASSWORD=\${DEMYX_APP_OLS_ADMIN_PASSWORD}
              - DEMYX_ADMIN_USERNAME=\${DEMYX_APP_OLS_ADMIN_USERNAME}
              - DEMYX_BASIC_AUTH_PASSWORD=\${DEMYX_APP_AUTH_PASSWORD}
              - DEMYX_BASIC_AUTH_USERNAME=\${DEMYX_APP_AUTH_USERNAME}
              - DEMYX_BASIC_AUTH_WP=\${DEMYX_APP_AUTH_WP}
              - DEMYX_CACHE=\${DEMYX_APP_CACHE}
              - DEMYX_CLIENT_THROTTLE_BANDWIDTH_IN=\${DEMYX_APP_OLS_CLIENT_THROTTLE_BANDWIDTH_IN}
              - DEMYX_CLIENT_THROTTLE_BANDWIDTH_OUT=\${DEMYX_APP_OLS_CLIENT_THROTTLE_BANDWIDTH_OUT}
              - DEMYX_CLIENT_THROTTLE_BAN_PERIOD=\${DEMYX_APP_OLS_CLIENT_THROTTLE_BAN_PERIOD}
              - DEMYX_CLIENT_THROTTLE_BLOCK_BAD_REQUEST=\${DEMYX_APP_OLS_CLIENT_THROTTLE_BLOCK_BAD_REQUEST}
              - DEMYX_CLIENT_THROTTLE_DYNAMIC=\${DEMYX_APP_OLS_CLIENT_THROTTLE_DYNAMIC}
              - DEMYX_CLIENT_THROTTLE_GRACE_PERIOD=\${DEMYX_APP_OLS_CLIENT_THROTTLE_GRACE_PERIOD}
              - DEMYX_CLIENT_THROTTLE_HARD_LIMIT=\${DEMYX_APP_OLS_CLIENT_THROTTLE_HARD_LIMIT}
              - DEMYX_CLIENT_THROTTLE_SOFT_LIMIT=\${DEMYX_APP_OLS_CLIENT_THROTTLE_SOFT_LIMIT}
              - DEMYX_CLIENT_THROTTLE_STATIC=\${DEMYX_APP_OLS_CLIENT_THROTTLE_STATIC}
              - DEMYX_APP_OLS_CRAWLER_LOAD_LIMIT=\${DEMYX_APP_OLS_CRAWLER_LOAD_LIMIT}
              - DEMYX_APP_OLS_CRAWLER_USLEEP=\${DEMYX_APP_OLS_CRAWLER_USLEEP}
              - DEMYX_CRON=\${DEMYX_APP_CRON}
              - DEMYX_CRON_LOGROTATE_INTERVAL=\"\${DEMYX_APP_CRON_LOGROTATE_INTERVAL}\"
              - DEMYX_CRON_WP_INTERVAL=\"\${DEMYX_APP_CRON_WP_INTERVAL}\"
              - DEMYX_DB_HOST=\${WORDPRESS_DB_HOST}
              - DEMYX_DB_NAME=\${WORDPRESS_DB_NAME}
              - DEMYX_DB_PASSWORD=\${WORDPRESS_DB_PASSWORD}
              - DEMYX_DB_USERNAME=\${WORDPRESS_DB_USER}
              - DEMYX_DOMAIN=$(demyx_app_domain)
              - DEMYX_LOGROTATE=\${DEMYX_APP_LOGROTATE}
              - DEMYX_LOGROTATE_INTERVAL=\${DEMYX_APP_LOGROTATE_INTERVAL}
              - DEMYX_LOGROTATE_SIZE=\${DEMYX_APP_LOGROTATE_SIZE}
              - DEMYX_LSAPI_AVOID_FORK=\${DEMYX_APP_OLS_LSAPI_AVOID_FORK}
              - DEMYX_LSAPI_CHILDREN=\${DEMYX_APP_OLS_LSAPI_CHILDREN}
              - DEMYX_LSAPI_MAX_IDLE=\${DEMYX_APP_OLS_LSAPI_MAX_IDLE}
              - DEMYX_LSAPI_MAX_PROCESS_TIME=\${DEMYX_APP_OLS_LSAPI_MAX_PROCESS_TIME}
              - DEMYX_LSAPI_MAX_REQS=\${DEMYX_APP_OLS_LSAPI_MAX_REQS}
              - DEMYX_LSPHP=\${DEMYX_APP_OLS_LSPHP}
              - DEMYX_MAX_EXECUTION_TIME=\${DEMYX_APP_PHP_MAX_EXECUTION_TIME}
              - DEMYX_MEMORY=\${DEMYX_APP_PHP_MEMORY}
              - DEMYX_OPCACHE=\${DEMYX_APP_PHP_OPCACHE}
              - DEMYX_PROTO=$(demyx_app_proto)
              - DEMYX_RECAPTCHA_CONNECTION_LIMIT=\${DEMYX_APP_OLS_RECAPTCHA_CONNECTION_LIMIT}
              - DEMYX_RECAPTCHA_ENABLE=\${DEMYX_APP_OLS_RECAPTCHA_ENABLE}
              - DEMYX_RECAPTCHA_TYPE=\${DEMYX_APP_OLS_RECAPTCHA_TYPE}
              - DEMYX_TUNING_CONNECTION_TIMEOUT=\${DEMYX_APP_OLS_TUNING_CONNECTION_TIMEOUT}
              - DEMYX_TUNING_KEEP_ALIVE_TIMEOUT=\${DEMYX_APP_OLS_TUNING_KEEP_ALIVE_TIMEOUT}
              - DEMYX_TUNING_MAX_CONNECTIONS=\${DEMYX_APP_OLS_TUNING_MAX_CONNECTIONS}
              - DEMYX_TUNING_MAX_KEEP_ALIVE=\${DEMYX_APP_OLS_TUNING_MAX_KEEP_ALIVE}
              - DEMYX_TUNING_SMART_KEEP_ALIVE=\${DEMYX_APP_OLS_TUNING_SMART_KEEP_ALIVE}
              - DEMYX_UPLOAD_LIMIT=\${DEMYX_APP_UPLOAD_LIMIT}
              - DEMYX_WP_EMAIL=\${WORDPRESS_USER_EMAIL}
              - DEMYX_WP_PASSWORD=\${WORDPRESS_USER_PASSWORD}
              - DEMYX_WP_USERNAME=\${WORDPRESS_USER}
              - DEMYX_XMLRPC=\${DEMYX_APP_XMLRPC}
              - TZ=$TZ
              $DEMYX_YML_OLS_DEV_PASSWORD
            hostname: \${DEMYX_APP_COMPOSE_PROJECT}
            image: ${DEMYX_YML_OLS_IMAGE}
            labels:
              - \"traefik.enable=true\"
              $(demyx_yml_auth_label)
              $(demyx_yml_http_labels)
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols.rule=Host(\`$(demyx_app_domain)\`) && PathPrefix(\`/demyx/ols/\`)\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols.middlewares=\${DEMYX_APP_COMPOSE_PROJECT}-ols-prefix\"
              - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-ols-prefix.stripprefix.prefixes=/demyx/ols/\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols.service=\${DEMYX_APP_COMPOSE_PROJECT}-ols-port\"
              - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-ols-port.loadbalancer.server.port=${DEMYX_YML_OLS_PORT}\"
              $DEMYX_YML_OLS_LABEL_ADMIN
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols.priority=99\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols-assets.rule=Host(\`$(demyx_app_domain)\`) && PathPrefix(\`/res/\`)\"
              - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-ols-assets-prefix.stripprefix.prefixes=/demyx/ols/\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols-assets.service=\${DEMYX_APP_COMPOSE_PROJECT}-ols-assets-port\"
              - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-ols-assets-port.loadbalancer.server.port=${DEMYX_YML_OLS_PORT}\"
              $DEMYX_YML_OLS_LABEL_ASSETS
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols-assets.priority=99\"
              $DEMYX_YML_OLS_DEV_LABELS
            mem_limit: $DEMYX_YML_OLS_DEV_MEM
            networks:
              - demyx
            restart: unless-stopped
            volumes:
              - \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}:/demyx
              - \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_custom:/etc/demyx/custom
              - \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_log:/var/log/demyx
              $DEMYX_YML_OLS_DEV_VOLUME
          $(demyx_yml_service_pma)
          $(demyx_yml_service_redis)
          $(demyx_yml_service_sftp)
        volumes:
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}:
            external: true
            name: \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_code:
            external: true
            name: \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_code
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_custom:
            external: true
            name: \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_custom
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_db:
            external: true
            name: \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_db
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_log:
            external: true
            name: \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_log
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_sftp:
            external: true
            name: \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_sftp
        " | sed "s|        ||g" > "$DEMYX_APP_PATH"/docker-compose.yml
}
#
#   YAML template for the ols-bedrock stack.
#
demyx_yml_ols_bedrock() {
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_DOMAIN
        DEMYX_APP_DEV
        DEMYX_APP_ID
        DEMYX_APP_PATH
        DEMYX_APP_TYPE
    "

    local DEMYX_YML_OLS_DEV_CPU="\${DEMYX_APP_WP_CPU}"
    local DEMYX_YML_OLS_DEV_ENTRYPOINTS=
    local DEMYX_YML_OLS_DEV_LABELS=
    local DEMYX_YML_OLS_DEV_MEM="\${DEMYX_APP_WP_MEM}"
    local DEMYX_YML_OLS_DEV_PASSWORD=
    local DEMYX_YML_OLS_DEV_VOLUME=
    local DEMYX_YML_OLS_IMAGE=demyx/openlitespeed:bedrock
    local DEMYX_YML_OLS_LABEL_ADMIN=
    local DEMYX_YML_OLS_LABEL_ASSETS=
    local DEMYX_YML_OLS_PORT=8080

    if [[ "$DEMYX_APP_DEV" = true ]]; then
        DEMYX_YML_OLS_DEV_CPU=".80"
        DEMYX_YML_OLS_DEV_MEM="$(demyx_yml_memory)"
        DEMYX_YML_OLS_DEV_PASSWORD="- DEMYX_CODE_PASSWORD=\${DEMYX_APP_DEV_PASSWORD}"
        DEMYX_YML_OLS_DEV_VOLUME="- \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_code:/home/demyx"
        DEMYX_YML_OLS_IMAGE=demyx/code-server:openlitespeed-bedrock
        DEMYX_YML_OLS_PORT=8081

        if [[ "$(demyx_app_proto)" = https ]]; then
            DEMYX_YML_OLS_DEV_ENTRYPOINTS="- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.entrypoints=https\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.tls.certresolver=$(demyx_yml_resolver)\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js.entrypoints=https\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js.tls.certresolver=$(demyx_yml_resolver)\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json.entrypoints=https\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json.tls.certresolver=$(demyx_yml_resolver)\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-webpack.entrypoints=https\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-webpack.tls.certresolver=$(demyx_yml_resolver)\""
        else
            DEMYX_YML_OLS_DEV_ENTRYPOINTS="- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.entrypoints=http\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js.entrypoints=http\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json.entrypoints=http\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-webpack.entrypoints=http\""
        fi

        DEMYX_YML_OLS_DEV_LABELS="- \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-cs-prefix.stripprefix.prefixes=/demyx/cs/\"
              - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js-prefix.stripprefix.prefixes=/app.[a-z0-9].hot-update.js\"
              - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json-prefix.stripprefix.prefixes=/app.[a-z0-9].hot-update.json\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.middlewares=\${DEMYX_APP_COMPOSE_PROJECT}-cs-prefix\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.priority=99\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.rule=Host(\`$(demyx_app_domain)\`) && PathPrefix(\`/demyx/cs/\`)\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.service=\${DEMYX_APP_COMPOSE_PROJECT}-cs-port\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js.middlewares=\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js-prefix\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js.priority=99\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js.rule=(Host(\`$(demyx_app_domain)\`) && PathPrefix(\`/app.{hash:[a-z.0-9]+}.hot-update.js\`))\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js.service=\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json.middlewares=\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json-prefix\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json.priority=99\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json.rule=(Host(\`$(demyx_app_domain)\`) && PathPrefix(\`/app.{hash:[a-z.0-9]+}.hot-update.json\`))\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json.service=\${DEMYX_APP_COMPOSE_PROJECT}-json\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-webpack.priority=99\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-webpack.rule=(Host(\`$(demyx_app_domain)\`) && PathPrefix(\`/__bud/hmr\`))\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-webpack.service=\${DEMYX_APP_COMPOSE_PROJECT}-webpack\"
              - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-cs-port.loadbalancer.server.port=8080\"
              - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js.loadbalancer.server.port=3000\"
              - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-json.loadbalancer.server.port=3000\"
              - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-webpack.loadbalancer.server.port=3000\"
              $DEMYX_YML_OLS_DEV_ENTRYPOINTS"
    fi

    if [[ "$(demyx_app_proto)" = https ]]; then
        DEMYX_YML_OLS_LABEL_ADMIN="- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols.entrypoints=https\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols.tls.certresolver=$(demyx_yml_resolver)\""
        DEMYX_YML_OLS_LABEL_ASSETS="- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols-assets.entrypoints=https\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols-assets.tls.certresolver=$(demyx_yml_resolver)\""
    else
        DEMYX_YML_OLS_LABEL_ADMIN="- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols.entrypoints=http\""
        DEMYX_YML_OLS_LABEL_ASSETS="- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols-assets.entrypoints=http\""
    fi

    echo "# DEMYX $DEMYX_VERSION
        networks:
          demyx:
            external: true
            name: demyx
        services:
          $(demyx_yml_service_mariadb)
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}:
            cpus: $DEMYX_YML_OLS_DEV_CPU
            depends_on:
              - db_\${DEMYX_APP_ID}
            environment:
              - DEMYX_ADMIN_IP=\${DEMYX_APP_OLS_ADMIN_IP}
              - DEMYX_ADMIN_PASSWORD=\${DEMYX_APP_OLS_ADMIN_PASSWORD}
              - DEMYX_ADMIN_USERNAME=\${DEMYX_APP_OLS_ADMIN_USERNAME}
              - DEMYX_BASIC_AUTH_PASSWORD=\${DEMYX_APP_AUTH_PASSWORD}
              - DEMYX_BASIC_AUTH_USERNAME=\${DEMYX_APP_AUTH_USERNAME}
              - DEMYX_BASIC_AUTH_WP=\${DEMYX_APP_AUTH_WP}
              - DEMYX_BEDROCK=true
              - DEMYX_BEDROCK_MODE=\${DEMYX_APP_BEDROCK_MODE}
              - DEMYX_CACHE=\${DEMYX_APP_CACHE}
              - DEMYX_CLIENT_THROTTLE_BANDWIDTH_IN=\${DEMYX_APP_OLS_CLIENT_THROTTLE_BANDWIDTH_IN}
              - DEMYX_CLIENT_THROTTLE_BANDWIDTH_OUT=\${DEMYX_APP_OLS_CLIENT_THROTTLE_BANDWIDTH_OUT}
              - DEMYX_CLIENT_THROTTLE_BAN_PERIOD=\${DEMYX_APP_OLS_CLIENT_THROTTLE_BAN_PERIOD}
              - DEMYX_CLIENT_THROTTLE_BLOCK_BAD_REQUEST=\${DEMYX_APP_OLS_CLIENT_THROTTLE_BLOCK_BAD_REQUEST}
              - DEMYX_CLIENT_THROTTLE_DYNAMIC=\${DEMYX_APP_OLS_CLIENT_THROTTLE_DYNAMIC}
              - DEMYX_CLIENT_THROTTLE_GRACE_PERIOD=\${DEMYX_APP_OLS_CLIENT_THROTTLE_GRACE_PERIOD}
              - DEMYX_CLIENT_THROTTLE_HARD_LIMIT=\${DEMYX_APP_OLS_CLIENT_THROTTLE_HARD_LIMIT}
              - DEMYX_CLIENT_THROTTLE_SOFT_LIMIT=\${DEMYX_APP_OLS_CLIENT_THROTTLE_SOFT_LIMIT}
              - DEMYX_CLIENT_THROTTLE_STATIC=\${DEMYX_APP_OLS_CLIENT_THROTTLE_STATIC}
              - DEMYX_APP_OLS_CRAWLER_LOAD_LIMIT=\${DEMYX_APP_OLS_CRAWLER_LOAD_LIMIT}
              - DEMYX_APP_OLS_CRAWLER_USLEEP=\${DEMYX_APP_OLS_CRAWLER_USLEEP}
              - DEMYX_CRON=\${DEMYX_APP_CRON}
              - DEMYX_CRON_LOGROTATE_INTERVAL=\"\${DEMYX_APP_CRON_LOGROTATE_INTERVAL}\"
              - DEMYX_CRON_WP_INTERVAL=\"\${DEMYX_APP_CRON_WP_INTERVAL}\"
              - DEMYX_DB_HOST=\${WORDPRESS_DB_HOST}
              - DEMYX_DB_NAME=\${WORDPRESS_DB_NAME}
              - DEMYX_DB_PASSWORD=\${WORDPRESS_DB_PASSWORD}
              - DEMYX_DB_USERNAME=\${WORDPRESS_DB_USER}
              - DEMYX_DOMAIN=$(demyx_app_domain)
              - DEMYX_LOGROTATE=\${DEMYX_APP_LOGROTATE}
              - DEMYX_LOGROTATE_INTERVAL=\${DEMYX_APP_LOGROTATE_INTERVAL}
              - DEMYX_LOGROTATE_SIZE=\${DEMYX_APP_LOGROTATE_SIZE}
              - DEMYX_LSAPI_AVOID_FORK=\${DEMYX_APP_OLS_LSAPI_AVOID_FORK}
              - DEMYX_LSAPI_CHILDREN=\${DEMYX_APP_OLS_LSAPI_CHILDREN}
              - DEMYX_LSAPI_MAX_IDLE=\${DEMYX_APP_OLS_LSAPI_MAX_IDLE}
              - DEMYX_LSAPI_MAX_PROCESS_TIME=\${DEMYX_APP_OLS_LSAPI_MAX_PROCESS_TIME}
              - DEMYX_LSAPI_MAX_REQS=\${DEMYX_APP_OLS_LSAPI_MAX_REQS}
              - DEMYX_LSPHP=\${DEMYX_APP_OLS_LSPHP}
              - DEMYX_MAX_EXECUTION_TIME=\${DEMYX_APP_PHP_MAX_EXECUTION_TIME}
              - DEMYX_MEMORY=\${DEMYX_APP_PHP_MEMORY}
              - DEMYX_OPCACHE=\${DEMYX_APP_PHP_OPCACHE}
              - DEMYX_PROTO=$(demyx_app_proto)
              - DEMYX_RECAPTCHA_CONNECTION_LIMIT=\${DEMYX_APP_OLS_RECAPTCHA_CONNECTION_LIMIT}
              - DEMYX_RECAPTCHA_ENABLE=\${DEMYX_APP_OLS_RECAPTCHA_ENABLE}
              - DEMYX_RECAPTCHA_TYPE=\${DEMYX_APP_OLS_RECAPTCHA_TYPE}
              - DEMYX_TUNING_CONNECTION_TIMEOUT=\${DEMYX_APP_OLS_TUNING_CONNECTION_TIMEOUT}
              - DEMYX_TUNING_KEEP_ALIVE_TIMEOUT=\${DEMYX_APP_OLS_TUNING_KEEP_ALIVE_TIMEOUT}
              - DEMYX_TUNING_MAX_CONNECTIONS=\${DEMYX_APP_OLS_TUNING_MAX_CONNECTIONS}
              - DEMYX_TUNING_MAX_KEEP_ALIVE=\${DEMYX_APP_OLS_TUNING_MAX_KEEP_ALIVE}
              - DEMYX_TUNING_SMART_KEEP_ALIVE=\${DEMYX_APP_OLS_TUNING_SMART_KEEP_ALIVE}
              - DEMYX_UPLOAD_LIMIT=\${DEMYX_APP_UPLOAD_LIMIT}
              - DEMYX_WP_EMAIL=\${WORDPRESS_USER_EMAIL}
              - DEMYX_WP_PASSWORD=\${WORDPRESS_USER_PASSWORD}
              - DEMYX_WP_USERNAME=\${WORDPRESS_USER}
              - DEMYX_XMLRPC=\${DEMYX_APP_XMLRPC}
              $DEMYX_YML_OLS_DEV_PASSWORD
              - TZ=$TZ
            hostname: \${DEMYX_APP_COMPOSE_PROJECT}
            image: ${DEMYX_YML_OLS_IMAGE}
            labels:
              - \"traefik.enable=true\"
              $(demyx_yml_auth_label)
              $(demyx_yml_http_labels)
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols.rule=Host(\`$(demyx_app_domain)\`) && PathPrefix(\`/demyx/ols/\`)\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols.middlewares=\${DEMYX_APP_COMPOSE_PROJECT}-ols-prefix\"
              - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-ols-prefix.stripprefix.prefixes=/demyx/ols/\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols.service=\${DEMYX_APP_COMPOSE_PROJECT}-ols-port\"
              - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-ols-port.loadbalancer.server.port=${DEMYX_YML_OLS_PORT}\"
              $DEMYX_YML_OLS_LABEL_ADMIN
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols.priority=99\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols-assets.rule=Host(\`$(demyx_app_domain)\`) && PathPrefix(\`/res/\`)\"
              - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-ols-assets-prefix.stripprefix.prefixes=/demyx/ols/\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols-assets.service=\${DEMYX_APP_COMPOSE_PROJECT}-ols-assets-port\"
              - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-ols-assets-port.loadbalancer.server.port=${DEMYX_YML_OLS_PORT}\"
              $DEMYX_YML_OLS_LABEL_ASSETS
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-ols-assets.priority=99\"
              $DEMYX_YML_OLS_DEV_LABELS
            mem_limit: $DEMYX_YML_OLS_DEV_MEM
            networks:
              - demyx
            restart: unless-stopped
            volumes:
              - \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}:/demyx
              - \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_custom:/etc/demyx/custom
              - \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_log:/var/log/demyx
              $DEMYX_YML_OLS_DEV_VOLUME
          $(demyx_yml_service_pma)
          $(demyx_yml_service_redis)
          $(demyx_yml_service_sftp)
        volumes:
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}:
            external: true
            name: \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_code:
            external: true
            name: \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_code
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_custom:
            external: true
            name: \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_custom
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_db:
            external: true
            name: \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_db
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_log:
            external: true
            name: \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_log
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_sftp:
            external: true
            name: \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_sftp
        " | sed "s|        ||g" > "$DEMYX_APP_PATH"/docker-compose.yml
}
#
#   Traefik resolver.
#
demyx_yml_resolver() {
    demyx_event
    local DEMYX_YML_RESOLVER=demyx

    if [[ "$DEMYX_EMAIL" != false && "$DEMYX_CF_KEY" != false ]]; then
        DEMYX_YML_RESOLVER=demyx-cf
    fi

    echo "$DEMYX_YML_RESOLVER"
}
#
#   YAML template for the browser-sync service.
#
demyx_yml_service_bs() {
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_COMPOSE_PROJECT
        DEMYX_APP_DOMAIN
        DEMYX_APP_ID
        DEMYX_APP_NX_CONTAINER
        DEMYX_APP_STACK
        DEMYX_APP_WP_CONTAINER
    "

    if [[ "$DEMYX_APP_DEV" = true ]]; then
        local DEMYX_YML_SERVICE_BS=
        local DEMYX_YML_SERVICE_BS_PROXY=
        local DEMYX_YML_SERVICE_BS_SOCKET=
        local DEMYX_YML_SERVICE_BS_TYPE=
        DEMYX_YML_SERVICE_BS_TYPE=${DEMYX_CONFIG_FLAG_DEV_WATCH:-}
        local DEMYX_YML_SERVICE_BS_WATCH=

        if [[ "$DEMYX_YML_SERVICE_BS_TYPE" = plugins ]]; then
            DEMYX_YML_SERVICE_BS_WATCH="\"/demyx/wp-content/plugins/**/*\""
        elif [[ "$DEMYX_YML_SERVICE_BS_TYPE" = false ]]; then
            DEMYX_YML_SERVICE_BS_WATCH=
        else
            DEMYX_YML_SERVICE_BS_WATCH="\"/demyx/wp-content/themes/**/*\""
        fi

        if [[ "$(demyx_app_proto)" = https ]]; then
            DEMYX_YML_SERVICE_BS="- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-bs.entrypoints=https\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-bs.tls.certresolver=$(demyx_yml_resolver)\""
            DEMYX_YML_SERVICE_BS_SOCKET="- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-socket.entrypoints=https\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-socket.tls.certresolver=$(demyx_yml_resolver)\""
        else
            DEMYX_YML_SERVICE_BS="- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-bs.entrypoints=http\""
            DEMYX_YML_SERVICE_BS_SOCKET="- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-socket.entrypoints=http\""
        fi

        if [[ "$DEMYX_APP_STACK" = ols || "$DEMYX_APP_STACK" = ols-bedrock ]]; then
            DEMYX_YML_SERVICE_BS_PROXY="\${DEMYX_APP_WP_CONTAINER}"
        else
            DEMYX_YML_SERVICE_BS_PROXY="\${DEMYX_APP_NX_CONTAINER}"
        fi

        echo "bs_${DEMYX_APP_ID}:
            cpus: \${DEMYX_APP_WP_CPU}
            depends_on:
              - db_${DEMYX_APP_ID}
            environment:
              - DEMYX_DOMAIN_MATCH=$(demyx_app_domain)
              - DEMYX_DOMAIN_RETURN=$(demyx_app_domain)
              - DEMYX_DOMAIN_SOCKET=$(demyx_app_domain)
              - DEMYX_FILES=$DEMYX_YML_SERVICE_BS_WATCH
              - DEMYX_PATH=/demyx
              - DEMYX_PROXY=$DEMYX_YML_SERVICE_BS_PROXY
              - TZ=$TZ
            image: demyx/browsersync
            labels:
              - \"traefik.enable=true\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-bs.rule=(Host(\`$(demyx_app_domain)\`) && PathPrefix(\`/demyx/bs/\`))\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-bs.middlewares=\${DEMYX_APP_COMPOSE_PROJECT}-bs-prefix\"
              - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-bs-prefix.stripprefix.prefixes=/demyx/bs/\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-bs.service=\${DEMYX_APP_COMPOSE_PROJECT}-bs\"
              - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-bs.loadbalancer.server.port=3000\"
              $DEMYX_YML_SERVICE_BS
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-bs.priority=99\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-socket.rule=(Host(\`$(demyx_app_domain)\`) && PathPrefix(\`/browser-sync/socket.io/\`))\"
              - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-socket-prefix.stripprefix.prefixes=/demyx/bs/browser-sync/socket.io/\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-socket.service=\${DEMYX_APP_COMPOSE_PROJECT}-socket\"
              - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-socket.loadbalancer.server.port=3000\"
              $DEMYX_YML_SERVICE_BS_SOCKET
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-socket.priority=99\"
            mem_limit: \${DEMYX_APP_WP_MEM}
            networks:
              - demyx
            restart: unless-stopped
            volumes:
              - \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}:/demyx"
    fi
}
#
#   YAML template for the MariaDB service.
#
demyx_yml_service_mariadb() {
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_ID
        DEMYX_APP_TYPE
    "

    echo "db_${DEMYX_APP_ID}:
            cpus: \${DEMYX_APP_DB_CPU}
            environment:
              - DEMYX_DOMAIN=\${DEMYX_APP_DOMAIN}
              - MARIADB_CHARACTER_SET_SERVER=\${MARIADB_CHARACTER_SET_SERVER}
              - MARIADB_COLLATION_SERVER=\${MARIADB_COLLATION_SERVER}
              - MARIADB_DATABASE=\${WORDPRESS_DB_NAME}
              - MARIADB_DEFAULT_CHARACTER_SET=\${MARIADB_DEFAULT_CHARACTER_SET}
              - MARIADB_DOMAIN=\${DEMYX_APP_DOMAIN}
              - MARIADB_INNODB_BUFFER_POOL_SIZE=\${MARIADB_INNODB_BUFFER_POOL_SIZE}
              - MARIADB_INNODB_DATA_FILE_PATH=\${MARIADB_INNODB_DATA_FILE_PATH}
              - MARIADB_INNODB_FLUSH_LOG_AT_TRX_COMMIT=\${MARIADB_INNODB_FLUSH_LOG_AT_TRX_COMMIT}
              - MARIADB_INNODB_LOCK_WAIT_TIMEOUT=\${MARIADB_INNODB_LOCK_WAIT_TIMEOUT}
              - MARIADB_INNODB_LOG_BUFFER_SIZE=\${MARIADB_INNODB_LOG_BUFFER_SIZE}
              - MARIADB_INNODB_LOG_FILE_SIZE=\${MARIADB_INNODB_LOG_FILE_SIZE}
              - MARIADB_INNODB_USE_NATIVE_AIO=\${MARIADB_INNODB_USE_NATIVE_AIO}
              - MARIADB_KEY_BUFFER_SIZE=\${MARIADB_KEY_BUFFER_SIZE}
              - MARIADB_MAX_ALLOWED_PACKET=\${MARIADB_MAX_ALLOWED_PACKET}
              - MARIADB_MAX_CONNECTIONS=\${MARIADB_MAX_CONNECTIONS}
              - MARIADB_MYISAM_SORT_BUFFER_SIZE=\${MARIADB_MYISAM_SORT_BUFFER_SIZE}
              - MARIADB_NET_BUFFER_SIZE=\${MARIADB_NET_BUFFER_SIZE}
              - MARIADB_PASSWORD=\${WORDPRESS_DB_PASSWORD}
              - MARIADB_READ_BUFFER=\${MARIADB_READ_BUFFER}
              - MARIADB_READ_BUFFER_SIZE=\${MARIADB_READ_BUFFER_SIZE}
              - MARIADB_READ_RND_BUFFER_SIZE=\${MARIADB_READ_RND_BUFFER_SIZE}
              - MARIADB_ROOT_PASSWORD=\${MARIADB_ROOT_PASSWORD}
              - MARIADB_SERVER_ID=\${MARIADB_SERVER_ID}
              - MARIADB_SORT_BUFFER_SIZE=\${MARIADB_SORT_BUFFER_SIZE}
              - MARIADB_TABLE_OPEN_CACHE=\${MARIADB_TABLE_OPEN_CACHE}
              - MARIADB_USERNAME=\${WORDPRESS_DB_USER}
              - MARIADB_WRITE_BUFFER=\${MARIADB_WRITE_BUFFER}
              - TZ=$TZ
            image: demyx/mariadb
            mem_limit: \${DEMYX_APP_DB_MEM}
            networks:
              - demyx
            restart: unless-stopped
            volumes:
              - \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_db:/demyx
              - \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_log:/var/log/demyx"
}
#
#   YAML template for the phpMyAdmin service.
#
demyx_yml_service_pma() {
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_ID
        DEMYX_APP_PMA
    "

    if [[ "$(demyx_app_proto)" = https ]]; then
        DEMYX_YML_SERVICE_PMA_LABELS="- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-pma.entrypoints=$(demyx_app_proto)\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-pma.tls.certresolver=$(demyx_yml_resolver)\""
    else
        DEMYX_YML_SERVICE_PMA_LABELS="- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-pma.entrypoints=http\""
    fi

    if [[ "$DEMYX_APP_PMA" = true ]]; then
        echo "pma_${DEMYX_APP_ID}:
            cpus: \${DEMYX_APP_DB_CPU}
            environment:
              - MYSQL_ROOT_PASSWORD=\${MARIADB_ROOT_PASSWORD}
              - PMA_ABSOLUTE_URI=$(demyx_app_proto)://\${DEMYX_APP_DOMAIN}/demyx/pma/
              - PMA_HOST=db_\${DEMYX_APP_ID}
              - TZ=$TZ
              - UPLOAD_LIMIT=64M
            image: phpmyadmin/phpmyadmin
            labels:
              - \"traefik.enable=true\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-pma.rule=(Host(\`$(demyx_app_domain)\`) && PathPrefix(\`/demyx/pma/\`))\"
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-pma.middlewares=\${DEMYX_APP_COMPOSE_PROJECT}-pma-prefix\"
              - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-pma-prefix.stripprefix.prefixes=/demyx/pma/\"
              $DEMYX_YML_SERVICE_PMA_LABELS
              - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-pma.priority=99\"
            mem_limit: \${DEMYX_APP_DB_MEM}
            networks:
              - demyx
            restart: unless-stopped"
    fi
}
#
#   YAML template for the phpMyAdmin service.
#
demyx_yml_service_redis() {
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_ID
        DEMYX_APP_REDIS
    "

    if [[ "$DEMYX_APP_REDIS" = true ]]; then
        echo "rd_${DEMYX_APP_ID}:
            cpus: \${DEMYX_APP_DB_CPU}
            image: redis:alpine3.18
            mem_limit: \${DEMYX_APP_DB_MEM}
            networks:
              - demyx
            restart: unless-stopped"
    fi
}
#
#   YAML template for the SFTP service.
#
demyx_yml_service_sftp() {
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_COMPOSE_PROJECT
        DEMYX_APP_DOMAIN
        DEMYX_APP_ID
        DEMYX_APP_SFTP
        DEMYX_APP_SFTP_PASSWORD
        DEMYX_APP_SFTP_USERNAME
        DEMYX_APP_TYPE
    "

    if [[ "$DEMYX_APP_SFTP" = true ]]; then
        local DEMYX_YML_SERVICE_SFTP_PORTS=

        # shellcheck disable=2153
        if [[ ! -f "$DEMYX_TMP"/"$DEMYX_APP_DOMAIN"_sftp ]]; then
            demyx_open_port
        fi

        # shellcheck disable=2153
        DEMYX_YML_SERVICE_SFTP_PORTS="$(cat < "$DEMYX_TMP"/"$DEMYX_APP_DOMAIN"_sftp)"

        echo "sftp_${DEMYX_APP_ID}:
            cpus: \${DEMYX_APP_DB_CPU}
            environment:
              - DEMYX_DOMAIN=\${DEMYX_APP_DOMAIN}
              - DEMYX_PASSWORD=\${DEMYX_APP_SFTP_PASSWORD}
              - TZ=$TZ
            hostname: \${DEMYX_APP_COMPOSE_PROJECT}_sftp
            image: demyx/ssh
            mem_limit: \${DEMYX_APP_DB_MEM}
            networks:
              - demyx
            ports:
              - ${DEMYX_YML_SERVICE_SFTP_PORTS}:2222
            restart: unless-stopped
            volumes:
              - \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}:/demyx
              - \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_log:/var/log/demyx
              - \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_sftp:/home"
    fi
}
#
#   YAML template for traefik.
#
demyx_yml_traefik() {
    demyx_event
    demyx_source utility

    local DEMYX_YML_TRAEFIK_DASHBOARD=
    local DEMYX_YML_TRAEFIK_LABELS=
    local DEMYX_YML_TRAEFIK_SECURITY=

    if [[ "$DEMYX_TRAEFIK_DASHBOARD" = true ]]; then
        DEMYX_YML_TRAEFIK_DASHBOARD="labels:
              - \"traefik.enable=true\"
              - \"traefik.http.routers.traefik-http.entrypoints=http\"
              - \"traefik.http.routers.traefik-http.rule=Host(\`${DEMYX_TRAEFIK_DASHBOARD_DOMAIN}.${DEMYX_DOMAIN}\`)\"
              - \"traefik.http.routers.traefik-http.service=traefik-http-port\"
              - \"traefik.http.services.traefik-http-port.loadbalancer.server.port=8080\""

        if [[ "$DEMYX_TRAEFIK_SSL" = true ]]; then
            DEMYX_YML_TRAEFIK_LABELS="  - \"traefik.http.routers.traefik-http.middlewares=traefik-redirect\"
              - \"traefik.http.middlewares.traefik-redirect.redirectscheme.scheme=https\"
              - \"traefik.http.routers.traefik-https.entrypoints=https\"
              - \"traefik.http.routers.traefik-https.rule=Host(\`${DEMYX_TRAEFIK_DASHBOARD_DOMAIN}.${DEMYX_DOMAIN}\`)\"
              - \"traefik.http.routers.traefik-https.service=api@internal\"
              - \"traefik.http.routers.traefik-https.service=traefik-https-port\"
              - \"traefik.http.routers.traefik-https.tls.certresolver=$(demyx_yml_resolver)\"
              - \"traefik.http.services.traefik-https-port.loadbalancer.server.port=8080\""

            if [[ "$DEMYX_IP" != false ]]; then
                DEMYX_YML_TRAEFIK_SECURITY="  - \"traefik.http.middlewares.traefik-whitelist.ipwhitelist.sourcerange=${DEMYX_IP}\"
              - \"traefik.http.routers.traefik-https.middlewares=traefik-whitelist\""
            else
                DEMYX_YML_TRAEFIK_SECURITY="  - \"traefik.http.middlewares.traefik-auth.basicauth.users=$(demyx_utility htpasswd -r "$DEMYX_AUTH_USERNAME" "$DEMYX_AUTH_PASSWORD" | sed "s|\\$|\$$|g")\"
              - \"traefik.http.routers.traefik-https.middlewares=traefik-auth\""
            fi
        else
            if [[ "$DEMYX_IP" != false ]]; then
                DEMYX_YML_TRAEFIK_SECURITY="  - \"traefik.http.middlewares.traefik-whitelist.ipwhitelist.sourcerange=${DEMYX_IP}\"
              - \"traefik.http.routers.traefik-http.middlewares=traefik-whitelist\""
            else
                DEMYX_YML_TRAEFIK_SECURITY="  - \"traefik.http.middlewares.traefik-auth.basicauth.users=$(demyx_utility htpasswd -r "$DEMYX_AUTH_USERNAME" "$DEMYX_AUTH_PASSWORD" | sed "s|\\$|\$$|g")\"
              - \"traefik.http.routers.traefik-http.middlewares=traefik-auth\""
            fi
        fi
    fi

    if [[ ! -d "$DEMYX_TRAEFIK" ]]; then
        mkdir -p "$DEMYX_TRAEFIK"
    fi

    echo "# DEMYX $DEMYX_VERSION
        networks:
          demyx:
            external: true
            name: demyx
          demyx_socket:
            external: true
            name: demyx_socket
        services:
          traefik:
            container_name: demyx_traefik
            cpus: $DEMYX_CPU
            environment:
              - CF_API_EMAIL=$DEMYX_EMAIL
              - CF_API_KEY=$DEMYX_CF_KEY
              - DEMYX_ACME_EMAIL=$DEMYX_EMAIL
              - DEMYX_TRAEFIK_LOG=$DEMYX_TRAEFIK_LOG
              - TRAEFIK_PROVIDERS_DOCKER_ENDPOINT=$DOCKER_HOST
              - TZ=$TZ
            image: demyx/traefik
            $DEMYX_YML_TRAEFIK_DASHBOARD
            $DEMYX_YML_TRAEFIK_LABELS
            $DEMYX_YML_TRAEFIK_SECURITY
            mem_limit: $DEMYX_MEM
            networks:
              - demyx
              - demyx_socket
            ports:
              - 80:8081
              - 443:8082
            restart: unless-stopped
            volumes:
              - demyx_log:/var/log/demyx
              - demyx_traefik:/demyx
        volumes:
          demyx_log:
            external: true
            name: demyx_log
          demyx_traefik:
            $(demyx_external_volume traefik)
            name: demyx_traefik" | sed "s|        ||g" > "$DEMYX_TRAEFIK"/docker-compose.yml
}
