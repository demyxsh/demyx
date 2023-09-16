# Demyx
# https://demyx.sh
#
#   demyx restore <app> <args>
#
demyx_restore() {
    DEMYX_ARG_2="${1:-$DEMYX_ARG_2}"
    local DEMYX_RESTORE_CHECK=
    local DEMYX_RESTORE_FLAG=
    local DEMYX_RESTORE_FLAG_CONFIG=
    local DEMYX_RESTORE_FLAG_DATE=
    local DEMYX_RESTORE_FLAG_DB=
    local DEMYX_RESTORE_FLAG_FORCE=

    demyx_source "
        backup
        config
        compose
        info
        rm
        wp
    "

    while :; do
        DEMYX_RESTORE_FLAG="${2:-}"
        case "$DEMYX_RESTORE_FLAG" in
            -c)
                DEMYX_RESTORE_FLAG_CONFIG=true
            ;;
            --date=?*)
                DEMYX_RESTORE_FLAG_DATE="${DEMYX_RESTORE_FLAG#*=}"
            ;;
            -d)
                DEMYX_RESTORE_FLAG_DB=true
            ;;
            -f)
                DEMYX_RESTORE_FLAG_FORCE=true
            ;;
            --)
                shift
                break
                ;;
            -?*)
                demyx_error flag "$DEMYX_RESTORE_FLAG"
            ;;
            *)
                break
        esac
        shift
    done

    DEMYX_RESTORE_CHECK="$(find "$DEMYX_BACKUP" -type f -name "*${DEMYX_ARG_2}*.tgz" )"

    if [[ -n "$DEMYX_ARG_2" ]]; then
        if [[ "$DEMYX_RESTORE_FLAG_DB" = true ]]; then
            demyx_restore_db
        elif [[ -n "$DEMYX_RESTORE_CHECK" ]]; then
            if [[ "$DEMYX_RESTORE_FLAG_CONFIG" = true ]]; then
                demyx_restore_config
            else
                demyx_restore_app
            fi
        else
            demyx_error custom "No backups found for $DEMYX_ARG_2"
        fi
    else
        demyx_help restore
    fi
}

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
