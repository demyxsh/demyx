# Demyx
# https://demyx.sh
# 
# demyx update
#

demyx_update() {
    demyx_echo 'Updating chroot.sh'
    demyx_execute docker run -t --user=root --privileged --rm -v /usr/local/bin:/usr/local/bin demyx/utilities demyx-chroot

    # Refresh stack if .env exists
    if [[ -f "$DEMYX_STACK"/.env ]]; then
        demyx stack refresh
    fi
}
