# Demyx
# https://demyx.sh

demyx_wp() {
    demyx_app_config
    
    if [[ "$DEMYX_TARGET" = all ]]; then
        cd "$DEMYX_WP" || exit
        for i in *
        do
            demyx wp "$i" "$@"
        done
    elif [[ "$DEMYX_APP_TYPE" = wp ]]; then
        
        [[ "$DEMYX_APP_STACK" = bedrock || "$DEMYX_APP_STACK" = ols-bedrock ]] && DEMYX_GLOBAL_WP_VOLUME=/demyx/web

        demyx_execute -v docker run -t --rm \
            --network=demyx \
            --volumes-from="$DEMYX_APP_WP_CONTAINER" \
            --workdir="$DEMYX_GLOBAL_WP_VOLUME" \
            demyx/wordpress:cli "$@"
    else
        demyx_die --not-found
    fi
}
