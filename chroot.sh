#!/bin/bash
# Demyx
# https://demyx.sh

DEMYX_CHROOT_CONTAINER_CHECK=$(docker ps -a | awk '{print $NF}' | grep -w demyx)
DEMYX_CHROOT_HOST=$(hostname)
DEMYX_CHROOT_SSH=2222
DEMYX_CHROOT_ET=2022

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
        rs)
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
        --dev)
            DEMYX_CHROOT_MODE=development
            ;;
        --nc)
            DEMYX_CHROOT_NC=1
            ;;
        --et=?*)
            DEMYX_CHROOT_ET=${1#*=}
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

demyx_permission() {
    docker exec -t demyx bash -c "chown -R demyx:demyx /home/demyx; \
        chown -R demyx:demyx /demyx; \
        chmod +x /demyx/etc/demyx.sh; \
        chmod +x /demyx/etc/cron/every-minute.sh; \
        chmod +x /demyx/etc/cron/every-6-hour.sh; \
        chmod +x /demyx/etc/cron/every-day.sh"
}
demyx_mode() {
    if [[ "$DEMYX_CHROOT_MODE" = development ]]; then
        DEMYX_CHROOT_MODE=development
        docker exec -t demyx bash -c "find /demyx -type d -print0 | xargs -0 chmod 0755; \
            find /demyx -type f -print0 | xargs -0 chmod 0644"
    elif [[ "$DEMYX_CHROOT_MODE" = production ]]; then
        DEMYX_CHROOT_MODE=production
        docker exec -t demyx bash -c "chmod -R a=X /demyx"
    fi
    demyx_permission
    docker exec -it -e DEMYX_MODE="$DEMYX_CHROOT_MODE" demyx demyx motd init
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

    while true; do
        DEMYX_ET_OPEN_PORT=$(netstat -tuplen 2>/dev/null | grep :"$DEMYX_CHROOT_ET" || true)
        if [[ -z "$DEMYX_ET_OPEN_PORT" ]]; then
            break
        else
            DEMYX_CHROOT_ET=$((DEMYX_CHROOT_ET+1))
        fi
    done

    docker run -dit \
    --name demyx \
    --restart unless-stopped \
    --hostname "$DEMYX_CHROOT_HOST" \
    --network demyx \
    -e DEMYX_HOST="$DEMYX_CHROOT_HOST" \
    -e DEMYX_SSH="$DEMYX_CHROOT_SSH" \
    -e DEMYX_ET="$DEMYX_CHROOT_ET" \
    -e DEMYX_MODE="$DEMYX_CHROOT_MODE" \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v demyx:/demyx \
    -v demyx_user:/home/demyx \
    -v demyx_log:/var/log/demyx \
    -e TZ=America/Los_Angeles \
    -p "$DEMYX_CHROOT_SSH":22 \
    -p "$DEMYX_CHROOT_ET":2022 \
    demyx/demyx
}
if [[ "$DEMYX_CHROOT" = execute ]]; then
    docker exec -t demyx demyx "$@"
elif [[ "$DEMYX_CHROOT" = help ]]; then
    echo
    echo "demyx <args>          Chroot into the demyx container"
    echo "      exec            Send demyx commands from host"
    echo "      help            Demyx help"
    echo "      rm              Stops and removes demyx container"
    echo "      rs              Stops, removes, and starts demyx container"
    echo "      tty             Execute root commands to demyx container from host"
    echo "      update          Update the demyx chroot"
    echo "      --dev           Puts demyx container into development mode"
    echo "      --nc            Starts demyx containr but prevent chrooting into container"
    echo "      --et            Override et port"
    echo "      --prod          Puts demyx container into production mode"
    echo "      --ssh           Override ssh port"
    echo
elif [[ "$DEMYX_CHROOT" = remove ]]; then
    demyx_rm
elif [[ "$DEMYX_CHROOT" = restart ]]; then
    demyx_rm
    demyx_run
    demyx_mode
    if [[ -z "$DEMYX_CHROOT_NC" ]]; then
        docker exec -it demyx zsh
    fi
elif [[ "$DEMYX_CHROOT" = tty ]]; then
    docker exec -t demyx "$@"
elif [[ "$DEMYX_CHROOT" = update ]]; then
    # sudo check
    DEMYX_CHROOT_SUDO_CHECK=$(id -u)
    if [[ "$DEMYX_CHROOT_SUDO_CHECK" != 0 ]]; then
        echo -e "\e[31m[CRITICAL]\e[39m --update must be ran as root or sudo"
        exit 1
    fi
    if [[ -f /usr/local/bin/demyx ]]; then
        rm /usr/local/bin/demyx
    fi
    if wget --spider demyx.sh/chroot 2>/dev/null; then
        wget demyx.sh/chroot -qO /usr/local/bin/demyx
    else
        wget https://raw.githubusercontent.com/demyxco/demyx/master/chroot.sh -qO /usr/local/bin/demyx
    fi
    echo -e "\e[32m[SUCCESS]\e[39m Demyx chroot has successfully updated"
    chmod +x /usr/local/bin/demyx
else
    if [[ -n "$DEMYX_CHROOT_CONTAINER_CHECK" ]]; then
        DEMYX_MODE_CHECK=$(docker exec -t demyx bash -c "grep DEMYX_MOTD_MODE /demyx/.env | awk -F '[=]' '{print \$2}'")
        if [[ -z "$DEMYX_CHROOT_MODE" ]] ; then
            DEMYX_CHROOT_MODE="$DEMYX_MODE_CHECK"
        fi
        if [[ -z "$DEMYX_CHROOT_NC" ]]; then
            demyx_mode
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
