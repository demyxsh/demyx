#!/bin/bash
# Demyx
# https://github.com/demyxco/demyx

source /srv/demyx/etc/.env

DOMAIN=$1

if [ -d $LOGS/$DOMAIN.access.log ] && [ -d $LOGS/$DOMAIN.error.log ]; then
    sudo rm -rf $LOGS/$DOMAIN.access.log $LOGS/$DOMAIN.error.log
    touch $LOGS/$DOMAIN.access.log $LOGS/$DOMAIN.error.log
elif [ ! -f $LOGS/$DOMAIN.access.log ] && [ ! -f $LOGS/$DOMAIN.error.log ]; then
    touch $LOGS/$DOMAIN.access.log $LOGS/$DOMAIN.error.log
fi