#!/bin/bash
# Demyx
# https://demyx.sh
# 0 0 * * *

# Rotate demyx log
/usr/local/bin/demyx log --rotate=demyx

# Rotate stack log
/usr/local/bin/demyx log --rotate=stack

# Rotate WordPress log
/usr/local/bin/demyx log --rotate=wp

# Backup WordPress sites at midnight
/usr/local/bin/demyx backup all

# Check for Demyx updates
cd /demyx/etc
git remote update
DEMYX_CRON_UPDATES=$(git rev-list HEAD...origin/master --count)
/bin/sed -i '/DEMYX_MOTD_STATUS/d' /demyx/.env
echo "DEMYX_MOTD_STATUS=$DEMYX_CRON_UPDATES" >> /demyx/.env
