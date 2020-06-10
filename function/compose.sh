# Demyx
# https://demyx.sh
# 
# demyx compose <app> <args> <docker-compose args>
#
demyx_compose() {
    demyx_app_config

    DEMYX_COMPOSE="$1"

    if [[ "$DEMYX_TARGET" = all ]]; then
        shift
        cd "$DEMYX_WP" || exit
        for i in *
        do
            [[ ! -d "$DEMYX_WP"/"$i" || -z "$(echo "$DEMYX_DOCKER_PS" | grep "$(demyx info "$i" --filter=DEMYX_APP_WP_CONTAINER)" || true)" ]] && continue
            demyx compose "$i" "$@"
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
