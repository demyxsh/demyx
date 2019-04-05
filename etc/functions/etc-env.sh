#!/bin/bash
# Demyx
# https://github.com/demyxco/demyx

PRIMARY_DOMAIN=$1
BASIC_AUTH_USER=$2
BASIC_AUTH_PASSWORD=$3
FORCE=$4
DEMYX=/srv/demyx
ETC=$DEMYX/etc

if [ -f $ETC/.env ]; then
	source $ETC/.env
	NO_UPDATE=$(grep -r "AUTO GENERATED" $ETC/.env)
  	[[ -z "$NO_UPDATE" ]] && [[ -z "$FORCE" ]] && echo -e "\e[33m[WARNING] Skipped .env\e[39m" && exit 1
fi

cat > $ETC/.env <<-EOF
# AUTO GENERATED
# To override, see demyx -h

DOCKER_COMPOSE_VERSION=3.7
SUBNETS=172
SUBNET_MAJOR=18
SUBNET_MINOR=0
DEMYX=$DEMYX
APPS=$DEMYX/apps
APPS_BACKUP=$DEMYX/backup
ETC=$ETC
LOGS=$DEMYX/logs
GIT=$DEMYX/git
PRIMARY_DOMAIN=$PRIMARY_DOMAIN
BASIC_AUTH_USER=$BASIC_AUTH_USER
BASIC_AUTH_PASSWORD=$BASIC_AUTH_PASSWORD
FORCE_STS_HEADER=true
STS_SECONDS=315360000
STS_INCLUDE_SUBDOMAINS=true
STS_PRELOAD=true
EOF

echo -e "\e[32m[SUCCESS] Generated .env\e[39m"