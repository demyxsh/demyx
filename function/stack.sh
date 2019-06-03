# Demyx
# https://demyx.sh
# 
# demyx stack <docker-compose args>
#
function demyx_stack() {
    while :; do
        case "$2" in
            down)
                DEMYX_STACK_DOWN=1
                ;;
            --du)
                DEMYX_STACK_DU=1
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
