# Demyx
# https://demyx.sh

# Set resolver
if [[ "$DEMYX_EMAIL" != false && "$DEMYX_CF_KEY" != false ]]; then
    DEMYX_YML_RESOLVER=demyx-cf
else
    DEMYX_YML_RESOLVER=demyx
fi

demyx_yml() {
    demyx_app_config
    
    if [[ "$DEMYX_APP_TYPE" = wp ]]; then
        if [[ "$DEMYX_APP_SSL" = true ]]; then
            DEMYX_YML_SUBDOMAIN_CHECK="$(dig +short "$DEMYX_APP_DOMAIN" | sed -e '1d')"
            DEMYX_YML_CLOUDFLARE_CHECK="$(curl -m 10 -svo /dev/null "$DEMYX_APP_DOMAIN" 2>&1 | grep cloudflare || true)"

            if [[ -n "$DEMYX_YML_SUBDOMAIN_CHECK" ]]; then
                DEMYX_DOMAIN_IP="$DEMYX_YML_SUBDOMAIN_CHECK"
            else
                DEMYX_DOMAIN_IP="$(dig +short "$DEMYX_APP_DOMAIN")"
            fi

            if [[ -z "$DEMYX_YML_CLOUDFLARE_CHECK" ]]; then
                if [[ "$DEMYX_SERVER_IP" != "$DEMYX_DOMAIN_IP" ]]; then
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

        if [[ "$(echo "$DEMYX_APP_DOMAIN" | awk -F '[.]' '{print $1}')" = www ]]; then
            DEMYX_YML_HOST_RULE='Host(`'"$(echo "$DEMYX_APP_DOMAIN" | sed 's|www.||g')"'`) || Host(`${DEMYX_APP_DOMAIN}`)'
            DEMYX_YML_REGEX=www.
        else
            DEMYX_YML_HOST_RULE='Host(`${DEMYX_APP_DOMAIN}`) || Host(`www.${DEMYX_APP_DOMAIN}`)'
            DEMYX_YML_REGEX=
        fi

        if [[ "$DEMYX_APP_DEV" = true ]]; then
            demyx_source yml-"$DEMYX_APP_STACK"-dev
        else
            demyx_source yml-"$DEMYX_APP_STACK"
        fi
    fi
}
demyx_code_yml() {
    echo "# AUTO GENERATED
        version: \"$DEMYX_DOCKER_COMPOSE\"
        services:
          code:
            image: demyx/code-server:browse
            cpus: ${DEMYX_CPU}
            mem_limit: ${DEMYX_MEM}
            container_name: demyx_code
            restart: unless-stopped
            hostname: code-${DEMYX_HOSTNAME}
            networks:
              - demyx
              - demyx_socket
            volumes:
              - demyx:/demyx
              - demyx_user:/home/demyx
              - demyx_log:/var/log/demyx
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
