# Demyx
# https://demyx.sh
# 
# demyx update
#

demyx_update() {
    # Build local versions
    if [[ ! -f "$DEMYX"/.update_local ]]; then
        demyx_execute -v demyx_update_local
    fi

    # Build remote versions
    if [[ ! -f "$DEMYX"/.update_remote ]]; then
        demyx_execute -v demyx_update_remote
    fi

    # Get versions counter
    if [[ ! -f "$DEMYX"/.update_count ]]; then
        demyx_execute -v demyx_update_count
    fi

    # Get images that needs updating
    if [[ ! -f "$DEMYX"/.update_image ]]; then
        demyx_execute -v demyx_update_image
    fi
}
