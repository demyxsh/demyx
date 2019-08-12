# Demyx
# https://demyx.sh
# 
# demyx stack <docker-compose args>
#
demyx_stack() {
    while :; do
        case "$2" in
            down)
                DEMYX_STACK_DOWN=1
                ;;
            --auto-update|--auto-update=on)
                DEMYX_STACK_AUTO_UPDATE=on
                ;;
            --auto-update=off)
                DEMYX_STACK_AUTO_UPDATE=off
                ;;
            --du)
                DEMYX_STACK_DU=1
                ;;
            --healthcheck|--healthcheck=on)
                DEMYX_STACK_HEALTHCHECK=on
                ;;
            --healthcheck=off)
                DEMYX_STACK_HEALTHCHECK=off
                ;;
            --monitor|--monitor=on)
                DEMYX_STACK_MONITOR=on
                ;;
            --monitor=off)
                DEMYX_STACK_MONITOR=off
                ;;
            --refresh)
                DEMYX_STACK_REFRESH=1
                ;;
            --)
                shift
                break
                ;;
            -?*)
                printf '\e[31m[CRITICAL]\e[39m Unknown option: %s\n' "$2" >&2
                exit 1
                ;;
            *)
                break
        esac
        shift
    done

    if [[ -n "$DEMYX_STACK_DOWN" ]]; then
        demyx_execute -v demyx stack stop
        demyx_execute -v demyx stack rm -f
    elif [[ -n "$DEMYX_STACK_DU" ]]; then
        demyx_execute -v demyx stack stop
        demyx_execute -v demyx stack rm -f
        demyx_execute -v demyx stack up -d --remove-orphans
    elif [[ "$DEMYX_STACK_AUTO_UPDATE" = on ]]; then
        demyx_echo 'Turn on stack auto update'
        demyx_execute sed -i 's/DEMYX_STACK_AUTO_UPDATE=off/DEMYX_STACK_AUTO_UPDATE=on/g' "$DEMYX_STACK"/.env
    elif [[ "$DEMYX_STACK_AUTO_UPDATE" = off ]]; then
        demyx_echo 'Turn off stack auto update'
        demyx_execute sed -i 's/DEMYX_STACK_AUTO_UPDATE=on/DEMYX_STACK_AUTO_UPDATE=off/g' "$DEMYX_STACK"/.env
    elif [[ "$DEMYX_STACK_HEALTHCHECK" = on ]]; then
        demyx_echo 'Turn on stack healthcheck'
        demyx_execute sed -i 's/DEMYX_STACK_HEALTHCHECK=off/DEMYX_STACK_HEALTHCHECK=on/g' "$DEMYX_STACK"/.env
    elif [[ "$DEMYX_STACK_HEALTHCHECK" = off ]]; then
        demyx_echo 'Turn off stack healthcheck'
        demyx_execute sed -i 's/DEMYX_STACK_HEALTHCHECK=on/DEMYX_STACK_HEALTHCHECK=off/g' "$DEMYX_STACK"/.env
    elif [[ "$DEMYX_STACK_MONITOR" = on ]]; then
        demyx_echo 'Turn on stack monitor'
        demyx_execute sed -i 's/DEMYX_STACK_MONITOR=off/DEMYX_STACK_MONITOR=on/g' "$DEMYX_STACK"/.env
    elif [[ "$DEMYX_STACK_MONITOR" = off ]]; then
        demyx_echo 'Turn off stack monitor'
        demyx_execute sed -i 's/DEMYX_STACK_MONITOR=on/DEMYX_STACK_MONITOR=off/g' "$DEMYX_STACK"/.env
    elif [[ -n "$DEMYX_STACK_REFRESH" ]]; then
        demyx_echo 'Backing up stack directory as /demyx/backup/stack.tgz'
        demyx_execute tar -czf /demyx/backup/stack.tgz -C /demyx/app stack

        source "$DEMYX_FUNCTION"/env.sh
        source "$DEMYX_FUNCTION"/yml.sh

        demyx_echo 'Refreshing stack env and yml'
        demyx_execute demyx_stack_env; demyx_stack_yml

        demyx stack up -d --remove-orphans
    else
        shift
        docker run -t --rm \
        --name demyx_compose \
        -v /var/run/docker.sock:/var/run/docker.sock:ro \
        --volumes-from demyx \
        --workdir "$DEMYX_STACK" \
        demyx/docker-compose "$@"
    fi
}
