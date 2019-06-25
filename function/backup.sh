# Demyx
# https://demyx.sh
# 
# demyx backup <app>
# demyx backup <args>
# 
function demyx_backup() {
    if [[ "$DEMYX_TARGET" = all ]]; then
        cd "$DEMYX_WP" || exit
        for i in *
        do
            echo -e "\e[34m[INFO]\e[39m Backing up $i"
            demyx backup "$i"
        done
    else
        DEMYX_BACKUP_TODAYS_DATE=$(date +%Y/%m/%d)

        demyx_app_config

        if [[ "$DEMYX_APP_TYPE" = wp ]]; then
            [[ ! -d "$DEMYX_BACKUP"/"$DEMYX_BACKUP_TODAYS_DATE"/wp ]] && mkdir -p "$DEMYX_BACKUP"/"$DEMYX_BACKUP_TODAYS_DATE"/wp

            demyx_echo 'Exporting database'
            demyx_execute demyx wp "$DEMYX_APP_DOMAIN" db export "$DEMYX_APP_CONTAINER".sql

            demyx_echo 'Exporting WordPress'
            demyx_execute docker cp "$DEMYX_APP_WP_CONTAINER":/var/www/html "$DEMYX_APP_PATH"

            demyx_echo 'Exporting logs'
            demyx_execute docker cp "$DEMYX_APP_WP_CONTAINER":/var/log/demyx "$DEMYX_APP_PATH"

            demyx_echo 'Archiving directory' 
            demyx_execute tar -czf "$DEMYX_BACKUP"/"$DEMYX_BACKUP_TODAYS_DATE"/wp/"$DEMYX_APP_DOMAIN".tgz -C "$DEMYX_WP" "$DEMYX_APP_DOMAIN"
            
            demyx_echo 'Cleaning up'
            demyx_execute rm -rf "$DEMYX_APP_PATH"/html; \
                rm -rf "$DEMYX_APP_PATH"/demyx; \
                demyx exec "$DEMYX_APP_DOMAIN" bash -c "rm $DEMYX_APP_CONTAINER.sql"
        else
            demyx_die --not-found
        fi
    fi
}
