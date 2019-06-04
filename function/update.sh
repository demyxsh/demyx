# Demyx
# https://demyx.sh
# 
# demyx update
#

function demyx_update() {
    source "$DEMYX_FUNCTION"/env.sh
    source "$DEMYX_FUNCTION"/yml.sh

    demyx_echo 'Updating demyx'
    demyx_execute -v cd "$DEMYX_ETC" && git pull

    demyx_echo 'Updating stack .env'
    demyx_execute demyx_stack_env

    demyx_echo 'Updating stack .yml'
    demyx_execute demyx_stack_yml

    demyx stack up -d --remove-orphans
}
