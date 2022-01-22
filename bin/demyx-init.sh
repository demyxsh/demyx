#!/bin/bash
# Demyx
# https://demyx.sh

# Initialize files/directories
demyx-skel &

# Refresh and bring up traefik
demyx refresh traefik &

# Refresh and bring up code-server
[[ "$DEMYX_CODE_ENABLE" = true && "$DEMYX_IP" != false ]] && demyx refresh code &

# TEMPORARY CODE
demyx-reset &

# Start api if DEMYX_API is set to true
if [[ "$DEMYX_API" != false ]]; then
    sudo -E crond -L /var/log/demyx/cron.log
    
    # Start the api
    shell2http -log=/var/log/demyx/api.log -form -show-errors -export-all-vars -shell bash \
        /run '
            if [[ -d /demyx/app/wp/$v_domain ]]; then
                echo "{\"status\": \"error\", \"message\": \"App already exists or missing domain.\"}"
            else
                demyx run $v_domain > /dev/null
                demyx info $v_domain --json
            fi
        ' \
        /clone '
            if [[ -d /demyx/app/wp/$v_domain || -z $v_clone ]]; then
                echo "{\"status\": \"error\", \"message\": \"App already exists, domain missing domain, or clone domain missing.\"}"
            else
                demyx run $v_domain --clone=$v_clone > /dev/null
                demyx info $v_domain --json
            fi
        ' \
        /info 'demyx info $v_domain --json --no-volume' \
        /motd 'demyx info motd --json' \
        /sites 'demyx info all --no-volume --no-password'

else
    sudo -E crond -fL /var/log/demyx/cron.log
fi
