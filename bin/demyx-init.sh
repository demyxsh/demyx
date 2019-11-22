#!/bin/bash
# Demyx
# https://demyx.sh

source /etc/demyx/.config

# Initialize files/directories
demyx-skel

# Run init scripts when docker.sock is mounted
if [[ -n "$(ls /run | grep docker.sock)" ]]; then
    # Execute update script
    demyx update

    # Start the API if DEMYX_STACK_SERVER_API has a url defined (Ex: api.domain.tld)
    DEMYX_STACK_SERVER_API="$(demyx info stack --filter=DEMYX_STACK_SERVER_API --quiet)"
    [[ "$DEMYX_STACK_SERVER_API" != false ]] && demyx-api &
fi

# Run sshd
demyx-ssh &

# Run sudo commands
demyx-env
# Don't run demyx-prod when DEMYX_MODE=development
[[ "$DEMYX_MODE" != development ]] && demyx-prod
demyx-crond
