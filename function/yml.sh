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

    echo "# AUTO GENERATED
        version: \"$DEMYX_DOCKER_COMPOSE\"
        services:
          traefik:
            image: demyx/traefik
            cpus: \${DEMYX_STACK_CPU}
            mem_limit: \${DEMYX_STACK_MEM}
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
              - TRAEFIK_PROVIDERS_DOCKER_ENDPOINT=tcp://demyx_socket:2375
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
        volumes:
          demyx_traefik:
            name: demyx_traefik
          demyx_log:
            name: demyx_log
        networks:
          demyx:
            name: demyx
          demyx_socket:
            name: demyx_socket" | sed "s|        ||g" > "$DEMYX_STACK"/docker-compose.yml
}
