# Demyx
# https://demyx.sh
# 
# demyx exec <app> <docker exec args>
# demyx exec <app> <args> <docker exec args>
#
demyx_exec() {
    while :; do
        case "$1" in
            db)
                DEMYX_EXEC_DB=1
                ;;
            -t)
                DEMYX_EXEC_TTY=1
                ;;
            --)
                shift
                break
                ;;
            -?*)
                printf '\e[31m[CRITICAL]\e[39m Unknown option: %s\n' "$1" >&2
                exit 1
                ;;
            *)
                break
        esac
        shift
    done

    demyx_app_config

    # If -t flag is passed then TTY only
    if [[ -n "$DEMYX_EXEC_TTY" ]]; then
        DEMYX_EXEC_FLAG="-t"
    else
        DEMYX_EXEC_FLAG="-it"
    fi

    if [[ "$DEMYX_TARGET" = all ]]; then
        cd "$DEMYX_WP" || exit
        for i in *
        do
            demyx exec "$i" "$@"
        done
    elif [[ "$DEMYX_APP_TYPE" = wp ]]; then
        DEMYX_EXEC_CONTAINER="$DEMYX_APP_WP_CONTAINER"
        [[ -n "$DEMYX_EXEC_DB" ]] && DEMYX_EXEC_CONTAINER="$DEMYX_APP_DB_CONTAINER"
        docker exec "$DEMYX_EXEC_FLAG" "$DEMYX_EXEC_CONTAINER" "$@"
    elif [[ -n "$DEMYX_GET_APP" ]]; then
        docker exec "$DEMYX_EXEC_FLAG" "$DEMYX_GET_APP" "$@"
    else
        demyx_die --not-found
    fi
}
