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
if [[ -f ~/.demyx ]]; then
    source ~/.demyx
else
    DEMYX_CHROOT_BRANCH=stable
    DEMYX_CHROOT_SSH=2222
    DEMYX_CHROOT_CPU=.50
    DEMYX_CHROOT_MEM=512m
    DEMYX_CHROOT_TZ=America/Los_Angeles
fi

DEMYX_CHROOT_HOST="$(hostname)"
DEMYX_CHROOT_MODE=production
DEMYX_CHROOT_USER=demyx
DEMYX_CHROOT_API=false
DEMYX_CHROOT=
DEMYX_CHROOT_NC=
DEMYX_CHROOT_ALL=
DEMYX_CHROOT_MODE=
DEMYX_CHROOT_SYSTEM=
DEMYX_CHROOT_SETTING=

while :; do
    case "${1:-}" in
        cmd)
            DEMYX_CHROOT=command
            shift
            break
            ;;
        help)
            DEMYX_CHROOT=help
            ;;
        rm)
            DEMYX_CHROOT=remove
            ;;
        rs|restart)
            DEMYX_CHROOT=restart
            ;;
        sh)
            DEMYX_CHROOT=shell
            shift
            break
            ;;
        update)
            DEMYX_CHROOT=update
            ;;
        -a|--all)
            DEMYX_CHROOT_ALL=1
            ;;
        --cpu=null|--cpu=?*)
            DEMYX_CHROOT_CPU="${1#*=}"
            DEMYX_CHROOT_SETTING=1
            ;;
        --cpu=)
            printf '\e[31m[CRITICAL]\e[39m "--cpu" cannot be empty\n'
            exit 1
            ;;
        -d|--dev)
            DEMYX_CHROOT_MODE=development
            ;;
        --edge)
            DEMYX_CHROOT_BRANCH=edge
            DEMYX_CHROOT_SETTING=1
            ;;
        --mem=null|--mem=?*)
            DEMYX_CHROOT_MEM="${1#*=}"
            DEMYX_CHROOT_SETTING=1
            ;;
        --mem=)
            printf '\e[31m[CRITICAL]\e[39m "--mem" cannot be empty\n'
            exit 1
            ;;
        --nc)
            DEMYX_CHROOT_NC=1
            ;;
        -p|--prod)
            DEMYX_CHROOT_MODE=production
            ;;
        -r|--root)
            DEMYX_CHROOT_USER=root
            ;;
        --ssh=?*)
            DEMYX_CHROOT_SSH="${1#*=}"
            DEMYX_CHROOT_SETTING=1
            ;;
        --ssh=)
            printf '\e[31m[CRITICAL]\e[39m "--ssh" cannot be empty\n'
            exit 1
            ;;
        --system)
            DEMYX_CHROOT_SYSTEM=1
            ;;
        --tz=?*)
            DEMYX_CHROOT_TZ="${1#*=}"
            DEMYX_CHROOT_SETTING=1
            ;;
        --tz=)
            printf '\e[31m[CRITICAL]\e[39m "--tz" cannot be empty\n'
            exit 1
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

DEMYX_CHROOT_DOCKER_PS="$(docker ps)"
DEMYX_CHROOT_DEMYX_CHECK="$(echo "$DEMYX_CHROOT_DOCKER_PS" | awk '{print $NF}' | grep -w demyx || true)"
DEMYX_CHROOT_SOCKET_CHECK="$(echo "$DEMYX_CHROOT_DOCKER_PS" | awk '{print $NF}' | grep -w demyx_socket || true)"

# Save settings to user's home directory
if [[ ! -f ~/.demyx || -n "$DEMYX_CHROOT_SETTING" ]]; then
    echo "DEMYX_CHROOT_BRANCH=$DEMYX_CHROOT_BRANCH
        DEMYX_CHROOT_SSH=$DEMYX_CHROOT_SSH
        DEMYX_CHROOT_CPU=$DEMYX_CHROOT_CPU
        DEMYX_CHROOT_MEM=$DEMYX_CHROOT_MEM
        DEMYX_CHROOT_TZ=$DEMYX_CHROOT_TZ" | sed "s|        ||" > ~/.demyx
fi

