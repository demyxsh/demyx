# Demyx
# https://demyx.sh
# 
# demyx restore <app> <args>
#
function demyx_restore() {
    while :; do
        case "$3" in
            -f|--force)
                DEMYX_RESTORE_FORCE=1
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
        DEMYX_LOG_PARAM+="$3 "
        shift
    done

    demyx_app_config
    
    if [[ "$DEMYX_APP_TYPE" = wp ]] || [[ -n "$DEMYX_RESTORE_FORCE" ]]; then
        if [[ -d "$DEMYX_APP_PATH" ]] && [[ -z "$DEMYX_RESTORE_FORCE" ]]; then
            echo -en "\e[33m"
            read -rep "[WARNING] $DEMYX_TARGET exits, delete? [yY]: " DEMYX_RM_CONFIRM
            echo -en "\e[39m"
            if [[ "$DEMYX_RM_CONFIRM" = [yY] ]]; then
                demyx rm "$DEMYX_TARGET" -f
            else
                demyx_die 'Cancelling restoration'
            fi
        fi

        demyx_echo 'Extracting archive'
        demyx_execute tar -xzf "$DEMYX_BACKUP"/"$DEMYX_TARGET".tgz -C "$DEMYX_WP"

        demyx_app_config

        demyx_echo 'Creating WordPress volume'
        demyx_execute docker volume create wp_"$DEMYX_APP_ID"

        demyx_echo 'Creating MariaDB volume'
        demyx_execute docker volume create wp_"$DEMYX_APP_ID"_db
        
        demyx_echo 'Creating config volume'
        demyx_execute docker volume create wp_"$DEMYX_APP_ID"_config

        demyx_echo 'Creating log volume'
        demyx_execute docker volume create wp_"$DEMYX_APP_ID"_log

        cd "$DEMYX_APP_PATH" || exit

        demyx_execute -v demyx compose "$DEMYX_APP_DOMAIN" db up -d --remove-orphans

        demyx_echo 'Initializing MariaDB' 
        demyx_execute sleep 10

        demyx_echo 'Creating temporary container' 
        demyx_execute docker run -dt --rm \
            --name "$DEMYX_APP_ID" \
            --network demyx \
            --entrypoint "/usr/local/sbin/php-fpm" \
            -v wp_"$DEMYX_APP_ID":/var/www/html \
            -v wp_"$DEMYX_APP_ID"_config:/demyx \
            -v wp_"$DEMYX_APP_ID"_log:/var/log/demyx \
            demyx/nginx-php-wordpress

        demyx_echo 'Restoring files'
        demyx_execute docker cp config/. "$DEMYX_APP_ID":/demyx; \
            docker cp html "$DEMYX_APP_ID":/var/www; \
            docker cp demyx "$DEMYX_APP_ID":/var/log

        demyx_echo 'Restoring database'
        demyx_execute docker run -it --rm \
            --volumes-from "$DEMYX_APP_ID" \
            --network container:"$DEMYX_APP_ID" \
            wordpress:cli db import "$DEMYX_APP_CONTAINER".sql

        demyx_echo 'Removing backup database'
        demyx_execute docker exec -t "$DEMYX_APP_ID" rm /var/www/html/"$DEMYX_APP_CONTAINER".sql; \
        
        demyx_echo 'Stopping temporary container'
        demyx_execute docker stop "$DEMYX_APP_ID"

        demyx_echo 'Cleaning up'
        demyx_execute rm -rf "$DEMYX_APP_PATH"/html; \
            rm -rf "$DEMYX_APP_PATH"/demyx

        demyx_execute -v demyx compose "$DEMYX_APP_DOMAIN" wp up -d --remove-orphans
    else
        demyx_die --restore-not-found
    fi
}
