# Demyx
# https://demyx.sh
# 
# demyx update
#

demyx_update() {
    demyx_echo 'Updating chroot.sh'
    demyx_execute docker run -t --user=root --rm -v /usr/local/bin:/usr/local/bin demyx/utilities "rm -f /usr/local/bin/demyx; curl -s https://raw.githubusercontent.com/demyxco/demyx/master/chroot.sh -o /usr/local/bin/demyx; chmod +x /usr/local/bin/demyx"

    # Refresh stack if .env exists
    if [[ -f "$DEMYX_STACK"/.env ]]; then
        demyx stack refresh
    fi
}
