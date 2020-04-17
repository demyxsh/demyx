# Demyx
# https://demyx.sh
# 
# demyx update
#

demyx_update() {
    # Use latest code updates from git repo
    if [[ "$DEMYX_BRANCH" = edge ]]; then
        git clone https://github.com/demyxco/demyx.git /etc/demyx-edge
        rm -rf /etc/demyx
        mv /etc/demyx-edge /etc/demyx
        chmod +x /etc/demyx/demyx.sh
        chmod +x /etc/demyx/bin/demyx-api.sh
        chmod +x /etc/demyx/bin/demyx-crond.sh
        chmod +x /etc/demyx/bin/demyx-dev.sh
        chmod +x /etc/demyx/bin/demyx-init.sh
        chmod +x /etc/demyx/bin/demyx-prod.sh
        chmod +x /etc/demyx/bin/demyx-skel.sh
        chmod +x /etc/demyx/bin/demyx-ssh.sh
    fi

    # Refresh stack if .env exists
    if [[ -f "$DEMYX_STACK"/.env ]]; then
        demyx stack refresh
    fi

    # Don't update chroot.sh when hostname is code - for internal use only
    if [[ "$DEMYX_HOST" != code ]]; then
        demyx_echo 'Updating chroot.sh'
        demyx_execute docker run -t --user=root --privileged --rm -v /usr/local/bin:/usr/local/bin demyx/utilities demyx-chroot
    fi

    # Get remote versions
    [[ ! -f "$DEMYX"/.update_remote ]] && demyx_execute -v demyx_update_remote

    # Get local versions
    [[ ! -f "$DEMYX"/.update_local ]] && demyx_execute -v demyx_update_local

    # Update versions counter
    demyx_execute -v demyx_update_count
}
