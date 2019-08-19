# Demyx
# https://demyx.sh
# 
# demyx update
#

demyx_update() {
    cd "$DEMYX_ETC"
    git pull

    demyx_echo 'Updating MOTD'
    demyx_execute sed -i '/DEMYX_MOTD_STATUS/d' "$DEMYX"/.env; echo 'DEMYX_MOTD_STATUS=0' >> "$DEMYX"/.env

    demyx stack --refresh
}
