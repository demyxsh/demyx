#!/bin/bash
# Demyx
# https://demyx.sh

DEMYX_MODE_ARG="$1"
DEMYX_ROOT_CHECK="$(id -u)"
[[ -z "$DEMYX_MODE" ]] && DEMYX_MODE=production
[[ -z "$DEMYX_HOST" ]] && DEMYX_HOST="$(hostname)"
[[ -z "$DEMYX_SSH" ]] && DEMYX_SSH=2222
[[ -z "$DEMYX_STATUS" ]] && DEMYX_STATUS=0

if [[ "$DEMYX_ROOT_CHECK" = 0 ]]; then
    echo "# AUTO GENERATED
        DEMYX_MOTD_MODE=$DEMYX_MODE
        DEMYX_MOTD_HOST=$DEMYX_HOST
        DEMYX_MOTD_USER=demyx
        DEMYX_MOTD_SSH=$DEMYX_SSH
        DEMYX_MOTD_STATUS=$DEMYX_STATUS" | sed 's/            //g' > /demyx/.env

    # Make /demyx browserable in development mode, else read-only
    if [[ "$DEMYX_MODE_ARG" = development ]]; then
        find /demyx -type d -print0 | xargs -0 chmod 0755
        find /demyx -type f -print0 | xargs -0 chmod 0644
        sed -i "s|DEMYX_MOTD_MODE=.*|DEMYX_MOTD_MODE=development|g" /demyx/.env
    else
        chmod -R a=X /demyx
        sed -i "s|DEMYX_MOTD_MODE=.*|DEMYX_MOTD_MODE=production|g" /demyx/.env
    fi

    chown -R demyx:demyx /home/demyx
    chown -R demyx:demyx /demyx
fi
