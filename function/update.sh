# Demyx
# https://demyx.sh
# 
# demyx update
#

demyx_update() {
    cd "$DEMYX_ETC"
    git pull

    demyx_echo 'Updating MOTD'
    demyx_execute sed -i "s|DEMYX_MOTD_STATUS=.*|DEMYX_MOTD_STATUS=0|g" "$DEMYX"/.env
    demyx stack refresh
}
