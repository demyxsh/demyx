#!/bin/bash
# Demyx
# https://demyx.sh
# 0 */6 * * *

# Check for Demyx updates
echo -e "[$(date +%F-%T)] CROND: CHECK DEMYX UPDATE"
cd /demyx/etc
git remote update
DEMYX_CRON_UPDATES=$(git rev-list HEAD...origin/master --count)
/bin/sed -i "s|DEMYX_MOTD_STATUS=.*|DEMYX_MOTD_STATUS=$DEMYX_CRON_UPDATES|g" /demyx/.env

# Run WP cron
echo -e "[$(date +%F-%T)] CROND: WORDPRESS EVENT CRON"
/usr/local/bin/demyx wp all cron event run --due-now

# Execute custom cron
echo -e "[$(date +%F-%T)] CROND: CUSTOM EVERY 6 HOUR"
if [[ -f /demyx/custom/cron/every-6-hour.sh ]]; then
    bash /demyx/custom/cron/every-6-hour.sh
fi
