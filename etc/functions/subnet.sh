#!/bin/bash
# Demyx
# https://github.com/demyxco/demyx

DOMAIN=$1
CONTAINER_NAME=$2
ACTION=$3
source /srv/demyx/etc/.env

if [ "$SUBNET_MINOR" = 255 ]; then
    SUBNET_MAJOR_UPDATE=$((SUBNET_MAJOR+1))
    sed -i "s/SUBNET_MAJOR=${SUBNET_MAJOR}/SUBNET_MAJOR=${SUBNET_MAJOR_UPDATE}/g" /srv/demyx/etc/.env
    sed -i "s/SUBNET_MINOR=255/SUBNET_MINOR=1/g" /srv/demyx/etc/.env
elif [ "$ACTION" = create ]; then
    SUBNET_MINOR_UPDATE=$((SUBNET_MINOR+1))
    sed -i "s/SUBNET_MINOR=${SUBNET_MINOR}/SUBNET_MINOR=${SUBNET_MINOR_UPDATE}/g" /srv/demyx/etc/.env
    #docker network create --driver=bridge --subnet=172.${SUBNET_MAJOR}.${SUBNET_MINOR_UPDATE}.0/24 $CONTAINER_NAME
elif [ "$ACTION" = remove ]; then
    if [ "$SUBNET_MINOR" != 0 ]; then
        SUBNET_MINOR_UPDATE=$((SUBNET_MINOR-1))
        sed -i "s/SUBNET_MINOR=${SUBNET_MINOR}/SUBNET_MINOR=${SUBNET_MINOR_UPDATE}/g" /srv/demyx/etc/.env
    fi
    #docker network rm $CONTAINER_NAME
fi

