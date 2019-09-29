#!/bin/bash
# Demyx
# https://demyx.sh
# 
DEMYX_CHROOT_SUDO_CHECK=$(id -u)
DEMYX_CHROOT_CONTAINER_CHECK=$(docker ps -a | awk '{print $NF}' | grep -w demyx)
DEMYX_CHROOT_HOST=$(hostname)
DEMYX_CHROOT_SSH=2222

# Check for demyx directory
if [[ ! -d /demyx ]]; then
    if [[ "$DEMYX_CHROOT_SUDO_CHECK" != 0 ]]; then
        echo -e "\e[31m[CRITICAL]\e[39m demyx chroot.sh needs to be ran as sudo or root to update, this is a one time thing."
        exit 1
    else
        read -rep "Enter your non-root username (for security purposes): " DEMYX_CHROOT_USER
        if [[ -z "$DEMYX_CHROOT_USER" ]] || [[ "$DEMYX_CHROOT_USER" = root ]]; then
            echo "Username cannot be root or empty"
            exit 1
        else
            mkdir -p /demyx
            echo "DEMYX_CHROOT_USER=$DEMYX_CHROOT_USER" > /demyx/config
            wget https://raw.githubusercontent.com/demyxco/demyx/master/chroot.sh -qO /demyx/chroot.sh
            rm /usr/local/bin/demyx
            ln -s /demyx/chroot.sh /usr/local/bin/demyx
            chown -R "$DEMYX_CHROOT_USER":"$DEMYX_CHROOT_USER" /demyx
            chmod +x /demyx/chroot.sh
        fi
    fi
else
    if [[ -n "$DEMYX_CHROOT_CONTAINER_CHECK" ]]; then
        wget https://raw.githubusercontent.com/demyxco/demyx/master/chroot.sh -qO /demyx/chroot.sh
        chmod +x /demyx/chroot.sh
    fi
fi

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

    docker run -dit \
    --name demyx \
    --restart unless-stopped \
    --hostname "$DEMYX_CHROOT_HOST" \
    --network demyx \
    -e DEMYX_MODE="$DEMYX_CHROOT_MODE" \
    -e DEMYX_HOST="$DEMYX_CHROOT_HOST" \
    -e DEMYX_SSH="$DEMYX_CHROOT_SSH" \
    -e TZ=America/Los_Angeles \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v demyx:/demyx \
    -v demyx_user:/home/demyx \
    -v demyx_log:/var/log/demyx \
    -p "$DEMYX_CHROOT_SSH":22 \
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
