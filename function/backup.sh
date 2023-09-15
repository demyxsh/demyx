# Demyx
# https://demyx.sh
#
#   demyx backup <app> <args>
#
demyx_backup() {
    DEMYX_ARG_2="${1:-$DEMYX_ARG_2}"
    shift && local DEMYX_BACKUP_ARGS="$*"
    local DEMYX_BACKUP_FLAG=
    local DEMYX_BACKUP_FLAG_CONFIG=
    local DEMYX_BACKUP_FLAG_DB=
    local DEMYX_BACKUP_FLAG_LIST=
    local DEMYX_BACKUP_FLAG_PATH=

    demyx_source wp

    while :; do
        DEMYX_BACKUP_FLAG="${1:-}"
        case "$DEMYX_BACKUP_FLAG" in
            -c)
                DEMYX_BACKUP_FLAG_CONFIG=true
            ;;
            -d)
                DEMYX_BACKUP_FLAG_DB=true
            ;;
            -l)
                DEMYX_BACKUP_FLAG_LIST=true
            ;;
            --path=?*)
                DEMYX_BACKUP_FLAG_PATH="${DEMYX_BACKUP_FLAG#*=}"
            ;;
            --path=)
                demyx_error flag-empty "$DEMYX_BACKUP_FLAG"
            ;;
            --)
                shift
                break
            ;;
            -?*)
                demyx_error flag "$DEMYX_BACKUP_FLAG"
            ;;
            *)
                break
        esac
        shift
    done

    case "$DEMYX_ARG_2" in
        all)
            demyx_backup_all
        ;;
        *)
            demyx_arg_valid

            if [[ "$DEMYX_BACKUP_FLAG_CONFIG" = true ]]; then
                demyx_backup_config
            elif [[ "$DEMYX_BACKUP_FLAG_DB" = true ]]; then
                demyx_backup_db
            elif [[ "$DEMYX_BACKUP_FLAG_LIST" = true ]]; then
                demyx_backup_list
            else
                if [[ -n "$DEMYX_ARG_2" ]]; then
                    demyx_backup_app
                else
                    demyx_help backup
                fi
            fi
        ;;
    esac
}
#
#   Loop for demyx_backup_app.
#
demyx_backup_all() {
    local DEMYX_BACKUP_ALL=
    local DEMYX_BACKUP_ALL_CHECK=
    local DEMYX_BACKUP_ALL_CHECK_WP=

    cd "$DEMYX_WP" || exit

    for DEMYX_BACKUP_ALL in *; do
        DEMYX_ARG_2="$DEMYX_BACKUP_ALL"
        DEMYX_BACKUP_ALL_CHECK=0

        demyx_app_env wp DEMYX_APP_WP_CONTAINER
        demyx_echo "Backing up $DEMYX_BACKUP_ALL"

        DEMYX_BACKUP_ALL_CHECK_WP="$(docker exec "$DEMYX_APP_WP_CONTAINER" "wp core is-installed" 2>&1 || true)"
        if [[ "$DEMYX_BACKUP_ALL_CHECK_WP" == *"Error"* ||
                "$DEMYX_BACKUP_ALL_CHECK_WP" == *"error"* ]]; then
            DEMYX_BACKUP_ALL_CHECK=1
            demyx_logger "Backing up $DEMYX_BACKUP_ALL" "demyx_backup $DEMYX_BACKUP_ALL $DEMYX_BACKUP_ARGS" "$DEMYX_BACKUP_ALL_CHECK_WP" error
        fi

        if [[ "$DEMYX_BACKUP_ALL_CHECK" = 1 ]]; then
            demyx_warning "$DEMYX_ARG_2 has one or more errors. Please check error log, skipping ..."
            continue
        else
            eval demyx_backup "$DEMYX_BACKUP_ALL" "$DEMYX_BACKUP_ARGS"
        fi
    done
}

        demyx_app_config
        demyx_app_is_up

        if [[ "$DEMYX_APP_TYPE" = wp ]]; then
            if [[ -n "$DEMYX_BACKUP_CONFIG" ]]; then
                if [[ ! -d "$DEMYX_BACKUP"/config ]]; then
                    mkdir "$DEMYX_BACKUP"/config
                fi

                demyx_echo 'Backing up configs'
                demyx_execute tar -czf "$DEMYX_BACKUP"/config/"$DEMYX_APP_DOMAIN".tgz -C "$DEMYX_WP" "$DEMYX_APP_DOMAIN"
            else
                [[ ! -d "$DEMYX_BACKUP_WP"/"$DEMYX_APP_DOMAIN" ]] && mkdir -p "$DEMYX_BACKUP_WP"/"$DEMYX_APP_DOMAIN"

                demyx_echo 'Exporting database'
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" db export "$DEMYX_APP_CONTAINER".sql

                demyx_echo 'Exporting WordPress'
                demyx_execute docker cp "$DEMYX_APP_WP_CONTAINER":/demyx "$DEMYX_APP_PATH"/demyx-wp

                demyx_echo 'Exporting logs'
                demyx_execute docker cp "$DEMYX_APP_WP_CONTAINER":/var/log/demyx "$DEMYX_APP_PATH"/demyx-log

                demyx_echo 'Archiving directory'
                demyx_execute tar -czf "$DEMYX_BACKUP_WP"/"$DEMYX_APP_DOMAIN"/"$DEMYX_BACKUP_TODAYS_DATE"-"$DEMYX_APP_DOMAIN".tgz -C "$DEMYX_WP" "$DEMYX_APP_DOMAIN"

                [[ -n "$DEMYX_BACKUP_PATH" ]] && mv "$DEMYX_BACKUP_WP"/"$DEMYX_APP_DOMAIN"/"$DEMYX_BACKUP_TODAYS_DATE"-"$DEMYX_APP_DOMAIN".tgz "$DEMYX_BACKUP_PATH" && chown demyx:demyx "$DEMYX_BACKUP_PATH"/"$DEMYX_APP_DOMAIN".tgz
                
                demyx_echo 'Cleaning up'
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" rm "$DEMYX_APP_CONTAINER".sql; \
                    rm -rf "$DEMYX_APP_PATH"/demyx-wp; \
                    rm -rf "$DEMYX_APP_PATH"/demyx-log
            fi
        else
            demyx_die --not-found
        fi
    fi
}
