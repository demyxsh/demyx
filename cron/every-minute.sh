#!/bin/bash
# Demyx
# https://demyx.sh
# * * * * *

# Monitor for auto scale
echo -e "[$(date +%F-%T)] CROND: MONITOR"
/usr/local/bin/demyx monitor

# Health checks
echo -e "[$(date +%F-%T)] CROND: HEALTHCHECK"
/usr/local/bin/demyx healthcheck

# Execute custom cron
echo -e "[$(date +%F-%T)] CROND: CUSTOM EVERY MINUTE"
if [[ -f /demyx/custom/cron/every-minute.sh ]]; then
    /bin/bash /demyx/custom/cron/every-minute.sh
fi
