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
            demyx_warning "$DEMYX_ARG_2 has one or more errors. Please check error log, skipping ..."
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
    local DEMYX_WP_APP_COUNT
    DEMYX_WP_APP_COUNT="$(demyx_count_wp)"
    local DEMYX_WP_APP_CHECK=
    local DEMYX_WP_APP_MEM=
    DEMYX_WP_APP_MEM="$(echo "$DEMYX_MEM" | tr '[:lower:]' '[:upper:]')"
    local DEMYX_WP_APP_WORKDIR=/demyx

    demyx_app_env wp "
        DEMYX_APP_DOMAIN
        DEMYX_APP_STACK
        DEMYX_APP_TYPE
        DEMYX_APP_WP_CONTAINER
    "

    if (( "$DEMYX_WP_APP_COUNT" > 0 )); then
        demyx_arg_valid

        if [[ "$DEMYX_APP_TYPE" = wp ]]; then
            DEMYX_WP_APP_CHECK="$(docker exec -t "$DEMYX_APP_WP_CONTAINER" which wp || true)"

            # PREP for next version.
            if [[ -n "$DEMYX_WP_APP_CHECK" ]]; then
                demyx_execute false \
                    "docker exec -t $DEMYX_APP_WP_CONTAINER wp --no-color $DEMYX_WP_ARGS"
            else
                DEMYX_WP_APP="docker run -t --rm \
                    --network=demyx \
                    --volumes-from=$DEMYX_APP_WP_CONTAINER \
                    --workdir=$DEMYX_WP_APP_WORKDIR \
                    --entrypoint=php \
                    demyx/wordpress:cli -d memory_limit=$DEMYX_WP_APP_MEM /usr/local/bin/wp --no-color $DEMYX_WP_ARGS"

                # shellcheck disable=2153
                if [[ "$DEMYX_ARG_1" = wp ]]; then
                    demyx_execute false "$DEMYX_WP_APP"
                else
                    eval "$DEMYX_WP_APP"
                fi
            fi
        fi
    fi
}
