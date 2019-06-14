#!/bin/bash
# Demyx
# https://demyx.sh
# 0 */6 * * *

# Run WP cron
/usr/local/bin/demyx wp all cron event run --due-now
