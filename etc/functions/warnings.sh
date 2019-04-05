#!/bin/bash
# Demyx
# https://github.com/demyxco/demyx

source /srv/demyx/etc/.env
DOMAIN=$1

if [ -d "$APPS"/"$DOMAIN" ]; then
	DEV_MODE_CHECK=$(grep -r "sendfile off" "$APPS"/"$DOMAIN"/conf/nginx.conf)
	[[ -n "$DEV_MODE_CHECK" ]] && echo -e "\e[33m[WARNING] $DOMAIN is currently in development mode\e[39m"
fi