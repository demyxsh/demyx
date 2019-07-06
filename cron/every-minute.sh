#!/bin/bash
# Demyx
# https://demyx.sh
# * * * * *

# Monitor for auto scale
/usr/local/bin/demyx monitor

# Health checks
/usr/local/bin/demyx healthcheck

# Execute custom cron
if [[ -f /demyx/custom/cron/every-minute.sh ]]; then
    bash /demyx/custom/cron/every-minute.sh
fi
