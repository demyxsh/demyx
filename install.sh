#!/bin/bash
# Demyx
# https://demyx.sh
set -eEuo pipefail
#
#   Main.
#
demyx_install() {
    local DEMYX_INSTALL="${1:-}"

    docker pull demyx/demyx
    docker pull demyx/docker-socket-proxy
    docker pull demyx/mariadb
    docker pull demyx/nginx
    docker pull demyx/traefik
    docker pull demyx/utilities
    docker pull demyx/wordpress

    if [[ "$DEMYX_INSTALL" != *"--no-ping"* ]]; then
        echo -e "\n\e[34m[INFO\e[39m] Pinging active server to demyx"
        docker run -t --rm demyx/utilities curl -s "https://demyx.sh/?action=active&version=1.9.0&token=V1VpdGNPcWNDVlZSUDFQdFBaR0Zhdz09OjrnA1h6ZbDFJ2T6MHOwg3p4" -o /dev/null
    fi

    echo -e "\n\e[34m[INFO\e[39m] Installing demyx helper"
    docker run -t --rm \
        -v demyx:/demyx \
        -v /usr/local/bin:/tmp \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -e DOCKER_HOST="" \
        --user=root \
        --entrypoint=bash \
        demyx/demyx -c 'demyx-yml; cp -f /etc/demyx/host.sh /tmp/demyx; chmod +x /tmp/demyx'

    demyx
}
#
#   Init.
#
demyx_install "$@"
