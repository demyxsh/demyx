#!/bin/bash
# Demyx
# https://github.com/demyxco/demyx

source /srv/demyx/etc/.env
DOMAIN=$1
WP_CHECK=$(grep -rs "WP_ID" "$APPS"/"$DOMAIN"/.env)

if [ -n "$WP_CHECK" ]; then
	DEV_MODE_CHECK=$(grep -r "sendfile off" "$APPS"/"$DOMAIN"/conf/nginx.conf)
	[[ -n "$DEV_MODE_CHECK" ]] && echo -e "\e[33m[WARNING]\e[39m $DOMAIN is currently in development mode"
	[[ -d "$APPS"/"$DOMAIN"/db ]] && echo -e "\e[33m[WARNING]\e[39m $DOMAIN is using the old file structure. \n\nPlease run: demyx wp --dom=$DOMAIN --update=structure --ssl \nTo update all old sites: demyx wp --update=structure --all --ssl \n \n\e[31mBACKUP BEFORE YOU RUN THE UPDATER\e[39m \n"
fi