# Demyx
# https://demyx.sh

demyx_yml() {
    demyx_app_config

    if [[ "$DEMYX_APP_TYPE" = wp ]]; then
        DEMYX_PROTOCOL="- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-http.rule=Host(\`\${DEMYX_APP_DOMAIN}\`) || Host(\`www.\${DEMYX_APP_DOMAIN}\`)\"
                        - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-http.entrypoints=http\"
                        - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-https.middlewares=\${DEMYX_APP_COMPOSE_PROJECT}-redirect\"
                        - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-https.rule=Host(\`\${DEMYX_APP_DOMAIN}\`) || Host(\`www.\${DEMYX_APP_DOMAIN}\`)\"
                        - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-https.entrypoints=https\"
                        - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-https.tls.certresolver=demyx\"
                        - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-redirect.redirectscheme.scheme=http\""

        if [[ "$DEMYX_APP_SSL" = true ]]; then
            DEMYX_SERVER_IP="$(curl -m 10 -s https://ipecho.net/plain)"
            DEMYX_SUBDOMAIN_CHECK="$(dig +short "$DEMYX_APP_DOMAIN" | sed -e '1d')"
            DEMYX_CLOUDFLARE_CHECK="$(curl -m 10 -svo /dev/null "$DEMYX_APP_DOMAIN" 2>&1 | grep "Server: cloudflare" || true)"
        
            if [[ -n "$DEMYX_SUBDOMAIN_CHECK" ]]; then
                DEMYX_DOMAIN_IP=$DEMYX_SUBDOMAIN_CHECK
            else
                DEMYX_DOMAIN_IP="$(dig +short "$DEMYX_APP_DOMAIN")"
            fi

            if [[ "$DEMYX_SERVER_IP" = "$DEMYX_DOMAIN_IP" || -n "$DEMYX_CLOUDFLARE_CHECK" ]]; then
                DEMYX_PROTOCOL="- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-http.rule=Host(\`\${DEMYX_APP_DOMAIN}\`) || Host(\`www.\${DEMYX_APP_DOMAIN}\`)\"
                      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-http.entrypoints=http\"
                      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-http.middlewares=\${DEMYX_APP_COMPOSE_PROJECT}-redirect\"
                      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-https.rule=Host(\`\${DEMYX_APP_DOMAIN}\`) || Host(\`www.\${DEMYX_APP_DOMAIN}\`)\"
                      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-https.entrypoints=https\"
                      - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-https.tls.certresolver=demyx\"
                      - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-redirect.redirectscheme.scheme=https\""
            else
                sed -i "s|DEMYX_APP_SSL=.*|DEMYX_APP_SSL=false|g" "$DEMYX_APP_PATH"/.env
                echo -e "\e[33m[WARNING]\e[39m $DEMYX_TARGET does not point to server's IP or isn't using a domain name!"
            fi
        fi
        
        DEMYX_YML_AUTH_CHECK="$(demyx info "$DEMYX_APP_DOMAIN" --filter=DEMYX_APP_AUTH)"

        if [[ "$DEMYX_YML_AUTH_CHECK" = true && -f "$DEMYX_STACK"/.env ]]; then
            demyx_source stack
            DEMYX_PARSE_BASIC_AUTH="$(grep -s DEMYX_STACK_AUTH "$DEMYX_STACK"/.env | awk -F '[=]' '{print $2}' | sed 's/\$/$$/g')"
            DEMYX_BASIC_AUTH="
                        - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-https.middlewares=\${DEMYX_APP_COMPOSE_PROJECT}-auth\"
                        - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-auth.basicauth.users=${DEMYX_PARSE_BASIC_AUTH}\""
        fi

        if [[ "$DEMYX_APP_WP_IMAGE" = demyx/wordpress:bedrock ]]; then
            DEMYX_YML_NX_EXTRAS+='
                        - WORDPRESS_BEDROCK=true'
            DEMYX_YML_WP_EXTRAS+='
                        - WORDPRESS_SSL=${DEMYX_APP_SSL}
                        - WORDPRESS_BEDROCK_MODE=${DEMYX_APP_BEDROCK_MODE}'
        fi

        if [[ "$DEMYX_COMMAND" = run ]]; then
            DEMYX_YML_WP_EXTRAS+='
                        - WORDPRESS_DB_HOST=${WORDPRESS_DB_HOST}
                        - WORDPRESS_DB_NAME=${WORDPRESS_DB_NAME}
                        - WORDPRESS_DB_USER=${WORDPRESS_DB_USER}
                        - WORDPRESS_DB_PASSWORD=${WORDPRESS_DB_PASSWORD}'
        fi

        if [[ "$DEMYX_APP_DEV" = true ]]; then
            DEMYX_YML_DEV_VOLUME="demyx_cs:
                    name: demyx_cs"
            if [[ "$DEMYX_APP_WP_IMAGE" = demyx/wordpress ]]; then
                if [[ -n "$DEMYX_CONFIG_EXPOSE" || -n "$(demyx_validate_ip)" ]]; then
                    DEMYX_YML_CODE_SERVER_BASE_PREFIX=false
                    DEMYX_CONFIG_DEV_BASE_PATH=false
                    DEMYX_YML_BROWSERSYNC_PREFIX=false
                    DEMYX_YML_WP_SERVICE_EXTRAS="ports:
                        - ${DEMYX_CONFIG_DEV_CS_PORT}:8080"
                    DEMYX_YML_BS_SERVICE_EXTRAS="ports:
                        - ${DEMYX_CONFIG_DEV_BS_PORT}:3000"
                    DEMYX_YML_BS_DOMAIN_MATCH="$DEMYX_CONFIG_DEV_PROTO"
                    DEMYX_YML_BS_DOMAIN_RETURN="$DEMYX_CONFIG_DEV_BS_URI"
                    DEMYX_YML_BS_DOMAIN_SOCKET="$DEMYX_CONFIG_DEV_BS_URI"
                else
                    DEMYX_YML_BS_DOMAIN_MATCH="$DEMYX_APP_DOMAIN"
                    DEMYX_YML_BS_DOMAIN_RETURN="$DEMYX_APP_DOMAIN"
                    DEMYX_YML_BS_DOMAIN_SOCKET="$DEMYX_APP_DOMAIN"
                    DEMYX_YML_CODE_SERVER_BASE_PREFIX=
                    DEMYX_YML_WP_SERVICE_EXTRAS="labels:
                        - \"traefik.enable=true\"
                        - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.rule=(Host(\`\${DEMYX_APP_DOMAIN}\`) && PathPrefix(\`${DEMYX_CONFIG_DEV_BASE_PATH}/cs/\`))\"
                        - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.middlewares=\${DEMYX_APP_COMPOSE_PROJECT}-cs-prefix\"
                        - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-cs-prefix.stripprefix.prefixes=${DEMYX_CONFIG_DEV_BASE_PATH}/cs/\"
                        - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.service=\${DEMYX_APP_COMPOSE_PROJECT}-cs\"
                        - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-cs.loadbalancer.server.port=8080\"
                        - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.priority=99\"
                        $DEMYX_CONFIG_DEV_CS_LABELS"
                    DEMYX_YML_BS_SERVICE_EXTRAS="labels:
                        - \"traefik.enable=true\"
                        - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-bs.rule=(Host(\`\${DEMYX_APP_DOMAIN}\`) && PathPrefix(\`${DEMYX_CONFIG_DEV_BASE_PATH}/bs/\`))\"
                        - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-bs.middlewares=\${DEMYX_APP_COMPOSE_PROJECT}-bs-prefix\"
                        - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-bs-prefix.stripprefix.prefixes=${DEMYX_CONFIG_DEV_BASE_PATH}/bs/\"
                        - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-bs.service=\${DEMYX_APP_COMPOSE_PROJECT}-bs\"
                        - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-bs.loadbalancer.server.port=3000\"
                        - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-bs.priority=99\"
                        $DEMYX_CONFIG_DEV_BS_LABELS
                        - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-socket.rule=(Host(\`\${DEMYX_APP_DOMAIN}\`) && PathPrefix(\`/browser-sync/socket.io/\`))\"
                        - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-socket-prefix.stripprefix.prefixes=${DEMYX_CONFIG_DEV_BASE_PATH}/bs/browser-sync/socket.io/\"
                        - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-socket.service=\${DEMYX_APP_COMPOSE_PROJECT}-socket\"
                        - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-socket.loadbalancer.server.port=3000\"
                        - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-socket.priority=99\"
                        $DEMYX_CONFIG_DEV_BS_SOCKET_LABELS"
                fi
                
                DEMYX_YML_WP_SERVICE="wp_${DEMYX_APP_ID}:
                    image: $DEMYX_CONFIG_DEV_IMAGE
                    cpus: \${DEMYX_APP_WP_CPU}
                    mem_limit: \${DEMYX_APP_WP_MEM}
                    restart: unless-stopped
                    hostname: \${DEMYX_APP_COMPOSE_PROJECT}
                    networks:
                        - demyx
                    environment:
                        - PASSWORD=$DEMYX_CONFIG_DEV_PASSWORD
                        - CODE_SERVER_BASE_PATH=$DEMYX_CONFIG_DEV_BASE_PATH
                        - CODE_SERVER_BASE_PREFIX=$DEMYX_YML_CODE_SERVER_BASE_PREFIX
                    volumes:
                        - demyx_cs:/home/demyx
                        - wp_${DEMYX_APP_ID}:/demyx
                        - wp_${DEMYX_APP_ID}_log:/var/log/demyx
                    $DEMYX_YML_WP_SERVICE_EXTRAS
                bs_${DEMYX_APP_ID}:
                    image: demyx/browsersync
                    cpus: \${DEMYX_APP_WP_CPU}
                    mem_limit: \${DEMYX_APP_WP_MEM}
                    restart: unless-stopped
                    networks:
                        - demyx
                    environment:
                        - BROWSERSYNC_DOMAIN_MATCH=$DEMYX_YML_BS_DOMAIN_MATCH
                        - BROWSERSYNC_DOMAIN_RETURN=$DEMYX_YML_BS_DOMAIN_RETURN
                        - BROWSERSYNC_DOMAIN_SOCKET=$DEMYX_YML_BS_DOMAIN_SOCKET
                        - BROWSERSYNC_PROXY=$DEMYX_APP_NX_CONTAINER
                        - BROWSERSYNC_FILES=$DEMYX_BS_FILES
                        - BROWSERSYNC_PATH=$DEMYX_CONFIG_DEV_BASE_PATH
                        - BROWSERSYNC_PREFIX=$DEMYX_YML_BROWSERSYNC_PREFIX
                    volumes:
                        - wp_${DEMYX_APP_ID}:/demyx
                    $DEMYX_YML_BS_SERVICE_EXTRAS"
            else
                DEMYX_YML_WP_SERVICE="wp_${DEMYX_APP_ID}:
                        image: $DEMYX_CONFIG_DEV_IMAGE
                        cpus: \${DEMYX_APP_WP_CPU}
                        mem_limit: \${DEMYX_APP_WP_MEM}
                        restart: unless-stopped
                        hostname: \${DEMYX_APP_COMPOSE_PROJECT}
                        networks:
                            - demyx
                        environment:
                            - PASSWORD=$DEMYX_CONFIG_DEV_PASSWORD
                            - CODE_SERVER_BASE_PATH=$DEMYX_CONFIG_DEV_BASE_PATH
                            - BROWSERSYNC_PROXY=\${DEMYX_APP_NX_CONTAINER}
                        volumes:
                            - demyx_cs:/home/demyx
                            - wp_${DEMYX_APP_ID}:/demyx
                            - wp_${DEMYX_APP_ID}_log:/var/log/demyx
                        labels:
                            - \"traefik.enable=true\"
                            # code-server
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.rule=(Host(\`\${DEMYX_APP_DOMAIN}\`) && PathPrefix(\`${DEMYX_CONFIG_DEV_BASE_PATH}/cs/\`))\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.entrypoints=https\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.middlewares=\${DEMYX_APP_COMPOSE_PROJECT}-cs-prefix\"
                            - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-cs-prefix.stripprefix.prefixes=${DEMYX_CONFIG_DEV_BASE_PATH}/cs/\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.service=\${DEMYX_APP_COMPOSE_PROJECT}-cs\"
                            - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-cs.loadbalancer.server.port=8080\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.priority=99\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-cs.tls.certresolver=demyx\"
                            # browsersync
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-bs.rule=(Host(\`\${DEMYX_APP_DOMAIN}\`) && PathPrefix(\`${DEMYX_CONFIG_DEV_BASE_PATH}/bs/\`))\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-bs.entrypoints=https\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-bs.middlewares=\${DEMYX_APP_COMPOSE_PROJECT}-bs-prefix\"
                            - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-bs-prefix.stripprefix.prefixes=${DEMYX_CONFIG_DEV_BASE_PATH}/bs/\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-bs.service=\${DEMYX_APP_COMPOSE_PROJECT}-bs\"
                            - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-bs.loadbalancer.server.port=3000\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-bs.priority=99\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-bs.tls.certresolver=demyx\"
                            # browsersync socket
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-socket.rule=(Host(\`\${DEMYX_APP_DOMAIN}\`) && PathPrefix(\`/browser-sync/socket.io/\`))\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-socket.entrypoints=https\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-socket.middlewares=\${DEMYX_APP_COMPOSE_PROJECT}-socket-prefix\"
                            - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-socket-prefix.stripprefix.prefixes=${DEMYX_CONFIG_DEV_BASE_PATH}/bs/browser-sync/socket.io/\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-socket.service=\${DEMYX_APP_COMPOSE_PROJECT}-socket\"
                            - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-socket.loadbalancer.server.port=3000\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-socket.priority=99\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-socket.tls.certresolver=demyx\"
                            # webpack
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-webpack.rule=(Host(\`\${DEMYX_APP_DOMAIN}\`) && PathPrefix(\`/__webpack_hmr\`))\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-webpack.entrypoints=https\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-webpack.middlewares=\${DEMYX_APP_COMPOSE_PROJECT}-webpack-prefix\"
                            - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-webpack-prefix.stripprefix.prefixes=${DEMYX_CONFIG_DEV_BASE_PATH}/bs/__webpack_hmr\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-webpack.service=\${DEMYX_APP_COMPOSE_PROJECT}-webpack\"
                            - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-webpack.loadbalancer.server.port=3000\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-webpack.priority=99\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-webpack.tls.certresolver=demyx\"
                            # hot-update.js
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js.rule=(Host(\`\${DEMYX_APP_DOMAIN}\`) && PathPrefix(\`/app/themes/{path:[a-z0-9]+}/dist/{hash:[a-z.0-9]+}.hot-update.js\`))\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js.entrypoints=https\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js.middlewares=\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js-prefix\"
                            - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js-prefix.stripprefix.prefixes=${DEMYX_CONFIG_DEV_BASE_PATH}/bs/app/themes/[a-z0-9]/dist/[a-z.0-9].hot-update.js\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js.service=\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js\"
                            - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js.loadbalancer.server.port=3000\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js.priority=99\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js.tls.certresolver=demyx\"
                            # hot-update.json
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json.rule=(Host(\`\${DEMYX_APP_DOMAIN}\`) && PathPrefix(\`/app/themes/{path:[a-z0-9]+}/dist/{hash:[a-z.0-9]+}.hot-update.json\`))\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json.entrypoints=https\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json.middlewares=\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json-prefix\"
                            - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json-prefix.stripprefix.prefixes=${DEMYX_CONFIG_DEV_BASE_PATH}/bs/app/themes/[a-z0-9]/dist/[a-z.0-9].hot-update.json\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json.service=\${DEMYX_APP_COMPOSE_PROJECT}-json\"
                            - \"traefik.http.services.\${DEMYX_APP_COMPOSE_PROJECT}-json.loadbalancer.server.port=3000\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json.priority=99\"
                            - \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json.tls.certresolver=demyx\""
            fi
        else
            DEMYX_YML_WP_SERVICE="wp_${DEMYX_APP_ID}:
                    image: \${DEMYX_APP_WP_IMAGE}
                    cpus: \${DEMYX_APP_WP_CPU}
                    mem_limit: \${DEMYX_APP_WP_MEM}
                    restart: unless-stopped
                    networks:
                        - demyx
                    environment:
                        - TZ=America/Los_Angeles
                        - WORDPRESS_DOMAIN=\${DEMYX_APP_DOMAIN}
                        - WORDPRESS_UPLOAD_LIMIT=\${DEMYX_APP_UPLOAD_LIMIT}
                        - WORDPRESS_PHP_MEMORY=\${DEMYX_APP_PHP_MEMORY}
                        - WORDPRESS_PHP_MAX_EXECUTION_TIME=\${DEMYX_APP_PHP_MAX_EXECUTION_TIME}
                        - WORDPRESS_PHP_OPCACHE=\${DEMYX_APP_PHP_OPCACHE}
                        - WORDPRESS_PHP_PM=\${DEMYX_APP_PHP_PM}
                        - WORDPRESS_PHP_PM_MAX_CHILDREN=\${DEMYX_APP_PHP_PM_MAX_CHILDREN}
                        - WORDPRESS_PHP_PM_START_SERVERS=\${DEMYX_APP_PHP_PM_START_SERVERS}
                        - WORDPRESS_PHP_PM_MIN_SPARE_SERVERS=\${DEMYX_APP_PHP_PM_MIN_SPARE_SERVERS}
                        - WORDPRESS_PHP_PM_MAX_SPARE_SERVERS=\${DEMYX_APP_PHP_PM_MAX_SPARE_SERVERS}
                        - WORDPRESS_PHP_PM_PROCESS_IDLE_TIMEOUT=\${DEMYX_APP_PHP_PM_PROCESS_IDLE_TIMEOUT}
                        - WORDPRESS_PHP_PM_MAX_REQUESTS=\${DEMYX_APP_PHP_PM_MAX_REQUESTS}${DEMYX_YML_WP_EXTRAS}
                    volumes:
                        - wp_${DEMYX_APP_ID}:/demyx
                        - wp_${DEMYX_APP_ID}_log:/var/log/demyx"
        fi

        cat > "$DEMYX_APP_PATH"/docker-compose.yml <<-EOF
            # AUTO GENERATED
            version: "$DEMYX_DOCKER_COMPOSE"
            services:
                db_${DEMYX_APP_ID}:
                    image: demyx/mariadb:edge
                    cpus: \${DEMYX_APP_DB_CPU}
                    mem_limit: \${DEMYX_APP_DB_MEM}
                    restart: unless-stopped
                    networks:
                        - demyx
                    volumes:
                        - wp_${DEMYX_APP_ID}_db:/demyx
                        - wp_${DEMYX_APP_ID}_log:/var/log/demyx
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
                        - MARIADB_LOG_BIN=\${MARIADB_LOG_BIN}
                        - MARIADB_BINLOG_FORMAT=\${MARIADB_BINLOG_FORMAT}
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
                        - TZ=America/Los_Angeles
                nx_${DEMYX_APP_ID}:
                    image: demyx/nginx
                    cpus: \${DEMYX_APP_WP_CPU}
                    mem_limit: \${DEMYX_APP_WP_MEM}
                    restart: unless-stopped
                    networks:
                        - demyx
                    environment:
                        - TZ=America/Los_Angeles
                        - WORDPRESS=true
                        - WORDPRESS_CONTAINER=\${DEMYX_APP_WP_CONTAINER}
                        - NGINX_DOMAIN=\${DEMYX_APP_DOMAIN}
                        - NGINX_CACHE=\${DEMYX_APP_CACHE}
                        - NGINX_UPLOAD_LIMIT=\${DEMYX_APP_UPLOAD_LIMIT}
                        - NGINX_RATE_LIMIT=\${DEMYX_APP_RATE_LIMIT}
                        - NGINX_XMLRPC=\${DEMYX_APP_XMLRPC}
                        - NGINX_BASIC_AUTH=\${DEMYX_APP_AUTH_WP}${DEMYX_YML_NX_EXTRAS}
                    volumes:
                        - wp_${DEMYX_APP_ID}:/demyx
                        - wp_${DEMYX_APP_ID}_log:/var/log/demyx
                    labels:
                        - "traefik.enable=true"
                        $DEMYX_PROTOCOL $DEMYX_BASIC_AUTH
                $DEMYX_YML_WP_SERVICE
            volumes:
                wp_${DEMYX_APP_ID}:
                    name: wp_${DEMYX_APP_ID}
                wp_${DEMYX_APP_ID}_db:
                    name: wp_${DEMYX_APP_ID}_db
                wp_${DEMYX_APP_ID}_log:
                    name: wp_${DEMYX_APP_ID}_log
                $DEMYX_YML_DEV_VOLUME
            networks:
                demyx:
                    name: demyx
EOF
        # Stupid YAML indentations
        sed -i 's/        //' "$DEMYX_WP"/"$DEMYX_APP_DOMAIN"/docker-compose.yml
        sed -i 's/            /          /' "$DEMYX_WP"/"$DEMYX_APP_DOMAIN"/docker-compose.yml
        sed -i 's/    /  /' "$DEMYX_WP"/"$DEMYX_APP_DOMAIN"/docker-compose.yml
        sed -i 's/      /    /' "$DEMYX_WP"/"$DEMYX_APP_DOMAIN"/docker-compose.yml
        sed -i 's/  //' "$DEMYX_WP"/"$DEMYX_APP_DOMAIN"/docker-compose.yml
        sed -i 's/        /      /' "$DEMYX_WP"/"$DEMYX_APP_DOMAIN"/docker-compose.yml
    fi
}
demyx_stack_yml() {
    if [[ -f "$DEMYX_STACK"/.env ]]; then
        DEMYX_PARSE_BASIC_AUTH="$(grep -s DEMYX_STACK_AUTH "$DEMYX_STACK"/.env | awk -F '[=]' '{print $2}')"
        demyx_source stack
        DEMYX_STACK_AUTH="$DEMYX_PARSE_BASIC_AUTH"
    fi

    if [[ "$DEMYX_STACK_CLOUDFLARE" = true ]]; then
        DEMYX_STACK_CHALLENGES="- TRAEFIK_CERTIFICATESRESOLVERS_DEMYX_ACME_DNSCHALLENGE=true
                    - TRAEFIK_CERTIFICATESRESOLVERS_DEMYX_ACME_DNSCHALLENGE_PROVIDER=cloudflare
                    - TRAEFIK_CERTIFICATESRESOLVERS_DEMYX_ACME_DNSCHALLENGE_DELAYBEFORECHECK=5
                    - TRAEFIK_CERTIFICATESRESOLVERS_DEMYX_ACME_DNSCHALLENGE_RESOLVERS=1.1.1.1
                    - CF_API_EMAIL=\${DEMYX_STACK_CLOUDFLARE_EMAIL}
                    - CF_API_KEY=\${DEMYX_STACK_CLOUDFLARE_KEY}"
    else
        DEMYX_STACK_CHALLENGES="- TRAEFIK_CERTIFICATESRESOLVERS_DEMYX_ACME_HTTPCHALLENGE=true
                    - TRAEFIK_CERTIFICATESRESOLVERS_DEMYX_ACME_HTTPCHALLENGE_ENTRYPOINT=http"
    fi

    # Will remove this backwards compability in January 1st, 2020
    if [[ "$(demyx_check_docker_sock)" = volume ]]; then
        DEMYX_YML_TRAEFIK=traefik
        DEMYX_YML_TRAEFIK_PORTS="ports:
                    - 80:80
                    - 443:443"
        DEMYX_YML_TRAEFIK_ENVIRONMENT="- TRAEFIK_ENTRYPOINTS_HTTP_ADDRESS=:80
                    - TRAEFIK_ENTRYPOINTS_HTTPS_ADDRESS=:443"
        DEMYX_YML_TRAEFIK_SOCKET="- /var/run/docker.sock:/var/run/docker.sock:ro"
        DEMYX_YML_OUROBOROS_IMAGE=pyouroboros/ouroboros
        DEMYX_YML_OUROBOROS_VOLUME="volumes:
                    - /var/run/docker.sock:/var/run/docker.sock:ro"
    else
        DEMYX_YML_TRAEFIK=demyx/traefik
        DEMYX_YML_TRAEFIK_PORTS="ports:
                    - 80:8081
                    - 443:8082"
        DEMYX_YML_TRAEFIK_ENVIRONMENT="- TRAEFIK_PROVIDERS_DOCKER_ENDPOINT=tcp://demyx_socket:2375"
        DEMYX_YML_OUROBOROS_IMAGE=demyx/ouroboros
        DEMYX_YML_OUROBOROS_SOCKET="- DOCKER_SOCKETS=tcp://demyx_socket:2375"
        DEMYX_YML_SOCKET_NETWORK="- demyx_socket"
        DEMYX_YML_SOCKET_NETWORK_NAME="demyx_socket:
                name: demyx_socket"
    fi

    if [[ "$DEMYX_STACK_OUROBOROS" = true ]]; then
        DEMYX_YML_OUROBOROS="ouroboros:
                container_name: demyx_ouroboros
                image: $DEMYX_YML_OUROBOROS_IMAGE
                cpus: \${DEMYX_STACK_CPU}
                mem_limit: \${DEMYX_STACK_MEM}
                restart: unless-stopped
                networks:
                    - demyx
                    $DEMYX_YML_SOCKET_NETWORK
                environment:
                    - SELF_UPDATE=true
                    - CLEANUP=true
                    - LATEST=true
                    - IGNORE=\${DEMYX_STACK_OUROBOROS_IGNORE}
                    - TZ=America/Los_Angeles
                    $DEMYX_YML_OUROBOROS_SOCKET
                $DEMYX_YML_OUROBOROS_VOLUME"
    fi

    if [[ "$DEMYX_STACK_API" = true ]]; then
        DEMYX_STACK_TRAEFIK_LABEL='labels:
                    - "traefik.enable=true"
                    - "traefik.http.routers.traefik-http.rule=Host(`traefik.${DEMYX_STACK_DOMAIN}`)"
                    - "traefik.http.routers.traefik-http.entrypoints=http"
                    - "traefik.http.routers.traefik-http.middlewares=traefik-redirect"
                    - "traefik.http.routers.traefik-https.rule=Host(`traefik.${DEMYX_STACK_DOMAIN}`)"
                    - "traefik.http.routers.traefik-https.entrypoints=https"
                    - "traefik.http.routers.traefik-https.service=api@internal"
                    - "traefik.http.routers.traefik-https.tls.certresolver=demyx"
                    - "traefik.http.routers.traefik-https.middlewares=traefik-auth"
                    - "traefik.http.middlewares.traefik-auth.basicauth.users=${DEMYX_STACK_AUTH}"
                    - "traefik.http.middlewares.traefik-redirect.redirectscheme.scheme=https"'
    fi

    cat > "$DEMYX_STACK"/docker-compose.yml <<-EOF
        # AUTO GENERATED
        version: "$DEMYX_DOCKER_COMPOSE"
        services:
            traefik:
                image: ${DEMYX_YML_TRAEFIK}
                cpus: \${DEMYX_STACK_CPU}
                mem_limit: \${DEMYX_STACK_MEM}
                container_name: demyx_traefik
                restart: unless-stopped
                networks:
                    - demyx
                    $DEMYX_YML_SOCKET_NETWORK
                $DEMYX_YML_TRAEFIK_PORTS
                volumes:
                    - demyx_traefik:/demyx
                    - demyx_log:/var/log/demyx
                    $DEMYX_YML_TRAEFIK_SOCKET
                environment:
                    $DEMYX_YML_TRAEFIK_ENVIRONMENT
                    - TRAEFIK_API=$DEMYX_STACK_API
                    - TRAEFIK_PROVIDERS_DOCKER=true
                    - TRAEFIK_PROVIDERS_DOCKER_EXPOSEDBYDEFAULT=false
                    $DEMYX_STACK_CHALLENGES
                    - TRAEFIK_CERTIFICATESRESOLVERS_DEMYX_ACME_EMAIL=\${DEMYX_STACK_ACME_EMAIL}
                    - TRAEFIK_CERTIFICATESRESOLVERS_DEMYX_ACME_STORAGE=\${DEMYX_STACK_ACME_STORAGE}
                    - TRAEFIK_LOG=true
                    - TRAEFIK_LOG_LEVEL=INFO
                    - TRAEFIK_LOG_FILEPATH=/var/log/demyx/traefik.error.log
                    - TRAEFIK_ACCESSLOG=true
                    - TRAEFIK_ACCESSLOG_FILEPATH=/var/log/demyx/traefik.access.log
                    - TZ=America/Los_Angeles
                $DEMYX_STACK_TRAEFIK_LABEL
            $DEMYX_YML_OUROBOROS
        volumes:
            demyx_traefik:
                name: demyx_traefik
            demyx_log:
                name: demyx_log
        networks:
            demyx:
                name: demyx
            $DEMYX_YML_SOCKET_NETWORK_NAME
EOF
    # Stupid YAML indentations
    sed -i 's/      //' "$DEMYX_STACK"/docker-compose.yml
    sed -i 's/            /          /' "$DEMYX_STACK"/docker-compose.yml
    sed -i 's/    /  /' "$DEMYX_STACK"/docker-compose.yml
    sed -i 's/      /    /' "$DEMYX_STACK"/docker-compose.yml
    sed -i 's/  //' "$DEMYX_STACK"/docker-compose.yml
    sed -i 's/        /      /' "$DEMYX_STACK"/docker-compose.yml
}
