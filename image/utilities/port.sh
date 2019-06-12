#!/bin/bash

while true; do
DEMYX_SFTP_OPEN_PORT=$(netstat -tupln 2>/dev/null | grep :"$DEMYX_SFTP_PORT" || true)
    if [[ -z "$DEMYX_SFTP_OPEN_PORT" ]]; then
        break
    else
        DEMYX_SFTP_PORT="$((DEMYX_SFTP_PORT+1))"
    fi
done

echo "$DEMYX_SFTP_PORT"
