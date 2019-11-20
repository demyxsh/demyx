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

    source "$DEMYX_STACK"/.env

    if [[ "$DEMYX_CRON" = daily ]]; then
        if [[ "$DEMYX_STACK_TELEMETRY" = true ]]; then
            demyx_echo "[$(date +%F-%T)] CROND: TELEMETRY"
            demyx_execute curl -s "https://demyx.sh/?action=active&token=V1VpdGNPcWNDVlZSUDFQdFBaR0Zhdz09OjrnA1h6ZbDFJ2T6MHOwg3p4" > /dev/null
        fi

        # Ouroboros is known to crash, so stop/rm it and have the updater bring it back up 
        demyx_echo "[$(date +%F-%T)] CROND: RESTARTING OUROBOROS"
        demyx_execute docker stop demyx_ouroboros; \
            docker rm -f demyx_ouroboros
        
        if [[ "$DEMYX_STACK_AUTO_UPDATE" = true ]]; then
            # Auto update demyx images incase Ouroboros crashes
            demyx_echo "[$(date +%F-%T)] CROND: PULL DEMYX IMAGES"
            demyx_execute demyx pull
        fi

        # Auto update Demyx core files
        if [[ "$DEMYX_STACK_AUTO_UPDATE" = true ]]; then
            demyx_echo "[$(date +%F-%T)] CROND: UPDATE DEMYX CORE"
            demyx_execute demyx update
        fi

        # Update demyx chroot.sh on the host using a container
        demyx_echo "[$(date +%F-%T)] CROND: UPDATE DEMYX CHROOT"
        demyx_execute docker run -t --user=root --rm -v /usr/local/bin:/usr/local/bin demyx/utilities "rm -f /usr/local/bin/demyx; curl -s https://raw.githubusercontent.com/demyxco/demyx/master/chroot.sh -o /usr/local/bin/demyx; chmod +x /usr/local/bin/demyx"

        # Update Oh My Zsh and its plugin
        cd /home/demyx/.oh-my-zsh
        demyx_echo "[$(date +%F-%T)] CROND: UPDATE OH-MY-ZSH"
        demyx_execute git pull

        # Update Oh My Zsh plugin
        cd /home/demyx/.oh-my-zsh/plugins/zsh-autosuggestions
        demyx_echo "[$(date +%F-%T)] CROND: UPDATE OH-MY-ZSH PLUGIN"
        demyx_execute git pull
        
        # Execute custom cron
        if [[ -f /demyx/custom/cron/every-day.sh ]]; then
            demyx_echo "[$(date +%F-%T)] CROND: CUSTOM EVERY DAY"
            demyx_execute bash /demyx/custom/cron/every-day.sh
        fi

        # Backup WordPress sites at midnight
        demyx_echo "[$(date +%F-%T)] CROND: WORDPRESS BACKUP"
        demyx_execute demyx backup all

        # WP auto update
        demyx_echo "[$(date +%F-%T)] CROND: WORDPRESS UPDATE"
        cd "$DEMYX_WP"
        for i in *
        do
            source "$DEMYX_WP"/"$i"/.env
            if [[ "$DEMYX_APP_WP_UPDATE" = true ]]; then
                if [[ "$DEMYX_APP_WP_IMAGE" = demyx/wordpress ]]; then
                    demyx_execute demyx wp "$i" core update; \
                        demyx wp "$i" theme update --all; \
                        demyx wp "$i" plugin update --all
                else
                    demyx_execute docker exec "$DEMYX_APP_WP_CONTAINER" composer update
                fi
            fi
        done
    elif [[ "$DEMYX_CRON" = minute ]]; then
        # Monitor for auto scale
        demyx_echo "[$(date +%F-%T)] CROND: MONITOR"
        demyx_execute demyx monitor

        # Healthchecks
        demyx_echo "[$(date +%F-%T)] CROND: HEALTHCHECK"
        demyx_execute demyx healthcheck

        # Execute custom cron
        if [[ -f /demyx/custom/cron/every-minute.sh ]]; then
            demyx_echo "[$(date +%F-%T)] CROND: CUSTOM"
            demyx_execute bash /demyx/custom/cron/every-minute.sh
        fi
    elif [[ "$DEMYX_CRON" = six-hour ]]; then
        # Check for Demyx updates
        cd "$DEMYX_ETC"
        git remote update
        DEMYX_CRON_UPDATES="$(git rev-list HEAD...origin/master --count)"
        demyx_echo "[$(date +%F-%T)] CROND: CHECK DEMYX UPDATE"
        demyx_execute sed -i "s|DEMYX_MOTD_STATUS=.*|DEMYX_MOTD_STATUS=$DEMYX_CRON_UPDATES|g" "$DEMYX"/.env

        # Run WP cron
        demyx_echo "[$(date +%F-%T)] CROND: WORDPRESS EVENT CRON"
        demyx_execute demyx wp all cron event run --due-now

        # Execute custom cron
        if [[ -f /demyx/custom/cron/every-6-hour.sh ]]; then
            demyx_echo "[$(date +%F-%T)] CROND: CUSTOM"
            demyx_execute bash /demyx/custom/cron/every-6-hour.sh
        fi
    elif [[ "$DEMYX_CRON" = weekly ]]; then
        # Rotate demyx log
        demyx_echo "[$(date +%F-%T)] CROND: LOGROTATE DEMYX"
        demyx_execute demyx log main --rotate

        # Rotate WordPress log
        demyx_echo "[$(date +%F-%T)] CROND: LOGROTATE WORDPRESS"
        cd "$DEMYX_WP"
        for i in *
        do
            demyx_execute demyx log "$i" --rotate
        done

        # Execute custom cron
        if [[ -f /demyx/custom/cron/every-week.sh ]]; then
            demyx_echo "[$(date +%F-%T)] CROND: CUSTOM EVERY WEEK"
            demyx_execute bash /demyx/custom/cron/every-week.sh
        fi
    else
        if [[ -z "$1" ]]; then
            demyx_die 'Missing argument'
        else
            demyx_die --command-not-found
        fi
    fi
}
