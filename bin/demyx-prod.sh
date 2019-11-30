#!/bin/bash
# Demyx
# https://demyx.sh

# Delete dev file
[[ -f /tmp/demyx-dev ]] && rm -f /tmp/demyx-dev

# Set proper ownership and permission
find /var/log/demyx -type d -print0 | xargs -0 chmod 0755
find /var/log/demyx -type f -print0 | xargs -0 chmod 0644

chown -R demyx:demyx /demyx
chown -R demyx:demyx /home/demyx
chown -R demyx:demyx /var/log/demyx
chmod -R a=X /demyx
