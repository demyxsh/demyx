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

        if [[ "$DEMYX_APP_STACK" = bedrock || "$DEMYX_APP_STACK" = ols-bedrock ]]; then
            DEMYX_WP_WORKDIR=/demyx/web
        else
            DEMYX_WP_WORKDIR=/demyx
        fi

        if [[ "$*" == "help"* ]]; then
            docker run -it --rm -e PAGER=more demyx/wordpress:cli "$@"
        else
            demyx_execute -v docker run -t --rm \
                --network=demyx \
                --volumes-from="$DEMYX_APP_WP_CONTAINER" \
                --workdir="$DEMYX_WP_WORKDIR" \
                demyx/wordpress:cli "$@"
        fi

    else
        demyx_die --not-found
    fi
}
