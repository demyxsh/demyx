#!/bin/bash
# Demyx
# https://demyx.sh
# Rename this file to callback.sh; feel free to edit/modify this file since it will not be updated.
# Below is an example of demyx monitor callback to matrix via webhooks (https://github.com/nim65s/matrix-webhook).
set -euo pipefail
#
#   Main.
#
demyx_callback() {
    local DEMYX_CALLBACK_ARG_1="${1:-}"
    local DEMYX_CALLBACK_ARG_2="${2:-}"
    local DEMYX_CALLBACK_ARG_3="ECHO: ${3:-}<br/>"
    local DEMYX_CALLBACK_ARG_4="${4:-}"
    local DEMYX_CALLBACK_ARG_5="${5:-}"
    local DEMYX_CALLBACK_ARG_6="${6:-}"
    local DEMYX_CALLBACK_DOMAIN=
    DEMYX_CALLBACK_DOMAIN="$(echo "$DEMYX_CALLBACK_ARG_2" | tr '[:upper:]' '[:lower:]')"
    local DEMYX_CALLBACK_KEY=
    local DEMYX_CALLBACK_WEBHOOK="https://domain.tld/!7mabYl8wfAjhc9zoHD:domain.tld'"

    if [[ "$DEMYX_CALLBACK_ARG_3" = false || -z "$DEMYX_CALLBACK_ARG_3" ]]; then
        DEMYX_CALLBACK_ARG_3=
    fi

    case "$DEMYX_CALLBACK_ARG_1" in
        healthcheck)
            demyx_callback_curl "Server IP: ${DEMYX_CALLBACK_ARG_4}\nDomain IP: ${DEMYX_CALLBACK_ARG_5}\nNameservers: ${DEMYX_CALLBACK_ARG_6}"
        ;;
        error)
            demyx_callback_curl "HOSTNAME: $DEMYX_HOSTNAME - ${DEMYX_CALLBACK_ARG_6}<br>ERROR: demyx ${DEMYX_CALLBACK_ARG_2}<br>${DEMYX_CALLBACK_ARG_3}EXECUTE: ${DEMYX_CALLBACK_ARG_4}<br>STDOUT: ${DEMYX_CALLBACK_ARG_5}"
        ;;
        monitor-on)
            demyx_callback_curl "$DEMYX_CALLBACK_DOMAIN: $DEMYX_CALLBACK_ARG_1 $DEMYX_CALLBACK_ARG_2 $DEMYX_CALLBACK_ARG_3 $DEMYX_CALLBACK_ARG_4 $DEMYX_CALLBACK_ARG_5"
        ;;
        monitor-off)
            demyx_callback_curl "$DEMYX_CALLBACK_DOMAIN: $DEMYX_CALLBACK_ARG_1 $DEMYX_CALLBACK_ARG_2 $DEMYX_CALLBACK_ARG_3 $DEMYX_CALLBACK_ARG_4 $DEMYX_CALLBACK_ARG_5"
        ;;
    esac
}
#
#   Curl template.
#
demyx_callback_curl() {
    local DEMYX_CALLBACK_CURL="${1:-}"
    curl -X POST \
    -H 'Content-Type: application/json' \
    --data "
        {
            \"text\":\"$DEMYX_CALLBACK_CURL\",
            \"key\":\"$DEMYX_CALLBACK_KEY\"
        }
    " \
    "$DEMYX_CALLBACK_WEBHOOK"
}
#
#   Init.
#
demyx_callback "$@"
