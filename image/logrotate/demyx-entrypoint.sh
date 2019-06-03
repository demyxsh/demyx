#!/bin/sh

if [ -d /var/log/demyx ]; then
    /usr/sbin/logrotate --force /etc/logrotate.d/demyx.conf
fi
