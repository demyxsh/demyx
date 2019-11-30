#!/bin/bash
# Demyx
# https://demyx.sh

# Run only if user is root
DEMYX_ROOT_CHECK="$(id -u)"
if [[ "$DEMYX_ROOT_CHECK" = 0 ]]; then
    find /demyx -type d -print0 | xargs -0 chmod 0755
    find /demyx -type f -print0 | xargs -0 chmod 0644
    find /var/log/demyx -type d -print0 | xargs -0 chmod 0755
    find /var/log/demyx -type f -print0 | xargs -0 chmod 0644
    touch /tmp/demyx-dev
fi
