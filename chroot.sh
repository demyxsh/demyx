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

DEMYX_CONTAINER_CHECK=$(docker ps | awk '{print $NF}' | grep -w demyx)

function demyx_run() {
    DEMYX_SSH=2222
    DEMYX_ET=2022
    
    while true; do
        DEMYX_SFTP_OPEN_PORT=$(netstat -tuplen 2>/dev/null | grep :"$DEMYX_SSH" || true)
        if [ -z "$DEMYX_SFTP_OPEN_PORT" ]; then
            break
        else
            DEMYX_SSH=$((DEMYX_SSH+1))
        fi
    done

    while true; do
        DEMYX_ET_OPEN_PORT=$(netstat -tuplen 2>/dev/null | grep :"$DEMYX_ET" || true)
        if [ -z "$DEMYX_ET_OPEN_PORT" ]; then
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
    -v /usr/local/bin/demyx:/demyx/etc/chroot.sh:ro \
    -v demyx:/demyx \
    -v demyx_user:/home/demyx \
    -v demyx_log:/var/log/demyx \
    -e TZ=America/Los_Angeles \
    -p "$DEMYX_SSH":22 \
    -p "$DEMYX_ET":2022 \
    demyx/demyx
}

if [ -n "$DEMYX_HELP" ]; then
    echo
    echo "demyx <args>          Chroot into the demyx container"
    echo "      --dev           Puts demyx container into development mode"
    echo "      --et            Override et port"
    echo "      --help          Demyx help"
    echo "      --nc            Prevent chrooting into container"
    echo "      --rs            Stops, removes, and starts demyx container"
    echo "      --ssh           Override ssh port"
    echo
    echo -e "\e[32m[SUCCESS]\e[39m Demyx chroot has successfully updated"
elif [ -n "$DEMYX_DEVELOPMENT_MODE" ]; then
    if [ -n "$DEMYX_CONTAINER_CHECK" ]; then
        docker stop demyx
        docker rm -f demyx
    fi
    demyx_run
    if [ -z "$DEMYX_NO_CHROOT" ]; then
        docker exec -it demyx zsh
    fi
elif [ -n "$DEMYX_RESTART" ]; then
    if [ -n "$DEMYX_CONTAINER_CHECK" ]; then
        docker stop demyx
        docker rm -f demyx
    fi
    demyx
elif [ -n "$DEMYX_CONTAINER_CHECK" ]; then
    docker exec -it demyx zsh
else
    demyx_run
    if [ -z "$DEMYX_NO_CHROOT" ]; then
        docker exec -it demyx zsh
    fi
fi
