#!/bin/bash
# Demyx
# https://demyx.sh

# Set resolver
if [[ "$DEMYX_EMAIL" != false && "$DEMYX_CF_KEY" != false ]]; then
    DEMYX_YML_RESOLVER=demyx-cf
else
    DEMYX_YML_RESOLVER=demyx
fi

# Generate basic auth
echo "DEMYX_YML_AUTH=$(demyx util --user=$DEMYX_AUTH_USERNAME --htpasswd=$DEMYX_AUTH_PASSWORD --raw)" > "$DEMYX"/.env

# Set label for api if conditions are met
if [[ "$DEMYX_DOMAIN" != false && "$DEMYX_API" != false ]]; then
    DEMYX_YML_LABELS="labels:
      - \"traefik.enable=true\"
      - \"traefik.http.middlewares.demyx-auth-http.basicauth.users=\${DEMYX_YML_AUTH}\"
      - \"traefik.http.middlewares.demyx-auth-https.basicauth.users=\${DEMYX_YML_AUTH}\"
      - \"traefik.http.middlewares.demyx-redirect.redirectregex.permanent=true\"
      - \"traefik.http.middlewares.demyx-redirect.redirectregex.regex=^https?:\/\/(?:www\\\\.)?(.+)\"
      - \"traefik.http.middlewares.demyx-redirect.redirectregex.replacement=https://\$\${1}\"
      - \"traefik.http.routers.demyx-http.entrypoints=http\"
      - \"traefik.http.routers.demyx-http.middlewares=demyx-redirect\"
      - \"traefik.http.routers.demyx-http.rule=Host(\`${DEMYX_API}.${DEMYX_DOMAIN}\`)\"
      - \"traefik.http.routers.demyx-http.service=demyx-http-port\"
      - \"traefik.http.routers.demyx-https.entrypoints=https\"
      - \"traefik.http.routers.demyx-https.middlewares=demyx-auth-http\"
      - \"traefik.http.routers.demyx-https.middlewares=demyx-auth-https\"
      - \"traefik.http.routers.demyx-https.rule=Host(\`${DEMYX_API}.${DEMYX_DOMAIN}\`)\"
      - \"traefik.http.routers.demyx-https.service=demyx-https-port\"
      - \"traefik.http.routers.demyx-https.tls.certresolver=${DEMYX_YML_RESOLVER}\"
      - \"traefik.http.services.demyx-http-port.loadbalancer.server.port=8080\"
      - \"traefik.http.services.demyx-https-port.loadbalancer.server.port=8080\""

      # IP whitelisting
      #- \"traefik.http.routers.demyx-https.middlewares=demyx-auth,demyx-whitelist\"
      #- \"traefik.http.middlewares.demyx-whitelist.ipwhitelist.sourcerange=${DEMYX_IP}\"
fi

# Use privilege flag if host OS isn't Alpine/Debian/Ubuntu
DEMYX_YML_UNAME="$(uname -a)"
DEMYX_YML_UNAME_ALPINE="$(echo "$DEMYX_YML_UNAME" | grep Alpine || true)"
DEMYX_YML_UNAME_DEBIAN="$(echo "$DEMYX_YML_UNAME" | grep Debian || true)"
DEMYX_YML_UNAME_UBUNTU="$(echo "$DEMYX_YML_UNAME" | grep Ubuntu || true)"
DEMYX_YML_PRIVILEGED="privileged: true"
[[ -n "$DEMYX_YML_UNAME_ALPINE" || -n "$DEMYX_YML_UNAME_DEBIAN" || -n "$DEMYX_YML_UNAME_UBUNTU" ]] && DEMYX_YML_PRIVILEGED=

# Generate /demyx/docker-compose.yml
echo "# AUTO GENERATED
version: \"2.4\"
services:
  socket:
    image: demyx/docker-socket-proxy
    cpus: $DEMYX_CPU
    mem_limit: $DEMYX_MEM
    container_name: demyx_socket
    restart: unless-stopped
    networks:
      - demyx_socket
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      - BUILD=1
      - CONTAINERS=1
      - EXEC=1
      - IMAGES=1
      - INFO=1
      - NETWORKS=1
      - POST=1
      - VOLUMES=1
    $DEMYX_YML_PRIVILEGED
  demyx:
    image: demyx/demyx:${DEMYX_IMAGE_VERSION}
    cpus: $DEMYX_CPU
    mem_limit: $DEMYX_MEM
    container_name: demyx
    restart: unless-stopped
    hostname: $DEMYX_HOSTNAME
    depends_on:
      - socket
    networks:
      - demyx
      - demyx_socket
    volumes:
      - demyx:/demyx
      - demyx_log:/var/log/demyx
    environment:
      - DEMYX_API=$DEMYX_API
      - DEMYX_AUTH_USERNAME=$DEMYX_AUTH_USERNAME
      - DEMYX_AUTH_PASSWORD=$DEMYX_AUTH_PASSWORD
      - DEMYX_BACKUP_ENABLE=$DEMYX_BACKUP_ENABLE
      - DEMYX_BACKUP_LIMIT=$DEMYX_BACKUP_LIMIT
      - DEMYX_CODE_DOMAIN=$DEMYX_CODE_DOMAIN
      - DEMYX_CODE_ENABLE=$DEMYX_CODE_ENABLE
      - DEMYX_CODE_PASSWORD=$DEMYX_CODE_PASSWORD
      - DEMYX_CF_KEY=$DEMYX_CF_KEY
      - DEMYX_CPU=$DEMYX_CPU
      - DEMYX_DOMAIN=$DEMYX_DOMAIN
      - DEMYX_EMAIL=$DEMYX_EMAIL
      - DEMYX_HEALTHCHECK_ENABLE=$DEMYX_HEALTHCHECK_ENABLE
      - DEMYX_HEALTHCHECK_TIMEOUT=$DEMYX_HEALTHCHECK_TIMEOUT
      - DEMYX_HOSTNAME=$DEMYX_HOSTNAME
      - DEMYX_IMAGE_VERSION=$DEMYX_IMAGE_VERSION
      - DEMYX_IP=$DEMYX_IP
      - DEMYX_MEM=$DEMYX_MEM
      - DEMYX_MONITOR_ENABLE=$DEMYX_MONITOR_ENABLE
      - DEMYX_SERVER_IP=$DEMYX_SERVER_IP
      - DEMYX_TELEMETRY=$DEMYX_TELEMETRY
      - DEMYX_TRAEFIK_DASHBOARD=$DEMYX_TRAEFIK_DASHBOARD
      - DEMYX_TRAEFIK_DASHBOARD_DOMAIN=$DEMYX_TRAEFIK_DASHBOARD_DOMAIN
      - DEMYX_TRAEFIK_LOG=$DEMYX_TRAEFIK_LOG
      - TZ=$TZ
    $DEMYX_YML_LABELS
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
    name: demyx_socket
" > /demyx/docker-compose.yml

# Reset
demyx-reset
