#!/bin/bash
# Demyx
# https://demyx.sh

DEMYX_MODE_ARG="$1"
DEMYX_ROOT_CHECK="$(id -u)"

if [[ "$DEMYX_ROOT_CHECK" = 0 ]]; then
    # Make /demyx browserable in development mode, else read-only
    if [[ "$DEMYX_MODE_ARG" = development ]]; then
        find /demyx -type d -print0 | xargs -0 chmod 0755
        find /demyx -type f -print0 | xargs -0 chmod 0644
        sed -i "s|DEMYX_MOTD_MODE=.*|DEMYX_MOTD_MODE=development|g" /demyx/.env
    else
        chmod -R a=X /demyx
        sed -i "s|DEMYX_MOTD_MODE=.*|DEMYX_MOTD_MODE=production|g" /demyx/.env
    fi

    chown -R demyx:demyx /demyx
fi
