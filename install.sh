#!/bin/bash
# Demyx
# https://demyx.sh
set -euo pipefail

docker pull demyx/code-server:browse
docker pull demyx/demyx
docker pull demyx/docker-compose
docker pull demyx/docker-socket-proxy
docker pull demyx/logrotate
docker pull demyx/mariadb
docker pull demyx/nginx
docker pull demyx/ssh
docker pull demyx/traefik
docker pull demyx/utilities
docker pull demyx/wordpress
docker pull demyx/wordpress:cli

echo -e "\n\e[34m[INFO\e[39m] Pinging active server to demyx"
docker run -t --rm demyx/utilities curl -s "https://demyx.sh/?action=active&token=V1VpdGNPcWNDVlZSUDFQdFBaR0Zhdz09OjrnA1h6ZbDFJ2T6MHOwg3p4" -o /dev/null

echo -e "\n\e[34m[INFO\e[39m] Installing demyx helper"
docker run -t --rm -v /usr/local/bin:/tmp --user=root --privileged --entrypoint=bash demyx/demyx -c 'cp -f /etc/demyx/host.sh /tmp/demyx; chmod +x /tmp/demyx'

demyx
