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

    if [[ "$DEMYX_TARGET" = all ]]; then
        if [[ -n "$DEMYX_RM_WP" ]]; then
            if [[ -z "$DEMYX_RM_FORCE" ]]; then
                echo -en "\e[33m"
                read -rep "[WARNING] Delete all WordPress sites? [yY]: " DEMYX_RM_CONFIRM
                echo -en "\e[39m"    
                [[ "$DEMYX_RM_CONFIRM" != [yY] ]] && demyx_die 'Cancelled deletion'
            fi
            cd "$DEMYX_WP" || exit
            for i in *
            do
                demyx rm "$i" -f
            done
        fi
    elif [[ "$DEMYX_APP_TYPE" = wp ]]; then
        if [[ -z "$DEMYX_RM_FORCE" ]]; then
            echo -en "\e[33m"
            read -rep "[WARNING] Delete $DEMYX_TARGET? [yY]: " DEMYX_RM_CONFIRM
            echo -en "\e[39m"    
            [[ "$DEMYX_RM_CONFIRM" != [yY] ]] && demyx_die 'Cancelled deletion'
        fi

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
