#!/bin/bash
# Demyx
# https://demyx.sh

while :; do
    case "$1" in
        --dev)
            DEMYX_DEVELOPMENT_MODE=1
            ;;
        -e)
            DEMYX_EXEC=1
            shift
            break
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
        --prod)
            DEMYX_PRODUCTION_MODE=1
            ;;
        --rs)
            DEMYX_RESTART=1
            ;;
        --ssh)
            DEMYX_SSH=${1#*=}
            ;;
        -t)
            DEMYX_TTY=1
            shift
            break
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

demyx_permission() {
    docker exec -t demyx bash -c "chown -R demyx:demyx /home/demyx; \
        chown -R demyx:demyx /demyx; \
        chmod +x /demyx/etc/demyx.sh; \
        chmod +x /demyx/etc/cron/every-minute.sh; \
        chmod +x /demyx/etc/cron/every-6-hour.sh; \
        chmod +x /demyx/etc/cron/every-day.sh"
}
demyx_dev() {
    if [[ -z "$DEMYX_CONTAINER_CHECK" ]]; then
        demyx_run
    fi
    docker exec -t demyx bash -c "find /demyx -type d -print0 | xargs -0 chmod 0755; \
        find /demyx -type f -print0 | xargs -0 chmod 0644; \
        sed -i 's/PRODUCTION/DEVELOPMENT/g' /demyx/.motd"
    demyx_permission
}
demyx_prod() {
    if [[ -z "$DEMYX_CONTAINER_CHECK" ]]; then
        demyx_run
    fi
    docker exec -t demyx bash -c "chmod -R a=X /demyx; sed -i 's/DEVELOPMENT/PRODUCTION/g' /demyx/.motd"
    demyx_permission
}
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
    -e DEMYX_SSH="$DEMYX_SSH" \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v demyx:/demyx \
    -v demyx_user:/home/demyx \
    -v demyx_log:/var/log/demyx \
    -e TZ=America/Los_Angeles \
    -p "$DEMYX_SSH":22 \
    -p "$DEMYX_ET":2022 \
    demyx/demyx

    [[ -n "$DEMYX_DEVELOPMENT_MODE" ]] && demyx_dev
    [[ -n "$DEMYX_PRODUCTION_MODE" ]] && demyx_prod
}

if [[ "$DEMYX_EXEC" ]]; then
    docker exec -t demyx demyx "$@"
elif [[ -n "$DEMYX_HELP" ]]; then
    echo
    echo "demyx <args>          Chroot into the demyx container"
    echo "      --dev           Puts demyx container into development mode"
    echo "      -e              Send demyx commands from host"
    echo "      --et            Override et port"    
    echo "      --help          Demyx help"
    echo "      --nc            Prevent chrooting into container"
    echo "      --prod          Puts demyx container into production mode"
    echo "      --rs            Stops, removes, and starts demyx container"
    echo "      --ssh           Override ssh port"
    echo "      -t              Execute root commands to demyx container from host"
    echo "      --update        Update the demyx chroot"
    echo    
elif [[ -n "$DEMYX_RESTART" ]]; then
    docker stop demyx
    docker rm -f demyx
    demyx --nc
    [[ -n "$DEMYX_DEVELOPMENT_MODE" ]] && demyx_dev
    [[ -n "$DEMYX_PRODUCTION_MODE" ]] && demyx_prod
    demyx
elif [[ "$DEMYX_TTY" ]]; then
    docker exec -t demyx "$@"
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
else
    if [[ -n "$DEMYX_CONTAINER_CHECK" ]]; then
        if [[ -n "$DEMYX_NO_CHROOT" ]]; then
            demyx_run
        else
            [[ -n "$DEMYX_DEVELOPMENT_MODE" ]] && demyx_dev
            [[ -n "$DEMYX_PRODUCTION_MODE" ]] && demyx_prod
            docker exec -it demyx zsh
        fi
    else
        demyx_run
        if [[ -z "$DEMYX_NO_CHROOT" ]]; then
            [[ -n "$DEMYX_DEVELOPMENT_MODE" ]] && demyx_dev
            [[ -n "$DEMYX_PRODUCTION_MODE" ]] && demyx_prod
            demyx "$@"
        fi
    fi
fi
