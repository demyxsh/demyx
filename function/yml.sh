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
            source "$DEMYX_STACK"/.env
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

        cat > "$DEMYX_WP"/"$DEMYX_APP_DOMAIN"/docker-compose.yml <<-EOF
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
                        - wp_${DEMYX_APP_ID}_db:/var/lib/mysql
                    environment:
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
                        - WORDPRESS_CONTAINER=wp_${DEMYX_APP_ID}
                        - NGINX_DOMAIN=\${DEMYX_APP_DOMAIN}
                        - NGINX_CACHE=\${DEMYX_APP_CACHE}
                        - NGINX_UPLOAD_LIMIT=\${DEMYX_APP_UPLOAD_LIMIT}
                        - NGINX_RATE_LIMIT=\${DEMYX_APP_RATE_LIMIT}
                        - NGINX_XMLRPC=\${DEMYX_APP_XMLRPC}
                        - NGINX_BASIC_AUTH=\${DEMYX_APP_AUTH_WP}${DEMYX_YML_NX_EXTRAS}
                    volumes:
                        - wp_${DEMYX_APP_ID}:/var/www/html
                        - wp_${DEMYX_APP_ID}_log:/var/log/demyx
                    labels:
                        - "traefik.enable=true"
                        $DEMYX_PROTOCOL $DEMYX_BASIC_AUTH
                wp_${DEMYX_APP_ID}:
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
                        - wp_${DEMYX_APP_ID}:/var/www/html
                        - wp_${DEMYX_APP_ID}_log:/var/log/demyx
            volumes:
                wp_${DEMYX_APP_ID}:
                    name: wp_${DEMYX_APP_ID}
                wp_${DEMYX_APP_ID}_db:
                    name: wp_${DEMYX_APP_ID}_db
                wp_${DEMYX_APP_ID}_log:
                    name: wp_${DEMYX_APP_ID}_log
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
        source "$DEMYX_STACK"/.env
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

    if [[ "$DEMYX_STACK_OUROBOROS" = true ]]; then
        DEMYX_YML_OUROBOROS='ouroboros:
                container_name: demyx_ouroboros
                image: pyouroboros/ouroboros
                cpus: ${DEMYX_STACK_CPU}
                mem_limit: ${DEMYX_STACK_MEM}
                restart: unless-stopped
                networks:
                    - demyx
                environment:
                    - SELF_UPDATE=true
                    - CLEANUP=true
                    - LATEST=true
                    - IGNORE=${DEMYX_STACK_OUROBOROS_IGNORE}
                    - TZ=America/Los_Angeles
                volumes:
                    - /var/run/docker.sock:/var/run/docker.sock:ro
        '
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
                image: traefik
                cpus: \${DEMYX_STACK_CPU}
                mem_limit: \${DEMYX_STACK_MEM}
                container_name: demyx_traefik
                restart: unless-stopped
                networks:
                    - demyx
                ports:
                    - 80:80
                    - 443:443
                volumes:
                    - /var/run/docker.sock:/var/run/docker.sock:ro
                    - demyx_traefik:/demyx
                    - demyx_log:/var/log/demyx
                environment:
                    - TRAEFIK_API=$DEMYX_STACK_API
                    - TRAEFIK_PROVIDERS_DOCKER=true
                    - TRAEFIK_PROVIDERS_DOCKER_EXPOSEDBYDEFAULT=false
                    - TRAEFIK_ENTRYPOINTS_HTTP_ADDRESS=:80
                    - TRAEFIK_ENTRYPOINTS_HTTPS_ADDRESS=:443
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
EOF
    # Stupid YAML indentations
    sed -i 's/      //' "$DEMYX_STACK"/docker-compose.yml
    sed -i 's/            /          /' "$DEMYX_STACK"/docker-compose.yml
    sed -i 's/    /  /' "$DEMYX_STACK"/docker-compose.yml
    sed -i 's/      /    /' "$DEMYX_STACK"/docker-compose.yml
    sed -i 's/  //' "$DEMYX_STACK"/docker-compose.yml
    sed -i 's/        /      /' "$DEMYX_STACK"/docker-compose.yml
}
