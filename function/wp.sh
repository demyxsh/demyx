# Demyx
# https://demyx.sh

#
#   demyx wp <app> <args>
#
demyx_wp() {
    DEMYX_ARG_2="${1:-$DEMYX_ARG_2}"
    [[ -n "$DEMYX_ARG_2" ]] && shift && local DEMYX_WP_ARGS="$*"

    case "$DEMYX_ARG_2" in
        all)
            demyx_wp_all
        ;;
        *)
            if [[ -n "$DEMYX_ARG_2" ]]; then
                demyx_wp_app "$DEMYX_ARG_2"
            else
                demyx_help wp
            fi
        ;;
    esac
}
#
#   Loop for demyx_wp_app.
#
demyx_wp_all() {
    local DEMYX_WP_ALL=
    local DEMYX_WP_ALL_CHECK=
    local DEMYX_WP_ALL_CHECK_WP=

    cd "$DEMYX_WP" || exit

    for DEMYX_WP_ALL in *; do
        DEMYX_ARG_2="$DEMYX_WP_ALL"
        DEMYX_WP_ALL_CHECK=0

        demyx_app_env wp DEMYX_APP_WP_CONTAINER

        DEMYX_WP_ALL_CHECK_WP="$(docker exec "$DEMYX_APP_WP_CONTAINER" wp core is-installed 2>&1 || true)"
        if [[ "$DEMYX_WP_ALL_CHECK_WP" == *"Error"* ||
                "$DEMYX_WP_ALL_CHECK_WP" == *"error"* ]]; then
            DEMYX_WP_ALL_CHECK=1
            demyx_logger "Executing WP-CLI for $DEMYX_WP_ALL" "demyx_wp $DEMYX_WP_ALL $DEMYX_WP_ARGS" "$DEMYX_WP_ALL_CHECK_WP" error
        fi

        if [[ "$DEMYX_WP_ALL_CHECK" = 1 ]]; then
            demyx_warning "$DEMYX_ARG_2 has one or more errors. Please check error log, skipping ..."
            continue
        else
            eval demyx_wp "$DEMYX_WP_ALL" "$DEMYX_WP_ARGS"
        fi
    done
}

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
