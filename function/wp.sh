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
