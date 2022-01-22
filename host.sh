#!/bin/bash
# Demyx
# https://demyx.sh
set -euo pipefail

# Check if user is in docker group first
if [[ -z "$(id | grep docker)" ]]; then
    # Fallback check for root/sudo
    if [[ "$(id -u)" != 0 ]]; then
        echo -e "\e[31m[CRITICAL]\e[39m Must be ran as root/sudo or add user to the docker group"
        exit 1
    fi
fi

# Set default variables
DEMYX_HOST="${1:-}"
DEMYX_HOST_COMMAND="${2:-}"
DEMYX_HOST_CONFIG="$HOME"/.demyx
DEMYX_HOST_DOCKER_PS="$(docker ps)"
DEMYX_HOST_DEMYX_CHECK="$(echo "$DEMYX_HOST_DOCKER_PS" | grep demyx-init | grep Up || true)"
#DEMYX_HOST_SOCKET_CHECK="$(echo "$DEMYX_HOST_DOCKER_PS" | awk '{print $NF}' | grep -w demyx_socket || true)"

# Update check
if [[ -n "$DEMYX_HOST_DEMYX_CHECK" ]]; then
    DEMYX_HOST_IMAGES="$(docker exec -t --user=root demyx bash -c "[[ -f /demyx/.update_image ]] && cat /demyx/.update_image || true" | sed 's/\r//g')"
    DEMYX_HOST_IMAGES_COUNT="$(echo "$DEMYX_HOST_IMAGES" | wc -l)"
else
    DEMYX_HOST_IMAGES=
    DEMYX_HOST_IMAGES_COUNT=
fi

