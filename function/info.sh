# Demyx
# https://demyx.sh
# 
# demyx info <app> <args>
#
function demyx_info() {
    while :; do
        case "$3" in
            --all)
                DEMYX_INFO=all
                ;;
            --filter=?*)
                DEMYX_INFO_FILTER=${3#*=}
                ;;
            --filter=)
                demyx_die '"--filter" cannot be empty'
                ;;
            --quiet)
                DEMYX_INFO_QUIET=1
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
    
    demyx_app_config

    if [[ "$DEMYX_APP_TYPE" = wp ]]; then
        if [[ -n "$DEMYX_INFO_ALL" ]]; then
            DEMYX_INFO_ALL=$(cat $DEMYX_APP_PATH/.env | sed '1d')
            PRINT_TABLE="DEMYX, INFO\n"
            for i in $DEMYX_INFO_ALL
            do
                PRINT_TABLE+="$(echo "$i" | awk -F '[=]' '{print $1}'), $(echo "$i" | awk -F '[=]' '{print $2}')\n"
            done
            demyx_execute -v -q demyx_table "$PRINT_TABLE"
        elif [[ -n "$DEMYX_INFO_FILTER" ]]; then
            DEMYX_INFO_FILTER=$(cat "$DEMYX_APP_PATH"/.env | grep -s "$DEMYX_INFO_FILTER")
            if [[ -n "$DEMYX_INFO_FILTER" ]]; then
                demyx_execute -v -q echo "$DEMYX_INFO_FILTER" | awk -F '[=]' '{print $2}'
            else
                demyx_die 'Filter not found'
            fi
        else
            DEMYX_INFO_DATA_VOLUME=$(demyx exec "$DEMYX_APP_DOMAIN" bash -c "du -sh /var/www/html" | cut -f1)
            DEMYX_INFO_DB_VOLUME=$(demyx exec "$DEMYX_APP_DOMAIN" db sh -c "du -sh /var/lib/mysql/$WORDPRESS_DB_NAME" | cut -f1)

            PRINT_TABLE="DEMYX, INFO\n"
            PRINT_TABLE+="PATH, $DEMYX_APP_PATH\n"
            PRINT_TABLE+="WP USER, $WORDPRESS_USER\n"
            PRINT_TABLE+="WP PASSWORD, $WORDPRESS_USER_PASSWORD\n"
            PRINT_TABLE+="WP CONTAINER, $DEMYX_APP_WP_CONTAINER\n"
            PRINT_TABLE+="DB CONTAINER, $DEMYX_APP_DB_CONTAINER\n"
            PRINT_TABLE+="DATA VOLUME, $DEMYX_INFO_DATA_VOLUME\n"
            PRINT_TABLE+="DB VOLUME, $DEMYX_INFO_DB_VOLUME\n"
            PRINT_TABLE+="SSL, $DEMYX_APP_SSL\n"
            PRINT_TABLE+="CACHE, $DEMYX_APP_CACHE\n"
            PRINT_TABLE+="CDN, $DEMYX_APP_CDN\n"
            PRINT_TABLE+="AUTH, $DEMYX_APP_AUTH\n"
            PRINT_TABLE+="DEV, $DEMYX_APP_DEV\n"
            demyx_execute -v demyx_table "$(echo -e $PRINT_TABLE)"
        fi
    else
        [[ -z "$DEMYX_INFO_QUIET" ]] && demyx_die --not-found
    fi
}
