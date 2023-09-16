# Demyx
# https://demyx.sh
#
#   demyx refresh <app> <args>
#
demyx_refresh() {
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
    local DEMYX_REFRESH_ALL=

    cd "$DEMYX_WP" || exit

    for DEMYX_REFRESH_ALL in *; do
        demyx_echo "Refreshing $DEMYX_REFRESH_ALL"
        eval demyx_refresh "$DEMYX_REFRESH_ALL" "$DEMYX_REFRESH_ARGS"
    done
}

        demyx compose code up -d --remove-orphans
    elif [[ "$DEMYX_TARGET" = traefik ]]; then
        demyx_source yml

        # TEMPORARY CODE
        if [[ ! -d "$DEMYX_TRAEFIK" ]]; then
            demyx_echo 'Traefik directory not found, creating now'
            demyx_execute mkdir -p "$DEMYX_TRAEFIK"; \
                docker pull demyx/traefik; \
                docker stop demyx_traefik; \
                docker rm demyx_traefik
        fi
        
        demyx_echo 'Backing up traefik directory as /demyx/backup/traefik.tgz'
        demyx_execute tar -czf /demyx/backup/traefik.tgz -C /demyx/app traefik

        demyx_echo 'Refreshing traefik'
        demyx_execute demyx_traefik_yml

        demyx compose traefik up -d --remove-orphans
    else
        [[ ! -d "$DEMYX_WP"/"$DEMYX_TARGET" || -z "$DEMYX_TARGET" ]] && demyx_die --not-found

        demyx_app_config

        if [[ -z "$DEMYX_REFRESH_SKIP_BACKUP" ]]; then
            demyx backup "$DEMYX_APP_DOMAIN" --config
        fi

        demyx_source env
        demyx_source yml

        demyx_echo 'Refreshing .env'
        demyx_execute demyx_env

        if [[ -n "$DEMYX_REFRESH_FORCE" ]]; then
            demyx_execute -v echo "$(cat "$DEMYX_APP_PATH"/.env | head -n 45)" > "$DEMYX_APP_PATH"/.env
            demyx_echo 'Force refreshing the non-essential variables'
            demyx_execute demyx_env
        fi

        demyx_echo 'Refreshing .yml'
        demyx_execute demyx_yml

        demyx compose "$DEMYX_APP_DOMAIN" fr

        if [[ -z "$DEMYX_REFRESH_SKIP_CHECKS" ]]; then
            [[ "$DEMYX_APP_RATE_LIMIT" = true ]] && demyx config "$DEMYX_APP_DOMAIN" --rate-limit -f
            [[ "$DEMYX_APP_CACHE" = true ]] && demyx config "$DEMYX_APP_DOMAIN" --cache -f
            [[ "$DEMYX_APP_AUTH" = true ]] && demyx config "$DEMYX_APP_DOMAIN" --auth -f
            [[ "$DEMYX_APP_AUTH_WP" = true ]] && demyx config "$DEMYX_APP_DOMAIN" --auth-wp -f
            [[ "$DEMYX_APP_HEALTHCHECK" = true ]] && demyx config "$DEMYX_APP_DOMAIN" --healthcheck -f
        fi
    fi
}
