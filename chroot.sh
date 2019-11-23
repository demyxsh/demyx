#!/bin/bash
# Demyx
# https://demyx.sh
#

DEMYX_CHROOT_CONTAINER_CHECK="$(docker ps -a | awk '{print $NF}' | grep -w demyx)"
DEMYX_CHROOT_HOST="$(hostname)"
DEMYX_CHROOT_USER=demyx
DEMYX_CHROOT_SSH=2222
DEMYX_CHROOT_API=false
DEMYX_CHROOT_CPU=.50
DEMYX_CHROOT_MEM=512m

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
demyx_until() {
    if [[ "$DEMYX_CHROOT_MODE" = development ]]; then
        until docker exec -t demyx stat /demyx | grep -q 111
        do
            sleep 1
        done
    fi
}
demyx_mode() {
    if [[ "$DEMYX_CHROOT_MODE" = development ]]; then
        docker exec -t --user=root demyx demyx-dev
    else
        docker exec -t demyx demyx-prod
    fi
}
demyx_rm() {
    if [[ -n "$DEMYX_CHROOT_CONTAINER_CHECK" ]]; then
        docker stop demyx
        docker rm -f demyx
    fi
}
demyx_run() {
    while true; do
    DEMYX_SFTP_OPEN_PORT="$(netstat -tuplen 2>/dev/null | grep :${DEMYX_CHROOT_SSH} || true)"
        if [[ -z "$DEMYX_SFTP_OPEN_PORT" ]]; then
            break
        else
            DEMYX_CHROOT_SSH="$((DEMYX_CHROOT_SSH+1))"
        fi
    done

    if [[ -n "$DEMYX_CHROOT_CONTAINER_CHECK" ]]; then
        IFS=$'\r\n' GLOBIGNORE='*' command eval 'DEMYX_CHROOT_API_GET_ENV=($(docker run -t --user=root --rm --name=demyx_tmp -v demyx:/demyx demyx/utilities "cat /demyx/app/stack/.env | sed 1d"))'
        DEMYX_CHROOT_API_DOMAIN="$(echo ${DEMYX_CHROOT_API_GET_ENV[1]} | awk -F '[=]' '{print $2}')"
        DEMYX_CHROOT_API_AUTH="$(echo ${DEMYX_CHROOT_API_GET_ENV[2]} | awk -F '[=]' '{print $2}')"
    fi

    if [[ "$DEMYX_CHROOT_CPU" = null ]]; then
        DEMYX_CHROOT_RESOURCES+=" "
    else
        DEMYX_CHROOT_RESOURCES+="--cpus=$DEMYX_CHROOT_CPU "
    fi

    if [[ "$DEMYX_CHROOT_MEM" = null ]]; then
        DEMYX_CHROOT_RESOURCES+=" "
    else
        DEMYX_CHROOT_RESOURCES+="--memory=$DEMYX_CHROOT_MEM "
    fi

    if [[ -n "$DEMYX_CHROOT_API_DOMAIN" ]]; then
        docker run -dit \
        --name=demyx \
        $DEMYX_CHROOT_RESOURCES \
        --restart=unless-stopped \
        --hostname="$DEMYX_CHROOT_HOST" \
        --network=demyx \
        -e TEST=cim \
        -e DEMYX_MODE="$DEMYX_CHROOT_MODE" \
        -e DEMYX_HOST="$DEMYX_CHROOT_HOST" \
        -e DEMYX_SSH="$DEMYX_CHROOT_SSH" \
        -e TZ=America/Los_Angeles \
        -v /var/run/docker.sock:/var/run/docker.sock:ro \
        -v demyx:/demyx \
        -v demyx_user:/home/demyx \
        -v demyx_log:/var/log/demyx \
        -p "$DEMYX_CHROOT_SSH":2222 \
        -l "traefik.enable=true" \
        -l "traefik.http.routers.demyx.rule=Host(\`${DEMYX_CHROOT_API_DOMAIN}\`)" \
        -l "traefik.http.routers.demyx.entrypoints=https" \
        -l "traefik.http.routers.demyx.tls.certresolver=demyx" \
        -l "traefik.http.routers.demyx.service=demyx" \
        -l "traefik.http.services.demyx.loadbalancer.server.port=8080" \
        -l "traefik.http.routers.demyx.middlewares=demyx-auth" \
        -l "traefik.http.middlewares.demyx-auth.basicauth.users=${DEMYX_CHROOT_API_AUTH}" \
        demyx/demyx 2>/dev/null
    else
        docker run -dit \
        --name=demyx \
        $DEMYX_CHROOT_RESOURCES \
        --restart=unless-stopped \
        --hostname="$DEMYX_CHROOT_HOST" \
        --network=demyx \
        -e TEST=cim \
        -e DEMYX_MODE="$DEMYX_CHROOT_MODE" \
        -e DEMYX_HOST="$DEMYX_CHROOT_HOST" \
        -e DEMYX_SSH="$DEMYX_CHROOT_SSH" \
        -e TZ=America/Los_Angeles \
        -v /var/run/docker.sock:/var/run/docker.sock:ro \
        -v demyx:/demyx \
        -v demyx_user:/home/demyx \
        -v demyx_log:/var/log/demyx \
        -p "$DEMYX_CHROOT_SSH":2222 \
        demyx/demyx 2>/dev/null
    fi

    demyx_until
}

