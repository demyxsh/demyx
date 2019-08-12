# Demyx
# https://demyx.sh
# 
# demyx log <args>
#
demyx_log() {
    while :; do
        case "$2" in
            -f|--follow)
                DEMYX_LOG_FOLLOW=1
                ;;
            --rotate=?*)
                DEMYX_LOG_ROTATE=${2#*=}
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

    demyx_app_config

    if [[ "$DEMYX_APP_TYPE" = wp ]]; then
        shift 2
        docker logs "$DEMYX_APP_WP_CONTAINER" "$@"
    else
        if [[ -n "$DEMYX_LOG_FOLLOW" ]]; then
            tail -f /var/log/demyx/demyx.log
        elif [[ -n "$DEMYX_LOG_ROTATE" ]]; then
            if [[ "$DEMYX_LOG_ROTATE" = demyx ]]; then
                demyx_echo 'Rotating demyx log'
                demyx_execute docker run -t --rm --volumes-from demyx demyx/logrotate
            elif [[ "$DEMYX_LOG_ROTATE" = stack ]]; then
                demyx_echo 'Rotating stack log'
                demyx_execute docker run -t --rm --volumes-from demyx_traefik demyx/logrotate
            elif [[ "$DEMYX_LOG_ROTATE" = wp ]]; then
                cd "$DEMYX_WP" || exit
                for i in *
                do
                    source "$DEMYX_WP"/"$i"/.env
                    demyx_echo "Rotating $i log"
                    demyx_execute docker run -t --rm --volumes-from "$DEMYX_APP_WP_CONTAINER" demyx/logrotate
                done
            fi
        else
            tail -100 /var/log/demyx/demyx.log
        fi
    fi
}
