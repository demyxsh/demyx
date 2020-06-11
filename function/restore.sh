# Demyx
# https://demyx.sh
# 
# demyx restore <app> <args>
#
demyx_restore() {
    while :; do
        case "$3" in
            -f|--force)
                DEMYX_RESTORE_FORCE=1
                ;;
            --config)
                DEMYX_RESTORE_CONFIG=1
                ;;
            --date=?*)
                DEMYX_RESTORE_DATE="${3#*=}"
                ;;
            --date=)
                demyx_die '"--date" cannot be empty'
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

    DEMYX_RESTORE_TODAYS_DATE="$(date +%Y-%m-%d)"

    demyx_app_config
    
    if [[ -n "$DEMYX_RESTORE_DATE" ]]; then
        [[ ! -f "$DEMYX_BACKUP_WP"/"$DEMYX_TARGET"/"$DEMYX_RESTORE_DATE"-"$DEMYX_TARGET".tgz ]] && demyx_die 'No file found'
    else
        [[ ! -f "$DEMYX_BACKUP_WP"/"$DEMYX_TARGET"/"$DEMYX_RESTORE_TODAYS_DATE"-"$DEMYX_TARGET".tgz ]] && demyx_die 'No file found'
    fi

    if [[ "$DEMYX_APP_TYPE" = wp || -n "$DEMYX_RESTORE_FORCE" ]]; then
        if [[ -n "$DEMYX_RESTORE_CONFIG" ]]; then
            demyx_echo 'Restoring configs'
            demyx_execute rm -rf "$DEMYX_WP"/"$DEMYX_TARGET"; \
                tar -xzf "$DEMYX_BACKUP"/config/"$DEMYX_APP_DOMAIN".tgz -C "$DEMYX_WP"
        else
            if [[ -d "$DEMYX_APP_PATH" && -z "$DEMYX_RESTORE_FORCE" ]]; then
                echo -en "\e[33m"
                read -rep "[WARNING] $DEMYX_TARGET exits, delete? [yY]: " DEMYX_RM_CONFIRM
                echo -en "\e[39m"
                if [[ "$DEMYX_RM_CONFIRM" = [yY] ]]; then
                    demyx rm "$DEMYX_TARGET" -f
                else
                    demyx_die 'Cancelling restoration'
                fi
            fi

            if [[ -n "$DEMYX_RESTORE_DATE" ]]; then
                demyx_echo "Extracting archive from $DEMYX_RESTORE_DATE"
                demyx_execute tar -xzf "$DEMYX_BACKUP_WP"/"$DEMYX_TARGET"/"$DEMYX_RESTORE_DATE"-"$DEMYX_TARGET".tgz -C "$DEMYX_WP"
            else
                demyx_echo 'Extracting archive'
                demyx_execute tar -xzf "$DEMYX_BACKUP_WP"/"$DEMYX_TARGET"/"$DEMYX_RESTORE_TODAYS_DATE"-"$DEMYX_TARGET".tgz -C "$DEMYX_WP"
            fi

            demyx_app_config

            demyx config "$DEMYX_APP_DOMAIN" --healthcheck=false

            demyx_echo 'Creating WordPress volume'
            demyx_execute docker volume create wp_"$DEMYX_APP_ID"

            demyx_echo 'Creating MariaDB volume'
            demyx_execute docker volume create wp_"$DEMYX_APP_ID"_db

            demyx_echo 'Creating log volume'
            demyx_execute docker volume create wp_"$DEMYX_APP_ID"_log

            cd "$DEMYX_APP_PATH" || exit

            demyx compose "$DEMYX_APP_DOMAIN" db up -d --remove-orphans

            demyx_echo 'Initializing MariaDB'
            demyx_execute demyx_mariadb_ready

            demyx_echo 'Creating temporary container'
            demyx_execute docker run -dit --rm \
                --name "$DEMYX_APP_WP_CONTAINER" \
                --network=demyx \
                --entrypoint=sh \
                -v wp_"$DEMYX_APP_ID":/demyx \
                -v wp_"$DEMYX_APP_ID"_log:/var/log/demyx \
                demyx/wordpress

            demyx_echo 'Restoring files'
            demyx_execute docker cp demyx-wp/. "$DEMYX_APP_WP_CONTAINER":/demyx; \
                docker cp demyx-log/. "$DEMYX_APP_WP_CONTAINER":/var/log/demyx

            demyx_echo 'Restoring database'
            demyx_execute demyx wp "$DEMYX_APP_DOMAIN" db import "$DEMYX_APP_CONTAINER".sql
            
            demyx_echo 'Removing backup database'
            demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" rm -f /demyx/"$DEMYX_APP_CONTAINER".sql

            demyx_echo 'Stopping temporary container'
            demyx_execute docker stop "$DEMYX_APP_WP_CONTAINER"

            demyx compose "$DEMYX_APP_DOMAIN" up -d --remove-orphans
            demyx config "$DEMYX_APP_DOMAIN" --healthcheck

            demyx_echo 'Cleaning up'
            demyx_execute rm -rf "$DEMYX_APP_PATH"/demyx-wp; \
                rm -rf "$DEMYX_APP_PATH"/demyx-log

            demyx info "$DEMYX_APP_DOMAIN"
        fi
    else
        demyx_die --restore-not-found
    fi
}
