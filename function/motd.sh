# Demyx
# https://demyx.sh

DEMYX_MOTD_CHECK_WP="$([[ -d "$DEMYX_WP" ]] && ls -A "$DEMYX_WP")"

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
        demyx_execute -v echo -e "\e[34m[INFO]\e[39m To create a WordPress app: demyx run ${DEMYX_DOMAIN:-domain.tld}"
        demyx_execute -v echo -e "\e[34m[INFO]\e[39m Supported stacks: bedrock, nginx-php, ols, ols-bedrock"
        demyx_execute -v echo -e "\e[34m[INFO]\e[39m To see more run options: demyx help run"
    fi
}
demyx_motd_stack_check() {
    if [[ "$DEMYX_BACKUP_ENABLE" = false ]]; then
        demyx_execute -v echo -e "\e[33m[WARNING]\e[39m Auto backups are disabled, set DEMYX_HOST_BACKUP to true: demyx host edit"
    fi
    if [[ "$DEMYX_MONITOR_ENABLE" = false ]]; then
        demyx_execute -v echo -e "\e[33m[WARNING]\e[39m Global monitors are disabled, set DEMYX_HOST_MONITOR to true: demyx host edit"
    fi
    if [[ "$DEMYX_HEALTHCHECK_ENABLE" = false ]]; then
        demyx_execute -v echo -e "\e[33m[WARNING]\e[39m Global healthchecks are disabled, set DEMYX_HOST_HEALTHCHECK to true: demyx host edit"
    fi
}
demyx_motd() {
    echo "
        Demyx
        https://demyx.sh

        Welcome to Demyx! Please report any bugs you see.

        - Help: demyx help
        - Bugs: github.com/demyxco/demyx/issues
        - Changelog: github.com/demyxco/demyx/blob/master/changelog/${DEMYX_VERSION}.md
        - Chat: https://web.libera.chat/?channel=#demyx
        - Contact: info@demyx.sh
        " | sed 's/        //g'
    
    demyx info motd
    demyx_motd_getting_started
    demyx_motd_stack_check
    demyx_motd_dev_warning
}
