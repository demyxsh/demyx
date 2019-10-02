#!/bin/bash
# Demyx
# https://demyx.sh
# 0 0 * * 0

# Rotate demyx log
echo -e "[$(date +%F-%T)] CROND: LOGROTATE DEMYX"
/usr/local/bin/demyx log --rotate=demyx

# Rotate WordPress log
echo -e "[$(date +%F-%T)] CROND: LOGROTATE WORDPRESS"
/usr/local/bin/demyx log --rotate=wp

# Execute custom cron
echo -e "[$(date +%F-%T)] CROND: CUSTOM EVERY WEEK"
if [[ -f /demyx/custom/cron/every-week.sh ]]; then
    /bin/bash /demyx/custom/cron/every-week.sh
fi
