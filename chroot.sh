#!/bin/bash
# Demyx
# https://demyx.sh

while :; do
    case "$1" in
        --dev)
            DEMYX_DEVELOPMENT_MODE=true
            ;;
        --et)
            DEMYX_ET=${1#*=}
            ;;
        --help)
            DEMYX_HELP=1
            ;;
        --nc)
            DEMYX_NO_CHROOT=1
            ;;
        --rs)
            DEMYX_RESTART=1
            ;;
        --ssh)
            DEMYX_SSH=${1#*=}
            ;;
        --update)
            DEMYX_UPDATE=1
            ;;
        --)
            shift
            break
            ;;
        -?*)
            echo -e '\e[31m[CRITICAL]\e[39m Unknown option: %s\n' "$1" >&2
            exit 1
            ;;
        *)
            break
    esac
    shift
done

DEMYX_CONTAINER_CHECK=$(docker ps -a | awk '{print $NF}' | grep -w demyx)

demyx_run() {
    DEMYX_SSH=2222
    DEMYX_ET=2022
    
    while true; do
        DEMYX_SFTP_OPEN_PORT=$(netstat -tuplen 2>/dev/null | grep :"$DEMYX_SSH" || true)
        if [[ -z "$DEMYX_SFTP_OPEN_PORT" ]]; then
            break
        else
            DEMYX_SSH=$((DEMYX_SSH+1))
        fi
    done

    while true; do
        DEMYX_ET_OPEN_PORT=$(netstat -tuplen 2>/dev/null | grep :"$DEMYX_ET" || true)
        if [[ -z "$DEMYX_ET_OPEN_PORT" ]]; then
            break
        else
            DEMYX_ET=$((DEMYX_ET+1))
        fi
    done
    
    docker run -dit \
    --name demyx \
    --restart unless-stopped \
    --network demyx \
    -e DEMYX_DEVELOPMENT_MODE="$DEMYX_DEVELOPMENT_MODE" \
    -e DEMYX_SSH="$DEMYX_SSH" \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v demyx:/demyx \
    -v demyx_user:/home/demyx \
    -v demyx_log:/var/log/demyx \
    -e TZ=America/Los_Angeles \
    -p "$DEMYX_SSH":22 \
    -p "$DEMYX_ET":2022 \
    demyx/demyx
}

if [[ -n "$DEMYX_HELP" ]]; then
    echo
    echo "demyx <args>          Chroot into the demyx container"
    echo "      --dev           Puts demyx container into development mode"
    echo "      --et            Override et port"
    echo "      --help          Demyx help"
    echo "      --nc            Prevent chrooting into container"
    echo "      --rs            Stops, removes, and starts demyx container"
    echo "      --ssh           Override ssh port"
    echo "      --update        Update the demyx chroot"
    echo
elif [[ -n "$DEMYX_UPDATE" ]]; then
    # sudo check
    DEMYX_SUDO_CHECK=$(id -u)
    if [[ "$DEMYX_SUDO_CHECK" != 0 ]]; then
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
elif [[ -n "$DEMYX_DEVELOPMENT_MODE" ]]; then
    if [[ -n "$DEMYX_CONTAINER_CHECK" ]]; then
        docker stop demyx
        docker rm -f demyx
    fi
    demyx_run
    if [[ -z "$DEMYX_NO_CHROOT" ]]; then
        docker exec -it demyx zsh
    fi
elif [[ -n "$DEMYX_RESTART" ]]; then
    if [[ -n "$DEMYX_CONTAINER_CHECK" ]]; then
        docker stop demyx
        docker rm -f demyx
    fi
    if [[ -z "$DEMYX_NO_CHROOT" ]]; then
        demyx --nc
    else
        demyx
    fi
elif [[ -n "$DEMYX_CONTAINER_CHECK" ]]; then
    docker exec -it demyx zsh
else
    demyx_run
    if [[ -z "$DEMYX_NO_CHROOT" ]]; then
        docker exec -it demyx zsh
    fi
fi
