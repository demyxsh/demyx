#!/bin/bash
# Demyx
# https://demyx.sh
 
# Clone demyx if it doesn't exist
if [[ ! -d /demyx/etc ]]; then
    echo "[demyx] installing now..."
    git clone https://github.com/demyxco/demyx.git /demyx/etc
    mkdir -p /demyx/app/html
    mkdir -p /demyx/app/php
    mkdir -p /demyx/app/wp
    mkdir -p /demyx/app/stack
    mkdir -p /demyx/backup
    mkdir -p /demyx/custom
    touch /demyx/app/stack/.env
    cp /demyx/etc/example/example-callback.sh /demyx/custom
fi

# Create /demyx/.env if it doesn't exist
if [[ ! -f /demyx/.env ]]; then
    [[ -z "$DEMYX_MODE" ]] && DEMYX_MODE=production
    [[ -z "$DEMYX_HOST" ]] && DEMYX_HOST="$(hostname)"
    [[ -z "$DEMYX_SSH" ]] && DEMYX_SSH=2222
    [[ -z "$DEMYX_STATUS" ]] && DEMYX_STATUS=0

    cat > /demyx/.env <<-EOF
        # AUTO GENERATED
        DEMYX_MOTD_MODE=$DEMYX_MODE
        DEMYX_MOTD_HOST=$DEMYX_HOST
        DEMYX_MOTD_USER=demyx
        DEMYX_MOTD_SSH=$DEMYX_SSH
        DEMYX_MOTD_STATUS=$DEMYX_STATUS
EOF
        sed -i 's/		//g' /demyx/.env
fi

# Make demyx user's .ssh directory if it isn't made yet
if [[ ! -d /home/demyx/.ssh ]]; then
    mkdir -p /home/demyx/.ssh
fi

# Prevents ssh errors from local machine
if [[ -f /home/demyx/.ssh/ssh_host_rsa_key ]]; then
    cp /home/demyx/.ssh/ssh_host_rsa_key /etc/ssh
    cp /home/demyx/.ssh/ssh_host_rsa_key.pub /etc/ssh
else
    ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
    cp /etc/ssh/ssh_host_rsa_key /home/demyx/.ssh
    cp /etc/ssh/ssh_host_rsa_key.pub /home/demyx/.ssh
fi

# Set proper ssh permissions
if [[ -f /home/demyx/.ssh/authorized_keys ]]; then
    chmod 644 /home/demyx/.ssh/authorized_keys
fi
chmod 700 /home/demyx/.ssh
chmod 600 /etc/ssh/ssh_host_rsa_key

# Need to execute demyx update due to breaking changes
# Will remove this in December 2019
demyx update &

# Show demyx help menu
demyx

# Start the API if DEMYX_STACK_SERVER_API has a url defined (Ex: api.domain.tld)
DEMYX_STACK_SERVER_API="$(demyx info stack --filter=DEMYX_STACK_SERVER_API)"
if [[ "$DEMYX_STACK_SERVER_API" != false ]]; then
    demyx-api &
fi

demyx-ssh &
demyx-crond