if [[ "$DEMYX_CHROOT" = execute ]]; then
    docker exec -it demyx demyx "$@"
elif [[ "$DEMYX_CHROOT" = help ]]; then
    echo
    echo "demyx <args>          Chroot into the demyx container"
    echo "      exec            Send demyx commands from host"
    echo "      help            Demyx help"
    echo "      rm              Stops and removes demyx container"
    echo "      restart         Stops, removes, and starts demyx container"
    echo "      tty             Execute root commands to demyx container from host"
    echo "      update          Update chroot.sh from GitHub"
    echo "      --cpu           Set container CPU usage, --cpu=null to remove cap"
    echo "      --dev           Puts demyx container into development mode"
    echo "      --mem           Set container MEM usage, --mem=null to remove cap"
    echo "      --nc            Starts demyx containr but prevent chrooting into container"
    echo "      --prod          Puts demyx container into production mode"
    echo "      -r, --root      Execute as root user"
    echo "      --ssh           Override ssh port"
    echo
elif [[ "$DEMYX_CHROOT" = remove ]]; then
    demyx_rm
elif [[ "$DEMYX_CHROOT" = restart ]]; then
    demyx_rm
    demyx_run
    demyx_mode
    if [[ -z "$DEMYX_CHROOT_NC" ]]; then
        docker exec -it --user="$DEMYX_CHROOT_USER" demyx zsh
    fi
elif [[ "$DEMYX_CHROOT" = tty ]]; then
    docker exec -it --user="$DEMYX_CHROOT_USER" demyx "$@"
elif [[ "$DEMYX_CHROOT" = update ]]; then
    docker run -t --user=root --privileged --rm -v /usr/local/bin:/usr/local/bin demyx/utilities demyx-chroot
    echo -e "\e[32m[SUCCESS]\e[39m Demyx chroot has successfully updated"
else
    if [[ -n "$DEMYX_CHROOT_CONTAINER_CHECK" ]]; then
        DEMYX_MODE_CHECK="$(docker exec -t --user=root demyx sh -c "[[ -f /demyx/.env ]] && grep DEMYX_ENV_MODE /demyx/.env | awk -F '[=]' '{print \$2}'")"
        if [[ -z "$DEMYX_CHROOT_MODE" ]]; then
            DEMYX_CHROOT_MODE="$DEMYX_MODE_CHECK"
        fi
        demyx_mode
        if [[ -z "$DEMYX_CHROOT_NC" ]]; then
            docker exec -it --user="$DEMYX_CHROOT_USER" demyx zsh
        fi
    else
        demyx_run
        if [[ -z "$DEMYX_CHROOT_NC" ]]; then
            docker exec -it --user="$DEMYX_CHROOT_USER" demyx zsh
        fi
    fi
fi
