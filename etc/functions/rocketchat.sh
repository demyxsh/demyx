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