# Demyx
# https://demyx.sh

demyx_motd_app_check() {
    cd "$DEMYX_WP"
    for i in *
    do
        DEMYX_CHECK_APP_ON_CHECK=$(grep -c "=on" /demyx/app/wp/"$i"/.env || true)
        if [[ "$DEMYX_CHECK_APP_ON_CHECK" > 0 ]]; then
            demyx_execute -v echo -e "\e[33m[WARNING]\e[39m $i has outdated configs, run: demyx config "$i" --refresh"
        fi
    done
}
demyx_motd_chroot_warning() {
    DEMYX_MOTD_CHROOT_CHECK=$(docker run --rm -v /usr/local/bin:/usr/local/bin demyx/utilities "[[ -L /usr/local/bin/demyx ]] && echo true")
    [[ "$DEMYX_MOTD_CHROOT_CHECK" = true ]] && demyx_execute -v echo -e "\e[33m[WARNING]\e[39m The demyx chroot.sh script needs to be updated on the host, please run this command:\n\ndocker run -t --rm -v /usr/local/bin:/usr/local/bin demyx/utilities \"rm -f /usr/local/bin/demyx; curl -s https://raw.githubusercontent.com/demyxco/demyx/master/chroot.sh -o /usr/local/bin/demyx; chmod +x /usr/local/bin/demyx\"\n"
}
demyx_motd_dev_warning() {
    DEMYX_COMMON_WP_NOT_EMPTY=$(ls "$DEMYX_WP")
    if [[ -n "$DEMYX_COMMON_WP_NOT_EMPTY" ]]; then
        cd "$DEMYX_WP"
        for i in *
        do
            DEMYX_COMMON_DEV_CHECK=$(grep DEMYX_APP_DEV "$DEMYX_WP"/"$i"/.env | awk -F '[=]' '{print $2}')
            if [[ "$DEMYX_COMMON_DEV_CHECK" = true ]]; then
                demyx_execute -v echo -e "\e[33m[WARNING]\e[39m $i is in development mode"
            fi
        done
    fi
}
demyx_motd_stack_upgrade_notice() {
    if [[ "$DEMYX_CHECK_TRAEFIK" = 1 ]]; then
        demyx_execute -v echo -e "\e[34m[INFO]\e[39m An upgrade is available for the stack, please run: demyx stack upgrade"
    fi
}
demyx_motd_git_latest() {
    cd "$DEMYX_ETC" || exit
    DEMYX_MOTD_GIT_LOG="$(git --no-pager log -5 --format=format:'- %s %C(white dim)(%ar)%C(reset)')"
    demyx_execute -v echo -e "Latest Updates\n----------------\n$DEMYX_MOTD_GIT_LOG\n"
}
demyx_motd() {
    source /demyx/.env
    
    if (( "$DEMYX_MOTD_STATUS" > 1 )); then
        DEMYX_MOTD_STATUS="$DEMYX_MOTD_STATUS UPDATES"
    elif [[ "$DEMYX_MOTD_STATUS" = 1 ]]; then
        DEMYX_MOTD_STATUS="1 UPDATE"
    else
        DEMYX_MOTD_STATUS="UPDATED"
    fi

    DEMYX_MOTD_MODE=$(echo "$DEMYX_MOTD_MODE" | tr [a-z] [A-Z] | sed -e 's/\r//g')
    DEMYX_MOTD_SYSTEM_INFO=$(demyx info system --json)
    DEMYX_MOTD_SYSTEM_DISK=$(echo "$DEMYX_MOTD_SYSTEM_INFO" | jq .disk_used | sed 's|"||g')
    DEMYX_MOTD_SYSTEM_DISK_TOTAL=$(echo "$DEMYX_MOTD_SYSTEM_INFO" | jq .disk_total | sed 's|"||g')
    DEMYX_MOTD_SYSTEM_DISK_TOTAL_PERCENTAGE=$(echo "$DEMYX_MOTD_SYSTEM_INFO" | jq .disk_total_percentage | sed 's|"||g')
    DEMYX_MOTD_SYSTEM_DISK_TOTAL_PERCENTAGE_NUMERIC=$(echo "$DEMYX_MOTD_SYSTEM_DISK_TOTAL_PERCENTAGE" | sed "s|%||g")
    DEMYX_MOTD_SYSTEM_MEMORY=$(echo "$DEMYX_MOTD_SYSTEM_INFO" | jq .memory_used | sed 's|"||g')
    DEMYX_MOTD_SYSTEM_MEMORY_TOTAL=$(echo "$DEMYX_MOTD_SYSTEM_INFO" | jq .memory_total | sed 's|"||g')
    DEMYX_MOTD_SYSTEM_UPTIME=$(echo "$DEMYX_MOTD_SYSTEM_INFO" | jq .uptime | sed 's|"||g')
    DEMYX_MOTD_SYSTEM_LOAD=$(echo "$DEMYX_MOTD_SYSTEM_INFO" | jq .load_average | sed 's|"||g')
    DEMYX_MOTD_SYSTEM_CONTAINER=$(echo "$DEMYX_MOTD_SYSTEM_INFO" | jq .container_running | sed 's|"||g')
    DEMYX_MOTD_SYSTEM_CONTAINER_DEAD=$(echo "$DEMYX_MOTD_SYSTEM_INFO" | jq .container_dead | sed 's|"||g')

    if [[ "$DEMYX_MOTD_SYSTEM_CONTAINER_DEAD" = 0 ]]; then
        DEMYX_MOTD_SYSTEM_CONTAINER_DEAD_COUNT=
    else
        DEMYX_MOTD_SYSTEM_CONTAINER_DEAD_COUNT="($DEMYX_MOTD_SYSTEM_CONTAINER_DEAD dead)"
    fi

    PRINT_MOTD_TABLE="DEMYX^ SYSTEM INFO - $DEMYX_MOTD_STATUS\n"
    PRINT_MOTD_TABLE+="MODE^ $DEMYX_MOTD_MODE\n"
    PRINT_MOTD_TABLE+="HOST^ $DEMYX_MOTD_HOST\n"
    PRINT_MOTD_TABLE+="SSH^ $DEMYX_MOTD_SSH\n"
    PRINT_MOTD_TABLE+="DISK^ $DEMYX_MOTD_SYSTEM_DISK/$DEMYX_MOTD_SYSTEM_DISK_TOTAL ($DEMYX_MOTD_SYSTEM_DISK_TOTAL_PERCENTAGE)\n"
    PRINT_MOTD_TABLE+="MEMORY^ $DEMYX_MOTD_SYSTEM_MEMORY/$DEMYX_MOTD_SYSTEM_MEMORY_TOTAL\n"
    PRINT_MOTD_TABLE+="UPTIME^ ${DEMYX_MOTD_SYSTEM_UPTIME}\n"
    PRINT_MOTD_TABLE+="LOAD^ $DEMYX_MOTD_SYSTEM_LOAD\n"
    PRINT_MOTD_TABLE+="CONTAINERS^ $DEMYX_MOTD_SYSTEM_CONTAINER $DEMYX_MOTD_SYSTEM_CONTAINER_DEAD_COUNT"

    echo "
        Demyx
        https://demyx.sh

        Welcome to Demyx! Please report any bugs you see.

        - Help: demyx help
        - Bugs: github.com/demyxco/demyx/issues
        - Contact: info@demyx.sh
        " | sed 's/        //g'

    demyx_motd_git_latest
    demyx_execute -v demyx_table "$PRINT_MOTD_TABLE"
    demyx_motd_chroot_warning
    demyx_motd_stack_upgrade_notice
    demyx_motd_dev_warning
    demyx_motd_app_check
}
