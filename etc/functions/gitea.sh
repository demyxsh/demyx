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