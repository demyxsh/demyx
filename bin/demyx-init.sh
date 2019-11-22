#!/bin/bash
# Demyx
# https://demyx.sh

source /etc/demyx/.config

# Initialize files/directories
if [[ -z "$(ls -A "$DEMYX")" ]]; then
    echo "[demyx] initialize files/directories..."
    mkdir -p "$DEMYX_APP"/html
    mkdir -p "$DEMYX_APP"/php
    mkdir -p "$DEMYX_APP"/wp
    mkdir -p "$DEMYX_APP"/stack
    mkdir -p "$DEMYX_BACKUP"
    mkdir -p "$DEMYX"/custom
    cp "$DEMYX_ETC"/example/example-callback.sh "$DEMYX"/custom
fi

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
