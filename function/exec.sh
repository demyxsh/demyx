# Demyx
# https://demyx.sh
#
#   demyx exec <app> <args>
#
demyx_exec() {
    local DEMYX_EXEC=
    local DEMYX_EXEC_CONTAINER=
    local DEMYX_EXEC_FLAG=
    local DEMYX_EXEC_FLAG_DB=
    local DEMYX_EXEC_FLAG_NX=
    local DEMYX_EXEC_FLAG_ROOT=
    local DEMYX_EXEC_FLAG_NON_INTERACTIVE=
    local DEMYX_EXEC_TTY=
    local DEMYX_EXEC_USER=

    while :; do
        DEMYX_EXEC_FLAG="${2:-}"
        case "$DEMYX_EXEC_FLAG" in
            -d)
                DEMYX_EXEC_FLAG_DB=true
            ;;
            -n)
                DEMYX_EXEC_FLAG_NX=true
            ;;
            -r)
                DEMYX_EXEC_FLAG_ROOT=true
            ;;
            -t)
                DEMYX_EXEC_FLAG_NON_INTERACTIVE=true
            ;;
            --)
                shift
                break
            ;;
            -?*)
                demyx_error flag "$DEMYX_EXEC_FLAG"
            ;;
            *)
                break
        esac
        shift
    done

    if [[ -n "$DEMYX_ARG_2" ]]; then
        demyx_arg_valid
        demyx_app_env wp "
            DEMYX_APP_DB_CONTAINER
            DEMYX_APP_NX_CONTAINER
            DEMYX_APP_WP_CONTAINER
        "

        # If -t flag is passed then TTY only
        if [[ -n "$DEMYX_EXEC_FLAG_NON_INTERACTIVE" ]]; then
            DEMYX_EXEC_TTY="-t"
        else
            DEMYX_EXEC_TTY="-it"
        fi

        # Execute as root
        if [[ "$DEMYX_EXEC_FLAG_ROOT" = true ]]; then
            DEMYX_EXEC_USER="--user=root"
        else
            DEMYX_EXEC_USER="--user=demyx"
        fi

        if [[ "$DEMYX_EXEC_FLAG_DB" = true ]]; then
            DEMYX_EXEC_CONTAINER="$DEMYX_APP_DB_CONTAINER"
        elif [[ "$DEMYX_EXEC_FLAG_NX" = true ]]; then
            DEMYX_EXEC_CONTAINER="$DEMYX_APP_NX_CONTAINER"
        else
            DEMYX_EXEC_CONTAINER="$DEMYX_APP_WP_CONTAINER"
        fi

        shift

        DEMYX_EXEC="docker exec $DEMYX_EXEC_TTY $DEMYX_EXEC_USER $DEMYX_EXEC_CONTAINER ${*:-bash}"

        if eval "$DEMYX_EXEC" 2>&1 | tee "$DEMYX_TMP"/demyx_execute; then
            demyx_logger false "docker exec $DEMYX_EXEC" "$(cat < "$DEMYX_TMP"/demyx_execute)"
        else
            demyx_logger false "docker exec $DEMYX_EXEC" "$(cat < "$DEMYX_TMP"/demyx_execute)" error
        fi
    else
        demyx_help exec
    fi
}
