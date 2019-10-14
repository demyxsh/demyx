#!/bin/bash
# Demyx
# https://demyx.sh
# 

DEMYX_CHROOT_CONTAINER_CHECK=$(docker ps -a | awk '{print $NF}' | grep -w demyx)
DEMYX_CHROOT_HOST=$(hostname)
DEMYX_CHROOT_SSH=2222
DEMYX_CHROOT_API=false

while :; do
    case "$1" in
        exec)
            DEMYX_CHROOT=execute
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
        tty)
            DEMYX_CHROOT=tty
            shift
            break
            ;;
        update)
            DEMYX_CHROOT=update
            ;;
        --api)
            DEMYX_CHROOT_API=true
            ;;
        --dev)
            DEMYX_CHROOT_MODE=development
            ;;
        --nc)
            DEMYX_CHROOT_NC=1
            ;;
        --prod)
            DEMYX_CHROOT_MODE=production
            ;;
        --ssh=?*)
            DEMYX_CHROOT_SSH=${1#*=}
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
demyx_mode() {
    docker exec -t demyx demyx-helper "$DEMYX_CHROOT_MODE"
}
demyx_rm() {
    if [[ -n "$DEMYX_CHROOT_CONTAINER_CHECK" ]]; then
        docker stop demyx
        docker rm -f demyx
    fi
}
demyx_run() {
    while true; do
    DEMYX_SFTP_OPEN_PORT=$(netstat -tuplen 2>/dev/null | grep :"$DEMYX_CHROOT_SSH" || true)
        if [[ -z "$DEMYX_SFTP_OPEN_PORT" ]]; then
            break
        else
            DEMYX_CHROOT_SSH=$((DEMYX_CHROOT_SSH+1))
        fi
    done

    IFS=$'\r\n' GLOBIGNORE='*' command eval 'DEMYX_CHROOT_API_GET_ENV=($(docker run --rm --name demyx_tmp -v demyx:/demyx demyx/utilities "cat /demyx/app/stack/.env | sed 1d"))'
    DEMYX_CHROOT_API_DOMAIN="$(echo ${DEMYX_CHROOT_API_GET_ENV[3]} | awk -F '[=]' '{print $2}')"
    DEMYX_CHROOT_API_AUTH="$(echo ${DEMYX_CHROOT_API_GET_ENV[4]} | awk -F '[=]' '{print $2}')"

    if [[ "$DEMYX_CHROOT_API" = true ]]; then
        docker run -dit \
        --name demyx \
        --restart unless-stopped \
        --hostname "$DEMYX_CHROOT_HOST" \
        --network demyx \
        -e DEMYX_MODE="$DEMYX_CHROOT_MODE" \
        -e DEMYX_HOST="$DEMYX_CHROOT_HOST" \
        -e DEMYX_SSH="$DEMYX_CHROOT_SSH" \
        -e DEMYX_API="$DEMYX_CHROOT_API" \
        -e TZ=America/Los_Angeles \
        -v /var/run/docker.sock:/var/run/docker.sock:ro \
        -v demyx:/demyx \
        -v demyx_user:/home/demyx \
        -v demyx_log:/var/log/demyx \
        -p "$DEMYX_CHROOT_SSH":22 \
        -l "traefik.enable=true" \
        -l "traefik.http.routers.demyx.rule=Host(\`api.${DEMYX_CHROOT_API_DOMAIN}\`)" \
        -l "traefik.http.routers.demyx.entrypoints=https" \
        -l "traefik.http.routers.demyx.tls.certresolver=demyx" \
        -l "traefik.http.routers.demyx.service=demyx" \
        -l "traefik.http.services.demyx.loadbalancer.server.port=8080" \
        -l "traefik.http.routers.demyx.middlewares=demyx-auth" \
        -l "traefik.http.middlewares.demyx-auth.basicauth.users=${DEMYX_CHROOT_API_AUTH}" \
        demyx/demyx
    else
        docker run -dit \
        --name demyx \
        --restart unless-stopped \
        --hostname "$DEMYX_CHROOT_HOST" \
        --network demyx \
        -e DEMYX_MODE="$DEMYX_CHROOT_MODE" \
        -e DEMYX_HOST="$DEMYX_CHROOT_HOST" \
        -e DEMYX_SSH="$DEMYX_CHROOT_SSH" \
        -e DEMYX_API="$DEMYX_CHROOT_API" \
        -e TZ=America/Los_Angeles \
        -v /var/run/docker.sock:/var/run/docker.sock:ro \
        -v demyx:/demyx \
        -v demyx_user:/home/demyx \
        -v demyx_log:/var/log/demyx \
        -p "$DEMYX_CHROOT_SSH":22 \
        demyx/demyx
    fi
}

if [[ "$DEMYX_CHROOT" = execute ]]; then
    docker exec -t demyx demyx "$@"
elif [[ "$DEMYX_CHROOT" = help ]]; then
    echo
    echo "demyx <args>          Chroot into the demyx container"
    echo "      exec            Send demyx commands from host"
    echo "      help            Demyx help"
    echo "      rm              Stops and removes demyx container"
    echo "      restart         Stops, removes, and starts demyx container"
    echo "      tty             Execute root commands to demyx container from host"
    echo "      update          Update chroot.sh from GitHub"
    echo "      --api           Expose demyx api"
    echo "      --dev           Puts demyx container into development mode"
    echo "      --nc            Starts demyx containr but prevent chrooting into container"
    echo "      --prod          Puts demyx container into production mode"
    echo "      --ssh           Override ssh port"
    echo
elif [[ "$DEMYX_CHROOT" = remove ]]; then
    demyx_rm
elif [[ "$DEMYX_CHROOT" = restart ]]; then
    if [[ -z "$DEMYX_CHROOT_MODE" ]]; then
        DEMYX_CHROOT_MODE=production
    fi
    demyx_rm
    demyx_run
    demyx_mode
    if [[ -z "$DEMYX_CHROOT_NC" ]]; then
        docker exec -it demyx zsh
    fi
elif [[ "$DEMYX_CHROOT" = tty ]]; then
    docker exec -t demyx "$@"
elif [[ "$DEMYX_CHROOT" = update ]]; then
    docker run -t --rm -v /usr/local/bin:/usr/local/bin demyx/utilities "rm -f /usr/local/bin/demyx; curl -s https://raw.githubusercontent.com/demyxco/demyx/master/chroot.sh -o /usr/local/bin/demyx; chmod +x /usr/local/bin/demyx"
    echo -e "\e[32m[SUCCESS]\e[39m Demyx chroot has successfully updated"
else
    if [[ -n "$DEMYX_CHROOT_CONTAINER_CHECK" ]]; then
        DEMYX_MODE_CHECK=$(docker exec -t demyx sh -c "grep DEMYX_MOTD_MODE /demyx/.env | awk -F '[=]' '{print \$2}'")
        if [[ -z "$DEMYX_CHROOT_MODE" ]]; then
            DEMYX_CHROOT_MODE="$DEMYX_MODE_CHECK"
        fi
        demyx_mode
        if [[ -z "$DEMYX_CHROOT_NC" ]]; then
            docker exec -it demyx zsh
        fi
    else
        demyx_run
        demyx_mode
        if [[ -z "$DEMYX_CHROOT_NC" ]]; then
            docker exec -it demyx zsh
        fi
    fi
fi
