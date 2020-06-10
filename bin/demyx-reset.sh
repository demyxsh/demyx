#!/bin/bash
# Demyx
# https://demyx.sh

# Reset permissions if /demyx is not empty
if (( "$(ls "$DEMYX" | wc -l)" > 0 )); then
    find "$DEMYX" -type d -print0 | xargs -0 chmod 0755
    find "$DEMYX" -type f -print0 | xargs -0 chmod 0644
fi

# Reset permissions if /var/log/demyx is not empty
if (( "$(ls "$DEMYX_LOG" | wc -l)" > 0 )); then
    find "$DEMYX_LOG" -type d -print0 | xargs -0 chmod 0755
    find "$DEMYX_LOG" -type f -print0 | xargs -0 chmod 0644
fi

# Reset ownership
chown -R demyx:demyx "$DEMYX"
chown -R demyx:demyx "$DEMYX_LOG"
