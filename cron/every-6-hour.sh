#!/bin/bash
# Demyx
# https://demyx.sh
# 0 */6 * * *

# Run WP cron
/usr/local/bin/demyx wp all cron event run --due-now
# Restart php-fpm to clear opcache caching old code in memory
/usr/local/bin/demyx config all --restart=php
