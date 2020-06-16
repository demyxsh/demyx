# Demyx
# https://demyx.sh
# 
# demyx refresh <app>
#
demyx_refresh() {
    while :; do
        case "$3" in
            -f|--force)
                DEMYX_REFRESH_FORCE=true
                ;;
            --skip-backup)
                DEMYX_REFRESH_SKIP_BACKUP=true
                ;;
            --skip-checks)
                DEMYX_REFRESH_SKIP_CHECKS=true
                ;;
            --)
                shift
                break
                ;;
            -?*)
                printf '\e[31m[CRITICAL]\e[39m Unknown option: %s\n' "$3" >&2
                exit 1
                ;;
            *)
                break
        esac
        shift
    done

    if [[ "$DEMYX_TARGET" = all ]]; then
        cd "$DEMYX_WP" || exit
        for i in *
        do
            demyx refresh "$i" "$@"
        done
    elif [[ "$DEMYX_TARGET" = code ]]; then
        demyx_source env
        demyx_source yml

        [[ ! -d "$DEMYX_CODE" ]] && mkdir -p "$DEMYX_CODE"

        demyx_echo 'Refreshing code-server'
        demyx_execute demyx_code_yml

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
