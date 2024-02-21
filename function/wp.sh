# Demyx
# https://demyx.sh
# shellcheck shell=bash

#
#   demyx wp <app> <args>
#
demyx_wp() {
    demyx_event
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
        demyx_event
        DEMYX_ARG_2="$DEMYX_WP_ALL"
        DEMYX_WP_ALL_CHECK=0

        demyx_app_env wp DEMYX_APP_WP_CONTAINER

        DEMYX_WP_ALL_CHECK_WP="$(docker exec "$DEMYX_APP_WP_CONTAINER" wp core is-installed 2>&1 || true)"
        if [[ "$DEMYX_WP_ALL_CHECK_WP" == *"Error"* ||
                "$DEMYX_WP_ALL_CHECK_WP" == *"error"* ]]; then
            DEMYX_WP_ALL_CHECK=1
        fi

        if [[ "$DEMYX_WP_ALL_CHECK" = 1 ]]; then
            demyx_warning "$DEMYX_ARG_2 has one or more errors, skipping ..."
            continue
        else
            eval demyx_wp "$DEMYX_WP_ALL" "$DEMYX_WP_ARGS"
        fi
    done
}
#
#   Main WP-CLI function.
#
demyx_wp_app() {
    demyx_event
    local DEMYX_WP_APP=
    DEMYX_WP_APP="$(demyx_count_wp)"

    demyx_app_env wp "
        DEMYX_APP_TYPE
        DEMYX_APP_WP_CONTAINER
    "

    if (( "$DEMYX_WP_APP" > 0 )); then
        demyx_arg_valid

        if [[ "$DEMYX_APP_TYPE" = wp ]]; then
            eval docker exec -t "$DEMYX_APP_WP_CONTAINER" wp "$DEMYX_WP_ARGS"
        fi
    fi
}
