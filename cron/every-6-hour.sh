#!/bin/bash
# Demyx
# https://demyx.sh
# 0 */6 * * *

# Run WP cron
/usr/local/bin/demyx wp all cron event run --due-now

# Execute custom cron
if [[ -f /demyx/custom/cron/every-6-hour.sh ]]; then
    bash /demyx/custom/cron/every-6-hour.sh
fi
