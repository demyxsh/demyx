# Demyx
# https://demyx.sh
# 
# demyx exec <app> <docker exec args>
# demyx exec <app> <args> <docker exec args>
#
function demyx_exec() {
    while :; do
        case "$1" in
            db)
                DEMYX_EXEC_DB=1
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

    if [[ "$DEMYX_TARGET" = all ]]; then
        cd "$DEMYX_WP" || exit
        for i in *
        do
            demyx exec "$i" "$@"
        done
    elif [[ "$DEMYX_APP_TYPE" = wp ]]; then
        DEMYX_EXEC_CONTAINER="$DEMYX_APP_WP_CONTAINER"
        [[ -n "$DEMYX_EXEC_DB" ]] && DEMYX_EXEC_CONTAINER="$DEMYX_APP_DB_CONTAINER"
        docker exec -it "$DEMYX_EXEC_CONTAINER" "$@"
    else
        demyx_die --not-found
    fi
}
