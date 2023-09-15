# Demyx
# https://demyx.sh

#
#   Main motd function.
#
demyx_motd() {
    demyx_source info
    demyx_divider_title "DEMYX" "https://demyx.sh" "${DEMYX_STTY:-}"
    echo "Welcome to Demyx! Please report any bugs you see."
    echo
    echo "- Docs: https://demyx.sh/kb"
    echo "- Bugs: https://github.com/demyxsh/demyx/issues"
    echo "- Changelog: https://github.com/demyxsh/demyx/blob/master/CHANGELOG.md"
    echo "- Discussions: https://github.com/demyxsh/demyx/discussions"
    echo "- Chat: https://web.libera.chat/?channel=#demyx"
    demyx_info system
    echo
    demyx_motd_warning
    demyx_motd_start
}

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
        - Bugs: github.com/demyxsh/demyx/issues
        - Changelog: github.com/demyxsh/demyx/blob/master/changelog/${DEMYX_VERSION}.md
        - Chat: https://webchat.freenode.net/?channel=#demyx
        - Contact: info@demyx.sh
        " | sed 's/        //g'
    
    demyx info motd
    demyx_motd_getting_started
    demyx_motd_stack_check
    demyx_motd_dev_warning
}
