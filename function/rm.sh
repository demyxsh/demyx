# Demyx
# https://demyx.sh
# shellcheck shell=bash

#
#   demyx rm <app> <args>
#
demyx_rm() {
    demyx_event
    DEMYX_ARG_2="${1:-$DEMYX_ARG_2}"
    local DEMYX_RM_FLAG=
    local DEMYX_RM_FLAG_FORCE=

    demyx_source "
        config
        compose
    "

    while :; do
        DEMYX_RM_FLAG="${2:-}"
        case "$DEMYX_RM_FLAG" in
            -f)
                DEMYX_RM_FLAG_FORCE=true
                ;;
            --)
                shift
                break
                ;;
            -?*)
                demyx_error flag "$DEMYX_RM_FLAG"
                ;;
            *)
                break
        esac
        shift
    done

    case "$DEMYX_ARG_2" in
        all)
            demyx_rm_all
        ;;
        *)
            if [[ -n "$DEMYX_ARG_2" ]]; then
                demyx_rm_app
            else
                demyx_help rm
            fi
        ;;
    esac
}
#
#   Loop for demyx_rm_app.
#
demyx_rm_all() {
    demyx_event
    local DEMYX_RM_ALL=
    local DEMYX_RM_ALL_APP_CONFIRM=
    local DEMYX_RM_ALL_HTML=
    local DEMYX_RM_ALL_PHP=
    local DEMYX_RM_ALL_WP=

    if [[ -z "$DEMYX_RM_FLAG_FORCE" ]]; then
        echo -en "\e[33m"
        read -rep "[WARNING] Delete all demyx apps? [yY]: " DEMYX_RM_ALL_APP_CONFIRM
        echo -en "\e[39m"
        [[ "$DEMYX_RM_ALL_APP_CONFIRM" != [yY] ]] && demyx_error cancel
    fi

    DEMYX_RM_ALL_HTML="$(ls -A "$DEMYX_HTML")"
    if [[ -n "$DEMYX_RM_ALL_HTML" ]]; then
        cd "$DEMYX_HTML" || exit

        for DEMYX_RM_ALL in *; do
            if [[   -f "$DEMYX_HTML"/"$DEMYX_RM_ALL"/.env &&
                    -f "$DEMYX_HTML"/"$DEMYX_RM_ALL"/compose.yml ]]; then
                demyx_echo "Removing $DEMYX_RM_ALL"
                eval demyx_rm "$DEMYX_RM_ALL" -f
            fi
        done
    else
        demyx_warning "No apps found in $DEMYX_HTML, skipping ..."
    fi

    DEMYX_RM_ALL_PHP="$(ls -A "$DEMYX_PHP")"
    if [[ -n "$DEMYX_RM_ALL_PHP" ]]; then
        cd "$DEMYX_PHP" || exit

        for DEMYX_RM_ALL in *; do
            if [[   -f "$DEMYX_PHP"/"$DEMYX_RM_ALL"/.env &&
                    -f "$DEMYX_PHP"/"$DEMYX_RM_ALL"/compose.yml ]]; then
                demyx_echo "Removing $DEMYX_RM_ALL"
                eval demyx_rm "$DEMYX_RM_ALL" -f
            fi
        done
    else
        demyx_warning "No apps found in $DEMYX_PHP, skipping ..."
    fi

    DEMYX_RM_ALL_WP="$(ls -A "$DEMYX_WP")"
    if [[ -n "$DEMYX_RM_ALL_WP" ]]; then
        cd "$DEMYX_WP" || exit

        for DEMYX_RM_ALL in *; do
            if [[   -f "$DEMYX_WP"/"$DEMYX_RM_ALL"/.env &&
                    -f "$DEMYX_WP"/"$DEMYX_RM_ALL"/compose.yml ]]; then
                demyx_echo "Removing $DEMYX_RM_ALL"
                eval demyx_rm "$DEMYX_RM_ALL" -f
            fi
        done
    else
        demyx_warning "No apps found in $DEMYX_WP, skipping ..."
    fi
}
#
#   Main rm function.
#
demyx_rm_app() {
    demyx_event
    local DEMYX_RM_APP_CONFIRM=
    local DEMYX_RM_APP_PATH=
    DEMYX_RM_APP_PATH="$(demyx_app_path "$DEMYX_ARG_2")"
    local DEMYX_RM_APP_STRAGGLER=
    local DEMYX_RM_APP_STRAGGLERS=
    local DEMYX_RM_APP_VOLUME=
    local DEMYX_RM_APP_VOLUMES=

    demyx_arg_valid
    demyx_app_env wp "
        DEMYX_APP_DOMAIN
        DEMYX_APP_ID
        DEMYX_APP_PATH
        DEMYX_APP_PREFIX
    "

    if [[ -d "$DEMYX_APP_PATH" && -z "$DEMYX_RM_FLAG_FORCE" ]]; then
        echo -en "\e[33m"
        read -rep "[WARNING] Delete $DEMYX_ARG_2? [yY]: " DEMYX_RM_APP_CONFIRM
        echo -en "\e[39m"

        if [[ "$DEMYX_RM_APP_CONFIRM" != [yY] ]]; then
            if [[ -d "$DEMYX_TMP"/"$DEMYX_APP_DOMAIN" ]]; then
                demyx_execute "Cleaning up" \
                    "rm -rf ${DEMYX_TMP}/${DEMYX_APP_DOMAIN}"
            fi

            demyx_error cancel
        fi
    fi

    demyx_config "$DEMYX_APP_DOMAIN" --healthcheck=false
    demyx_compose "$DEMYX_APP_DOMAIN" kill
    demyx_compose "$DEMYX_APP_DOMAIN" rm -f

    DEMYX_RM_APP_STRAGGLERS="$(docker ps -q --filter="name=^${DEMYX_APP_PREFIX}")"
    if [[ -n "$DEMYX_RM_APP_STRAGGLERS" ]]; then
        for DEMYX_RM_APP_STRAGGLER in $DEMYX_RM_APP_STRAGGLERS; do
            demyx_execute "Killing $DEMYX_RM_APP_STRAGGLER" \
                "docker kill $DEMYX_RM_APP_STRAGGLER"
        done
    fi

    DEMYX_RM_APP_VOLUMES="$(docker volume ls -q --filter="name=^${DEMYX_APP_PREFIX}")"
    for DEMYX_RM_APP_VOLUME in $DEMYX_RM_APP_VOLUMES; do
        demyx_execute "Deleting $DEMYX_RM_APP_VOLUME" \
            "docker volume rm $DEMYX_RM_APP_VOLUME"
    done

    demyx_execute "Deleting $DEMYX_ARG_2" \
        "rm -rf $DEMYX_RM_APP_PATH"
}
