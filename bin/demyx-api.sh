#!/bin/zsh
# Demyx
# https://demyx.sh
 
shell2http -log=/var/log/demyx/api.log -form -show-errors -export-all-vars \
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
    /sites 'demyx info all --no-volume --no-password' \
    /system 'demyx info system --json'
