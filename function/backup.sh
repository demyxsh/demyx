# Demyx
# https://demyx.sh
# 
# demyx backup <app>
# demyx backup <args>
# 
demyx_backup() {
    while :; do
        case "$3" in
            --config)
                DEMYX_BACKUP_CONFIG=1
                ;;
            --path=?*)
                DEMYX_BACKUP_PATH="${3#*=}"
                ;;
            --path=)
                demyx_die '"--path" cannot be empty'
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
            echo -e "\e[34m[INFO]\e[39m Backing up $i"
            if [[ -n "$DEMYX_BACKUP_PATH" ]]; then
                demyx backup "$i" --path="$DEMYX_BACKUP_PATH"
            else
                demyx backup "$i"
            fi
        done
    else
        DEMYX_BACKUP_TODAYS_DATE="$(date +%Y-%m-%d)"

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
