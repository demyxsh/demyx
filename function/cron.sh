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

    demyx_source stack

    if [[ "$DEMYX_CRON" = daily ]]; then
        if [[ "$DEMYX_STACK_TELEMETRY" = true ]]; then
            echo "[$(date +%F-%T)] CROND: TELEMETRY"
            demyx_execute -v curl -s "https://demyx.sh/?action=active&token=V1VpdGNPcWNDVlZSUDFQdFBaR0Zhdz09OjrnA1h6ZbDFJ2T6MHOwg3p4" -o /dev/null
        fi

        # Backup demyx system and configs
        echo "[$(date +%F-%T)] CROND: BACKING UP DEMYX"
        demyx_execute -v mkdir -p "$DEMYX_BACKUP"/system; \
            cp -r "$DEMYX_APP" "$DEMYX_BACKUP"/system; \
            docker cp demyx_traefik:/demyx "$DEMYX_BACKUP"/system/traefik; \
            tar -czf "$DEMYX_BACKUP"/system-"$DEMYX_HOST".tgz -C "$DEMYX_BACKUP" system
        
        # Update Oh My Zsh
        cd /home/demyx/.oh-my-zsh
        echo "[$(date +%F-%T)] CROND: UPDATE OH-MY-ZSH"
        demyx_execute -v git pull

        # Update Oh My Zsh plugin
        cd /home/demyx/.oh-my-zsh/plugins/zsh-autosuggestions
        echo "[$(date +%F-%T)] CROND: UPDATE OH-MY-ZSH PLUGIN"
        demyx_execute -v git pull
        
        # Execute custom cron
        if [[ -f /demyx/custom/cron/daily.sh ]]; then
            echo "[$(date +%F-%T)] CROND: CUSTOM EVERY DAY"
            demyx_execute -v bash /demyx/custom/cron/daily.sh
        fi

        if [[ "$DEMYX_STACK_BACKUP" = true ]]; then
            # Backup WordPress sites at midnight
            echo "[$(date +%F-%T)] CROND: WORDPRESS BACKUP"
            demyx_execute -v demyx backup all

            # Delete backups older than X amounts of days
            echo "[$(date +%F-%T)] CROND: DELETING BACKUPS OLDER THAN $DEMYX_STACK_BACKUP_LIMIT"
            demyx_execute -v find "$DEMYX_BACKUP_WP" -type f -mindepth 1 -mtime +"$DEMYX_STACK_BACKUP_LIMIT" -delete
        fi

        # WP auto update
        echo "[$(date +%F-%T)] CROND: WORDPRESS UPDATE"
        cd "$DEMYX_WP"
        for i in *
        do
            source "$DEMYX_WP"/"$i"/.env
            if [[ "$DEMYX_APP_WP_UPDATE" = true ]]; then
                if [[ "$DEMYX_APP_WP_IMAGE" = demyx/wordpress ]]; then
                    demyx_execute -v demyx wp "$i" core update; \
                        demyx wp "$i" theme update --all; \
                        demyx wp "$i" plugin update --all
                else
                    demyx_execute -v docker exec -t "$DEMYX_APP_WP_CONTAINER" composer update
                fi
            fi
        done
    elif [[ "$DEMYX_CRON" = minute ]]; then
        # Monitor for auto scale
        echo "[$(date +%F-%T)] CROND: MONITOR"
        demyx_execute -v demyx monitor

        # Healthchecks
        echo "[$(date +%F-%T)] CROND: HEALTHCHECK"
        demyx_execute -v demyx healthcheck

        # Execute custom cron
        if [[ -f /demyx/custom/cron/minute.sh ]]; then
            echo "[$(date +%F-%T)] CROND: CUSTOM"
            demyx_execute -v bash /demyx/custom/cron/minute.sh
        fi
    elif [[ "$DEMYX_CRON" = six-hour ]]; then
        # Check for Demyx updates
        #cd "$DEMYX_ETC"
        #git remote update
        #DEMYX_CRON_UPDATES="$(git rev-list HEAD...origin/master --count)"
        #echo "[$(date +%F-%T)] CROND: CHECK DEMYX UPDATE"
        #demyx_execute -v sed -i "s|DEMYX_ENV_STATUS=.*|DEMYX_ENV_STATUS=$DEMYX_CRON_UPDATES|g" "$DEMYX"/.env

        # Run WP cron
        echo "[$(date +%F-%T)] CROND: WORDPRESS EVENT CRON"
        demyx_execute -v -v demyx wp all cron event run --due-now

        # Execute custom cron
        if [[ -f /demyx/custom/cron/six-hour.sh ]]; then
            echo "[$(date +%F-%T)] CROND: CUSTOM"
            demyx_execute -v -v bash /demyx/custom/cron/six-hour.sh
        fi
    elif [[ "$DEMYX_CRON" = weekly ]]; then
        # Rotate demyx log
        echo "[$(date +%F-%T)] CROND: LOGROTATE DEMYX"
        demyx_execute -v demyx log main --rotate

        # Rotate WordPress log
        echo "[$(date +%F-%T)] CROND: LOGROTATE WORDPRESS"
        cd "$DEMYX_WP"
        for i in *
        do
            demyx_execute -v demyx log "$i" --rotate
        done

        # Execute custom cron
        if [[ -f /demyx/custom/cron/weekly.sh ]]; then
            echo "[$(date +%F-%T)] CROND: CUSTOM EVERY WEEK"
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
