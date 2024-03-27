#!/bin/bash
# Demyx
# https://demyx.sh
set -euo pipefail
#
#   Main.
#
demyx_host() {
    demyx_host_gatekeeper

    # Set default variables
    local DEMYX_HOST_ARG_1="${1:-}"
    local DEMYX_HOST_ARG_2="${2:-}"
    local DEMYX_HOST_ARG_3="${3:-}"
    local DEMYX_HOST_ARGS="$*"
    local DEMYX_HOST_CONFIRM=
    local DEMYX_HOST_DEV=
    local DEMYX_HOST_HOSTNAME=
    DEMYX_HOST_HOSTNAME="$(hostname)"
    local DEMYX_HOST_DEMYX_PS=
    DEMYX_HOST_DEMYX_PS="$(docker ps)"
    local DEMYX_HOST_UPDATE_IMAGES=
    [[ "$DEMYX_HOST_DEMYX_PS" == *"demyx/demyx"* ]] && \
        DEMYX_HOST_UPDATE_IMAGES="$(docker exec -t --user=root demyx bash -c "[[ -f /demyx/.update_image ]] && cat /demyx/.update_image | sed 's|\r$||g' || true")"
    local DEMYX_HOST_UPDATE_IMAGES_COUNT=0

    if [[ -n "$DEMYX_HOST_UPDATE_IMAGES" ]]; then
        DEMYX_HOST_UPDATE_IMAGES_COUNT="$(echo "$DEMYX_HOST_UPDATE_IMAGES" | wc -l)"
    fi

    case "$DEMYX_HOST_ARG_1" in
        shell) shift
            demyx_host_not_running

            if [[ -z "$DEMYX_HOST_ARG_2" ]]; then
                docker exec -it --user=root demyx bash
            else
                docker exec -it --user=root demyx "$@"
            fi
        ;;
        host)
            case "$DEMYX_HOST_ARG_2" in
                ctop)
                    if docker inspect demyx_ctop >/dev/null 2>&1; then
                        docker exec -it demyx_ctop /ctop
                    else
                        docker run -it --rm \
                            --name=demyx_ctop \
                            --volume /var/run/docker.sock:/var/run/docker.sock:ro \
                            quay.io/vektorlab/ctop
                    fi
                ;;
                dev)
                    shift 2
                    DEMYX_HOST_DEV="${1:-false}"

                    if [[ "$DEMYX_HOST_DEV" = true ]]; then
                        echo -e "\e[33m[WARNING]\e[39m Enabling developer mode"
                        docker exec --user=root demyx bash -c 'sed -i "s|-eEuo|-eEuox|g" /etc/demyx/bin/demyx.sh'
                    elif [[ "$DEMYX_HOST_DEV" = false ]]; then
                        echo -e "\e[34m[INFO]\e[39m  Disabling developer mode"
                        docker exec --user=root demyx bash -c 'sed -i "s|-eEuox|-eEuo|g" /etc/demyx/bin/demyx.sh'
                    fi
                ;;
                edit)
                    # shellcheck disable=2153
                    docker run -it --rm \
                        --user=root \
                        --entrypoint=nano \
                        -v demyx:/demyx \
                        demyx/demyx .env

                    demyx_host_remove
                    demyx_host_run
                ;;
                env)
                    docker exec --user=root demyx cat .env
                ;;
                help)
                    demyx_host_help
                ;;
                rm|remove)
                    demyx_host_remove "$DEMYX_HOST_ARG_3"
                ;;
                rs|restart)
                    demyx_host_remove
                    demyx_host_run
                ;;
                upgrade)
                    demyx_host_not_running
                    demyx_host_upgrade
                ;;
            esac
        ;;
        *)
            if [[ "$DEMYX_HOST_DEMYX_PS" != *"demyx/demyx"* ]]; then
                demyx_host_run
                demyx_host_exec "$@"
            else
                demyx_host_exec "$@"
            fi
        ;;
    esac

    demyx_host_motd
    demyx_host_update
    demyx_host_error
}
#
#   Checks if database needs upgrading.
#
demyx_host_app_upgrade() {
    local DEMYX_HOST_APP_UPGRADE_I=
    local DEMYX_HOST_APP_UPGRADE_LIST=
    DEMYX_HOST_APP_UPGRADE_LIST="$(demyx_host_exec info apps -r | sed 's/\r//g')"

    if [[ "$DEMYX_HOST_UPDATE_IMAGES" == *"mariadb"* ]]; then
        for DEMYX_HOST_APP_UPGRADE_I in $DEMYX_HOST_APP_UPGRADE_LIST; do
            demyx_host_exec backup "$DEMYX_HOST_APP_UPGRADE_I"
            demyx_host_exec backup "$DEMYX_HOST_APP_UPGRADE_I" -d
            demyx_host_exec restore "$DEMYX_HOST_APP_UPGRADE_I" -d -f
            demyx_host_exec refresh "$DEMYX_HOST_APP_UPGRADE_I" -nfr
        done
    fi
}
#
#   Run demyx container to execute docker-compose.
#
demyx_host_compose() {
    docker run -it --rm \
        --entrypoint=docker-compose \
        -v /var/run/docker.sock:/var/run/docker.sock:ro \
        -v demyx:/demyx \
        -e DOCKER_HOST= \
        demyx/docker-compose "$@"
}
#
#   Removes specific dangling images.
#
demyx_host_dangling_images() {
    local DEMYX_HOST_DANGLING_IMAGES=
    local DEMYX_HOST_DANGLING_IMAGES_CHECK_CTOP=
    local DEMYX_HOST_DANGLING_IMAGES_CHECK_PMA=
    local DEMYX_HOST_DANGLING_IMAGES_I=
    DEMYX_HOST_DANGLING_IMAGES="$(docker images "demyx/*" --filter=dangling=true -q)"

    if [[ -n "$DEMYX_HOST_DANGLING_IMAGES" ]]; then
        echo "$DEMYX_HOST_DANGLING_IMAGES" | xargs docker rmi || true
    fi

    # Remove third party dangling images
    DEMYX_HOST_DANGLING_IMAGES="$(docker images --filter=dangling=true -q)"
    for DEMYX_HOST_DANGLING_IMAGES_I in $DEMYX_HOST_DANGLING_IMAGES; do
        DEMYX_HOST_DANGLING_IMAGES_CHECK_CTOP="$(docker inspect "$DEMYX_HOST_DANGLING_IMAGES_I" | grep ctop || true)"
        DEMYX_HOST_DANGLING_IMAGES_CHECK_PMA="$(docker inspect "$DEMYX_HOST_DANGLING_IMAGES_I" | grep phpmyadmin || true)"
        DEMYX_HOST_DANGLING_IMAGES_CHECK_REDIS="$(docker inspect "$DEMYX_HOST_DANGLING_IMAGES_I" | grep redis || true)"

        if [[ -n "$DEMYX_HOST_DANGLING_IMAGES_CHECK_CTOP" ||
                -n "$DEMYX_HOST_DANGLING_IMAGES_CHECK_PMA" ||
                -n "$DEMYX_HOST_DANGLING_IMAGES_CHECK_REDIS" ]]; then
            docker image rm "$DEMYX_HOST_DANGLING_IMAGES_I" || true
        fi
    done
}
#
#   Warns users for new error log entries.
#
demyx_host_error() {
    local DEMYX_HOST_ERROR=
    DEMYX_HOST_ERROR="$(docker exec -t --user=root demyx bash -c "[[ -f /demyx/tmp/demyx_log_error ]] && echo true" || true)"
    # shellcheck disable=2001
    DEMYX_HOST_ERROR="$(echo "$DEMYX_HOST_ERROR" | sed 's|\r$||g')"

    if [[ "$DEMYX_HOST_ERROR" = true ]]; then
        echo -e "\e[31m[ERROR]\e[39m An error has occured, view error log: demyx log main -e"
        docker exec -t --user=root demyx bash -c "cat < /demyx/tmp/demyx_log_error && rm -f /demyx/tmp/demyx_log_error"
    fi
}
#
#   Send commands to demyx container.
#
demyx_host_exec() {
    local DEMYX_HOST_EXEC="${1:-}"

    if [[ -n "$DEMYX_HOST_EXEC" ]]; then
        docker exec -it demyx demyx "$@"
    else
        docker exec -t -e DEMYX_STTY="$(stty size | awk -F ' ' '{print $2}')" demyx demyx motd
    fi
}
#
#   Checks for proper permissions.
#
demyx_host_gatekeeper() {
    local DEMYX_HOST_CHECK_ID=
    DEMYX_HOST_CHECK_ID="$(id | grep docker || true)"

    # Check if user is in docker group first
    if [[ -z "$DEMYX_HOST_CHECK_ID" ]]; then
        # Fallback check for root/sudo
        if [[ "$(id -u)" != 0 ]]; then
            echo -e "\e[31m[ERROR]\e[39m Must be ran as root/sudo or add user to the docker group"
            exit 1
        fi
    fi
}
#
#   Help menu.
#
#
demyx_host_help() {
    echo
    echo "demyx host    <args>          Demyx helper commands"
    echo "      shell                   Execute commands to the demyx container, leave <arg> empty to open a bash shell"
    echo "              all             Targets both demyx and demyx_socket container, works with remove and restart"
    echo "              ctop            htop but for contaienrs"
    echo "              dev             Developer mode, value: <true|false>"
    echo "              edit            Edit Demyx config (~/.demyx) on the host"
    echo "              env             Prints the content of .env inside Demyx container"
    echo "              install         Prompt users to enter details for ~/.demyx"
    echo "              rm|remove       Stops and removes demyx container"
    echo "              rs|restart      Stops, removes, and starts demyx container"
    echo "              upgrade         Pull relevant images, refresh app configs, and delete old images"
    echo
}
#
#   Create a script to execute demyx motd when ssh-ing to server.
#
demyx_host_motd() {
    local DEMYX_HOST_MOTD_CHECK=

    if [[ -f /etc/profile.d/demyx-motd.sh ]]; then
        docker run -t --rm \
            -v /etc/profile.d:/tmp \
            --user=root \
            --entrypoint=bash \
            demyx/demyx -c "rm -f /tmp/demyx-motd.sh"
    fi

    if [[ -f ~/.bashrc ]]; then
        DEMYX_HOST_MOTD_CHECK="$(grep "demyx motd" ~/.bashrc || true)"
        if [[ -z "$DEMYX_HOST_MOTD_CHECK" ]]; then
            echo "demyx motd" >> ~/.bashrc
        fi
    fi

    if [[ -f ~/.zshrc ]]; then
        DEMYX_HOST_MOTD_CHECK="$(grep "demyx motd" ~/.zshrc || true)"
        if [[ -z "$DEMYX_HOST_MOTD_CHECK" ]]; then
            echo "demyx motd" >> ~/.zshrc
        fi
    fi
}
#
#   Notify user demyx container isn't running.
#
demyx_host_not_running() {
    if [[ "$DEMYX_HOST_DEMYX_PS" != *"demyx/demyx"* ]]; then
        echo -e "\e[31m[ERROR]\e[39m Demyx isn't running, please run: demyx host restart"
        exit 1
    fi
}
#
#   Generate main demyx yml and run all services.
#
demyx_host_run() {
    if [[ -f ~/.demyx ]]; then
        docker run -t --rm \
            --network=host \
            --hostname="$DEMYX_HOST_HOSTNAME" \
            --user=root \
            --entrypoint=demyx-yml \
            -v demyx:/demyx \
            -v "$HOME"/.demyx:/tmp/.demyx \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            -e DOCKER_HOST= \
            demyx/demyx

        mv ~/.demyx ~/.demyx.bak
    else
        docker run -t --rm \
            --network=host \
            --hostname="$DEMYX_HOST_HOSTNAME" \
            --user=root \
            --entrypoint=demyx-yml \
            -v demyx:/demyx \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            -e DOCKER_HOST= \
            demyx/demyx
    fi

    demyx_host_compose up -d
}
#
#   Stops and removes demyx container or all demyx services.
#
demyx_host_remove() {
    local DEMYX_HOST_RM="${1:-}"

    case "$DEMYX_HOST_RM" in
        all)
            demyx_host_exec compose code down
            demyx_host_exec compose traefik down
            demyx_host_compose stop
            demyx_host_compose rm -f
        ;;
        *)
            docker stop demyx
            docker rm demyx
        ;;
    esac
}
#
#   Notify user of updates.
#
demyx_host_update() {
    if [[ "$DEMYX_HOST_DEMYX_PS" == *"demyx/demyx"* ]]; then
        if [[ "$DEMYX_HOST_UPDATE_IMAGES_COUNT" != 0 ]]; then
            echo -e "\e[32m[UPDATE]\e[39m $DEMYX_HOST_UPDATE_IMAGES_COUNT update(s) available!"
            echo -e "\e[32m[UPDATE]\e[39m View update(s): demyx update -l"
            echo -e "\e[32m[UPDATE]\e[39m Start upgrade: demyx host upgrade"
        fi
    fi
}
#
#   Upgrade function.
#
demyx_host_upgrade() {
    local DEMYX_HOST_UPGRADE_FORCE=
    DEMYX_HOST_UPGRADE_FORCE="$(echo "$DEMYX_HOST_ARGS" | grep -e "-f" || true)"

    # Exit if no updates are available
    if [[ "$DEMYX_HOST_UPDATE_IMAGES_COUNT" = 0 ]]; then
        echo -e "\e[34m[INFO]\e[39m No updates available"
        exit
    fi

    if [[ -z "$DEMYX_HOST_UPGRADE_FORCE" ]]; then
        echo -en "\e[33m"
        read -rep "[WARNING] Depending on the update, services may be temporarily disrupted. Continue? [yY]: " DEMYX_HOST_CONFIRM
        echo -en "\e[39m"

        if [[ "$DEMYX_HOST_CONFIRM" != [yY] ]]; then
            echo -e "\e[31m[ERROR]\e[39m Update cancelled"
            exit 1
        fi
    fi

    # Pull core/relevant images
    demyx_host_exec pull all

    # Use new images for core services
    demyx_host_exec refresh traefik
    demyx_host_exec refresh code
    demyx_host_compose up -d --remove-orphans

    # Upgrade database if needed
    demyx_host_app_upgrade

    # Use new images
    demyx_host_exec refresh all

    # Remove old images
    demyx_host_dangling_images

    # Update cache
    demyx_host_exec update

    # Empty out this variable to suppress update message
    DEMYX_HOST_UPDATE_IMAGES_COUNT=0

    demyx_host_exec motd

    echo -e "\e[32m[SUCCESS]\e[39m Successfully updated!"
}
#
#   Init.
#
demyx_host "$@"
