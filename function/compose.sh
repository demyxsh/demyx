# Demyx
# https://demyx.sh
#
#   demyx compose <app> <args> <docker-compose args>
#
demyx_compose() {
    DEMYX_ARG_2="${1:-$DEMYX_ARG_2}"
    local DEMYX_COMPOSE_TYPE="${2:-}"
    [[ -n "$DEMYX_ARG_2" ]] && shift && local DEMYX_COMPOSE_ARGS="$*"

    case "$DEMYX_ARG_2" in
        all)
            demyx_compose_all
        ;;
        *)
            demyx_compose_app
        ;;
    esac
}
#
#   Loop for demyx_compose_app.
#
demyx_compose_all() {
    local DEMYX_COMPOSE_ALL=

    cd "$DEMYX_WP" || exit

    for DEMYX_COMPOSE_ALL in *; do
        eval demyx_compose "$DEMYX_COMPOSE_ALL" "$DEMYX_COMPOSE_ARGS"
    done
}

            demyx compose "$i" "$@"

            if [[ "$DEMYX_COMPOSE_CHECK_DB" = --check-db ]]; then
                DEMYX_COMPOSE_CHECK_DB_CONTAINER="$(docker inspect --format='{{.State.Status}}' "$DEMYX_APP_DB_CONTAINER")"

                if [[ "$DEMYX_COMPOSE_CHECK_DB_CONTAINER" != running ]]; then
                    demyx config "$i" --fix-innodb
                fi
            fi
        done
    elif [[ "$DEMYX_APP_TYPE" = wp ]]; then
        [[ ! -d "$DEMYX_WP"/"$DEMYX_APP_DOMAIN" ]] && demyx_die --not-found
        shift
        DEMYX_COMPOSE="$1"
        if [[ "$DEMYX_COMPOSE" = db ]]; then
            shift
            demyx_execute -v docker run -t --rm \
            -e DOCKER_HOST=tcp://demyx_socket:2375 \
            --network=demyx_socket \
            --volumes-from=demyx \
            --workdir="$DEMYX_APP_PATH" \
            demyx/docker-compose "$@" db_"$DEMYX_APP_ID"
        elif [[ "$DEMYX_COMPOSE" = down ]]; then
            demyx_execute -v docker run -t --rm \
            -e DOCKER_HOST=tcp://demyx_socket:2375 \
            --network=demyx_socket \
            --volumes-from=demyx \
            --workdir="$DEMYX_APP_PATH" \
            demyx/docker-compose stop

            demyx_execute -v docker run -t --rm \
            -e DOCKER_HOST=tcp://demyx_socket:2375 \
            --network=demyx_socket \
            --volumes-from=demyx \
            --workdir="$DEMYX_APP_PATH" \
            demyx/docker-compose rm -f
        elif [[ "$DEMYX_COMPOSE" = fr ]]; then
            demyx_execute -v docker run -t --rm \
            -e DOCKER_HOST=tcp://demyx_socket:2375 \
            --network=demyx_socket \
            --volumes-from=demyx \
            --workdir="$DEMYX_APP_PATH" \
            demyx/docker-compose up -d --force-recreate --remove-orphans
        elif [[ "$DEMYX_COMPOSE" = nx ]]; then
            shift
            demyx_execute -v docker run -t --rm \
            -e DOCKER_HOST=tcp://demyx_socket:2375 \
            --network=demyx_socket \
            --volumes-from=demyx \
            --workdir="$DEMYX_APP_PATH" \
            demyx/docker-compose "$@" nx_"$DEMYX_APP_ID"
        elif [[ "$DEMYX_COMPOSE" = wp ]]; then
            shift
            demyx_execute -v docker run -t --rm \
            -e DOCKER_HOST=tcp://demyx_socket:2375 \
            --network=demyx_socket \
            --volumes-from=demyx \
            --workdir="$DEMYX_APP_PATH" \
            demyx/docker-compose "$@" wp_"$DEMYX_APP_ID"
        else
            demyx_execute -v docker run -t --rm \
            -e DOCKER_HOST=tcp://demyx_socket:2375 \
            --network=demyx_socket \
            --volumes-from=demyx \
            --workdir="$DEMYX_APP_PATH" \
            demyx/docker-compose "$@"
        fi
    elif [[ -n "$DEMYX_GET_APP" ]]; then
        [[ ! -d "$DEMYX_APP"/"$DEMYX_TARGET" ]] && demyx_die --not-found
        shift 1
        DEMYX_COMPOSE="$1"
        if [[ "$DEMYX_COMPOSE" = down ]]; then
            demyx_execute -v docker run -t --rm \
            -e DOCKER_HOST=tcp://demyx_socket:2375 \
            --network=demyx_socket \
            --volumes-from=demyx \
            --workdir="$DEMYX_APP"/"$DEMYX_TARGET" \
            demyx/docker-compose stop

            demyx_execute -v docker run -t --rm \
            -e DOCKER_HOST=tcp://demyx_socket:2375 \
            --network=demyx_socket \
            --volumes-from=demyx \
            --workdir="$DEMYX_APP"/"$DEMYX_TARGET" \
            demyx/docker-compose rm -f
        elif [[ "$DEMYX_COMPOSE" = fr ]]; then
            shift
            demyx_execute -v docker run -t --rm \
            -e DOCKER_HOST=tcp://demyx_socket:2375 \
            --network=demyx_socket \
            --volumes-from=demyx \
            --workdir="$DEMYX_APP"/"$DEMYX_TARGET" \
            demyx/docker-compose up -d --force-recreate --remove-orphans
        else
            demyx_execute -v docker run -t --rm \
            -e DOCKER_HOST=tcp://demyx_socket:2375 \
            --network=demyx_socket \
            --volumes-from=demyx \
            --workdir="$DEMYX_APP"/"$DEMYX_TARGET" \
            demyx/docker-compose "$@"
        fi
    elif [[ -z "$DEMYX_GET_APP" ]]; then
        [[ ! -d "$DEMYX_APP"/"$DEMYX_TARGET" ]] && demyx_die --not-found
        if [[ "$DEMYX_COMPOSE" = down ]]; then
            demyx_execute -v docker run -t --rm \
            -e DOCKER_HOST=tcp://demyx_socket:2375 \
            --network=demyx_socket \
            --volumes-from=demyx \
            --workdir="$PWD" \
            demyx/docker-compose stop

            demyx_execute -v docker run -t --rm \
            -e DOCKER_HOST=tcp://demyx_socket:2375 \
            --network=demyx_socket \
            --volumes-from=demyx \
            --workdir="$PWD" \
            demyx/docker-compose rm -f
        elif [[ "$DEMYX_COMPOSE" = fr ]]; then
            demyx_execute -v docker run -t --rm \
            -e DOCKER_HOST=tcp://demyx_socket:2375 \
            --network=demyx_socket \
            --volumes-from=demyx \
            --workdir="$PWD" \
            demyx/docker-compose up -d --force-recreate --remove-orphans
        else
            demyx_execute -v docker run -t --rm \
            -e DOCKER_HOST=tcp://demyx_socket:2375 \
            --network=demyx_socket \
            --volumes-from=demyx \
            --workdir="$PWD" \
            demyx/docker-compose "$@"
        fi
    else
        demyx_die --not-found
    fi
}
