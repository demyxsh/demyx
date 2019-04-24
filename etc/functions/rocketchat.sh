#!/bin/bash
# Demyx
# https://github.com/demyxco/demyx

DOMAIN=$1
EMAIL=$2
CONTAINER_PATH=$3

cat > "$CONTAINER_PATH"/.env <<-EOF
DOMAIN=$DOMAIN
EMAIL=$EMAIL
CONTAINER_PATH=$CONTAINER_PATH
EOF

cat > "$CONTAINER_PATH"/docker-compose.yml <<-EOF
version: '3.7'

services:
  rocketchat:
    image: rocketchat/rocket.chat:latest
    restart: unless-stopped
    volumes:
      - rocketchat:/app/uploads
    environment:
      - MONGO_URL=mongodb://mongo:27017/rocketchat
      - MONGO_OPLOG_URL=mongodb://mongo:27017/local
      - MAIL_URL=smtp://\$EMAIL
    depends_on:
      - mongo
    labels:
      - "traefik.enable=true"
      - "traefik.frontend.rule=Host:\$DOMAIN,www.\$DOMAIN"
      - "traefik.port=3000"
      - "traefik.frontend.redirect.regex=^www.\$DOMAIN/(.*)"
      - "traefik.frontend.redirect.replacement=\$DOMAIN/\$\$1"
      - "traefik.frontend.redirect.entryPoint=https"
      - "traefik.frontend.headers.forceSTSHeader=true"
      - "traefik.frontend.headers.STSSeconds=315360000"
      - "traefik.frontend.headers.STSIncludeSubdomains=true"
      - "traefik.frontend.headers.STSPreload=true"
    networks:
      - traefik
  mongo:
    image: mongo:4.0
    restart: unless-stopped
    volumes:
     - rocketchat_db:/data/db
     - rocketchat_dump:/dump
    command: mongod --smallfiles --oplogSize 128 --replSet rs0 --storageEngine=mmapv1
    networks:
      - traefik
  mongo-init-replica:
    image: mongo:4.0
    command: 'mongo mongo/rocketchat --eval "rs.initiate({ _id: ''rs0'', members: [ { _id: 0, host: ''localhost:27017'' } ]})"'
    depends_on:
      - mongo
    networks:
      - traefik
volumes:
  rocketchat:
    name: rocketchat
  rocketchat_db:
    name: rocketchat_db
  rocketchat_dump:
    name: rocketchat_dump
networks:
  traefik:
    external: true
EOF

echo -e "\e[32m[SUCCESS]\e[39m Generated Rocket.Chat to $CONTAINER_PATH"
echo
echo -e "\e[34m[INFO]\e[39m For first time install, please allow several minutes for Mongo to setup Rocket.Chat"
echo