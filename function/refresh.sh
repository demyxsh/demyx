# Demyx
# https://demyx.sh
# shellcheck shell=bash

#
#   demyx refresh <app> <args>
#
demyx_refresh() {
    demyx_event
    DEMYX_ARG_2="${1:-$DEMYX_ARG_2}"
    shift && local DEMYX_REFRESH_ARGS="$*"
    local DEMYX_REFRESH_FLAG=
    local DEMYX_REFRESH_FLAG_FORCE=
    local DEMYX_REFRESH_FLAG_NO_COMPOSE=
    local DEMYX_REFRESH_FLAG_NO_FORCE_RECREATE=
    local DEMYX_REFRESH_FLAG_SKIP=

    demyx_source "
        env
        backup
        compose
        yml
    "

    while :; do
        DEMYX_REFRESH_FLAG="${1:-}"
        case "$DEMYX_REFRESH_FLAG" in
            -f)
                DEMYX_REFRESH_FLAG_FORCE=true
                ;;
            -nc)
                DEMYX_REFRESH_FLAG_NO_COMPOSE=true
            ;;
            -nfr)
                DEMYX_REFRESH_FLAG_NO_FORCE_RECREATE=true
            ;;
            -s)
                DEMYX_REFRESH_FLAG_SKIP=true
            ;;
            --)
                shift
                break
                ;;
            -?*)
                demyx_error flag "$DEMYX_REFRESH_FLAG"
                ;;
            *)
                break
        esac
        shift
    done

    case "$DEMYX_ARG_2" in
        all)
            demyx_refresh_all
        ;;
        code)
            demyx_refresh_code
        ;;
        traefik)
            demyx_refresh_traefik
        ;;
        *)
            if [[ -n "$DEMYX_ARG_2" ]]; then
                demyx_arg_valid
                demyx_refresh_app
            else
                demyx_help refresh
            fi
        ;;
    esac
}
#
#   Loop for demyx_backup_app.
#
demyx_refresh_all() {
    demyx_event
    local DEMYX_REFRESH_ALL=

    cd "$DEMYX_WP" || exit

    for DEMYX_REFRESH_ALL in *; do
        demyx_echo "Refreshing $DEMYX_REFRESH_ALL"
        eval demyx_refresh "$DEMYX_REFRESH_ALL" "$DEMYX_REFRESH_ARGS"
    done
}
#
#   Main refresh function.
#
demyx_refresh_app() {
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_DEV
        DEMYX_APP_DOMAIN
        DEMYX_APP_PATH
        DEMYX_APP_STACK
    "

    if [[ -z "$DEMYX_REFRESH_FLAG_SKIP" ]]; then
        demyx_backup "$DEMYX_APP_DOMAIN" -c
    fi

    if [[ "$DEMYX_REFRESH_FLAG_FORCE" = true ]]; then
        demyx_execute "Force refreshing configs" \
            "sed -i '/# START REFRESHABLE VARIABLES/,/# END REFRESHABLE VARIABLES/d' ${DEMYX_APP_PATH}/.env; \
            demyx_env; \
            demyx_yml $DEMYX_APP_STACK"
    else
        demyx_execute "Refreshing configs" \
            "demyx_env; \
            demyx_yml $DEMYX_APP_STACK"
    fi

    # TODO
    #if [[ -z "$DEMYX_REFRESH_SKIP_CHECKS" ]]; then
    #    [[ "$DEMYX_APP_RATE_LIMIT" = true ]] && demyx config "$DEMYX_APP_DOMAIN" --rate-limit -f
    #    [[ "$DEMYX_APP_CACHE" = true ]] && demyx config "$DEMYX_APP_DOMAIN" --cache -f
    #    [[ "$DEMYX_APP_AUTH" = true ]] && demyx config "$DEMYX_APP_DOMAIN" --auth -f
    #    [[ "$DEMYX_APP_AUTH_WP" = true ]] && demyx config "$DEMYX_APP_DOMAIN" --auth-wp -f
    #    [[ "$DEMYX_APP_HEALTHCHECK" = true ]] && demyx config "$DEMYX_APP_DOMAIN" --healthcheck -f
    #fi

    if [[ -z "$DEMYX_REFRESH_FLAG_NO_COMPOSE" ]]; then
        if [[ "$DEMYX_REFRESH_FLAG_NO_FORCE_RECREATE" = true ]]; then
            demyx_compose "$DEMYX_APP_DOMAIN" up -d --remove-orphans
        else
            demyx_compose "$DEMYX_APP_DOMAIN" fr
        fi
    fi
}
#
#   Refresh code-server.
#
demyx_refresh_code() {
    demyx_event
    if [[ "$DEMYX_CODE_ENABLE" = true ]]; then
        if [[ ! -d "$DEMYX_CODE" ]]; then
            mkdir -p "$DEMYX_CODE"
        fi

        demyx_execute "Refreshing code-server" \
            "demyx_yml_code"

        demyx_compose code up -d --remove-orphans
    else
        if docker inspect demyx_code >/dev/null 2>&1; then
            demyx_compose code down
        fi
    fi
}
#
#   Refresh traefik.
#
demyx_refresh_traefik() {
    demyx_event
    demyx_execute "Backing up traefik directory to ${DEMYX_BACKUP}/traefik.tgz" \
        "tar -czf ${DEMYX_BACKUP}/traefik.tgz -C $DEMYX_APP traefik"

    demyx_execute "Refreshing traefik" \
        "demyx_yml_traefik"

    demyx_compose traefik up -d --remove-orphans
}