demyx_mode() {
    DEMYX_MODE_CHECK="$(docker exec -t demyx zsh -c "[[ -f /tmp/demyx-dev ]] && echo development || true")"
    if [[ -n "$DEMYX_MODE_CHECK" && "$DEMYX_CHROOT_MODE" != production ]]; then
        docker exec -t --user=root demyx demyx-dev
    else
        if [[ "$DEMYX_CHROOT_MODE" = development ]]; then
            docker exec -t --user=root demyx demyx-dev
        else
            docker exec -t demyx demyx-prod
        fi
    fi
}
demyx_chroot() {
    if [[ -z "$DEMYX_CHROOT_NC" ]]; then
        docker exec -it --user="$DEMYX_CHROOT_USER" demyx zsh
    fi
}
demyx_compose() {
    docker run -t --rm \
    --workdir=/demyx \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v demyx:/demyx \
    demyx/docker-compose "$@"
}
demyx_rm() {
    DEMYX_CHROOT_COMPOSE_UP_CHECK="$(docker inspect demyx | grep com.docker.compose)"
    DEMYX_CHROOT_COMPOSE_UP_SOCKET_CHECK="$(docker inspect demyx_socket | grep com.docker.compose)"
    if [[ -n "$DEMYX_CHROOT_COMPOSE_UP_CHECK" || -n "$DEMYX_CHROOT_COMPOSE_UP_SOCKET_CHECK" ]]; then
        if [[ -n "$DEMYX_CHROOT_ALL" ]]; then
            demyx_compose stop
            demyx_compose rm -f
        else
            demyx_compose stop demyx
            demyx_compose rm -f demyx
        fi
    else
        docker stop demyx
        docker rm -f demyx
    fi
}
demyx_run() {
    docker run -t --rm \
    --user=root \
    --entrypoint=demyx-yml \
    --workdir=/demyx \
    --network=host \
    -v demyx:/demyx \
    -e DEMYX_CPU="$DEMYX_CHROOT_CPU" \
    -e DEMYX_MEM="$DEMYX_CHROOT_MEM" \
    -e DEMYX_BRANCH="$DEMYX_CHROOT_BRANCH" \
    -e DEMYX_MODE="$DEMYX_CHROOT_MODE" \
    -e DEMYX_HOST="$DEMYX_CHROOT_HOST" \
    -e DEMYX_SSH="$DEMYX_CHROOT_SSH" \
    -e TZ="$DEMYX_CHROOT_TZ" \
    demyx/demyx

    demyx_compose up -d
}

if [[ "$DEMYX_CHROOT" = command ]]; then
    docker exec -it demyx demyx "$@"
elif [[ "$DEMYX_CHROOT" = help ]]; then
    echo
    echo "demyx <args>          Chroot into the demyx container"
    echo "      cmd             Send demyx commands from host"
    echo "      help            Demyx help"
    echo "      rm              Stops and removes demyx container"
    echo "      rs|restart      Stops, removes, and starts demyx container"
    echo "      sh              Execute root commands to demyx container from host"
    echo "      update          Update chroot.sh from GitHub"
    echo "      -a, --all       Targets both demyx and demyx_socket container"
    echo "      --cpu           Set container CPU usage, --cpu=null to remove cap"
    echo "      -d|--dev        Puts demyx container into development mode"
    echo "      --edge          Use latest code updates from git repo"
    echo "      --mem           Set container MEM usage, --mem=null to remove cap"
    echo "      --nc            Starts demyx containr but prevent chrooting into container"
    echo "      -p|--prod       Puts demyx container into production mode"
    echo "      -r, --root      Execute as root user"
    echo "      --ssh           Override ssh port"
    echo "      --system        Pulls all demyx images, updates demyx helper script, and force recreates the demyx_socket and demyx containers when using demyx update --system"
    echo "      --tz            Set timezone"
    echo
elif [[ "$DEMYX_CHROOT" = remove ]]; then
    demyx_rm
elif [[ "$DEMYX_CHROOT" = restart ]]; then
    demyx_rm
    demyx_run
    [[ "$DEMYX_CHROOT_MODE" = development ]] && sleep 5
    demyx_mode
    demyx_chroot
elif [[ "$DEMYX_CHROOT" = shell ]]; then
    docker exec -it --user="$DEMYX_CHROOT_USER" demyx "$@"
elif [[ "$DEMYX_CHROOT" = update ]]; then
    if [[ -n "$DEMYX_CHROOT_SYSTEM" ]]; then
        docker pull demyx/demyx
        docker pull demyx/docker-compose
        docker pull demyx/docker-socket-proxy
        docker pull demyx/logrotate
        docker pull demyx/mariadb
        docker pull demyx/nginx
        docker pull demyx/openlitespeed
        docker pull demyx/traefik
        docker pull demyx/utilities
        docker pull demyx/wordpress
        docker pull demyx/wordpress:cli

        demyx_compose up -d --remove-orphans --force-recreate
    fi

    docker run -t --user=root --privileged --rm -v /usr/local/bin:/usr/local/bin demyx/utilities demyx-chroot

    echo -e "\e[32m[SUCCESS]\e[39m Successfully updated"
else
    if [[ -n "$DEMYX_CHROOT_DEMYX_CHECK" ]]; then
        demyx_mode
        demyx_chroot
    else
        demyx_run
        demyx_mode
        demyx_chroot
    fi
fi
