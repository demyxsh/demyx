# Demyx
# https://demyx.sh
# 
# demyx cp <app/path>:<path> <app/path>:<path>
#
demyx_cp() {
    demyx_app_is_up

    if [[ "$1" = db ]]; then
        DEMYX_CP_FIRST_ARG="$2"
        DEMYX_CP_SECOND_ARG="$3"
        DEMYX_CP_FIRST_ARG_PATH_CHECK="${2:0:1}"
        DEMYX_CP_SECOND_ARG_PATH_CHECK="${3:0:1}"
    else
        DEMYX_CP_FIRST_ARG="$1"
        DEMYX_CP_SECOND_ARG="$2"
        DEMYX_CP_FIRST_ARG_PATH_CHECK="${1:0:1}"
        DEMYX_CP_SECOND_ARG_PATH_CHECK="${2:0:1}"
    fi

    DEMYX_CP_FIRST_ARG_PARAM_1="$(echo "$DEMYX_CP_FIRST_ARG" | awk -F '[:]' '{print $1}')"
    DEMYX_CP_FIRST_ARG_PARAM_2="$(echo "$DEMYX_CP_FIRST_ARG" | awk -F '[:]' '{print $2}')"
    DEMYX_CP_SECOND_ARG_PARAM_1="$(echo "$DEMYX_CP_SECOND_ARG" | awk -F '[:]' '{print $1}')"
    DEMYX_CP_SECOND_ARG_PARAM_2="$(echo "$DEMYX_CP_SECOND_ARG" | awk -F '[:]' '{print $2}')"

    if [[ "$1" = db ]]; then
        [[ "$DEMYX_CP_FIRST_ARG_PATH_CHECK" != / ]] && DEMYX_CP_FIRST_ARG_APP_CHECK="$(demyx info "$DEMYX_CP_FIRST_ARG_PARAM_1" --filter=DEMYX_APP_DB_CONTAINER --quiet)"
        [[ "$DEMYX_CP_SECOND_ARG_PATH_CHECK" != / ]] && DEMYX_CP_SECOND_ARG_APP_CHECK="$(demyx info "$DEMYX_CP_SECOND_ARG_PARAM_1" --filter=DEMYX_APP_DB_CONTAINER --quiet)"
    else
        [[ "$DEMYX_CP_FIRST_ARG_PATH_CHECK" != / ]] && DEMYX_CP_FIRST_ARG_APP_CHECK="$(demyx info "$DEMYX_CP_FIRST_ARG_PARAM_1" --filter=DEMYX_APP_WP_CONTAINER --quiet)"
        [[ "$DEMYX_CP_SECOND_ARG_PATH_CHECK" != / ]] && DEMYX_CP_SECOND_ARG_APP_CHECK="$(demyx info "$DEMYX_CP_SECOND_ARG_PARAM_1" --filter=DEMYX_APP_WP_CONTAINER --quiet)"
    fi

    if [[ -n "$DEMYX_CP_FIRST_ARG_APP_CHECK" ]]; then
        DEMYX_CP_FIRST_ARG="$DEMYX_CP_FIRST_ARG_APP_CHECK":"$DEMYX_CP_FIRST_ARG_PARAM_2"
    else
        DEMYX_CP_FIRST_ARG="$DEMYX_CP_FIRST_ARG_PARAM_1"
        [[ -n "$DEMYX_CP_FIRST_ARG_PARAM_2" ]] && DEMYX_CP_FIRST_ARG="$DEMYX_CP_FIRST_ARG_PARAM_1":"$DEMYX_CP_FIRST_ARG_PARAM_2"
    fi

    if [[ -n "$DEMYX_CP_SECOND_ARG_APP_CHECK" ]]; then
        DEMYX_CP_SECOND_ARG="$DEMYX_CP_SECOND_ARG_APP_CHECK":"$DEMYX_CP_SECOND_ARG_PARAM_2"
    else
        DEMYX_CP_SECOND_ARG="$DEMYX_CP_SECOND_ARG_PARAM_1"
        [[ -n "$DEMYX_CP_SECOND_ARG_PARAM_2" ]] && DEMYX_CP_SECOND_ARG="$DEMYX_CP_SECOND_ARG_PARAM_1":"$DEMYX_CP_SECOND_ARG_PARAM_2"
    fi

    docker cp "$DEMYX_CP_FIRST_ARG" "$DEMYX_CP_SECOND_ARG"
}
