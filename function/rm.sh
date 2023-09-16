# Demyx
# https://demyx.sh
#
#   demyx rm <app> <args>
#
demyx_rm() {
    DEMYX_ARG_2="${1:-$DEMYX_ARG_2}"
    local DEMYX_RM_FLAG=
    local DEMYX_RM_FLAG_FORCE=

    demyx_source "
        config
        compose
    "

    while :; do
        DEMYX_RM_FLAG="${2:-}"
        case "$DEMYX_RM_FLAG" in
            -f)
                DEMYX_RM_FLAG_FORCE=true
                ;;
            --)
                shift
                break
                ;;
            -?*)
                demyx_error flag "$DEMYX_RM_FLAG"
                ;;
            *)
                break
        esac
        shift
    done

    case "$DEMYX_ARG_2" in
        all)
            demyx_rm_all
        ;;
        *)
            if [[ -n "$DEMYX_ARG_2" ]]; then
                demyx_rm_app
            else
                demyx_help rm
            fi
        ;;
    esac
}
#
#   Loop for demyx_rm_app.
#
demyx_rm_all() {
    local DEMYX_RM_ALL=
    local DEMYX_RM_ALL_APP_CONFIRM=
    local DEMYX_RM_ALL_HTML=
    local DEMYX_RM_ALL_PHP=
    local DEMYX_RM_ALL_WP=

    if [[ -z "$DEMYX_RM_FLAG_FORCE" ]]; then
        echo -en "\e[33m"
        read -rep "[WARNING] Delete all demyx apps? [yY]: " DEMYX_RM_ALL_APP_CONFIRM
        echo -en "\e[39m"
        [[ "$DEMYX_RM_ALL_APP_CONFIRM" != [yY] ]] && demyx_error cancel
    fi

    DEMYX_RM_ALL_HTML="$(ls -A "$DEMYX_HTML")"
    if [[ -n "$DEMYX_RM_ALL_HTML" ]]; then
        cd "$DEMYX_HTML" || exit

        for DEMYX_RM_ALL in *; do
            if [[   -f "$DEMYX_HTML"/"$DEMYX_RM_ALL"/.env &&
                    -f "$DEMYX_HTML"/"$DEMYX_RM_ALL"/docker-compose.yml ]]; then
                demyx_echo "Removing $DEMYX_RM_ALL"
                eval demyx_rm "$DEMYX_RM_ALL" -f
            fi
        done
    else
        demyx_warning "No apps found in $DEMYX_HTML, skipping ..."
    fi

    DEMYX_RM_ALL_PHP="$(ls -A "$DEMYX_PHP")"
    if [[ -n "$DEMYX_RM_ALL_PHP" ]]; then
        cd "$DEMYX_PHP" || exit

        for DEMYX_RM_ALL in *; do
            if [[   -f "$DEMYX_PHP"/"$DEMYX_RM_ALL"/.env &&
                    -f "$DEMYX_PHP"/"$DEMYX_RM_ALL"/docker-compose.yml ]]; then
                demyx_echo "Removing $DEMYX_RM_ALL"
                eval demyx_rm "$DEMYX_RM_ALL" -f
            fi
        done
    else
        demyx_warning "No apps found in $DEMYX_PHP, skipping ..."
    fi

    DEMYX_RM_ALL_WP="$(ls -A "$DEMYX_WP")"
    if [[ -n "$DEMYX_RM_ALL_WP" ]]; then
        cd "$DEMYX_WP" || exit

        for DEMYX_RM_ALL in *; do
            if [[   -f "$DEMYX_WP"/"$DEMYX_RM_ALL"/.env &&
                    -f "$DEMYX_WP"/"$DEMYX_RM_ALL"/docker-compose.yml ]]; then
                demyx_echo "Removing $DEMYX_RM_ALL"
                eval demyx_rm "$DEMYX_RM_ALL" -f
            fi
        done
    else
        demyx_warning "No apps found in $DEMYX_WP, skipping ..."
    fi
}

        DEMYX_RM_VOLUMES="$(docker volume ls | grep "$DEMYX_APP_ID" | awk '{print $2}' | awk 'BEGIN { ORS = " " } { print }')"

        cd "$DEMYX_APP_PATH" || exit

        demyx config "$DEMYX_APP_DOMAIN" --healthcheck=false
        demyx compose "$DEMYX_APP_DOMAIN" down

        DEMYX_RM_STRAGGLERS="$(docker ps | grep "$DEMYX_APP_COMPOSE_PROJECT" | awk '{print $(NF)}' | awk '$1 ~ /^'"${DEMYX_APP_COMPOSE_PROJECT}"'/')"

        if [[ -n "$DEMYX_RM_STRAGGLERS" ]]; then
            for i in $DEMYX_RM_STRAGGLERS
            do
                demyx_echo "Killing $i"
                demyx_execute docker kill "$i"
            done
        fi

        for i in $DEMYX_RM_VOLUMES
        do
            demyx_echo "Deleting $i"
            demyx_execute docker volume rm "$i"
            
        done

        demyx_echo "Deleting $DEMYX_APP_DOMAIN"
        demyx_execute rm -rf "$DEMYX_APP_PATH"
    else
        demyx_die --not-found
    fi
}
