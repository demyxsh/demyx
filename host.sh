#!/bin/bash
# Demyx
# https://demyx.sh
set -euo pipefail
#
#   Main.
#
demyx_host() {
    demyx_host_gatekeeper

    # Set default variables
    local DEMYX_HOST_ARG_1="${1:-}"
    local DEMYX_HOST_ARG_2="${2:-}"
    local DEMYX_HOST_ARG_3="${3:-}"
    local DEMYX_HOST_ARGS="$*"
    local DEMYX_HOST_CONFIRM=
    local DEMYX_HOST_HOSTNAME=
    DEMYX_HOST_HOSTNAME="$(hostname)"
    local DEMYX_HOST_DEMYX_PS=
    DEMYX_HOST_DEMYX_PS="$(docker ps)"
    local DEMYX_HOST_UPDATE_IMAGES=
    [[ "$DEMYX_HOST_DEMYX_PS" == *"demyx/demyx"* ]] && \
        DEMYX_HOST_UPDATE_IMAGES="$(docker exec -t --user=root demyx bash -c "[[ -f /demyx/.update_image ]] && cat /demyx/.update_image | sed 's|\r$||g' || true")"
    local DEMYX_HOST_UPDATE_IMAGES_COUNT=0

    if [[ -n "$DEMYX_HOST_UPDATE_IMAGES" ]]; then
        DEMYX_HOST_UPDATE_IMAGES_COUNT="$(echo "$DEMYX_HOST_UPDATE_IMAGES" | wc -l)"
    fi

    case "$DEMYX_HOST_ARG_1" in
        shell) shift
            demyx_host_not_running

            if [[ -z "$DEMYX_HOST_ARG_2" ]]; then
                docker exec -it --user=root demyx bash
            else
                docker exec -it --user=root demyx "$@"
            fi
        ;;
        host)
            case "$DEMYX_HOST_ARG_2" in
                ctop)
                    if docker inspect demyx_ctop >/dev/null 2>&1; then
                        docker exec -it demyx_ctop /ctop
                    else
                        docker run -it --rm \
                            --name=demyx_ctop \
                            --volume /var/run/docker.sock:/var/run/docker.sock:ro \
                            quay.io/vektorlab/ctop
                    fi
                ;;
                edit)
                    # shellcheck disable=2153
                    docker run -it --rm \
                        --user=root \
                        --entrypoint=nano \
                        -v demyx:/demyx \
                        demyx/demyx .env

                    demyx_host_remove
                    demyx_host_run
                ;;
                help)
                    demyx_host_help
                ;;
                rm|remove)
                    demyx_host_remove "$DEMYX_HOST_ARG_3"
                ;;
                rs|restart)
                    demyx_host_remove
                    demyx_host_run
                ;;
                upgrade)
                    demyx_host_not_running
                    demyx_host_upgrade
                ;;
            esac

        ;;
        *)
            if [[ "$DEMYX_HOST_DEMYX_PS" != *"demyx/demyx"* ]]; then
                demyx_host_run
                demyx_host_exec "$@"
            else
                demyx_host_exec "$@"
            fi
        ;;
    esac

    demyx_host_motd
    demyx_host_update
    demyx_host_error
}
#
#   Checks if database needs upgrading.
#
demyx_host_app_upgrade() {
    local DEMYX_HOST_APP_UPGRADE_I=
    local DEMYX_HOST_APP_UPGRADE_LIST=
    DEMYX_HOST_APP_UPGRADE_LIST="$(demyx_host_exec info apps -r | sed 's/\r//g')"

    if [[ "$DEMYX_HOST_UPDATE_IMAGES" == *"mariadb"* ]]; then
        for DEMYX_HOST_APP_UPGRADE_I in $DEMYX_HOST_APP_UPGRADE_LIST; do
            demyx_host_exec backup "$DEMYX_HOST_APP_UPGRADE_I"
            demyx_host_exec backup "$DEMYX_HOST_APP_UPGRADE_I" -d
            demyx_host_exec restore "$DEMYX_HOST_APP_UPGRADE_I" -d -f
            demyx_host_exec refresh "$DEMYX_HOST_APP_UPGRADE_I" -nfr
        done
    fi
}
#
#   Run demyx container to execute docker-compose.
#
demyx_host_compose() {
    docker run -it --rm \
        --entrypoint=docker-compose \
        -v /var/run/docker.sock:/var/run/docker.sock:ro \
        -v demyx:/demyx \
        -e DOCKER_HOST= \
        demyx/docker-compose "$@"
}
#
#   Removes specific dangling images.
#
demyx_host_dangling_images() {
    local DEMYX_HOST_DANGLING_IMAGES=
    local DEMYX_HOST_DANGLING_IMAGES_CHECK_CTOP=
    local DEMYX_HOST_DANGLING_IMAGES_CHECK_PMA=
    local DEMYX_HOST_DANGLING_IMAGES_I=
    DEMYX_HOST_DANGLING_IMAGES="$(docker images "demyx/*" --filter=dangling=true -q)"

    if [[ -n "$DEMYX_HOST_DANGLING_IMAGES" ]]; then
        echo "$DEMYX_HOST_DANGLING_IMAGES" | xargs docker rmi || true
    fi

    # Remove third party dangling images
    DEMYX_HOST_DANGLING_IMAGES="$(docker images --filter=dangling=true -q)"
    for DEMYX_HOST_DANGLING_IMAGES_I in $DEMYX_HOST_DANGLING_IMAGES; do
        DEMYX_HOST_DANGLING_IMAGES_CHECK_CTOP="$(docker inspect "$DEMYX_HOST_DANGLING_IMAGES_I" | grep ctop || true)"
        DEMYX_HOST_DANGLING_IMAGES_CHECK_PMA="$(docker inspect "$DEMYX_HOST_DANGLING_IMAGES_I" | grep phpmyadmin || true)"

        if [[ -n "$DEMYX_HOST_DANGLING_IMAGES_CHECK_CTOP" ||
                -n "$DEMYX_HOST_DANGLING_IMAGES_CHECK_PMA" ]]; then
            docker image rm "$DEMYX_HOST_DANGLING_IMAGES_I" || true
        fi
    done
}
#
#   Warns users for new error log entries.
#
demyx_host_error() {
    local DEMYX_HOST_ERROR=
    DEMYX_HOST_ERROR="$(docker exec -t --user=root demyx bash -c "[[ -f /demyx/tmp/demyx_log_error ]] && echo true" || true)"
    # shellcheck disable=2001
    DEMYX_HOST_ERROR="$(echo "$DEMYX_HOST_ERROR" | sed 's|\r$||g')"

    if [[ "$DEMYX_HOST_ERROR" = true ]]; then
        echo -e "\e[31m[ERROR]\e[39m New error(s): please run: demyx log main -e"
        docker exec -t --user=root demyx bash -c "rm -f /demyx/tmp/demyx_log_error"
    fi
}
#
#   Send commands to demyx container.
#
demyx_host_exec() {
    local DEMYX_HOST_EXEC="${1:-}"

    if [[ -n "$DEMYX_HOST_EXEC" ]]; then
        docker exec -it demyx demyx "$@"
    else
        docker exec -t -e DEMYX_STTY="$(stty size | awk -F ' ' '{print $2}')" demyx demyx motd
    fi
}
#
#   Checks for proper permissions.
#
demyx_host_gatekeeper() {
    local DEMYX_HOST_CHECK_ID=
    DEMYX_HOST_CHECK_ID="$(id | grep docker || true)"

    # Check if user is in docker group first
    if [[ -z "$DEMYX_HOST_CHECK_ID" ]]; then
        # Fallback check for root/sudo
        if [[ "$(id -u)" != 0 ]]; then
            echo -e "\e[31m[ERROR]\e[39m Must be ran as root/sudo or add user to the docker group"
            exit 1
        fi
    fi
}

    if [[ -n "${DEMYX_HOST_INSTALL_IP:-}" || "$DEMYX_HOST_IP" != false ]]; then
        echo -e "\n\e[34m[INFO]\e[39m Enable Traefik dashboard? true/false (IP whitelist and basic auth protected)"
        read -rep "(Default: false): " DEMYX_HOST_INSTALL_TRAEFIK_DASHBOARD
        sed -i "s|DEMYX_HOST_TRAEFIK_DASHBOARD=.*|DEMYX_HOST_TRAEFIK_DASHBOARD=${DEMYX_HOST_INSTALL_TRAEFIK_DASHBOARD:-false}|g" "$DEMYX_HOST_CONFIG"

        if [[ "$DEMYX_HOST_INSTALL_TRAEFIK_DASHBOARD" = true ]]; then
            echo -e "\n\e[34m[INFO]\e[39m Enter subdomain for Traefik dashboard, please do not add the .${DEMYX_HOST_INSTALL_DOMAIN} part"
            read -rep "(Default: traefik): " DEMYX_HOST_INSTALL_TRAEFIK_DASHBOARD_DOMAIN
            sed -i "s|DEMYX_HOST_TRAEFIK_DASHBOARD_DOMAIN=.*|DEMYX_HOST_TRAEFIK_DASHBOARD_DOMAIN=${DEMYX_HOST_INSTALL_TRAEFIK_DASHBOARD_DOMAIN:-traefik}|g" "$DEMYX_HOST_CONFIG"
        fi

        echo -e "\n\e[34m[INFO]\e[39m Enable code-server as the demyx file browser? true/false (IP whitelist protected)"
        read -rep "(Default: false): " DEMYX_HOST_INSTALL_CODE
        sed -i "s|DEMYX_HOST_CODE=.*|DEMYX_HOST_CODE=${DEMYX_HOST_INSTALL_CODE:-false}|g" "$DEMYX_HOST_CONFIG"

        if [[ "$DEMYX_HOST_INSTALL_CODE" = true ]]; then
            echo -e "\n\e[34m[INFO]\e[39m Enter subdomain for code-server, please do not add the .${DEMYX_HOST_INSTALL_DOMAIN} part"
            read -rep "(Default: code): " DEMYX_HOST_INSTALL_CODE_DOMAIN
            sed -i "s|DEMYX_HOST_CODE_DOMAIN=.*|DEMYX_HOST_CODE_DOMAIN=${DEMYX_HOST_INSTALL_CODE_DOMAIN:-code}|g" "$DEMYX_HOST_CONFIG"
        fi
    fi

    echo -e "\n\e[34m[INFO]\e[39m Enter your local timezone"
    read -rep "(Default: America/Los_Angeles): " DEMYX_HOST_INSTALL_TZ
    sed -i "s|DEMYX_HOST_TZ=.*|DEMYX_HOST_TZ=${DEMYX_HOST_INSTALL_TZ:-America/Los_Angeles}|g" "$DEMYX_HOST_CONFIG"

    echo -e "\n\e[34m[INFO]\e[39m Enter true or false to enable/disable telemetry"
    read -rep "(Default: true): " DEMYX_HOST_INSTALL_TELEMETRY
    sed -i "s|DEMYX_HOST_TELEMETRY=.*|DEMYX_HOST_TELEMETRY=${DEMYX_HOST_INSTALL_TELEMETRY:-true}|g" "$DEMYX_HOST_CONFIG"

    # Set install to false
    sed -i "s|DEMYX_HOST_INSTALL=.*|DEMYX_HOST_INSTALL=false|g" "$DEMYX_HOST_CONFIG"

    # Update source config for the last time
    demyx_config

    echo -e "\n\e[34m[INFO]\e[39m Demyx config has been updated! To see or edit more demyx config, run: demyx host config"
    echo -e "\n\e[34m[INFO]\e[39m Basic auth username: $DEMYX_HOST_AUTH_USERNAME"
    echo -e "\e[34m[INFO]\e[39m Basic auth password: $DEMYX_HOST_AUTH_PASSWORD"
    [[ "$DEMYX_HOST_TRAEFIK_DASHBOARD" = true ]] && echo -e "\e[34m[INFO]\e[39m Traefik dashboard: https://${DEMYX_HOST_TRAEFIK_DASHBOARD_DOMAIN}.${DEMYX_HOST_DOMAIN}"
    [[ "$DEMYX_HOST_CODE" = true ]] && echo -e "\e[34m[INFO]\e[39m code-server: https://${DEMYX_HOST_CODE_DOMAIN}.${DEMYX_HOST_DOMAIN}"
    [[ "$DEMYX_HOST_CODE" = true ]] && echo -e "\e[34m[INFO]\e[39m code-server password: $DEMYX_HOST_CODE_PASSWORD"

    # Restart demyx container to accept new changes
    demyx_run
}
demyx_rm() {
    if [[ "${1:-}" = all ]]; then
        demyx_compose stop
        demyx_compose rm -f
    else
        docker stop demyx
        docker rm demyx
    fi
}
demyx_run() {
    docker run -t --rm \
    --hostname="$DEMYX_HOST_HOSTNAME" \
    --user=root \
    --entrypoint=demyx-yml \
    --workdir=/demyx \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v demyx:/demyx \
    -e DEMYX_API="$DEMYX_HOST_API" \
    -e DEMYX_AUTH_USERNAME="$DEMYX_HOST_AUTH_USERNAME" \
    -e DEMYX_AUTH_PASSWORD="$DEMYX_HOST_AUTH_PASSWORD" \
    -e DEMYX_BACKUP_ENABLE="$DEMYX_HOST_BACKUP" \
    -e DEMYX_BACKUP_LIMIT="$DEMYX_HOST_BACKUP_LIMIT" \
    -e DEMYX_CODE_DOMAIN="$DEMYX_HOST_CODE_DOMAIN" \
    -e DEMYX_CODE_ENABLE="$DEMYX_HOST_CODE" \
    -e DEMYX_CODE_PASSWORD="$DEMYX_HOST_CODE_PASSWORD" \
    -e DEMYX_CF_KEY="$DEMYX_HOST_CF_KEY" \
    -e DEMYX_CPU="$DEMYX_HOST_CPU" \
    -e DEMYX_DOMAIN="$DEMYX_HOST_DOMAIN" \
    -e DEMYX_EMAIL="$DEMYX_HOST_EMAIL" \
    -e DEMYX_HEALTHCHECK_ENABLE="$DEMYX_HOST_HEALTHCHECK" \
    -e DEMYX_HEALTHCHECK_TIMEOUT="$DEMYX_HOST_HEALTHCHECK_TIMEOUT" \
    -e DEMYX_HOSTNAME="$DEMYX_HOST_HOSTNAME" \
    -e DEMYX_IMAGE_VERSION="$DEMYX_HOST_IMAGE_VERSION" \
    -e DEMYX_IP="$DEMYX_HOST_IP" \
    -e DEMYX_MEM="$DEMYX_HOST_MEM" \
    -e DEMYX_MONITOR_ENABLE="$DEMYX_HOST_MONITOR" \
    -e DEMYX_SERVER_IP="$DEMYX_HOST_SERVER_IP" \
    -e DEMYX_TELEMETRY="$DEMYX_HOST_TELEMETRY" \
    -e DEMYX_TRAEFIK_DASHBOARD="$DEMYX_HOST_TRAEFIK_DASHBOARD" \
    -e DEMYX_TRAEFIK_DASHBOARD_DOMAIN="$DEMYX_HOST_TRAEFIK_DASHBOARD_DOMAIN" \
    -e DEMYX_TRAEFIK_LOG="$DEMYX_HOST_TRAEFIK_LOG" \
    -e DOCKER_HOST="" \
    -e TZ="$DEMYX_HOST_TZ" \
    demyx/demyx

    demyx_compose up -d
}
demyx_update() {
    if [[ -n "$DEMYX_HOST_IMAGES" ]]; then
        echo -e "\e[32m[UPDATE]\e[39m $DEMYX_HOST_IMAGES_COUNT update(s) available!"
        echo -e "\e[32m[UPDATE]\e[39m View update(s): demyx update show"
        echo -e "\e[32m[UPDATE]\e[39m Start upgrade: demyx host upgrade"
    fi
}

# Generate or source config
demyx_config

# Prompt install if true
[[ "$DEMYX_HOST_INSTALL" = true ]] && demyx_install

if [[ "$DEMYX_HOST" = shell ]]; then
    shift 1
    if [[ -z "${1:-}" ]]; then
        docker exec -it --user=root demyx bash
    else
        docker exec -it --user=root demyx "$@"
    fi
elif [[ "$DEMYX_HOST" = host ]]; then
    if [[ "$DEMYX_HOST_COMMAND" = edit ]]; then
        # Check for default editor first
        if [[ -n "${EDITOR:-}" ]]; then
            "$EDITOR" "$DEMYX_HOST_CONFIG"
        elif [[ -f "$(which nano)" ]]; then
            nano "$DEMYX_HOST_CONFIG"
        elif [[ -f "$(which vi)" ]]; then
            vi "$DEMYX_HOST_CONFIG"
        else
            echo -en "\e[33m[WARNING]\e[39m No suitable text editors found, using demyx default ..."

            docker run -it --rm \
                --user=root \
                --entrypoint=nano \
                -v "$DEMYX_HOST_CONFIG":/tmp/.demyx \
                demyx/demyx /tmp/.demyx
        fi
    elif [[ "$DEMYX_HOST_COMMAND" = help ]]; then
        demyx_help
    elif [[ "$DEMYX_HOST_COMMAND" = install ]]; then
        demyx_install
    elif [[ "$DEMYX_HOST_COMMAND" = remove || "$DEMYX_HOST_COMMAND" = rm ]]; then
        demyx_rm "${3:-}"
    elif [[ "$DEMYX_HOST_COMMAND" = restart || "$DEMYX_HOST_COMMAND" = rs ]]; then
        if [[ -n "$DEMYX_HOST_DEMYX_CHECK" ]]; then
            demyx_rm "${3:-}"
            demyx_run
        else
            demyx_run
        fi
        demyx_exec motd
    elif [[ "$DEMYX_HOST_COMMAND" = update ]]; then
        docker exec -t demyx demyx list update
    elif [[ "$DEMYX_HOST_COMMAND" = upgrade ]]; then
        # Exit if no updates are available
        [[ -z "$DEMYX_HOST_IMAGES" ]] && echo "No updates available." && exit

        echo -en "\e[33m"
        read -rep "[WARNING] Depending on the update, services may temporarily disrupt. Continue? [yY]: " DEMYX_HOST_CONFIRM
        echo -en "\e[39m"

        [[ "$DEMYX_HOST_CONFIRM" != [yY] ]] && echo 'Update cancelled!' && exit 1

        DEMYX_HOST_IMAGE_WP_UPDATE=

        for i in $DEMYX_HOST_IMAGES
        do
            # Pull relevant tags
            if [[ "$i" = code-server ]]; then
                docker pull demyx/code-server:browse
                [[ -n "$(docker images demyx/code-server:bedrock -q)" ]] && docker pull demyx/code-server:bedrock
                [[ -n "$(docker images demyx/code-server:openlitespeed -q)" ]] && docker pull demyx/code-server:openlitespeed
                [[ -n "$(docker images demyx/code-server:openlitespeed-bedrock -q)" ]] &&  docker pull demyx/code-server:openlitespeed-bedrock
                [[ -n "$(docker images demyx/code-server:wp -q)" ]] && docker pull demyx/code-server:wp
            else
                docker pull demyx/"$i"
            fi

            [[ "$i" = wordpress && -n "$(docker images demyx/wordpress:bedrock -q)" ]] && docker pull demyx/wordpress:bedrock

            # Set variable to true if there's an update for the following images: mariadb, nginx, and wordpress/wordpress:bedrock
            [[ "$i" = mariadb || "$i" = nginx || "$i" = wordpress ]] && DEMYX_HOST_IMAGE_WP_UPDATE=true
        done

        demyx_compose up -d --remove-orphans

        # Force update cache
        demyx_exec update

        # Update WordPress services if true
        [[ "$DEMYX_HOST_IMAGE_WP_UPDATE" = true ]] && docker exec demyx demyx compose all --check-db up -d

        # Empty out this variable to suppress update message
        DEMYX_HOST_IMAGES=

        echo -e "\e[32m[SUCCESS]\e[39m Successfully updated!"

        demyx_exec motd
    else
        demyx_help
    fi
else
    if [[ -z "$DEMYX_HOST_DEMYX_CHECK" ]]; then
        demyx_run
        demyx_exec "$@"
    else
        demyx_exec "$@"
    fi
fi

demyx_update
