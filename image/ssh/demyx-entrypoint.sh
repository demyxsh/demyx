#!/bin/sh

if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
	ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
fi

if [ -f /home/www-data/.ssh/ssh_host_rsa_key ]; then
	cp /home/www-data/.ssh/ssh_host_rsa_key /etc/ssh
	cp /home/www-data/.ssh/ssh_host_rsa_key.pub /etc/ssh
else
	cp /etc/ssh/ssh_host_rsa_key /home/www-data/.ssh
	cp /etc/ssh/ssh_host_rsa_key.pub /home/www-data/.ssh
fi

chown -R www-data:www-data /home/www-data
chmod 700 /home/www-data/.ssh
chmod 644 /home/www-data/.ssh/authorized_keys
chmod 600 /etc/ssh/ssh_host_rsa_key

/usr/sbin/sshd -D
