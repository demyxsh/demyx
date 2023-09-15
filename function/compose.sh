# Demyx
# https://demyx.sh
#
#   demyx compose <app> <args> <docker-compose args>
#
demyx_compose() {
    DEMYX_ARG_2="${1:-$DEMYX_ARG_2}"
    local DEMYX_COMPOSE_TYPE="${2:-}"
    [[ -n "$DEMYX_ARG_2" ]] && shift && local DEMYX_COMPOSE_ARGS="$*"

    case "$DEMYX_ARG_2" in
        all)
            demyx_compose_all
        ;;
        *)
            demyx_compose_app
        ;;
    esac
}
#
#   Loop for demyx_compose_app.
#
demyx_compose_all() {
    local DEMYX_COMPOSE_ALL=

    cd "$DEMYX_WP" || exit

    for DEMYX_COMPOSE_ALL in *; do
        eval demyx_compose "$DEMYX_COMPOSE_ALL" "$DEMYX_COMPOSE_ARGS"
    done
}
#
#   Main docker-compose function.
#
demyx_compose_app() {
    local DEMYX_COMPOSE_APP=
    local DEMYX_COMPOSE_APP_CHECK=

    DEMYX_COMPOSE_APP_CHECK="$(demyx_app_path "$DEMYX_ARG_2")"

    if [[ -n "$DEMYX_COMPOSE_APP_CHECK" && "$DEMYX_COMPOSE_APP_CHECK" == *"wp/${DEMYX_ARG_2}"* ]]; then
        demyx_app_env wp "
            DEMYX_APP_DOMAIN
            DEMYX_APP_ID
            DEMYX_APP_PATH
        "
    elif [[ -n "$DEMYX_COMPOSE_APP_CHECK" ]]; then
        # shellcheck disable=2034
        DEMYX_APP_PATH="$DEMYX_COMPOSE_APP_CHECK"
    else
        demyx_error app
    fi

    cd "$DEMYX_APP_PATH" || exit

    case "$DEMYX_COMPOSE_TYPE" in
        -d)
            DEMYX_COMPOSE_APP="docker-compose ${DEMYX_COMPOSE_ARGS//db /} db_${DEMYX_APP_ID}"
            DEMYX_COMPOSE_APP="${DEMYX_COMPOSE_APP//docker-compose -d/docker-compose}"
            DEMYX_COMPOSE_APP="${DEMYX_COMPOSE_APP//docker-compose --database/docker-compose}"
        ;;
        down)
            DEMYX_COMPOSE_APP="docker-compose stop && docker-compose rm -f"
        ;;
        fr)
            DEMYX_COMPOSE_APP="docker-compose up -d --force-recreate --remove-orphans"
        ;;
        -n)
            DEMYX_COMPOSE_APP="docker-compose --no-deps ${DEMYX_COMPOSE_ARGS//nx /} nx_${DEMYX_APP_ID}"
            DEMYX_COMPOSE_APP="${DEMYX_COMPOSE_APP//docker-compose --no-deps -n/docker-compose}"
            DEMYX_COMPOSE_APP="${DEMYX_COMPOSE_APP//docker-compose --no-deps --nginx/docker-compose}"
        ;;
        -w)
            DEMYX_COMPOSE_APP="docker-compose --no-deps ${DEMYX_COMPOSE_ARGS//wp /} --no-deps wp_${DEMYX_APP_ID}"
            DEMYX_COMPOSE_APP="${DEMYX_COMPOSE_APP//docker-compose --no-deps -w/docker-compose}"
            DEMYX_COMPOSE_APP="${DEMYX_COMPOSE_APP//docker-compose --no-deps --wordpress/docker-compose}"
        ;;
        *)
            DEMYX_COMPOSE_APP="docker-compose $DEMYX_COMPOSE_ARGS"
        ;;
    esac

    if eval "$DEMYX_COMPOSE_APP" 2>&1 | tee "$DEMYX_TMP"/demyx_execute; then
        demyx_logger false "$DEMYX_COMPOSE_APP" "$(cat < "$DEMYX_TMP"/demyx_execute)"
    else
        demyx_logger false "$DEMYX_COMPOSE_APP" "$(cat < "$DEMYX_TMP"/demyx_execute)" error
    fi
}
