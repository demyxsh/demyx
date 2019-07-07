#!/bin/sh

if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
	ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
fi

if [ -f /home/demyx/.ssh/ssh_host_rsa_key ]; then
	cp /home/demyx/.ssh/ssh_host_rsa_key /etc/ssh
	cp /home/demyx/.ssh/ssh_host_rsa_key.pub /etc/ssh
else
	cp /etc/ssh/ssh_host_rsa_key /home/demyx/.ssh
	cp /etc/ssh/ssh_host_rsa_key.pub /home/demyx/.ssh
fi

chown -R demyx:demyx /home/demyx
chmod 700 /home/demyx/.ssh
chmod 644 /home/demyx/.ssh/authorized_keys
chmod 600 /etc/ssh/ssh_host_rsa_key

/usr/sbin/sshd
/usr/local/bin/etserver -v 9 -logtostdout true
