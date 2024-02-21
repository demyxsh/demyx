# Demyx
# https://demyx.sh
# shellcheck shell=bash

#
#   demyx log <app> <args>
#
demyx_log() {
    demyx_event
    DEMYX_ARG_2="${1:-$DEMYX_ARG_2}"
    local DEMYX_LOG_FLAG=
    local DEMYX_LOG_FLAG_CRON=
    local DEMYX_LOG_FLAG_DATABASE=
    local DEMYX_LOG_FLAG_ERROR=
    local DEMYX_LOG_FLAG_FOLLOW=
    local DEMYX_LOG_TAIL_FLAG=-200
    local DEMYX_LOG_STDOUT_FLAG=

    while :; do
        DEMYX_LOG_FLAG="${2:-}"
        case "$DEMYX_LOG_FLAG" in
            -c|-cf|-fc)
                DEMYX_LOG_FLAG_CRON=true

                if [[ "$DEMYX_LOG_FLAG" = -cf || "$DEMYX_LOG_FLAG" = -fc ]]; then
                    DEMYX_LOG_FLAG_FOLLOW=true
                fi
            ;;
            -d|-df|-fd)
                DEMYX_LOG_FLAG_DATABASE=true

                if [[ "$DEMYX_LOG_FLAG" = -df || "$DEMYX_LOG_FLAG" = -fd ]]; then
                    DEMYX_LOG_FLAG_FOLLOW=true
                fi
                ;;
            -e|-ef|-fe)
                DEMYX_LOG_FLAG_ERROR=true

            if [[ "$DEMYX_LOG_FLAG" = -ef || "$DEMYX_LOG_FLAG" = -fe ]]; then
                DEMYX_LOG_FLAG_FOLLOW=true
            fi
                ;;
            -f)
                DEMYX_LOG_FLAG_FOLLOW=true
                ;;
            -s|-sf|-fs)
                DEMYX_LOG_STDOUT_FLAG=true

                if [[ "$DEMYX_LOG_FLAG" = -sf || "$DEMYX_LOG_FLAG" = -fs ]]; then
                    DEMYX_LOG_FLAG_FOLLOW=true
                fi
                ;;
            --)
                shift
                break
                ;;
            -?*)
                demyx_error flag "$DEMYX_LOG_FLAG"
                ;;
            *)
                break
        esac
        shift
    done

    if [[ "$DEMYX_LOG_FLAG_FOLLOW" = true ]]; then
        DEMYX_LOG_TAIL_FLAG=-f
        DEMYX_LOG_FLAG_FOLLOW=-f
    fi

    case "$DEMYX_ARG_2" in
        cron)
            demyx_log_cron
        ;;
        main)
            demyx_log_main
        ;;
        traefik)
            demyx_log_traefik
        ;;
        *)
            if [[ -n "$DEMYX_ARG_2" ]]; then
                demyx_arg_valid
                demyx_log_app "$DEMYX_ARG_2"
            else
                demyx_help log
            fi
        ;;
    esac
}
#
#   Main log function.
#
demyx_log_app() {
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_DOMAIN
        DEMYX_APP_DB_CONTAINER
        DEMYX_APP_WP_CONTAINER
    "

    if [[ "$DEMYX_LOG_FLAG_CRON" ]]; then
        docker exec -it "$DEMYX_APP_WP_CONTAINER" \
            tail "$DEMYX_LOG_TAIL_FLAG" "$DEMYX_LOG"/"$DEMYX_APP_DOMAIN".cron.log
    elif [[ "$DEMYX_LOG_FLAG_DATABASE" = true ]]; then
        docker exec -it "$DEMYX_APP_DB_CONTAINER" \
            tail "$DEMYX_LOG_TAIL_FLAG" "$DEMYX_LOG"/"$DEMYX_APP_DOMAIN".mariadb.log
    elif [[ "$DEMYX_LOG_FLAG_ERROR" = true ]]; then
        docker exec -it "$DEMYX_APP_WP_CONTAINER" \
            tail "$DEMYX_LOG_TAIL_FLAG" "$DEMYX_LOG"/"$DEMYX_APP_DOMAIN".error.log
    elif [[ "$DEMYX_LOG_STDOUT_FLAG" = true ]]; then
        eval docker logs "$DEMYX_APP_WP_CONTAINER" "$DEMYX_LOG_FLAG_FOLLOW"
    else
        docker exec -it "$DEMYX_APP_WP_CONTAINER" \
            tail "$DEMYX_LOG_TAIL_FLAG" "$DEMYX_LOG"/"$DEMYX_APP_DOMAIN".access.log
    fi
}
#
#   View cron logs.
#
demyx_log_cron() {
    demyx_event
}
#
#   View demyx logs.
#
demyx_log_main() {
    demyx_event
    if [[ "$DEMYX_LOG_FLAG_ERROR" = true ]]; then
        if [[ -f "$DEMYX_LOG"/error.log ]]; then
            tail "$DEMYX_LOG_TAIL_FLAG" "$DEMYX_LOG"/error.log
        else
            demyx_warning "Error log file hasn't been created yet, exiting ..."
        fi
    elif [[ "$DEMYX_LOG_STDOUT_FLAG" = true ]]; then
        eval docker logs demyx "$DEMYX_LOG_FLAG_FOLLOW"
    else
        tail "$DEMYX_LOG_TAIL_FLAG" "$DEMYX_LOG"/demyx.log
    fi
}
#
#   View traefik logs.
#
demyx_log_traefik() {
    demyx_event
    if [[ "$DEMYX_LOG_FLAG_ERROR" = true ]]; then
        tail "$DEMYX_LOG_TAIL_FLAG" "$DEMYX_LOG"/traefik.error.log
    else
        tail "$DEMYX_LOG_TAIL_FLAG" "$DEMYX_LOG"/traefik.access.log
    fi
}
