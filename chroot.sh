#!/bin/sh
# Demyx
# https://demyx.sh
set -eu pipefail

# Set default variables
DEMYX_CHROOT=
DEMYX_CHROOT_NC=
DEMYX_CHROOT_ALL=
DEMYX_CHROOT_STACK=
DEMYX_CHROOT_HOST="$(hostname)"
DEMYX_CHROOT_BRANCH=stable
DEMYX_CHROOT_MODE=production
DEMYX_CHROOT_USER=demyx
DEMYX_CHROOT_SSH=2222
DEMYX_CHROOT_API=false
DEMYX_CHROOT_CPU=.50
DEMYX_CHROOT_MEM=512m

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
        restart)
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
            DEMYX_CHROOT_CPU=${1#*=}
            ;;
        --cpu=)
            printf '\e[31m[CRITICAL]\e[39m "--cpu" cannot be empty\n'
            exit 1
            ;;
        --dev)
            DEMYX_CHROOT_MODE=development
            ;;
        --edge)
            DEMYX_CHROOT_BRANCH=edge
            ;;
        --mem=null|--mem=?*)
            DEMYX_CHROOT_MEM=${1#*=}
            ;;
        --mem=)
            printf '\e[31m[CRITICAL]\e[39m "--mem" cannot be empty\n'
            exit 1
            ;;
        --nc)
            DEMYX_CHROOT_NC=1
            ;;
        --prod)
            DEMYX_CHROOT_MODE=production
            ;;
        -r|--root)
            DEMYX_CHROOT_USER=root
            ;;
        --ssh=?*)
            DEMYX_CHROOT_SSH=${1#*=}
            ;;
        --ssh=)
            printf '\e[31m[CRITICAL]\e[39m "--ssh" cannot be empty\n'
            exit 1
            ;;
        --stack)
            DEMYX_CHROOT_STACK=1
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

demyx_until() {
    if [ "$DEMYX_CHROOT_MODE" = development ]; then
        until docker exec -t demyx stat /demyx | grep -q 111
        do
            sleep 1
        done
    fi
}
demyx_mode() {
    if [ "$DEMYX_CHROOT_MODE" = development ]; then
        docker exec -t --user=root demyx demyx-dev
    else
        docker exec -t demyx demyx-prod
    fi
}
demyx_compose() {
    docker run -t --rm \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v demyx:/demyx \
    --workdir=/demyx \
    demyx/docker-compose "$@"
}
demyx_rm() {
    DEMYX_CHROOT_COMPOSE_UP_CHECK="$(docker inspect demyx | grep com.docker.compose)"
    DEMYX_CHROOT_COMPOSE_UP_SOCKET_CHECK="$(docker inspect demyx_socket | grep com.docker.compose)"
    if [ -n "$DEMYX_CHROOT_COMPOSE_UP_CHECK" || -n "$DEMYX_CHROOT_COMPOSE_UP_SOCKET_CHECK" ]; then
        if [ -n "$DEMYX_CHROOT_ALL" ]; then
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
    demyx/demyx

    demyx_compose up -d
    #demyx_until
}

if [ "$DEMYX_CHROOT" = command ]; then
    docker exec -it demyx demyx "$@"
elif [ "$DEMYX_CHROOT" = help ]; then
    echo
    echo "demyx <args>          Chroot into the demyx container"
    echo "      cmd             Send demyx commands from host"
    echo "      help            Demyx help"
    echo "      rm              Stops and removes demyx container"
    echo "      restart         Stops, removes, and starts demyx container"
    echo "      sh              Execute root commands to demyx container from host"
    echo "      update          Update chroot.sh from GitHub"
    echo "      -a, --all       Targets both demyx and demyx_socket container"
    echo "      --cpu           Set container CPU usage, --cpu=null to remove cap"
    echo "      --dev           Puts demyx container into development mode"
    echo "      --edge          Use latest code updates from git repo"
    echo "      --mem           Set container MEM usage, --mem=null to remove cap"
    echo "      --nc            Starts demyx containr but prevent chrooting into container"
    echo "      --prod          Puts demyx container into production mode"
    echo "      -r, --root      Execute as root user"
    echo "      --ssh           Override ssh port"
    echo "      --stack         Pulls all demyx images when running demyx update"
    echo
elif [ "$DEMYX_CHROOT" = remove ]; then
    demyx_rm
elif [ "$DEMYX_CHROOT" = restart ]; then
    demyx_rm
    demyx_run
    demyx_mode
    if [ -z "$DEMYX_CHROOT_NC" ]; then
        docker exec -it --user="$DEMYX_CHROOT_USER" demyx zsh
    fi
elif [ "$DEMYX_CHROOT" = shell ]; then
    docker exec -it --user="$DEMYX_CHROOT_USER" demyx "$@"
elif [ "$DEMYX_CHROOT" = update ]; then
    if [ -n "$DEMYX_CHROOT_STACK" ]; then
        docker pull demyx/browsersync
        docker pull demyx/code-server:wp
        docker pull demyx/demyx
        docker pull demyx/docker-compose
        docker pull demyx/docker-socket-proxy
        docker pull demyx/logrotate
        docker pull demyx/mariadb:edge
        docker pull demyx/nginx
        docker pull demyx/ouroboros
        docker pull demyx/ssh
        docker pull demyx/traefik
        docker pull demyx/utilities
        docker pull demyx/wordpress
        docker pull demyx/wordpress:cli
        docker pull phpmyadmin/phpmyadmin
    fi

    docker run -t --user=root --privileged --rm -v /usr/local/bin:/usr/local/bin demyx/utilities demyx-chroot

    echo -e "\e[32m[SUCCESS]\e[39m Successfully updated"
else
    if [ -n "$DEMYX_CHROOT_DEMYX_CHECK" ]; then
        DEMYX_MODE_CHECK="$(docker exec -t demyx zsh -c "[ -f /tmp/demyx-dev ] && echo 'development'")"
        if [ -z "$DEMYX_CHROOT_MODE" ]; then
            DEMYX_CHROOT_MODE="$DEMYX_MODE_CHECK"
        fi
        demyx_mode
        if [ -z "$DEMYX_CHROOT_NC" ]; then
            docker exec -it --user="$DEMYX_CHROOT_USER" demyx zsh
        fi
    else
        demyx_run
        if [ -z "$DEMYX_CHROOT_NC" ]; then
            docker exec -it --user="$DEMYX_CHROOT_USER" demyx zsh
        fi
    fi
fi
