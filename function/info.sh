# Demyx
# https://demyx.sh
# 
# demyx info <app> <args>
#
demyx_info() {
    while :; do
        case "$3" in
            --all)
                DEMYX_INFO_ALL=1
                ;;
            --filter=?*)
                DEMYX_INFO_FILTER=${3#*=}
                ;;
            --filter=)
                demyx_die '"--filter" cannot be empty'
                ;;
            --json)
                DEMYX_INFO_JSON=1
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

    if [[ "$DEMYX_TARGET" = all ]]; then
        [[ -z "$DEMYX_INFO_FILTER" ]] && demyx_die '--filter is required'
        cd "$DEMYX_WP"
        PRINT_TABLE="DEMYX^ $DEMYX_INFO_FILTER\n"
        for i in *
        do
            DEMYX_INFO_ALL_FILTER=$(grep "$DEMYX_INFO_FILTER" "$DEMYX_WP"/"$i"/.env | awk -F '[=]' '{print $2}')
            [[ -z "$DEMYX_INFO_ALL_FILTER" ]] && demyx_die "$DEMYX_INFO_FILTER is not a valid filter"
            PRINT_TABLE+="$i^ $DEMYX_INFO_ALL_FILTER\n"
        done
        demyx_execute -v -q demyx_table "$PRINT_TABLE"
    elif [[ "$DEMYX_TARGET" = dash ]]; then
        source "$DEMYX"/.env
        DEMYX_INFO_CONTAINER_RUNNING=$(/usr/local/bin/docker ps -q | wc -l)
        DEMYX_INFO_CONTAINER_DEAD=$(/usr/local/bin/docker ps -q --filter "status=exited" | wc -l)
        DEMYX_INFO_WP_COUNT=$(find "$DEMYX_WP" -mindepth 1 -maxdepth 1 -type d | wc -l)
        echo '{
            "hostname": "'$(hostname)'",
            "mode": "'$DEMYX_MOTD_MODE'",
            "wp_count": "'$DEMYX_INFO_WP_COUNT'",
            "disk_used": "'$(df -h /demyx | sed '1d' | awk '{print $3}')'",
            "disk_total": "'$(df -h /demyx | sed '1d' | awk '{print $2}')'",
            "memory_used": "'$(free -m | sed '1d' | sed '2d' | awk '{print $3}')'",
            "memory_total": "'$(free -m | sed '1d' | sed '2d' | awk '{print $2}')'",
            "uptime": "'$(uptime | awk -F '[,]' '{print $1}' | awk -F '[up]' '{print $3}')'",
            "load_average": "'$(cat /proc/loadavg | awk '{print $1 " " $2 " " $3}')'",
            "container_running": "'$DEMYX_INFO_CONTAINER_RUNNING'",
            "container_dead": "'$DEMYX_INFO_CONTAINER_DEAD'"' | sed 's/            /    /g'
        echo '}'
    elif [[ "$DEMYX_APP_TYPE" = wp ]]; then
        if [[ -n "$DEMYX_INFO_ALL" ]]; then
            DEMYX_INFO_ALL=$(cat $DEMYX_APP_PATH/.env | sed '1d')
            PRINT_TABLE="DEMYX^ INFO\n"
            for i in $DEMYX_INFO_ALL
            do
                PRINT_TABLE+="$(echo "$i" | awk -F '[=]' '{print $1}')^ $(echo "$i" | awk -F '[=]' '{print $2}')\n"
            done
            demyx_execute -v -q demyx_table "$PRINT_TABLE"
        elif [[ -n "$DEMYX_INFO_FILTER" ]]; then
            DEMYX_INFO_FILTER=$(cat "$DEMYX_APP_PATH"/.env | grep -w "$DEMYX_INFO_FILTER")
            if [[ -n "$DEMYX_INFO_FILTER" ]]; then
                demyx_execute -v -q echo "$DEMYX_INFO_FILTER" | awk -F '[=]' '{print $2}'
            else
                demyx_die 'Filter not found'
            fi
        else
            DEMYX_INFO_DATA_VOLUME=$(demyx exec "$DEMYX_APP_DOMAIN" sh -c "du -sh /var/www/html" | cut -f1)
            DEMYX_INFO_DB_VOLUME=$(demyx exec "$DEMYX_APP_DOMAIN" db sh -c "du -sh /var/lib/mysql/$WORDPRESS_DB_NAME" | cut -f1)

            if [[ -n "$DEMYX_INFO_JSON" ]]; then
                echo '{
                    "path": "'$DEMYX_APP_PATH'",
                    "wp_user": "'$WORDPRESS_USER'",
                    "wp_password": "'$WORDPRESS_USER_PASSWORD'",
                    "wp_container": "'$DEMYX_APP_WP_CONTAINER'",
                    "db_container": "'$DEMYX_APP_DB_CONTAINER'",
                    "wp_volume": "'$DEMYX_INFO_DATA_VOLUME'",
                    "db_volume": "'$DEMYX_INFO_DB_VOLUME'",
                    "ssl": "'$DEMYX_APP_SSL'",
                    "cache": "'$DEMYX_APP_CACHE'",
                    "cdn": "'$DEMYX_APP_CDN'",
                    "auth": "'$DEMYX_APP_AUTH'",
                    "auth_wp": "'$DEMYX_APP_AUTH_WP'",
                    "dev": "'$DEMYX_APP_DEV'",
                    "healthcheck": "'$DEMYX_APP_HEALTHCHECK'"' | sed 's/                    /    /g'
                echo '}'
            else
                [[ -z "$DEMYX_APP_AUTH_WP" ]] && DEMYX_APP_AUTH_WP=off
                PRINT_TABLE="DEMYX^ INFO\n"
                PRINT_TABLE+="PATH^ $DEMYX_APP_PATH\n"
                PRINT_TABLE+="WP USER^ $WORDPRESS_USER\n"
                PRINT_TABLE+="WP PASSWORD^ $WORDPRESS_USER_PASSWORD\n"
                PRINT_TABLE+="WP CONTAINER^ $DEMYX_APP_WP_CONTAINER\n"
                PRINT_TABLE+="DB CONTAINER^ $DEMYX_APP_DB_CONTAINER\n"
                PRINT_TABLE+="WP VOLUME^ $DEMYX_INFO_DATA_VOLUME\n"
                PRINT_TABLE+="DB VOLUME^ $DEMYX_INFO_DB_VOLUME\n"
                PRINT_TABLE+="UPLOAD LIMIT^ $DEMYX_APP_UPLOAD_LIMIT\n"
                PRINT_TABLE+="PHP MEMORY^ $DEMYX_APP_PHP_MEMORY\n"
                PRINT_TABLE+="PHP MAX EXECUTION TIME^ $DEMYX_APP_PHP_MAX_EXECUTION_TIME\n"
                PRINT_TABLE+="PHP OPCACHE^ $DEMYX_APP_PHP_OPCACHE\n"
                PRINT_TABLE+="SSL^ $DEMYX_APP_SSL\n"
                PRINT_TABLE+="CACHE^ $DEMYX_APP_CACHE\n"
                PRINT_TABLE+="CDN^ $DEMYX_APP_CDN\n"
                PRINT_TABLE+="AUTH^ $DEMYX_APP_AUTH\n"
                PRINT_TABLE+="WP AUTH^ $DEMYX_APP_AUTH_WP\n"
                PRINT_TABLE+="DEV^ $DEMYX_APP_DEV\n"
                PRINT_TABLE+="HEALTHCHECK^ $DEMYX_APP_HEALTHCHECK\n"
                PRINT_TABLE+="WP AUTO UPDATE^ $DEMYX_APP_WP_UPDATE\n"
                demyx_execute -v demyx_table "$PRINT_TABLE"
            fi
        fi
    else
        [[ -z "$DEMYX_INFO_QUIET" ]] && demyx_die --not-found
    fi
}
