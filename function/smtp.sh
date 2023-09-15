# Demyx
# https://demyx.sh
# shellcheck shell=bash

#
#   demyx smtp <args>
#
demyx_smtp() {
    local DEMYX_SMTP_ARG_1="${1:-"[DEMYX] SMTP test"}"
    local DEMYX_SMTP_ARG_2="${2:-"Success."}"
    local DEMYX_SMTP_FILE="$DEMYX_TMP"/demyx_smtp

    if [[ "$DEMYX_SMTP" != true ]]; then
        demyx_error custom "Please set DEMYX_SMTP to true, run on host: demyx host edit"
    fi

    {
        echo "To: $DEMYX_SMTP_TO"
        echo "From: $DEMYX_SMTP_FROM"
        echo "MIME-Version: 1.0"
        echo "Content-Type: text/html; charset=utf-8"
        echo -e "Subject: $DEMYX_SMTP_ARG_1 \n"
        echo "$DEMYX_SMTP_ARG_2" | sed 's|["'\'']||g' | sed ':a;N;$!ba;s/\n/<br>/g'
    } > "$DEMYX_SMTP_FILE"

    demyx_execute false "ssmtp $DEMYX_SMTP_TO < $DEMYX_SMTP_FILE"
}
