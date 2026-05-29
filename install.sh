#!/bin/bash
# Demyx
# https://demyx.sh
set -eEuo pipefail
#
#   Main.
#
demyx_install() {
    local DEMYX_INSTALL="${*:-}"
    local DEMYX_INSTALL_NO_PING=false
    local -a DEMYX_INSTALL_TELEMETRY_ENV=()
    local DEMYX_VERSION=1.11.0

    if [[ "$DEMYX_INSTALL" == *"--no-ping"* ]]; then
        DEMYX_INSTALL_NO_PING=true
        DEMYX_INSTALL_TELEMETRY_ENV=(-e DEMYX_TELEMETRY=false)
    fi

    docker pull demyx/demyx:"${DEMYX_VERSION}"
    docker pull demyx/docker-socket-proxy:"${DEMYX_VERSION}"
    docker pull demyx/mariadb:"${DEMYX_VERSION}"
    docker pull demyx/nginx:"${DEMYX_VERSION}"
    docker pull demyx/traefik:"${DEMYX_VERSION}"
    docker pull demyx/utilities:"${DEMYX_VERSION}"
    docker pull demyx/wordpress:"${DEMYX_VERSION}"

    if [[ "$DEMYX_INSTALL_NO_PING" = false ]]; then
        echo -e "\n\e[34m[INFO\e[39m] Pinging active server to demyx"
        docker run -t --rm demyx/utilities:"${DEMYX_VERSION}" curl -s "https://demyx.sh/?action=active&version=${DEMYX_VERSION}&token=V1VpdGNPcWNDVlZSUDFQdFBaR0Zhdz09OjrnA1h6ZbDFJ2T6MHOwg3p4" -o /dev/null
    fi

    echo -e "\n\e[34m[INFO\e[39m] Installing demyx helper"
    docker run -t --rm \
        -v demyx:/demyx \
        -v /usr/local/bin:/tmp \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -e DOCKER_HOST="" \
        --user=root \
        --entrypoint=bash \
        "${DEMYX_INSTALL_TELEMETRY_ENV[@]}" \
        demyx/demyx:"${DEMYX_VERSION}" -c 'demyx-yml; cp -f /etc/demyx/host.sh /tmp/demyx; chmod +x /tmp/demyx'

    demyx
}
#
#   Init.
#
demyx_install "$@"
