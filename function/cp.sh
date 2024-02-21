# Demyx
# https://demyx.sh
# shellcheck shell=bash
# TODO
#
#   demyx cp <app> <args> <target|path> <target|path>
#
demyx_cp() {
    demyx_event
    DEMYX_ARG_2="${1:-$DEMYX_ARG_2}"
    # shellcheck disable=SC2153
    local DEMYX_CP="$DEMYX_TMP"/demyx_transient

    if [[ -n "$DEMYX_ARG_2" ]]; then
        demyx_arg_valid
        demyx_app_env wp "
            DEMYX_APP_DB_CONTAINER
            DEMYX_APP_NX_CONTAINER
            DEMYX_APP_STACK
            DEMYX_APP_WP_CONTAINER
        "

        {
            echo "MariaDB       docker cp <target> ${DEMYX_APP_DB_CONTAINER}:${DEMYX}/<path>"
            echo "              docker cp ${DEMYX_APP_DB_CONTAINER}:${DEMYX}/<target> <path>"

            if [[ "$DEMYX_APP_STACK" = nginx-php || "$DEMYX_APP_STACK" = nginx-bedrock ]]; then
                echo
                echo "Nginx         docker cp <target> ${DEMYX_APP_NX_CONTAINER}:${DEMYX}/<path>"
                echo "              docker cp ${DEMYX_APP_NX_CONTAINER}:${DEMYX}/<target> <path>"
            fi

            echo
            echo "WordPress     docker cp <target> ${DEMYX_APP_WP_CONTAINER}:${DEMYX}/<path>"
            echo "              docker cp ${DEMYX_APP_WP_CONTAINER}:${DEMYX}/<target> <path>"

        } > "$DEMYX_CP"

        demyx_divider_title "CP Commands"
        cat < "$DEMYX_CP"
    else
        demyx_error app
    fi
}
