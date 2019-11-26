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
            --backup)
                DEMYX_INFO_BACKUP=1
                ;;
            --filter=?*)
                DEMYX_INFO_FILTER="${3#*=}"
                ;;
            --filter=)
                demyx_die '"--filter" cannot be empty'
                ;;
            --json)
                DEMYX_INFO_JSON=1
                ;;
            --no-password)
                DEMYX_INFO_NO_PASSWORD=1
                ;;
            --no-volume)
                DEMYX_INFO_NO_VOLUME=1
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
        if [[ -n "$DEMYX_INFO_BACKUP" ]]; then
            DEMYX_INFO_BACKUP_COUNT="$(ls -A "$DEMYX_BACKUP_WP" | wc -l)"
            DEMYX_INFO_BACKUP_TOTAL_SIZE="$(du -sh "$DEMYX_BACKUP_WP" | cut -f1)"
            PRINT_TABLE="DEMYX^ BACKUPS - $DEMYX_INFO_BACKUP_TOTAL_SIZE\n"

            if [[ "$DEMYX_INFO_BACKUP_COUNT" != 0 ]]; then
                cd "$DEMYX_BACKUP_WP"
                for i in *
                do
                    DEMYX_INFO_BACKUP_SIZE="$(du -sh "$DEMYX_BACKUP_WP"/"$i" | cut -f1)"
                    PRINT_TABLE+="$DEMYX_INFO_BACKUP_SIZE^ $i ("$(ls -A "$DEMYX_BACKUP_WP"/"$i" | wc -l)")\n"
                done
            fi
                        
            demyx_execute -v demyx_table "$PRINT_TABLE"
        else
            cd "$DEMYX_WP"
            for i in *
            do
                demyx_app_is_up

                source "$DEMYX_WP"/"$i"/.env

                if [[ -z "$DEMYX_INFO_NO_VOLUME" ]]; then
                    DEMYX_INFO_DATA_VOLUME="$(docker exec -t "$DEMYX_APP_WP_CONTAINER" du -sh /var/www/html | cut -f1)"
                    DEMYX_INFO_DB_VOLUME="$(docker exec -t "$DEMYX_APP_DB_CONTAINER" du -sh /var/lib/mysql/"$WORDPRESS_DB_NAME" | cut -f1)"
                fi

                if [[ -n "$DEMYX_INFO_NO_PASSWORD" ]]; then
                    WORDPRESS_USER_PASSWORD=
                fi

                DEMYX_INFO_ALL_JSON+='{'
                DEMYX_INFO_ALL_JSON+='"domain": "'$DEMYX_APP_DOMAIN'",'
                DEMYX_INFO_ALL_JSON+='"path": "'$DEMYX_APP_PATH'",'
                DEMYX_INFO_ALL_JSON+='"wp_user": "'$WORDPRESS_USER'",'
                DEMYX_INFO_ALL_JSON+='"wp_password": "'$WORDPRESS_USER_PASSWORD'",'
                DEMYX_INFO_ALL_JSON+='"nx_container": "'$DEMYX_APP_NX_CONTAINER'",'
                DEMYX_INFO_ALL_JSON+='"wp_container": "'$DEMYX_APP_WP_CONTAINER'",'
                DEMYX_INFO_ALL_JSON+='"db_container": "'$DEMYX_APP_DB_CONTAINER'",'
                DEMYX_INFO_ALL_JSON+='"wp_volume": "'$DEMYX_INFO_DATA_VOLUME'",'
                DEMYX_INFO_ALL_JSON+='"db_volume": "'$DEMYX_INFO_DB_VOLUME'",'
                DEMYX_INFO_ALL_JSON+='"wp_cpu": "'$DEMYX_APP_WP_CPU'",'
                DEMYX_INFO_ALL_JSON+='"wp_mem": "'$DEMYX_APP_WP_MEM'",'
                DEMYX_INFO_ALL_JSON+='"db_cpu": "'$DEMYX_APP_DB_CPU'",'
                DEMYX_INFO_ALL_JSON+='"db_mem": "'$DEMYX_APP_DB_MEM'",'
                DEMYX_INFO_ALL_JSON+='"ssl": "'$DEMYX_APP_SSL'",'
                DEMYX_INFO_ALL_JSON+='"cache": "'$DEMYX_APP_CACHE'",'
                DEMYX_INFO_ALL_JSON+='"cdn": "'$DEMYX_APP_CDN'",'
                DEMYX_INFO_ALL_JSON+='"auth": "'$DEMYX_APP_AUTH'",'
                DEMYX_INFO_ALL_JSON+='"auth_wp": "'$DEMYX_APP_AUTH_WP'",'
                DEMYX_INFO_ALL_JSON+='"dev": "'$DEMYX_APP_DEV'",'
                DEMYX_INFO_ALL_JSON+='"healthcheck": "'$DEMYX_APP_HEALTHCHECK'"'
                DEMYX_INFO_ALL_JSON+='},'
            done
            echo "[$DEMYX_INFO_ALL_JSON]" | sed 's|,]|]|g'
        fi
    elif [[ "$DEMYX_TARGET" = env ]]; then
        [[ -z "$DEMYX_INFO_FILTER" ]] && demyx_die '--filter is required'
        cd "$DEMYX_WP"
        PRINT_TABLE="DEMYX^ $DEMYX_INFO_FILTER\n"
        for i in *
        do
            DEMYX_INFO_ALL_FILTER="$(grep "$DEMYX_INFO_FILTER" "$DEMYX_WP"/"$i"/.env | awk -F '[=]' '{print $2}')"
            [[ -z "$DEMYX_INFO_ALL_FILTER" ]] && demyx_die "$DEMYX_INFO_FILTER is not a valid filter"
            PRINT_TABLE+="$i^ $DEMYX_INFO_ALL_FILTER\n"
        done
        demyx_execute -v -q demyx_table "$PRINT_TABLE"
    elif [[ "$DEMYX_TARGET" = stack ]]; then
        if [[ -n "$DEMYX_INFO_FILTER" ]]; then
            DEMYX_INFO_FILTER="$(cat "$DEMYX_STACK"/.env | grep -w "$DEMYX_INFO_FILTER")"
            if [[ -n "$DEMYX_INFO_FILTER" ]]; then
                demyx_execute -v -q echo "$DEMYX_INFO_FILTER" | awk -F '[=]' '{print $2}'
            else
                [[ -z "$DEMYX_INFO_QUIET" ]] && demyx_die 'Filter not found'
            fi
        else
            source "$DEMYX_STACK"/.env
            DEMYX_INFO_STACK_GET_NGINX="$(wget -qO- https://raw.githubusercontent.com/demyxco/nginx/master/README.md)"
            DEMYX_INFO_STACK_GET_WORDPRESS="$(wget -qO- https://raw.githubusercontent.com/demyxco/wordpress/master/README.md)"
            DEMYX_INFO_TRAEFIK_VERSION="$(docker run -it --rm --entrypoint=traefik traefik version | head -1 | awk -F '[:]' '{print $2}' | sed 's| ||g' | sed 's/\r//g')"
            PRINT_TABLE="DEMYX^ STACK\n"
            PRINT_TABLE+="IP^ $DEMYX_STACK_SERVER_IP\n"
            PRINT_TABLE+="DOMAIN^ $DEMYX_STACK_DOMAIN\n"
            PRINT_TABLE+="API^ $DEMYX_STACK_SERVER_API\n"
            PRINT_TABLE+="TRAEFIK^ $DEMYX_INFO_TRAEFIK_VERSION\n"
            PRINT_TABLE+="ALPINE^ $(cat /etc/os-release | grep VERSION_ID | awk -F '[=]' '{print $2}')\n"
            PRINT_TABLE+="NGINX^ $(grep "badge/nginx" <<< "$DEMYX_INFO_STACK_GET_NGINX" | awk -F '[-]' '{print $2}')\n"
            PRINT_TABLE+="PHP^ $(grep "badge/php" <<< "$DEMYX_INFO_STACK_GET_WORDPRESS" | awk -F '[-]' '{print $2}')\n"
            PRINT_TABLE+="WORDPRESS^ $(grep "badge/wordpress" <<< "$DEMYX_INFO_STACK_GET_WORDPRESS" | awk -F '[-]' '{print $2}')\n"
            PRINT_TABLE+="AUTO UPDATE^ $DEMYX_STACK_AUTO_UPDATE\n"
            PRINT_TABLE+="MONITOR^ $DEMYX_STACK_MONITOR\n"
            PRINT_TABLE+="HEALTHCHECK^ $DEMYX_STACK_HEALTHCHECK\n"
            PRINT_TABLE+="BACKUP^ $DEMYX_STACK_BACKUP\n"
            PRINT_TABLE+="BACKUP LIMIT^ $DEMYX_STACK_BACKUP_LIMIT\n"
            PRINT_TABLE+="BACKUP PATH^ $DEMYX_BACKUP_WP\n"
            PRINT_TABLE+="LOG PATH^ /var/log/demyx\n"
            demyx_execute -v demyx_table "$PRINT_TABLE"
        fi
    elif [[ "$DEMYX_TARGET" = system ]]; then
        DEMYX_INFO_WP_COUNT="$(find "$DEMYX_WP" -mindepth 1 -maxdepth 1 -type d | wc -l)"
        DEMYX_INFO_DISK_USED="$(df -h /demyx | sed '1d' | awk '{print $3}')"
        DEMYX_INFO_DISK_TOTAL="$(df -h /demyx | sed '1d' | awk '{print $2}')"
        DEMYX_INFO_DISK_PERCENTAGE="$(df -h /demyx | sed '1d' | awk '{print $5}')"
        DEMYX_INFO_MEMORY_USED="$(free -m | sed '1d' | sed '2d' | awk '{print $3}')"
        DEMYX_INFO_MEMORY_TOTAL="$(free -m | sed '1d' | sed '2d' | awk '{print $2}')"
        DEMYX_INFO_UPTIME="$(uptime | awk -F '[,]' '{print $1}' | awk -F '[up]' '{print $3}' | sed 's|^.||')"
        DEMYX_INFO_LOAD_AVERAGE="$(cat /proc/loadavg | awk '{print $1 " " $2 " " $3}')"

        if [[ "$(demyx_check_docker_sock)" = true ]]; then
            DEMYX_INFO_CONTAINER_RUNNING="$(/usr/local/bin/docker ps -q | wc -l)"
            DEMYX_INFO_CONTAINER_DEAD="$(/usr/local/bin/docker ps -q --filter "status=exited" | wc -l)"
        fi

        if [[ -n "$DEMYX_INFO_JSON" ]]; then 
            DEMYX_INFO_SYSTEM_JSON='{'
            DEMYX_INFO_SYSTEM_JSON+='"hostname": "'$DEMYX_ENV_HOST'",'
            DEMYX_INFO_SYSTEM_JSON+='"mode": "'$DEMYX_ENV_MODE'",'
            DEMYX_INFO_SYSTEM_JSON+='"wp_count": "'$DEMYX_INFO_WP_COUNT'",'
            DEMYX_INFO_SYSTEM_JSON+='"disk_used": "'$DEMYX_INFO_DISK_USED'",'
            DEMYX_INFO_SYSTEM_JSON+='"disk_total": "'$DEMYX_INFO_DISK_TOTAL'",'
            DEMYX_INFO_SYSTEM_JSON+='"disk_total_percentage": "'$DEMYX_INFO_DISK_PERCENTAGE'",'
            DEMYX_INFO_SYSTEM_JSON+='"memory_used": "'$DEMYX_INFO_MEMORY_USED'",'
            DEMYX_INFO_SYSTEM_JSON+='"memory_total": "'$DEMYX_INFO_MEMORY_TOTAL'",'
            DEMYX_INFO_SYSTEM_JSON+='"uptime": "'$DEMYX_INFO_UPTIME'",'
            DEMYX_INFO_SYSTEM_JSON+='"load_average": "'$DEMYX_INFO_LOAD_AVERAGE'",'
            DEMYX_INFO_SYSTEM_JSON+='"container_running": "'$DEMYX_INFO_CONTAINER_RUNNING'",'
            DEMYX_INFO_SYSTEM_JSON+='"container_dead": "'$DEMYX_INFO_CONTAINER_DEAD'"'
            DEMYX_INFO_SYSTEM_JSON+='}'
            echo "$DEMYX_INFO_SYSTEM_JSON"
        else
            PRINT_TABLE="DEMYX^ SYSTEM INFO\n"
            PRINT_TABLE+="HOSTNAME^ $DEMYX_ENV_HOST\n"
            PRINT_TABLE+="MODE^ $DEMYX_ENV_MODE\n"
            PRINT_TABLE+="WORDPRESS APPS^ $DEMYX_INFO_WP_COUNT\n"
            PRINT_TABLE+="DISK USED^ $DEMYX_INFO_DISK_USED\n"
            PRINT_TABLE+="DISK TOTAL^ $DEMYX_INFO_DISK_TOTAL\n"
            PRINT_TABLE+="DISK TOTAL PERCENTAGE^ $DEMYX_INFO_DISK_PERCENTAGE\n"
            PRINT_TABLE+="MEMORY USED^ $DEMYX_INFO_MEMORY_USED\n"
            PRINT_TABLE+="MEMORY TOTAL^ $DEMYX_INFO_MEMORY_TOTAL\n"
            PRINT_TABLE+="UPTIME^ $DEMYX_INFO_UPTIME\n"
            PRINT_TABLE+="LOAD AVERAGE^ $DEMYX_INFO_LOAD_AVERAGE\n"
            PRINT_TABLE+="RUNNING CONTAINERS^ $DEMYX_INFO_CONTAINER_RUNNING\n"
            PRINT_TABLE+="DEAD CONTAINERS^ $DEMYX_INFO_CONTAINER_DEAD"
            
            demyx_execute -v demyx_table "$PRINT_TABLE"
        fi
    elif [[ "$DEMYX_APP_TYPE" = wp ]]; then
        if [[ -n "$DEMYX_INFO_ALL" ]]; then
            DEMYX_INFO_ALL="$(cat "$DEMYX_APP_PATH"/.env | sed '1d')"
            PRINT_TABLE="DEMYX^ INFO\n"
            for i in $DEMYX_INFO_ALL
            do
                PRINT_TABLE+="$(echo "$i" | awk -F '[=]' '{print $1}')^ $(echo "$i" | awk -F '[=]' '{print $2}')\n"
            done
            demyx_execute -v -q demyx_table "$PRINT_TABLE"
        elif [[ -n "$DEMYX_INFO_BACKUP" ]]; then
            DEMYX_INFO_BACKUP_COUNT="$(ls -A "$DEMYX_BACKUP_WP"/"$DEMYX_APP_DOMAIN" | wc -l)"
            DEMYX_INFO_BACKUP_TOTAL_SIZE="$(du -sh "$DEMYX_BACKUP_WP"/"$DEMYX_APP_DOMAIN" | cut -f1)"
            PRINT_TABLE="DEMYX^ BACKUPS - $DEMYX_INFO_BACKUP_TOTAL_SIZE\n"

            if [[ "$DEMYX_INFO_BACKUP_COUNT" != 0 ]]; then
                cd "$DEMYX_BACKUP_WP"/"$DEMYX_APP_DOMAIN"
                for i in *
                do
                    DEMYX_INFO_BACKUP_SIZE="$(du -sh "$DEMYX_BACKUP_WP"/"$DEMYX_APP_DOMAIN"/"$i" | cut -f1)"
                    PRINT_TABLE+="$DEMYX_INFO_BACKUP_SIZE^ $i\n"
                done
            fi
                        
            demyx_execute -v demyx_table "$PRINT_TABLE"
        elif [[ -n "$DEMYX_INFO_FILTER" ]]; then
            DEMYX_INFO_FILTER="$(cat "$DEMYX_APP_PATH"/.env | grep -w "$DEMYX_INFO_FILTER")"
            if [[ -n "$DEMYX_INFO_FILTER" ]]; then
                demyx_execute -v -q echo "$DEMYX_INFO_FILTER" | awk -F '[=]' '{print $2}'
            else
                demyx_die 'Filter not found'
            fi
        else
            demyx_app_is_up
            
            if [[ -z "$DEMYX_INFO_NO_VOLUME" ]]; then
                DEMYX_INFO_DATA_VOLUME="$(docker exec -t "$DEMYX_APP_WP_CONTAINER" du -sh /var/www/html | cut -f1)"
                DEMYX_INFO_DB_VOLUME="$(docker exec -t "$DEMYX_APP_DB_CONTAINER" du -sh /var/lib/mysql/"$WORDPRESS_DB_NAME" | cut -f1)"
            fi

            if [[ -n "$DEMYX_INFO_JSON" ]]; then
                echo '{
                    "path": "'$DEMYX_APP_PATH'",
                    "wp_user": "'$WORDPRESS_USER'",
                    "wp_password": "'$WORDPRESS_USER_PASSWORD'",
                    "nx_container": "'$DEMYX_APP_NX_CONTAINER'",
                    "wp_container": "'$DEMYX_APP_WP_CONTAINER'",
                    "db_container": "'$DEMYX_APP_DB_CONTAINER'",
                    "wp_volume": "'$DEMYX_INFO_DATA_VOLUME'",
                    "db_volume": "'$DEMYX_INFO_DB_VOLUME'",
                    "wp_cpu": "'$DEMYX_APP_WP_CPU'",
                    "wp_mem": "'$DEMYX_APP_WP_MEM'",
                    "db_cpu": "'$DEMYX_APP_DB_CPU'",
                    "db_mem": "'$DEMYX_APP_DB_MEM'",
                    "ssl": "'$DEMYX_APP_SSL'",
                    "cache": "'$DEMYX_APP_CACHE'",
                    "cdn": "'$DEMYX_APP_CDN'",
                    "auth": "'$DEMYX_APP_AUTH'",
                    "auth_wp": "'$DEMYX_APP_AUTH_WP'",
                    "dev": "'$DEMYX_APP_DEV'",
                    "healthcheck": "'$DEMYX_APP_HEALTHCHECK'"' | sed 's/                    /    /g'
                echo '}'
            else
                [[ -z "$DEMYX_APP_AUTH_WP" ]] && DEMYX_APP_AUTH_WP=false
                PRINT_TABLE="DEMYX^ INFO\n"
                PRINT_TABLE+="DOMAIN^ $DEMYX_APP_DOMAIN\n"
                PRINT_TABLE+="PATH^ $DEMYX_APP_PATH\n"
                PRINT_TABLE+="WP USER^ $WORDPRESS_USER\n"
                PRINT_TABLE+="WP PASSWORD^ $WORDPRESS_USER_PASSWORD\n"
                PRINT_TABLE+="DB ROOT PASSWORD^ $MARIADB_ROOT_PASSWORD\n"
                PRINT_TABLE+="NX CONTAINER^ $DEMYX_APP_NX_CONTAINER\n"
                PRINT_TABLE+="WP CONTAINER^ $DEMYX_APP_WP_CONTAINER\n"
                PRINT_TABLE+="DB CONTAINER^ $DEMYX_APP_DB_CONTAINER\n"
                PRINT_TABLE+="WP VOLUME^ $DEMYX_INFO_DATA_VOLUME\n"
                PRINT_TABLE+="DB VOLUME^ $DEMYX_INFO_DB_VOLUME\n"
                PRINT_TABLE+="WP CPU^ $DEMYX_APP_WP_CPU\n"
                PRINT_TABLE+="WP MEM^ $DEMYX_APP_WP_MEM\n"
                PRINT_TABLE+="DB CPU^ $DEMYX_APP_DB_CPU\n"
                PRINT_TABLE+="DB MEM^ $DEMYX_APP_DB_MEM\n"
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
