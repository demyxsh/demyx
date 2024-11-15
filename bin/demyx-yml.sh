#!/bin/bash
# Demyx
# https://demyx.sh
set -euo pipefail
#
#   Main.
#
demyx_yml() {
    local DEMYX_YML_ENV="${DEMYX}/.env"
    local DEMYX_YML_NETWORK=
    local DEMYX_YML_VOLUME=
    local DEMYX_YML_VOLUME_DEMYX=
    local DEMYX_YML_VOLUME_LOG=
    local DEMYX_YML_VOLUME_USER=

    # shellcheck disable=SC1090
    [[ -f "${DEMYX_YML_ENV}" ]] && source "${DEMYX_YML_ENV}"

        cat << EOF > "${DEMYX_YML_ENV}"

            # HTTP AUTH
            DEMYX_AUTH_USERNAME=$(demyx_yml_env DEMYX_HOST_AUTH_USERNAME /tmp/.demyx)
            DEMYX_AUTH_PASSWORD=$(demyx_yml_env DEMYX_HOST_AUTH_PASSWORD /tmp/.demyx)

            # BACKUP
            DEMYX_BACKUP_ENABLE=$(demyx_yml_env DEMYX_HOST_BACKUP /tmp/.demyx)
            DEMYX_BACKUP_LIMIT=$(demyx_yml_env DEMYX_HOST_BACKUP_LIMIT /tmp/.demyx)

            # CODE-SERVER
            DEMYX_CODE_DOMAIN=$(demyx_yml_env DEMYX_HOST_CODE_DOMAIN /tmp/.demyx)
            DEMYX_CODE_ENABLE=$(demyx_yml_env DEMYX_HOST_CODE /tmp/.demyx)
            DEMYX_CODE_PASSWORD=$(demyx_yml_env DEMYX_HOST_CODE_PASSWORD /tmp/.demyx)
            DEMYX_CODE_SSL=false

            # CONTAINER CPU/MEM
            DEMYX_CPU=$(demyx_yml_env DEMYX_HOST_CPU /tmp/.demyx)
            DEMYX_MEM=$(demyx_yml_env DEMYX_HOST_MEM /tmp/.demyx)

            # LOGROTATE
            DEMYX_LOGROTATE=daily
            DEMYX_LOGROTATE_INTERVAL=7
            DEMYX_LOGROTATE_SIZE=10M

            # HEALTHCHECK
            DEMYX_HEALTHCHECK=$(demyx_yml_env DEMYX_HOST_HEALTHCHECK /tmp/.demyx)
            DEMYX_HEALTHCHECK_DISK=/demyx
            DEMYX_HEALTHCHECK_DISK_THRESHOLD=80
            DEMYX_HEALTHCHECK_LOAD=10

            # MATRIX
            DEMYX_MATRIX=false
            DEMYX_MATRIX_KEY=false
            DEMYX_MATRIX_URL=false

            # SMTP
            DEMYX_SMTP=false
            DEMYX_SMTP_HOST=false
            DEMYX_SMTP_FROM=false
            DEMYX_SMTP_PASSWORD=false
            DEMYX_SMTP_USERNAME=false
            DEMYX_SMTP_TO=false

            # TRAEFIK
            DEMYX_TRAEFIK_DASHBOARD=$(demyx_yml_env DEMYX_HOST_TRAEFIK_DASHBOARD /tmp/.demyx)
            DEMYX_TRAEFIK_DASHBOARD_DOMAIN=$(demyx_yml_env DEMYX_HOST_TRAEFIK_DASHBOARD_DOMAIN /tmp/.demyx)
            DEMYX_TRAEFIK_LOG=$(demyx_yml_env DEMYX_HOST_TRAEFIK_LOG /tmp/.demyx)
            DEMYX_TRAEFIK_SSL=false

            # MISC
            DEMYX_CF_KEY=$(demyx_yml_env DEMYX_HOST_CF_KEY /tmp/.demyx)
            DEMYX_DOMAIN=$(demyx_yml_env DEMYX_HOST_DOMAIN /tmp/.demyx)
            DEMYX_EMAIL=$(demyx_yml_env DEMYX_HOST_EMAIL /tmp/.demyx)
            DEMYX_IMAGE_VERSION=$(demyx_yml_env DEMYX_HOST_IMAGE_VERSION /tmp/.demyx)
            DEMYX_IP=$(demyx_yml_env DEMYX_HOST_IP /tmp/.demyx)
            DEMYX_HOSTNAME=$(demyx_yml_env DEMYX_HOST_HOSTNAME /tmp/.demyx)
            DEMYX_TELEMETRY=$(demyx_yml_env DEMYX_HOST_TELEMETRY /tmp/.demyx)
            DEMYX_TZ=$(demyx_yml_env DEMYX_HOST_TZ /tmp/.demyx)
        " | sed "s|            ||g" > "$DEMYX"/.env
    fi

    # GitHub Action and existing volume warning fix
    if [[ ! -f "$DEMYX"/github_action ]]; then
        DEMYX_YML_VOLUME="$(docker volume ls)"
        if [[ -n "$(echo "$DEMYX_YML_VOLUME" | grep -w demyx || true)" ]]; then
            DEMYX_YML_VOLUME_DEMYX="external: true"
        fi

        if [[ -n "$(echo "$DEMYX_YML_VOLUME" | grep -w demyx_log || true)" ]]; then
            DEMYX_YML_VOLUME_LOG="external: true"
        fi

        if [[ -n "$(echo "$DEMYX_YML_VOLUME" | grep -w demyx_user || true)" ]]; then
            DEMYX_YML_VOLUME_USER="external: true"
        fi
    fi

    # Set "external: true" for network
    if [[ -f "$DEMYX"/docker-compose.yml ]]; then
        DEMYX_YML_NETWORK="external: true"
    fi

    # TEMPORARY
    if [[ -f "${DEMYX}/docker-compose.yml" ]]; then
        rm -f "${DEMYX}/docker-compose.yml"
    fi

    # Generate /demyx/compose.yml
    echo "# DEMYX $DEMYX_VERSION
services:
  socket:
    image: demyx/docker-socket-proxy
    cpus: \${DEMYX_CPU:-0}
    mem_limit: \${DEMYX_MEM:-0}
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
  demyx:
    image: demyx/demyx:\${DEMYX_IMAGE_VERSION}
    cpus: \${DEMYX_CPU:-0}
    mem_limit: \${DEMYX_MEM:-0}
    container_name: demyx
    restart: unless-stopped
    hostname: \${DEMYX_HOSTNAME}
    depends_on:
      - socket
    networks:
      - demyx
      - demyx_socket
    volumes:
      - demyx:/demyx
      - demyx_log:/var/log/demyx
    environment:
      - DEMYX_AUTH_USERNAME=\${DEMYX_AUTH_USERNAME}
      - DEMYX_AUTH_PASSWORD=\${DEMYX_AUTH_PASSWORD}
      - DEMYX_BACKUP_ENABLE=\${DEMYX_BACKUP_ENABLE}
      - DEMYX_BACKUP_LIMIT=\${DEMYX_BACKUP_LIMIT}
      - DEMYX_CODE_DOMAIN=\${DEMYX_CODE_DOMAIN}
      - DEMYX_CODE_ENABLE=\${DEMYX_CODE_ENABLE}
      - DEMYX_CODE_PASSWORD=\${DEMYX_CODE_PASSWORD}
      - DEMYX_CODE_SSL=\${DEMYX_CODE_SSL}
      - DEMYX_CF_KEY=\${DEMYX_CF_KEY}
      - DEMYX_CPU=\${DEMYX_CPU}
      - DEMYX_DOMAIN=\${DEMYX_DOMAIN}
      - DEMYX_EMAIL=\${DEMYX_EMAIL}
      - DEMYX_LOGROTATE=\${DEMYX_LOGROTATE}
      - DEMYX_LOGROTATE_INTERVAL=\${DEMYX_LOGROTATE_INTERVAL}
      - DEMYX_LOGROTATE_SIZE=\${DEMYX_LOGROTATE_SIZE}
      - DEMYX_HEALTHCHECK=\${DEMYX_HEALTHCHECK}
      - DEMYX_HEALTHCHECK_DISK=\${DEMYX_HEALTHCHECK_DISK}
      - DEMYX_HEALTHCHECK_DISK_THRESHOLD=\${DEMYX_HEALTHCHECK_DISK_THRESHOLD}
      - DEMYX_HEALTHCHECK_LOAD=\${DEMYX_HEALTHCHECK_LOAD}
      - DEMYX_HOSTNAME=\${DEMYX_HOSTNAME}
      - DEMYX_IMAGE_VERSION=\${DEMYX_IMAGE_VERSION}
      - DEMYX_IP=\${DEMYX_IP}
      - DEMYX_MATRIX=\${DEMYX_MATRIX}
      - DEMYX_MATRIX_KEY=\${DEMYX_MATRIX_KEY}
      - DEMYX_MATRIX_URL=\${DEMYX_MATRIX_URL}
      - DEMYX_MEM=\${DEMYX_MEM}
      - DEMYX_SERVER_IP=$(dig @ns1.google.com -t txt o-o.myaddr.l.google.com +short | sed 's|"||g')
      - DEMYX_SMTP=\${DEMYX_SMTP}
      - DEMYX_SMTP_HOST=\${DEMYX_SMTP_HOST}
      - DEMYX_SMTP_FROM=\${DEMYX_SMTP_FROM}
      - DEMYX_SMTP_PASSWORD=\${DEMYX_SMTP_PASSWORD}
      - DEMYX_SMTP_USERNAME=\${DEMYX_SMTP_USERNAME}
      - DEMYX_SMTP_TO=\${DEMYX_SMTP_TO}
      - DEMYX_TELEMETRY=\${DEMYX_TELEMETRY}
      - DEMYX_TRAEFIK_DASHBOARD=\${DEMYX_TRAEFIK_DASHBOARD}
      - DEMYX_TRAEFIK_DASHBOARD_DOMAIN=\${DEMYX_TRAEFIK_DASHBOARD_DOMAIN}
      - DEMYX_TRAEFIK_LOG=\${DEMYX_TRAEFIK_LOG}
      - DEMYX_TRAEFIK_SSL=\${DEMYX_TRAEFIK_SSL}
      - TZ=\${DEMYX_TZ}
volumes:
  demyx:
    $DEMYX_YML_VOLUME_DEMYX
    name: demyx
  demyx_log:
    $DEMYX_YML_VOLUME_LOG
    name: demyx_log
  demyx_user:
    $DEMYX_YML_VOLUME_USER
    name: demyx_user
networks:
  demyx:
    $DEMYX_YML_NETWORK
    name: demyx
  demyx_socket:
    $DEMYX_YML_NETWORK
    name: demyx_socket
" > "${DEMYX}/compose.yml"
}
#
#   Grabs env variable without sourcing.
#
demyx_yml_env() {
    local DEMYX_YML_ENV="${1:-}"
    local DEMYX_YML_ENV_FILE="${2:-${DEMYX}/.env}"
    local DEMYX_YML_GREP=
    DEMYX_YML_GREP="$(grep -w "$DEMYX_YML_ENV" "$DEMYX_YML_ENV_FILE" | awk -F '[=]' '{print $2}' || true)"

    if [[ -n "$DEMYX_YML_GREP" ]]; then
        echo "$DEMYX_YML_GREP"
    fi
}
#
#   Init.
#
demyx_yml
