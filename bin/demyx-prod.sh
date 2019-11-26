#!/bin/bash
# Demyx
# https://demyx.sh

# Delete dev file
[[ -f /tmp/demyx-dev ]] && rm -f /tmp/demyx-dev

# Set proper ownership and permission
chown -R demyx:demyx /home/demyx
chown -R demyx:demyx /demyx 
chmod -R a=X /demyx
