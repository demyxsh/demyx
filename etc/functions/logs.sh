#!/bin/bash
source /srv/demyx/etc/.env

DOMAIN=$1

if [ ! -f $LOGS/$DOMAIN.access.log ] && [ ! -f $LOGS/$DOMAIN.error.log ]; then
	touch $LOGS/$DOMAIN.access.log $LOGS/$DOMAIN.error.log
fi