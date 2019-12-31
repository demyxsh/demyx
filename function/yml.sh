# Demyx
# https://demyx.sh

demyx_yml() {
    demyx_app_config
    
    if [[ "$DEMYX_APP_TYPE" = wp ]]; then
        if [[ "$DEMYX_APP_SSL" = true ]]; then
            DEMYX_YML_SERVER_IP="$(curl -m 10 -s https://ipecho.net/plain)"
            DEMYX_YML_SUBDOMAIN_CHECK="$(dig +short "$DEMYX_APP_DOMAIN" | sed -e '1d')"
            DEMYX_YML_CLOUDFLARE_CHECK="$(curl -m 10 -svo /dev/null "$DEMYX_APP_DOMAIN" 2>&1 | grep cloudflare || true)"
        
            if [[ -n "$DEMYX_YML_SUBDOMAIN_CHECK" ]]; then
                DEMYX_DOMAIN_IP="$DEMYX_YML_SUBDOMAIN_CHECK"
            else
                DEMYX_DOMAIN_IP="$(dig +short "$DEMYX_APP_DOMAIN")"
            fi

            if [[ -z "$DEMYX_YML_CLOUDFLARE_CHECK" ]]; then
                if [[ "$DEMYX_YML_SERVER_IP" != "$DEMYX_DOMAIN_IP" ]]; then
                    demyx_execute -v sed -i "s|DEMYX_APP_SSL=.*|DEMYX_APP_SSL=false|g" "$DEMYX_APP_PATH"/.env; \
                        demyx_warning "$DEMYX_TARGET does not point to server's IP or isn't using a domain name!"
                fi
            fi
        fi

        if [[ "$DEMYX_COMMAND" = run ]]; then
            DEMYX_YML_RUN_CREDENTIALS='- WORDPRESS_DB_HOST=${WORDPRESS_DB_HOST}
                - WORDPRESS_DB_NAME=${WORDPRESS_DB_NAME}
                - WORDPRESS_DB_USER=${WORDPRESS_DB_USER}
                - WORDPRESS_DB_PASSWORD=${WORDPRESS_DB_PASSWORD}'
            DEMYX_YML_RUN_CREDENTIALS="$(echo "$DEMYX_YML_RUN_CREDENTIALS" | sed "s|          ||")"
        fi

        if [[ "$DEMYX_APP_DEV" = true ]]; then
            demyx_source yml-"$DEMYX_APP_STACK"-dev
        else
            demyx_source yml-"$DEMYX_APP_STACK"
        fi
    fi
}

demyx_stack_yml() {
    demyx_source stack

    if [[ "$DEMYX_STACK_API" = true ]]; then
        DEMYX_YML_LABEL_TRAEFIK='labels: 
                      - "traefik.http.routers.traefik-https.rule=Host(`${DEMYX_STACK_DOMAIN}`)" 
                      - "traefik.http.routers.traefik-https.service=api@internal"
                      - "traefik.http.routers.traefik-https.entrypoints=https"
                      - "traefik.http.routers.traefik-https.tls.certresolver=demyx"

                      - "traefik.http.routers.traefik-https.middlewares=traefik-https-auth"
                      - "traefik.http.middlewares.traefik-https-auth.basicauth.users=${DEMYX_STACK_AUTH}"'
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
                      - CLEANUP=true
                      - IGNORE=\${DEMYX_STACK_OUROBOROS_IGNORE}
                      - LABEL_ENABLE=true
                      - LATEST=true
                      - SELF_UPDATE=true
                      - TZ=$TZ
                      $DEMYX_YML_OUROBOROS_SOCKET
                    $DEMYX_YML_OUROBOROS_VOLUME"
    fi

    echo "# AUTO GENERATED
        version: \"$DEMYX_DOCKER_COMPOSE\"
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
              - TRAEFIK_ENTRYPOINTS_HTTP_FORWARDEDHEADERS_TRUSTEDIPS=\${DEMYX_STACK_TRUSTED_IPS}
              - TRAEFIK_ENTRYPOINTS_HTTPS_FORWARDEDHEADERS_TRUSTEDIPS=\${DEMYX_STACK_TRUSTED_IPS}
              $DEMYX_STACK_CHALLENGES
              - TRAEFIK_CERTIFICATESRESOLVERS_DEMYX_ACME_EMAIL=\${DEMYX_STACK_ACME_EMAIL}
              - TRAEFIK_CERTIFICATESRESOLVERS_DEMYX_ACME_STORAGE=\${DEMYX_STACK_ACME_STORAGE}
              - TRAEFIK_LOG=true
              - TRAEFIK_LOG_LEVEL=INFO
              - TRAEFIK_LOG_FILEPATH=/var/log/demyx/traefik.error.log
              - TRAEFIK_ACCESSLOG=true
              - TRAEFIK_ACCESSLOG_FILEPATH=/var/log/demyx/traefik.access.log
              - TZ=$TZ
            $DEMYX_YML_LABEL_TRAEFIK
          $DEMYX_YML_OUROBOROS
        volumes:
          demyx_traefik:
            name: demyx_traefik
          demyx_log:
            name: demyx_log
        networks:
          demyx:
            name: demyx
          $DEMYX_YML_SOCKET_NETWORK_NAME" | sed "s|        ||g" > "$DEMYX_STACK"/docker-compose.yml
}
