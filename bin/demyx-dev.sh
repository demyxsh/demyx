#!/bin/bash
# Demyx
# https://demyx.sh

find /demyx -type d -print0 | xargs -0 chmod 0755
find /demyx -type f -print0 | xargs -0 chmod 0644
touch /tmp/demyx-dev
