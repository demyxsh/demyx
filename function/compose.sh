# Demyx
# https://demyx.sh
# 
# demyx compose <app> <args> <docker-compose args>
#
function demyx_compose() {
    demyx_app_config

    DEMYX_COMPOSE="$1"

    if [[ "$DEMYX_TARGET" = all ]]; then
        cd "$DEMYX_WP" || exit
        for i in *
        do 
            demyx compose "$i" "$DEMYX_COMPOSE"
        done
    elif [[ "$DEMYX_APP_TYPE" = wp ]]; then
        if [[ "$DEMYX_COMPOSE" = db ]]; then
            shift
            docker run -t --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --volumes-from demyx \
            --workdir "$DEMYX_APP_PATH" \
            demyx/docker-compose "$@" db_"$DEMYX_APP_ID"
        elif [[ "$DEMYX_COMPOSE" = down ]]; then
            docker run -t --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --volumes-from demyx \
            --workdir "$DEMYX_APP_PATH" \
            demyx/docker-compose stop

            docker run -t --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --volumes-from demyx \
            --workdir "$DEMYX_APP_PATH" \
            demyx/docker-compose rm -f
        elif [[ "$DEMYX_COMPOSE" = du ]]; then
            docker run -t --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --volumes-from demyx \
            --workdir "$DEMYX_APP_PATH" \
            demyx/docker-compose stop

            docker run -t --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --volumes-from demyx \
            --workdir "$DEMYX_APP_PATH" \
            demyx/docker-compose rm -f

            docker run -t --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --volumes-from demyx \
            --workdir "$DEMYX_APP_PATH" \
            demyx/docker-compose up -d --remove-orphans
        elif [[ "$DEMYX_COMPOSE" = wp ]]; then
            shift
            docker run -t --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --volumes-from demyx \
            --workdir "$DEMYX_APP_PATH" \
            demyx/docker-compose "$@" wp_"$DEMYX_APP_ID"
        else
            docker run -t --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --volumes-from demyx \
            --workdir "$DEMYX_APP_PATH" \
            demyx/docker-compose "$@"
        fi
    elif [[ -n "$DEMYX_GET_APP" ]]; then
        docker run -t --rm \
        -v /var/run/docker.sock:/var/run/docker.sock:ro \
        --volumes-from demyx \
        --workdir "$DEMYX_APP"/"$DEMYX_TARGET" \
        demyx/docker-compose "$@"
    else
        demyx_die --not-found
    fi
}
