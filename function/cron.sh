# Demyx
# https://demyx.sh
# 
# demyx cron <args>
#
demyx_cron() {
    while :; do
        case "$1" in
            daily)
                DEMYX_CRON=daily
                ;;
            hourly)
                DEMYX_CRON=hourly
                ;;
            minute)
                DEMYX_CRON=minute
                ;;
            six-hour)
                DEMYX_CRON=six-hour
                ;;
            weekly)
                DEMYX_CRON=weekly
                ;;
            --)
                shift
                break
                ;;
            -?*)
                printf '\e[31m[CRITICAL]\e[39m Unknown option: %s\n' "$1" >&2
                exit 1
                ;;
            *)
                break
        esac
        shift
    done

    if [[ "$DEMYX_CRON" = daily ]]; then
        if [[ "$DEMYX_TELEMETRY" = true ]]; then
            echo "[$(date +%F-%T)] CROND DAILY: TELEMETRY"
            demyx_execute -v curl -s "https://demyx.sh/?action=active&token=V1VpdGNPcWNDVlZSUDFQdFBaR0Zhdz09OjrnA1h6ZbDFJ2T6MHOwg3p4" -o /dev/null
        fi

        # Backup demyx system and configs
        echo "[$(date +%F-%T)] CROND DAILY: BACKING UP DEMYX"
        demyx_execute -v mkdir -p "$DEMYX_BACKUP"/system; \
            cp -r "$DEMYX_APP" "$DEMYX_BACKUP"/system; \
            docker cp demyx_traefik:/demyx "$DEMYX_BACKUP"/system/traefik; \
            tar -czf "$DEMYX_BACKUP"/system-"$DEMYX_HOST".tgz -C "$DEMYX_BACKUP" system

        if [[ "$DEMYX_BACKUP_ENABLE" = true ]]; then
            # Backup WordPress sites at midnight
            echo "[$(date +%F-%T)] CROND DAILY: WORDPRESS BACKUP"
            demyx_execute -v demyx backup all

            # Delete backups older than X amounts of days
            echo "[$(date +%F-%T)] CROND DAILY: DELETING BACKUPS OLDER THAN $DEMYX_BACKUP_LIMIT"
            demyx_execute -v find "$DEMYX_BACKUP_WP" -type f -mindepth 1 -mtime +"$DEMYX_BACKUP_LIMIT" -delete
        fi

        # WP auto update
        echo "[$(date +%F-%T)] CROND DAILY: WORDPRESS UPDATE"
        cd "$DEMYX_WP"
        for i in *
        do
            source "$DEMYX_WP"/"$i"/.env
            if [[ "$DEMYX_APP_WP_UPDATE" = true ]]; then
                if [[ "$DEMYX_APP_STACK" = ols || "$DEMYX_APP_STACK" = nginx-php ]]; then
                    demyx_execute -v demyx wp "$i" core update; \
                        demyx wp "$i" theme update --all; \
                        demyx wp "$i" plugin update --all
                else
                    demyx_execute -v docker exec -t "$DEMYX_APP_WP_CONTAINER" /usr/local/bin/composer update
                fi
            fi
        done
        
        # Execute custom cron
        if [[ -f /demyx/custom/cron/daily.sh ]]; then
            echo "[$(date +%F-%T)] CROND DAILY: CUSTOM"
            demyx_execute -v bash /demyx/custom/cron/daily.sh
        fi
    elif [[ "$DEMYX_CRON" = hourly ]]; then
        # Run WP cron
        echo "[$(date +%F-%T)] CROND HOURLY: WORDPRESS EVENT CRON"
        demyx_execute -v demyx wp all cron event run --due-now

        # Execute custom cron
        if [[ -f /demyx/custom/cron/hourly.sh ]]; then
            echo "[$(date +%F-%T)] CROND HOURLY: CUSTOM"
            demyx_execute -v bash /demyx/custom/cron/hourly.sh
        fi
    elif [[ "$DEMYX_CRON" = minute ]]; then
        # Monitor for auto scale
        echo "[$(date +%F-%T)] CROND MINUTE: MONITOR"
        demyx_execute -v demyx monitor

        # Healthchecks
        echo "[$(date +%F-%T)] CROND MINUTE: HEALTHCHECK"
        demyx_execute -v demyx healthcheck

        # Execute custom cron
        if [[ -f /demyx/custom/cron/minute.sh ]]; then
            echo "[$(date +%F-%T)] CROND MINUTE: CUSTOM"
            demyx_execute -v bash /demyx/custom/cron/minute.sh
        fi
    elif [[ "$DEMYX_CRON" = six-hour ]]; then
        # Check for Demyx updates
        #cd "$DEMYX_CONFIG"
        #git remote update
        #DEMYX_CRON_UPDATES="$(git rev-list HEAD...origin/master --count)"
        #echo "[$(date +%F-%T)] CROND: CHECK DEMYX UPDATE"
        #demyx_execute -v sed -i "s|DEMYX_ENV_STATUS=.*|DEMYX_ENV_STATUS=$DEMYX_CRON_UPDATES|g" "$DEMYX"/.env

        # Execute custom cron
        if [[ -f /demyx/custom/cron/six-hour.sh ]]; then
            echo "[$(date +%F-%T)] CROND SIX-HOUR: CUSTOM"
            demyx_execute -v bash /demyx/custom/cron/six-hour.sh
        fi
    elif [[ "$DEMYX_CRON" = weekly ]]; then
        # Rotate demyx log
        echo "[$(date +%F-%T)] CROND WEEKLY: LOGROTATE DEMYX"
        demyx_execute -v demyx log main --rotate

        # Rotate WordPress log
        echo "[$(date +%F-%T)] CROND WEEKLY: LOGROTATE WORDPRESS"
        cd "$DEMYX_WP"
        for i in *
        do
            demyx_execute -v demyx log "$i" --rotate
        done

        # Update local versions
        demyx_execute -v demyx_update_local

        # Update remote versions
        demyx_execute -v demyx_update_remote

        # Update image list
        demyx_execute -v demyx_update_image

        # Execute custom cron
        if [[ -f /demyx/custom/cron/weekly.sh ]]; then
            echo "[$(date +%F-%T)] CROND WEEKLY: CUSTOM"
            demyx_execute -v bash /demyx/custom/cron/weekly.sh
        fi
    else
        if [[ -z "$1" ]]; then
            demyx_die 'Missing argument'
        else
            demyx_die --command-not-found
        fi
    fi
}