demyx_exec() {
    if [[ -n "${DEMYX_HOST:-}" ]]; then
        docker exec -it demyx demyx "$@"
    else
        docker exec demyx demyx motd
    fi
}
demyx_compose() {
    docker run -t --rm \
    --workdir=/demyx \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v demyx:/demyx \
    demyx/docker-compose "$@"
}
demyx_config() {
    [[ -f "$DEMYX_HOST_CONFIG" ]] && source "$DEMYX_HOST_CONFIG"
    echo "DEMYX_HOST_API=${DEMYX_HOST_API:-false}
        DEMYX_HOST_AUTH_USERNAME=${DEMYX_HOST_AUTH_USERNAME:-demyx}
        DEMYX_HOST_AUTH_PASSWORD=${DEMYX_HOST_AUTH_PASSWORD:-$(docker run -t --rm demyx/utilities head /dev/urandom | tr -dc a-z0-9 | head -c 10 && echo)}
        DEMYX_HOST_BACKUP=${DEMYX_HOST_BACKUP:-true}
        DEMYX_HOST_BACKUP_LIMIT=${DEMYX_HOST_BACKUP_LIMIT:-30}
        DEMYX_HOST_CODE=${DEMYX_HOST_CODE:-false}
        DEMYX_HOST_CODE_DOMAIN=${DEMYX_HOST_CODE_DOMAIN:-code}
        DEMYX_HOST_CODE_PASSWORD=${DEMYX_HOST_CODE_PASSWORD:-$(docker run -t --rm demyx/utilities head /dev/urandom | tr -dc a-z0-9 | head -c 10 && echo)}
        DEMYX_HOST_CF_KEY=${DEMYX_HOST_CF_KEY:-false}
        DEMYX_HOST_CPU=${DEMYX_HOST_CPU:-.50}
        DEMYX_HOST_DOMAIN=${DEMYX_HOST_DOMAIN:-domain.tld}
        DEMYX_HOST_EMAIL=${DEMYX_HOST_EMAIL:-info@domain.tld}
        DEMYX_HOST_IMAGE_VERSION=${DEMYX_HOST_IMAGE_VERSION:-latest}
        DEMYX_HOST_INSTALL=${DEMYX_HOST_INSTALL:-true}
        DEMYX_HOST_IP=${DEMYX_HOST_IP:-false}
        DEMYX_HOST_HEALTHCHECK=${DEMYX_HOST_HEALTHCHECK:-true}
        DEMYX_HOST_HEALTHCHECK_TIMEOUT=${DEMYX_HOST_HEALTHCHECK_TIMEOUT:-30}
        DEMYX_HOST_HOSTNAME=${DEMYX_HOST_HOSTNAME:-$(hostname)}
        DEMYX_HOST_MEM=${DEMYX_HOST_MEM:-512m}
        DEMYX_HOST_MONITOR=${DEMYX_HOST_MONITOR:-true}
        DEMYX_HOST_SERVER_IP=${DEMYX_HOST_SERVER_IP:-$(docker run -t --rm --user=root --entrypoint=curl demyx/demyx -s https://ipecho.net/plain)}
        DEMYX_HOST_TELEMETRY=${DEMYX_HOST_TELEMETRY:-true}
        DEMYX_HOST_TRAEFIK_DASHBOARD=${DEMYX_HOST_TRAEFIK_DASHBOARD:-false}
        DEMYX_HOST_TRAEFIK_DASHBOARD_DOMAIN=${DEMYX_HOST_TRAEFIK_DASHBOARD_DOMAIN:-traefik}
        DEMYX_HOST_TRAEFIK_LOG=${DEMYX_HOST_TRAEFIK_LOG:-INFO}
        DEMYX_HOST_TZ=${DEMYX_HOST_TZ:-America/Los_Angeles}" | sed "s|        ||g" > "$DEMYX_HOST_CONFIG"

        # Source again to prevent unbound variable
        source "$DEMYX_HOST_CONFIG"
}
demyx_help() {
    echo
    echo "demyx host <args>          Demyx helper commands"
    echo "           all             Targets both demyx and demyx_socket container, works with remove and restart"
    echo "           config           Edit Demyx config on the host (~/.demyx)"
    echo "           help            Demyx helper help menu"
    echo "           install         Prompt users to enter details for ~/.demyx"
    echo "           remove|rm       Stops and removes demyx container"
    echo "           restart|rs      Stops, removes, and starts demyx container"
    echo "           update          List available updates"
    echo "           upgrade         Upgrade the demyx stack"
    echo
}
demyx_install() {
    # Execute migrate script
    docker run -t --rm \
    --user=root \
    --entrypoint=bash \
    -v "$HOME":/tmp \
    -v demyx:/demyx \
    demyx/demyx /etc/demyx/bin/demyx-migrate.sh

    # Source udpated configs
    demyx_config

    # Begin prompts
    if [[ "$DEMYX_HOST_DOMAIN" = domain.tld ]]; then
        echo -e "\n\e[34m[INFO]\e[39m Enter a valid main domain"
        read -rep "(Default: domain.tld): " DEMYX_HOST_INSTALL_DOMAIN
        sed -i "s|DEMYX_HOST_DOMAIN=.*|DEMYX_HOST_DOMAIN=${DEMYX_HOST_INSTALL_DOMAIN:-domain.tld}|g" "$DEMYX_HOST_CONFIG"
    else
        DEMYX_HOST_INSTALL_DOMAIN="$DEMYX_HOST_EMAIL"
    fi

    if [[ "$DEMYX_HOST_EMAIL" = info@domain.tld ]]; then
        echo -e "\n\e[34m[INFO]\e[39m Enter a valid email address for Lets Encrypt"
        read -rep "(Default: info@domain.tld): " DEMYX_HOST_INSTALL_EMAIL
        sed -i "s|DEMYX_HOST_EMAIL=.*|DEMYX_HOST_EMAIL=${DEMYX_HOST_INSTALL_EMAIL:-info@domain.tld}|g" "$DEMYX_HOST_CONFIG"
    fi

    if [[ "$DEMYX_HOST_AUTH_USERNAME" = demyx ]]; then
        echo -e "\n\e[34m[INFO]\e[39m Enter a username for basic auth"
        read -rep "(Default: demyx): " DEMYX_HOST_INSTALL_AUTH_USERNAME
        sed -i "s|DEMYX_HOST_AUTH_USERNAME=.*|DEMYX_HOST_AUTH_USERNAME=${DEMYX_HOST_INSTALL_AUTH_USERNAME:-demyx}|g" "$DEMYX_HOST_CONFIG"
    fi

    if [[ "$DEMYX_HOST_IP" = false ]]; then
        echo -e "\n\e[34m[INFO]\e[39m Enter IP address for whitelisting or else you won't be able to access code-server, traefik dashboard, and other URLs"
        echo -e "\e[34m[INFO]\e[39m For multiple IP addresses, please use commas to separate them"
        read -rep "(Default: false): " DEMYX_HOST_INSTALL_IP
        sed -i "s|DEMYX_HOST_IP=.*|DEMYX_HOST_IP=${DEMYX_HOST_INSTALL_IP:-false}|g" "$DEMYX_HOST_CONFIG"
    fi

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
