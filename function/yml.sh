# Demyx
# https://demyx.sh

#
#   Main function for yml generation.
#
demyx_yml() {
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
    demyx_app_env wp "
        DEMYX_APP_DOMAIN
        DEMYX_APP_DEV
        DEMYX_APP_ID
        DEMYX_APP_PATH
        DEMYX_APP_TYPE
    "

    local DEMYX_YML_BEDROCK_DEV_LABELS=
    local DEMYX_YML_BEDROCK_DEV_ENTRYPOINTS=
    local DEMYX_YML_BEDROCK_DEV_PASSWORD=
    local DEMYX_YML_BEDROCK_DEV_VOLUME=
    local DEMYX_YML_BEDROCK_IMAGE=demyx/wordpress:bedrock

    if [[ "$DEMYX_APP_DEV" = true ]]; then
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
              - \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_log:/var/log/demyx
          $(demyx_yml_service_pma)
          $(demyx_yml_service_sftp)
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}:
            cpus: \${DEMYX_APP_WP_CPU}
            depends_on:
              - db_\${DEMYX_APP_ID}
            environment:
              - DEMYX_BEDROCK_MODE=\${DEMYX_APP_BEDROCK_MODE}
              - DEMYX_CRON=\${DEMYX_APP_CRON}
              - DEMYX_CRON_WP_INTERVAL=\"\${DEMYX_APP_CRON_WP_INTERVAL}\"
              - DEMYX_CRON_LOGROTATE_INTERVAL=\"\${DEMYX_APP_CRON_LOGROTATE_INTERVAL}\"
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
            mem_limit: \${DEMYX_APP_WP_MEM}
            networks:
              - demyx
            restart: unless-stopped
            volumes:
              - \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}:/demyx
              - \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_log:/var/log/demyx
              $DEMYX_YML_BEDROCK_DEV_VOLUME
        version: \"$DEMYX_DOCKER_COMPOSE\"
        volumes:
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}:
            name: \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_code:
            name: \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_code
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_db:
            name: \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_db
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_log:
            name: \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_log
          ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_sftp:
            name: \${DEMYX_APP_TYPE}_\${DEMYX_APP_ID}_sftp
        " | sed "s|        ||g" > "$DEMYX_APP_PATH"/docker-compose.yml
}
#
#   YAML template for code-server.
#
demyx_yml_code() {
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
            name: demyx
          demyx_socket:
            name: demyx_socket
        services:
          code:
            container_name: demyx_code
            cpus: $DEMYX_CPU
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
            mem_limit: $DEMYX_MEM
            networks:
              - demyx
              - demyx_socket
            restart: unless-stopped
            volumes:
              - demyx:/demyx
              - demyx_user:/home/demyx
              - demyx_log:/var/log/demyx
        version: \"$DEMYX_DOCKER_COMPOSE\"
        volumes:
          demyx:
            name: demyx
          demyx_log:
            name: demyx_log
          demyx_user:
            name: demyx_user" | sed "s|        ||g" > "$DEMYX_CODE"/docker-compose.yml
}
#
#   YAML template for traefik http labels.
#
demyx_yml_http_labels() {
    demyx_app_env wp "
        DEMYX_APP_DOMAIN
        DEMYX_APP_DOMAIN_WWW
        DEMYX_APP_ID
    "

    local DEMYX_YML_HTTP_LABELS_RULE=
    DEMYX_YML_HTTP_LABELS_RULE="Host(\`\${DEMYX_APP_DOMAIN}\`)"
    local DEMYX_YML_HTTP_LABELS_REGEX=

    if [[ "$DEMYX_APP_DOMAIN_WWW" = true ]]; then
        DEMYX_YML_HTTP_LABELS_REGEX=www.
    fi

    if [[ "$(demyx_app_proto)" = https ]]; then
        echo "- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-http.rule=${DEMYX_YML_HTTP_LABELS_RULE}\"
      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-http.entrypoints=http\"
      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-http.service=\${DEMYX_APP_COMPOSE_PROJECT}-http-port\"
      - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-http-port.loadbalancer.server.port=80\"
      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-http.middlewares=\${DEMYX_APP_COMPOSE_PROJECT}-redirect\"
      - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-redirect.redirectregex.regex="'^https?:\\/\\/(?:www\\.)?(.+)'"\"
      - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-redirect.redirectregex.replacement=https://${DEMYX_YML_HTTP_LABELS_REGEX}\$\${1}\"
      - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-redirect.redirectregex.permanent=true\"
      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-https.rule=${DEMYX_YML_HTTP_LABELS_RULE}\"
      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-https.entrypoints=https\"
      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-https.tls.certresolver=$(demyx_yml_resolver)\"
      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-https.service=\${DEMYX_APP_COMPOSE_PROJECT}-https-port\"
      - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-https-port.loadbalancer.server.port=80\""
    else
        echo "- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-http.rule=${DEMYX_YML_HTTP_LABELS_RULE}\"
      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-http.entrypoints=http\"
      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-http.service=\${DEMYX_APP_COMPOSE_PROJECT}-http-port\"
      - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-http-port.loadbalancer.server.port=80\""
    fi
}
            environment:
              - PASSWORD=$DEMYX_CODE_PASSWORD
              - TZ=$TZ
            labels:
              - \"traefik.enable=true\"
              - \"traefik.http.routers.demyx-code-http.rule=Host(\`${DEMYX_CODE_DOMAIN}.${DEMYX_DOMAIN}\`)\"
              - \"traefik.http.routers.demyx-code-http.entrypoints=http\"
              - \"traefik.http.routers.demyx-code-http.service=demyx-code-http-port\"
              - \"traefik.http.services.demyx-code-http-port.loadbalancer.server.port=8080\"
              - \"traefik.http.routers.demyx-code-http.middlewares=demyx-code-redirect\"
              - \"traefik.http.middlewares.demyx-code-redirect.redirectscheme.scheme=https\"
              - \"traefik.http.routers.demyx-code-https.rule=Host(\`${DEMYX_CODE_DOMAIN}.${DEMYX_DOMAIN}\`)\"
              - \"traefik.http.routers.demyx-code-https.entrypoints=https\"
              - \"traefik.http.routers.demyx-code-https.tls.certresolver=${DEMYX_YML_RESOLVER}\"
              - \"traefik.http.routers.demyx-code-https.service=demyx-code-https-port\"
              - \"traefik.http.services.demyx-code-https-port.loadbalancer.server.port=8080\"
              - \"traefik.http.routers.demyx-code-https.middlewares=demyx-code-whitelist\"
              - \"traefik.http.middlewares.demyx-code-whitelist.ipwhitelist.sourcerange=${DEMYX_IP}\"
        volumes:
          demyx:
            name: demyx
          demyx_log:
            name: demyx_log
          demyx_user:
            name: demyx_user
        networks:
          demyx:
            name: demyx
          demyx_socket:
            name: demyx_socket" | sed "s|        ||g" > "$DEMYX_CODE"/docker-compose.yml
}
demyx_traefik_yml() {
    # TEMPORARY CODE
    if [[ -f "$DEMYX_APP"/stack/.env ]]; then
        source "$DEMYX_APP"/stack/.env
        DEMYX_TRAEFIK_YML="- CF_API_EMAIL=$DEMYX_STACK_ACME_EMAIL
              - CF_API_KEY=$DEMYX_STACK_CLOUDFLARE_KEY
              - DEMYX_ACME_EMAIL=$DEMYX_STACK_ACME_EMAIL"
    else
        DEMYX_TRAEFIK_YML="- CF_API_EMAIL=$DEMYX_EMAIL
              - CF_API_KEY=$DEMYX_CF_KEY
              - DEMYX_ACME_EMAIL=$DEMYX_EMAIL"
    fi

    # Copy .env from /demyx/.env
    [[ -f "$DEMYX"/.env ]] && cp -f "$DEMYX"/.env "$DEMYX_TRAEFIK"

    if [[ "$DEMYX_TRAEFIK_DASHBOARD" = true ]]; then
        DEMYX_YML_LABEL_TRAEFIK="labels:
              - \"traefik.enable=true\"
              - \"traefik.http.routers.traefik-http.rule=Host(\`${DEMYX_TRAEFIK_DASHBOARD_DOMAIN}.${DEMYX_DOMAIN}\`)\"
              - \"traefik.http.routers.traefik-http.entrypoints=http\"
              - \"traefik.http.routers.traefik-http.service=traefik-http-port\"
              - \"traefik.http.services.traefik-http-port.loadbalancer.server.port=8080\"
              - \"traefik.http.routers.traefik-http.middlewares=traefik-redirect\"
              - \"traefik.http.middlewares.traefik-redirect.redirectscheme.scheme=https\"
              - \"traefik.http.routers.traefik-https.service=api@internal\"
              - \"traefik.http.routers.traefik-https.rule=Host(\`${DEMYX_TRAEFIK_DASHBOARD_DOMAIN}.${DEMYX_DOMAIN}\`)\"
              - \"traefik.http.routers.traefik-https.entrypoints=https\"
              - \"traefik.http.routers.traefik-https.tls.certresolver=${DEMYX_YML_RESOLVER}\"
              - \"traefik.http.routers.traefik-https.service=traefik-https-port\"
              - \"traefik.http.services.traefik-https-port.loadbalancer.server.port=8080\"
              - \"traefik.http.routers.traefik-https.middlewares=traefik-auth,traefik-whitelist\"
              - \"traefik.http.middlewares.traefik-auth.basicauth.users=\${DEMYX_YML_AUTH}\"
              - \"traefik.http.middlewares.traefik-whitelist.ipwhitelist.sourcerange=${DEMYX_IP}\""
    fi

    echo "# AUTO GENERATED
        version: \"$DEMYX_DOCKER_COMPOSE\"
        services:
          traefik:
            image: demyx/traefik
            cpus: ${DEMYX_CPU}
            mem_limit: ${DEMYX_MEM}
            container_name: demyx_traefik
            restart: unless-stopped
            networks:
              - demyx
              - demyx_socket
            ports:
              - 80:8081
              - 443:8082
            volumes:
              - demyx_traefik:/demyx
              - demyx_log:/var/log/demyx
            environment:
              $DEMYX_TRAEFIK_YML
              - DEMYX_TRAEFIK_LOG=$DEMYX_TRAEFIK_LOG
              - TRAEFIK_PROVIDERS_DOCKER_ENDPOINT=$DOCKER_HOST
              - TZ=$TZ
            $DEMYX_YML_LABEL_TRAEFIK
        volumes:
          demyx_traefik:
            name: demyx_traefik
          demyx_log:
            name: demyx_log
        networks:
          demyx:
            name: demyx
          demyx_socket:
            name: demyx_socket" | sed "s|        ||g" > "$DEMYX_TRAEFIK"/docker-compose.yml
}
