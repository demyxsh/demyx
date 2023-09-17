# Demyx
# https://demyx.sh
# shellcheck shell=bash

#
#   Main motd function.
#
demyx_motd() {
    demyx_source info
    demyx_divider_title "DEMYX" "https://demyx.sh" "${DEMYX_STTY:-}"
    echo "Welcome to Demyx! Please report any bugs you see."
    echo
    echo "- Docs            https://demyx.sh/kb"
    echo "- Bugs            https://demyx.sh/issues"
    echo "- Changelog       https://demyx.sh/changelog"
    echo "- Discussions     https://demyx.sh/discussions"
    echo "- IRC             https://demyx.sh/irc"
    echo "- Discord         https://demyx.sh/discord"
    demyx_info system
    echo
    demyx_motd_warning
    demyx_motd_start
}
#
#   Show getting started message if no apps are installed.
#
demyx_motd_start() {
    if [[ -z "$(demyx_motd_wp)" ]]; then
        demyx_echo "To create a WordPress app: demyx run $DEMYX_DOMAIN"
        demyx_echo "Supported stacks: bedrock, nginx-php, ols, ols-bedrock"
        demyx_echo "To see more run options: demyx help run"
    fi
}
#
#   Warns users if certain system functions are disabled.
#
demyx_motd_warning() {
    local DEMYX_MOTD_WARNING_I=

    if [[ "$DEMYX_DOMAIN" = localhost ]]; then
        demyx_warning "For SSL to work properly, please set a valid domain for DEMYX_DOMAIN: demyx host edit"
    fi

    if [[ "$DEMYX_EMAIL" = info@localhost ]]; then
        demyx_warning "For SSL to work properly, please set a valid email for DEMYX_EMAIL: demyx host edit"
    fi

    if [[ "$DEMYX_BACKUP_ENABLE" = false ]]; then
        demyx_warning "Auto backups are disabled, set DEMYX_BACKUP_ENABLE to true: demyx host edit"
    fi

    if [[ "$DEMYX_HEALTHCHECK" = false ]]; then
        demyx_warning "Global healthchecks are disabled, set DEMYX_HEALTHCHECK to true: demyx host edit"
    fi

    if [[ "$(demyx_motd_wp)" = true ]]; then
        cd "$DEMYX_WP" || exit

        for DEMYX_MOTD_WARNING_I in *; do
            # shellcheck disable=2034
            DEMYX_ARG_2="$DEMYX_MOTD_WARNING_I"
            demyx_app_env wp "
                DEMYX_APP_DEV
                DEMYX_APP_PATH
            "

            if [[ "$DEMYX_APP_DEV" = true && -f "$DEMYX_APP_PATH"/.env && -f "$DEMYX_APP_PATH"/docker-compose.yml ]]; then
                demyx_warning "$DEMYX_MOTD_WARNING_I is in development mode"
            fi
        done
    fi
}
#
#   Checks if WP apps are installed.
#
demyx_motd_wp() {
    local DEMYX_MOTD_HAS_WP=
    DEMYX_MOTD_HAS_WP="$(find "$DEMYX_WP" -mindepth 1 -maxdepth 1 -type d | wc -l)"

    if (( "$DEMYX_MOTD_HAS_WP" > 0 )); then
        echo true
    fi
}
