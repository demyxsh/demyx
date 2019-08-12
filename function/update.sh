# Demyx
# https://demyx.sh
# 
# demyx update
#

demyx_update() {
    source "$DEMYX_FUNCTION"/env.sh
    source "$DEMYX_FUNCTION"/yml.sh

    cd "$DEMYX_ETC"
    git pull

    demyx_echo 'Updating stack .env'
    demyx_execute demyx_stack_env

    demyx_echo 'Updating stack .yml'
    demyx_execute demyx_stack_yml

    demyx_echo 'Updating MOTD'
    demyx_execute sed -i '/DEMYX_MOTD_STATUS/d' "$DEMYX"/.env; echo 'DEMYX_MOTD_STATUS=0' >> "$DEMYX"/.env

    demyx stack up -d --remove-orphans
}
