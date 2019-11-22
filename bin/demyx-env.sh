#!/bin/bash
# Demyx
# https://demyx.sh
 
# Generate .env for chroot.sh
[[ -z "$DEMYX_HOST" ]] && DEMYX_HOST="$(hostname)"
[[ -z "$DEMYX_SSH" ]] && DEMYX_SSH=2222
[[ -z "$DEMYX_STATUS" ]] && DEMYX_STATUS=0

echo "# AUTO GENERATED
        DEMYX_ENV_MODE=production
        DEMYX_ENV_HOST=$DEMYX_HOST
        DEMYX_ENV_USER=demyx
        DEMYX_ENV_SSH=$DEMYX_SSH
        DEMYX_ENV_STATUS=$DEMYX_STATUS" | sed 's|        ||g' > /demyx/.env
