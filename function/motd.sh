# Demyx
# https://demyx.sh

DEMYX_MOTD_CHECK_WP="$(ls -A "$DEMYX_WP")"

demyx_motd_dev_warning() {
    if [[ -n "$DEMYX_MOTD_CHECK_WP" ]]; then
        cd "$DEMYX_WP"
        for i in *
        do
            DEMYX_COMMON_DEV_CHECK="$(grep DEMYX_APP_DEV "$DEMYX_WP"/"$i"/.env | awk -F '[=]' '{print $2}')"
            if [[ "$DEMYX_COMMON_DEV_CHECK" = true ]]; then
                demyx_execute -v echo -e "\e[33m[WARNING]\e[39m $i is in development mode"
            fi
        done
    fi
}
demyx_motd_getting_started() {
    if [[ -z "$DEMYX_MOTD_CHECK_WP" ]]; then
        demyx_execute -v echo -e "\e[34m[INFO]\e[39m To create a WordPress site: demyx run domain.tld"
        demyx_execute -v echo -e "\e[34m[INFO]\e[39m To create a Bedrock site: demyx run domain.tld --bedrock"
    fi
}
demyx_motd_mariadb_check() {
    if [[ -n "$DEMYX_MOTD_CHECK_WP" ]]; then
        cd "$DEMYX_WP"
        for i in *
        do
            DEMYX_MOTD_CHECK_MARIADB="$(grep "demyx/mariadb:edge" /demyx/app/wp/"$i"/docker-compose.yml)"
            [[ -z "$DEMYX_MOTD_CHECK_MARIADB" ]] && DEMYX_MOTD_CHECK_MARIADB_TRUE=true
        done

        if [[ "$DEMYX_MOTD_CHECK_MARIADB_TRUE" = true ]]; then
            demyx_execute -v echo -e "\e[34m[INFO]\e[39m MariaDB needs an upgrade. This will temporarily bring down the sites during the upgrade. Please run the commands:\n\n- Test a single site: demyx config domain.tld --upgrade-db\n- Upgrade all sites: demyx config all --upgrade-db\n"
        fi
    fi
}
demyx_motd_stack_check() {
    if [[ -f "$DEMYX_STACK"/.env ]]; then
        source "$DEMYX_STACK"/.env
        if [[ "$DEMYX_STACK_AUTO_UPDATE" = false ]]; then
            demyx_execute -v echo -e "\e[33m[WARNING]\e[39m Auto updates are disabled, demyx stack --auto-update to enable"
        fi
        if [[ "$DEMYX_STACK_BACKUP" = false ]]; then
            demyx_execute -v echo -e "\e[33m[WARNING]\e[39m Auto backups are disabled, demyx stack --backup to enable"
        fi
        if [[ "$DEMYX_STACK_MONITOR" = false ]]; then
            demyx_execute -v echo -e "\e[33m[WARNING]\e[39m Global monitors are disabled, demyx stack --monitor to enable"
        fi
        if [[ "$DEMYX_STACK_HEALTHCHECK" = false ]]; then
            demyx_execute -v echo -e "\e[33m[WARNING]\e[39m Global healthchecks are disabled, demyx stack --healthcheck to enable"
        fi
    fi
}
#demyx_motd_git_latest() {
#    cd "$DEMYX_ETC" || exit
#    DEMYX_MOTD_GIT_LOG="$(git --no-pager log -5 --format=format:'- %s %C(white dim)(%ar)%C(reset)')"
#    demyx_execute -v echo -e "Latest Updates\n----------------\n$DEMYX_MOTD_GIT_LOG\n"
#}
demyx_motd() {
    echo "
        Demyx
        https://demyx.sh

        Welcome to Demyx! Please report any bugs you see.

        - Help: demyx help
        - Bugs: github.com/demyxco/demyx/issues
        - Chat: https://webchat.freenode.net/?channel=#demyx
        - Contact: info@demyx.sh
        " | sed 's/        //g'
    
    if [[ -n "$(demyx_upgrade_apps)" ]]; then
        demyx_execute -v echo -e '\e[31m==========[BREAKING CHANGES]==========\e[39m\n\nFor best security practice and performance, all demyx containers will now\nrun as the demyx user, including the WordPress containers. Each WordPress\nsites will now have a total of 3 containers: MariaDB, NGINX, and WordPress.\nCertain demyx commands will not work until you upgrade the sites.\n\nPlease run the following commands:\n'
        demyx_upgrade_apps
    else
        DEMYX_MOTD_MODE="$(demyx_get_mode)"
        DEMYX_MOTD_BACKUPS="$([[ -d "$DEMYX_BACKUP_WP" ]] && du -sh "$DEMYX_BACKUP_WP" | cut -f1)"
        [[ -z "$DEMYX_MOTD_BACKUPS" ]] && DEMYX_MOTD_BACKUPS=0
        DEMYX_MOTD_SYSTEM_INFO="$(demyx info system --json)"
        DEMYX_MOTD_SYSTEM_DISK="$(echo "$DEMYX_MOTD_SYSTEM_INFO" | jq .disk_used | sed 's|"||g')"
        DEMYX_MOTD_SYSTEM_DISK_TOTAL="$(echo "$DEMYX_MOTD_SYSTEM_INFO" | jq .disk_total | sed 's|"||g')"
        DEMYX_MOTD_SYSTEM_DISK_TOTAL_PERCENTAGE="$(echo "$DEMYX_MOTD_SYSTEM_INFO" | jq .disk_total_percentage | sed 's|"||g')"
        DEMYX_MOTD_SYSTEM_DISK_TOTAL_PERCENTAGE_NUMERIC="$(echo "$DEMYX_MOTD_SYSTEM_DISK_TOTAL_PERCENTAGE" | sed "s|%||g")"
        DEMYX_MOTD_SYSTEM_MEMORY="$(echo "$DEMYX_MOTD_SYSTEM_INFO" | jq .memory_used | sed 's|"||g')"
        DEMYX_MOTD_SYSTEM_MEMORY_TOTAL="$(echo "$DEMYX_MOTD_SYSTEM_INFO" | jq .memory_total | sed 's|"||g')"
        DEMYX_MOTD_SYSTEM_UPTIME="$(echo "$DEMYX_MOTD_SYSTEM_INFO" | jq .uptime | sed 's|"||g')"
        DEMYX_MOTD_SYSTEM_LOAD="$(echo "$DEMYX_MOTD_SYSTEM_INFO" | jq .load_average | sed 's|"||g')"
        DEMYX_MOTD_SYSTEM_CONTAINER="$(echo "$DEMYX_MOTD_SYSTEM_INFO" | jq .container_running | sed 's|"||g')"
        DEMYX_MOTD_SYSTEM_CONTAINER_DEAD="$(echo "$DEMYX_MOTD_SYSTEM_INFO" | jq .container_dead | sed 's|"||g')"
        DEMYX_MOTD_GET_RECENT_MODIFIED="$(find "$DEMYX_ETC" -type f -mtime -1 | xargs ls -lt 2>/dev/null | head -1 | awk '{print $NF}')"

        if [[ "$DEMYX_MOTD_SYSTEM_CONTAINER_DEAD" = 0 ]]; then
            DEMYX_MOTD_SYSTEM_CONTAINER_DEAD_COUNT=
        else
            DEMYX_MOTD_SYSTEM_CONTAINER_DEAD_COUNT="($DEMYX_MOTD_SYSTEM_CONTAINER_DEAD dead)"
        fi

        PRINT_MOTD_TABLE="DEMYX^ SYSTEM INFO\n"
        PRINT_MOTD_TABLE+="UPDATED^ $(stat -c '%y' "$DEMYX_MOTD_GET_RECENT_MODIFIED" | awk -F '[.]' '{print $1}')\n"
        PRINT_MOTD_TABLE+="MODE^ $(echo "$DEMYX_MOTD_MODE" | tr [a-z] [A-Z])\n"
        PRINT_MOTD_TABLE+="HOST^ $DEMYX_HOST\n"
        PRINT_MOTD_TABLE+="SSH^ $DEMYX_SSH\n"
        PRINT_MOTD_TABLE+="BACKUPS^ $DEMYX_MOTD_BACKUPS\n"
        PRINT_MOTD_TABLE+="DISK^ $DEMYX_MOTD_SYSTEM_DISK/$DEMYX_MOTD_SYSTEM_DISK_TOTAL ($DEMYX_MOTD_SYSTEM_DISK_TOTAL_PERCENTAGE)\n"
        PRINT_MOTD_TABLE+="MEMORY^ $DEMYX_MOTD_SYSTEM_MEMORY/$DEMYX_MOTD_SYSTEM_MEMORY_TOTAL\n"
        PRINT_MOTD_TABLE+="UPTIME^ ${DEMYX_MOTD_SYSTEM_UPTIME}\n"
        PRINT_MOTD_TABLE+="LOAD^ $DEMYX_MOTD_SYSTEM_LOAD\n"
        PRINT_MOTD_TABLE+="CONTAINERS^ $DEMYX_MOTD_SYSTEM_CONTAINER $DEMYX_MOTD_SYSTEM_CONTAINER_DEAD_COUNT"
        demyx_execute -v demyx_table "$PRINT_MOTD_TABLE"
        echo
    fi
    demyx_motd_getting_started
    demyx_motd_mariadb_check
    demyx_motd_stack_check
    demyx_motd_dev_warning
}
