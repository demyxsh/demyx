#!/bin/bash
# Demyx
# https://demyx.sh
# 0 0 * * 0

# Rotate demyx log
echo -e "[$(date +%F-%T)] CROND: LOGROTATE DEMYX"
/usr/local/bin/demyx log --rotate

# Rotate WordPress log
echo -e "[$(date +%F-%T)] CROND: LOGROTATE WORDPRESS"
cd /demyx/app/wp
for i in *
do
    /usr/local/bin/demyx log "$i" --rotate
done

# Execute custom cron
echo -e "[$(date +%F-%T)] CROND: CUSTOM EVERY WEEK"
if [[ -f /demyx/custom/cron/every-week.sh ]]; then
    /bin/bash /demyx/custom/cron/every-week.sh
fi
