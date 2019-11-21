# Demyx
# https://demyx.sh
# 
# demyx update
#

demyx_update() {
    cd "$DEMYX_ETC"
    git pull

    if [[ -f "$DEMYX"/.env ]]; then
        demyx_echo 'Updating MOTD'
        demyx_execute sed -i "s|DEMYX_MOTD_STATUS=.*|DEMYX_MOTD_STATUS=0|g" "$DEMYX"/.env
    fi
    
    demyx stack refresh
}
