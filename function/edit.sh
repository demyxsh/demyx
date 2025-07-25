# Demyx
# https://demyx.sh
# shellcheck shell=bash

#
#   demyx edit <app> <args>
#
demyx_edit() {
    demyx_event
    local DEMYX_EDIT_FLAG=
    local DEMYX_EDIT_FLAG_REFRESH=

    demyx_source refresh

    while :; do
        DEMYX_EDIT_FLAG="${2:-}"
        case "$DEMYX_EDIT_FLAG" in
            -r)
                DEMYX_EDIT_FLAG_REFRESH=true
            ;;
            --)
                shift
                break
            ;;
            -?*)
                demyx_error flag "$DEMYX_EDIT_FLAG"
            ;;
            *)
                break
        esac
        shift
    done

    if [[ -n "$DEMYX_ARG_2" ]]; then
        demyx_app_env wp "
            DEMYX_APP_DOMAIN
            DEMYX_APP_PATH
        "

        docker exec -it --user=root demyx bash -c "nano ${DEMYX_APP_PATH}/.env"

        if [[ "$DEMYX_EDIT_FLAG_REFRESH" = true ]]; then
            demyx_refresh "$DEMYX_APP_DOMAIN"
        fi
    else
        demyx_help edit
    fi

    # TODO
    #case "$DEMYX_ARG_2" in
    #    traefik)
    #        demyx_execute false \
    #            "nano ${DEMYX_TRAEFIK}/.env"

    #        if [[ "$DEMYX_EDIT_FLAG_REFRESH" = true ]]; then
    #            demyx_refresh traefik
    #        fi
    #    ;;
    #    *)
    #    ;;
    #esac
}
