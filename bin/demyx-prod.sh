#!/bin/bash
# Demyx
# https://demyx.sh

# Delete dev file
[[ -f /tmp/demyx-dev ]] && rm -f /tmp/demyx-dev

# Temporary fix, will remove this soon
find /var/log/demyx -type d -print0 | xargs -0 chmod 0755
find /var/log/demyx -type f -print0 | xargs -0 chmod 0644

# Set proper ownership and permission
chown -R demyx:demyx /demyx
chown -R demyx:demyx /home/demyx
chown -R demyx:demyx /var/log/demyx

# Lockdown
ln -sf /etc/demyx/.zshrc /home/demyx/.zshrc
chown -R root:root /home/demyx/.oh-my-zsh
chmod -R a=X /demyx
