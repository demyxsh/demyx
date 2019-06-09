#!/bin/bash
# Demyx
# https://demyx.sh

[[ "$DEMYX_MODE" != development ]] && DEMYX_MODE=production; chmod -R a=X /demyx
[[ -z "$DEMYX_SSH" ]] && DEMYX_SSH=2222
[[ -z "$DEMYX_ET" ]] && DEMYX_ET=2022

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
chown -R demyx:demyx /home/demyx
chown -R demyx:demyx /demyx
chmod +x /usr/local/bin/demyx
chmod +x /demyx/etc/demyx.sh
chmod +x /demyx/etc/cron/every-minute.sh
chmod +x /demyx/etc/cron/every-6-hour.sh
chmod +x /demyx/etc/cron/every-day.sh
demyx motd init

crond
/usr/sbin/sshd
/usr/local/bin/etserver -v 9 -logtostdout true
