#!/bin/bash
# Demyx
# https://github.com/demyxco/demyx

source /srv/demyx/etc/.env
FORCE=$1

if [ -f "$ETC"/docker-compose.yml ]; then
  NO_UPDATE=$(grep -r "AUTO GENERATED" "$ETC"/docker-compose.yml)
  [[ -z "$NO_UPDATE" ]] && [[ -z "$FORCE" ]] && echo -e "\e[33m[WARNING]\e[39m Skipped docker-compose.yml" && exit 1
fi

cat > "$ETC"/docker-compose.yml <<-EOF
# AUTO GENERATED
# To override, see demyx -h

version: "$DOCKER_COMPOSE_VERSION"

services:
  traefik:
    image: traefik
    container_name: traefik
    restart: unless-stopped
    networks:
      - traefik
    ports:
      - 80:80
      - 443:443
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - \${ETC}/traefik/traefik.toml:/etc/traefik/traefik.toml:ro
      - \${ETC}/traefik/acme.json:/etc/traefik/acme.json
      - \${LOGS}/traefik.access.log:/etc/traefik/access.log
      - \${LOGS}/traefik.error.log:/etc/traefik/traefik.log
    labels:
      - "traefik.enable=true"
      - "traefik.frontend.redirect.entryPoint=https"
      - "traefik.frontend.rule=Host:traefik.\${PRIMARY_DOMAIN}"
      - "traefik.port=8080"
      - "traefik.frontend.headers.forceSTSHeader=\${FORCE_STS_HEADER}"
      - "traefik.frontend.headers.STSSeconds=\${STS_SECONDS}"
      - "traefik.frontend.headers.STSIncludeSubdomains=\${STS_INCLUDE_SUBDOMAINS}"
      - "traefik.frontend.headers.STSPreload=\${STS_PRELOAD}"
  logrotate:
    container_name: logrotate
    image: demyx/logrotate
    restart: unless-stopped
    network_mode: none
    environment:
      TZ: America/Los_Angeles
    volumes:
      - \${LOGS}:/var/log/demyx
  watchtower:
    container_name: watchtower
    image: v2tec/watchtower
    restart: unless-stopped
    network_mode: none
    command: --cleanup
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
networks:
  traefik:
    name: traefik
EOF

echo -e "\e[32m[SUCCESS]\e[39m Generated .yml"