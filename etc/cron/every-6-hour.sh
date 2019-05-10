#!/bin/bash
# Demyx
# https://github.com/demyxco/demyx
# 0 */6 * * *
# AUTO GENERATED

/usr/local/bin/demyx wp --all --wpcli='cron event run --due-now'

# Restart php-fpm to clear opcache caching old code in memory
/usr/local/bin/demyx wp --restart=php