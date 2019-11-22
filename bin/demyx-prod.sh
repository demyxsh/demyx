#!/bin/bash
# Demyx
# https://demyx.sh

chown -R demyx:demyx /home/demyx
chown -R demyx:demyx /demyx 
chmod -R a=X /demyx
sed -i "s|DEMYX_ENV_MODE=.*|DEMYX_ENV_MODE=production|g" /demyx/.env
