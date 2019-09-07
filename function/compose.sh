# Demyx
# https://demyx.sh
# 
# demyx compose <app> <args> <docker-compose args>
#
demyx_compose() {
    demyx_app_config

    DEMYX_COMPOSE="$1"

    if [[ "$DEMYX_TARGET" = all ]]; then
        cd "$DEMYX_WP" || exit
        for i in *
        do 
            demyx compose "$i" "$@"
        done
    elif [[ "$DEMYX_APP_TYPE" = wp ]]; then
        shift
        DEMYX_COMPOSE="$1"
        if [[ "$DEMYX_COMPOSE" = db ]]; then
            shift
            demyx_execute -v docker run -t --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --volumes-from demyx \
            --workdir "$DEMYX_APP_PATH" \
            demyx/docker-compose "$@" db_"$DEMYX_APP_ID"
        elif [[ "$DEMYX_COMPOSE" = down ]]; then
            demyx_execute -v docker run -t --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --volumes-from demyx \
            --workdir "$DEMYX_APP_PATH" \
            demyx/docker-compose stop

            demyx_execute -v docker run -t --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --volumes-from demyx \
            --workdir "$DEMYX_APP_PATH" \
            demyx/docker-compose rm -f
        elif [[ "$DEMYX_COMPOSE" = du ]]; then
            demyx_execute -v docker run -t --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --volumes-from demyx \
            --workdir "$DEMYX_APP_PATH" \
            demyx/docker-compose stop

            demyx_execute -v docker run -t --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --volumes-from demyx \
            --workdir "$DEMYX_APP_PATH" \
            demyx/docker-compose rm -f

            demyx_execute -v docker run -t --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --volumes-from demyx \
            --workdir "$DEMYX_APP_PATH" \
            demyx/docker-compose up -d --remove-orphans
        elif [[ "$DEMYX_COMPOSE" = wp ]]; then
            shift
            demyx_execute -v docker run -t --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --volumes-from demyx \
            --workdir "$DEMYX_APP_PATH" \
            demyx/docker-compose "$@" wp_"$DEMYX_APP_ID"
        else
            demyx_execute -v docker run -t --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --volumes-from demyx \
            --workdir "$DEMYX_APP_PATH" \
            demyx/docker-compose "$@"
        fi
    elif [[ -n "$DEMYX_GET_APP" ]]; then
        shift 1
        if [[ "$DEMYX_COMPOSE" = down ]]; then
            demyx_execute -v docker run -t --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --volumes-from demyx \
            --workdir "$DEMYX_APP"/"$DEMYX_TARGET" \
            demyx/docker-compose stop

            demyx_execute -v docker run -t --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --volumes-from demyx \
            --workdir "$DEMYX_APP"/"$DEMYX_TARGET" \
            demyx/docker-compose rm -f
        elif [[ "$DEMYX_COMPOSE" = du ]]; then
            demyx_execute -v docker run -t --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --volumes-from demyx \
            --workdir "$DEMYX_APP"/"$DEMYX_TARGET" \
            demyx/docker-compose stop

            demyx_execute -v docker run -t --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --volumes-from demyx \
            --workdir "$DEMYX_APP"/"$DEMYX_TARGET" \
            demyx/docker-compose rm -f

            demyx_execute -v docker run -t --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --volumes-from demyx \
            --workdir "$DEMYX_APP"/"$DEMYX_TARGET" \
            demyx/docker-compose up -d --remove-orphans
        else
            demyx_execute -v docker run -t --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --volumes-from demyx \
            --workdir "$DEMYX_APP"/"$DEMYX_TARGET" \
            demyx/docker-compose "$@"
        fi
    elif [[ -z "$DEMYX_GET_APP" ]]; then
        if [[ "$DEMYX_COMPOSE" = down ]]; then
            demyx_execute -v docker run -t --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --volumes-from demyx \
            --workdir "$PWD" \
            demyx/docker-compose stop

            demyx_execute -v docker run -t --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --volumes-from demyx \
            --workdir "$PWD" \
            demyx/docker-compose rm -f
        elif [[ "$DEMYX_COMPOSE" = du ]]; then
            demyx_execute -v docker run -t --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --volumes-from demyx \
            --workdir "$PWD" \
            demyx/docker-compose stop

            demyx_execute -v docker run -t --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --volumes-from demyx \
            --workdir "$PWD" \
            demyx/docker-compose rm -f

            demyx_execute -v docker run -t --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --volumes-from demyx \
            --workdir "$PWD" \
            demyx/docker-compose up -d --remove-orphans
        else
            demyx_execute -v docker run -t --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --volumes-from demyx \
            --workdir "$PWD" \
            demyx/docker-compose "$@"
        fi
    else
        demyx_die --not-found
    fi
}
