#!/bin/bash
# Demyx
# https://demyx.sh
# 0 0 * * 0

# Rotate demyx log
/usr/local/bin/demyx log --rotate=demyx

# Rotate WordPress log
/usr/local/bin/demyx log --rotate=wp

# Execute custom cron
if [[ -f /demyx/custom/cron/every-week.sh ]]; then
    bash /demyx/custom/cron/every-week.sh
fi
