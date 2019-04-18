#!/bin/bash
# Demyx
# https://github.com/demyxco/demyx

DOMAIN=$1
CONTAINER_PATH=$2
DB_USER=$(docker run -it --rm demyx/utilities sh -c "gpw 1 10" | sed -e 's/\r//g')
DB_PASSWD=$(docker run -it --rm demyx/utilities sh -c "pwgen -cns 50 1" | sed -e 's/\r//g')
MARIADB_ROOT_PASSWORD=$(docker run -it --rm demyx/utilities sh -c "pwgen -cns 50 1" | sed -e 's/\r//g')

cat > "$CONTAINER_PATH"/.env <<-EOF
DOMAIN=$DOMAIN
CONTAINER_PATH=$CONTAINER_PATH
UID=$(id git -u)
GID=$(id git -g)
DB_TYPE=mysql
DB_HOST=gitea_db
DB_NAME=gitea
DB_USER=$DB_USER
DB_PASSWD=$DB_PASSWD
MARIADB_ROOT_PASSWORD=$MARIADB_ROOT_PASSWORD
EOF

cat > "$CONTAINER_PATH"/docker-compose.yml <<-EOF
version: "3.7"

services:
  gitea:
    image: gitea/gitea:latest
    environment:
      - USER_UID=\$UID
      - USER_GID=\$GID
      - DB_TYPE=\$DB_TYPE
      - DB_HOST=\$DB_HOST
      - DB_NAME=\$DB_NAME
      - DB_USER=\$DB_USER
      - DB_PASSWD=\$DB_PASSWD
    restart: unless-stopped
    volumes:
      - ./data:/data
      - /home/git/.ssh:/data/git/.ssh
    ports:
      - "127.0.0.1:2222:22"
    labels:
      - "traefik.enable=true"
      - "traefik.frontend.redirect.entryPoint=https"
      - "traefik.frontend.rule=Host:\$DOMAIN"
      - "traefik.port=3000"
      - "traefik.frontend.headers.forceSTSHeader=true"
      - "traefik.frontend.headers.STSSeconds=315360000"
      - "traefik.frontend.headers.STSIncludeSubdomains=true"
      - "traefik.frontend.headers.STSPreload=true"
    networks:
      - traefik
  gitea_db:
    image: demyx/mariadb
    restart: unless-stopped
    volumes:
      - ./db:/var/lib/mysql
    environment:
      MARIADB_DATABASE: \$DB_NAME
      MARIADB_USERNAME: \$DB_USER
      MARIADB_PASSWORD: \$DB_PASSWD
      MARIADB_ROOT_PASSWORD: \$MARIADB_ROOT_PASSWORD
    networks:
      - traefik
networks:
  traefik:
    name: traefik
EOF

echo -e "\e[32m[SUCCESS]\e[39m Generated Gitea to $CONTAINER_PATH"
echo
cat "$CONTAINER_PATH"/.env
echo