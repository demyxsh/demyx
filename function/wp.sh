# Demyx
# https://demyx.sh

function demyx_wp() {
    demyx_app_config
    if [[ "$DEMYX_TARGET" = all ]]; then
        cd "$DEMYX_WP" || exit
        for i in *
        do
            demyx wp "$i" "$@"
        done
    elif [[ "$DEMYX_APP_TYPE" = wp ]]; then
        demyx_execute -v docker run -t --rm \
            --volumes-from "$DEMYX_APP_WP_CONTAINER" \
            --network container:"$DEMYX_APP_WP_CONTAINER" \
            wordpress:cli "$@"
    else
        demyx_die --not-found
    fi
}
