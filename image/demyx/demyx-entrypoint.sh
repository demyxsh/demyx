#!/bin/bash
# Demyx
# https://demyx.sh

if [[ ! -d /demyx/etc ]]; then
	git clone https://github.com/demyxco/demyx.git /demyx/etc
    mkdir -p /demyx/app/html
    mkdir -p /demyx/app/php
    mkdir -p /demyx/app/wp
    mkdir -p /demyx/app/stack
    mkdir -p /demyx/backup
    mkdir -p /demyx/custom
    cp /demyx/etc/example/example-callback.sh /demyx/custom
    chown -R demyx:demyx /demyx
fi

[[ "$DEMYX_MODE" != development ]] && export DEMYX_MODE=production; chmod -R a=X /demyx
[[ -z "$DEMYX_SSH" ]] && export DEMYX_SSH=2222

if [[ ! -d /home/demyx/.ssh ]]; then
    mkdir -p /home/demyx/.ssh
fi
if [[ ! -f /etc/ssh/ssh_host_rsa_key ]]; then
	ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
fi
if [[ -f /home/demyx/.ssh/ssh_host_rsa_key ]]; then
	cp /home/demyx/.ssh/ssh_host_rsa_key /etc/ssh
	cp /home/demyx/.ssh/ssh_host_rsa_key.pub /etc/ssh
else
	cp /etc/ssh/ssh_host_rsa_key /home/demyx/.ssh
	cp /etc/ssh/ssh_host_rsa_key.pub /home/demyx/.ssh
fi

chmod 700 /home/demyx/.ssh
chmod 644 /home/demyx/.ssh/authorized_keys
chmod 600 /etc/ssh/ssh_host_rsa_key
chown -R demyx:demyx /home/demyx
chown -R demyx:demyx /demyx
chmod +x /demyx/etc/demyx.sh
chmod +x /demyx/etc/cron/every-minute.sh
chmod +x /demyx/etc/cron/every-6-hour.sh
chmod +x /demyx/etc/cron/every-day.sh
demyx motd init

crond -L /var/log/demyx/cron.log
/usr/sbin/sshd -D
