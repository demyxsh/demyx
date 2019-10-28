#!/bin/bash
# Demyx
# https://demyx.sh

DEMYX_HELPER_ARG="$1"

# Make /demyx browserable in development, else read-only
if [[ "$DEMYX_HELPER_ARG" = development ]]; then
    find /demyx -type d -print0 | xargs -0 chmod 0755; \
    find /demyx -type f -print0 | xargs -0 chmod 0644
    sed -i "s|DEMYX_MOTD_MODE=.*|DEMYX_MOTD_MODE=development|g" /demyx/.env
elif [[ "$DEMYX_HELPER_ARG" = production ]]; then
    export DEMYX_MODE=production
    chmod -R a=X /demyx
    sed -i "s|DEMYX_MOTD_MODE=.*|DEMYX_MOTD_MODE=production|g" /demyx/.env
fi

# Make core files executable
chmod +x /demyx/etc/demyx.sh
chmod +x /demyx/etc/cron/every-minute.sh
chmod +x /demyx/etc/cron/every-6-hour.sh
chmod +x /demyx/etc/cron/every-day.sh
chmod +x /demyx/etc/cron/every-week.sh

# Set ownerships
chown -R demyx:demyx /demyx
chown -R demyx:demyx /home/demyx
