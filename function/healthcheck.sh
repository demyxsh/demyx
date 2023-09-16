# Demyx
# https://demyx.sh
# shellcheck shell=bash

#
#   demyx healthcheck <args>
#
demyx_healthcheck() {
    local DEMYX_HEALTHCHECK_ARG="${1:-$DEMYX_ARG_2}"
    shift
    local DEMYX_HEALTHCHECK_TRANSIENT="$DEMYX_TMP"/demyx_notification

    if [[ "$DEMYX_HEALTHCHECK" = true ]]; then
        demyx_source smtp
        case "$DEMYX_HEALTHCHECK_ARG" in
            app)
                demyx_execute false \
                    demyx_healthcheck_app
            ;;
            disk)
                demyx_execute false \
                    demyx_healthcheck_disk
            ;;
            load)
                demyx_execute false \
                    demyx_healthcheck_load
            ;;
            *)
                demyx_help healthcheck
            ;;
        esac
    fi
}
#
#   Checks if apps are running.
#
demyx_healthcheck_app() {
    local DEMYX_HEALTHCHECK_APP_COUNT=0
    local DEMYX_HEALTHCHECK_APP_I=
    local DEMYX_HEALTHCHECK_APP_DB=
    local DEMYX_HEALTHCHECK_APP_NX=
    local DEMYX_HEALTHCHECK_APP_SUBJECT=
    local DEMYX_HEALTHCHECK_APP_TAIL=50
    local DEMYX_HEALTHCHECK_APP_WP=

    [[ -f "$DEMYX_HEALTHCHECK_TRANSIENT" ]] && rm -f "$DEMYX_HEALTHCHECK_TRANSIENT"

    cd "$DEMYX_WP" || exit

    for DEMYX_HEALTHCHECK_APP_I in *; do
        DEMYX_ARG_2="$DEMYX_HEALTHCHECK_APP_I"

        demyx_app_env wp "
            DEMYX_APP_DB_CONTAINER
            DEMYX_APP_DOMAIN
            DEMYX_APP_HEALTHCHECK
            DEMYX_APP_ID
            DEMYX_APP_NX_CONTAINER
            DEMYX_APP_STACK
            DEMYX_APP_WP_CONTAINER
        "

        [[ "$DEMYX_APP_HEALTHCHECK" = false ]] && continue

        if [[ "$DEMYX_APP_STACK" = nginx-php || "$DEMYX_APP_STACK" = bedrock ]]; then
            DEMYX_HEALTHCHECK_APP_NX="$(docker inspect "$DEMYX_APP_NX_CONTAINER" | jq -r '.[].State.Status' || true)"
        fi

        DEMYX_HEALTHCHECK_APP_DB="$(docker inspect "$DEMYX_APP_DB_CONTAINER" | jq -r '.[].State.Status' || true)"
        DEMYX_HEALTHCHECK_APP_WP="$(docker inspect "$DEMYX_APP_WP_CONTAINER" | jq -r '.[].State.Status' || true)"

        {
            if [[ "$DEMYX_HEALTHCHECK_APP_DB" != running ]]; then
                demyx_divider_title "HEALTHCHECK - MARIADB" "docker logs $DEMYX_APP_DB_CONTAINER ($DEMYX_HEALTHCHECK_APP_DB)"
                docker logs "$DEMYX_APP_DB_CONTAINER" 2>&1 | tail -n "$DEMYX_HEALTHCHECK_APP_TAIL"
                demyx_divider_title "HEALTHCHECK - MARIADB" "tail -n $DEMYX_HEALTHCHECK_APP_TAIL ${DEMYX_LOG}/${DEMYX_APP_DOMAIN}.mariadb.log"
                docker run -t --rm \
                    --entrypoint=tail \
                    -v wp_"$DEMYX_APP_ID"_log:/var/log/demyx demyx/wordpress \
                    -n "$DEMYX_HEALTHCHECK_APP_TAIL" "$DEMYX_LOG"/"$DEMYX_APP_DOMAIN".mariadb.log
            fi

            if [[ "$DEMYX_HEALTHCHECK_APP_NX" != running && "$DEMYX_APP_STACK" = nginx-php && "$DEMYX_APP_STACK" = bedrock ]]; then
                demyx_divider_title "HEALTHCHECK - NGINX" "docker logs $DEMYX_APP_NX_CONTAINER ($DEMYX_HEALTHCHECK_APP_NX)"
                docker logs "$DEMYX_APP_NX_CONTAINER" 2>&1 | tail -n "$DEMYX_HEALTHCHECK_APP_TAIL"
                demyx_divider_title "HEALTHCHECK - NGINX" "tail -n $DEMYX_HEALTHCHECK_APP_TAIL ${DEMYX_LOG}/${DEMYX_APP_DOMAIN}.access.log"
                docker run -t --rm \
                    --entrypoint=tail \
                    -v wp_"$DEMYX_APP_ID"_log:/var/log/demyx demyx/wordpress \
                    -n "$DEMYX_HEALTHCHECK_APP_TAIL" "$DEMYX_LOG"/"$DEMYX_APP_DOMAIN".access.log
            fi

            if [[ "$DEMYX_HEALTHCHECK_APP_WP" != running ]]; then
                demyx_divider_title "HEALTHCHECK - WORDPRESS" "docker logs $DEMYX_APP_WP_CONTAINER ($DEMYX_HEALTHCHECK_APP_WP)"
                docker logs "$DEMYX_APP_WP_CONTAINER" 2>&1 | tail -n "$DEMYX_HEALTHCHECK_APP_TAIL"
                demyx_divider_title "HEALTHCHECK - WORDPRESS" "tail -n $DEMYX_HEALTHCHECK_APP_TAIL ${DEMYX_LOG}/${DEMYX_APP_DOMAIN}.error.log"
                docker run -t --rm \
                    --entrypoint=tail \
                    -v wp_"$DEMYX_APP_ID"_log:/var/log/demyx demyx/wordpress \
                    -n "$DEMYX_HEALTHCHECK_APP_TAIL" "$DEMYX_LOG"/"$DEMYX_APP_DOMAIN".error.log
            fi
        } | tee -a "$DEMYX_HEALTHCHECK_TRANSIENT"

        demyx_proper "$DEMYX_HEALTHCHECK_TRANSIENT"

        [[ "$DEMYX_HEALTHCHECK_APP_DB" != running ]] && DEMYX_HEALTHCHECK_APP_COUNT=$((DEMYX_HEALTHCHECK_APP_COUNT+1))
        [[ "$DEMYX_HEALTHCHECK_APP_NX" != running &&
            "$DEMYX_APP_STACK" = nginx-php &&
            "$DEMYX_APP_STACK" = bedrock ]] && DEMYX_HEALTHCHECK_APP_COUNT=$((DEMYX_HEALTHCHECK_APP_COUNT+1))
        [[ "$DEMYX_HEALTHCHECK_APP_WP" != running ]] && DEMYX_HEALTHCHECK_APP_COUNT=$((DEMYX_HEALTHCHECK_APP_COUNT+1))
    done

    if [[ "$DEMYX_APP_HEALTHCHECK" = true ]]; then
        DEMYX_HEALTHCHECK_APP_SUBJECT="$DEMYX_HEALTHCHECK_APP_COUNT app isn't running"
        
        if (( "$DEMYX_HEALTHCHECK_APP_COUNT" >= 2 )); then
            DEMYX_HEALTHCHECK_APP_SUBJECT="$DEMYX_HEALTHCHECK_APP_COUNT apps aren't running"
        elif (( "$DEMYX_HEALTHCHECK_APP_COUNT" > 0 )); then
            demyx_notification healthcheck "$DEMYX_HEALTHCHECK_APP_SUBJECT"
        fi
    fi
}
#
#   Checks disk space.
#
demyx_healthcheck_disk() {
    local DEMYX_HEALTHCHECK_DISK=
    local DEMYX_HEALTHCHECK_DISK_ALL=
    DEMYX_HEALTHCHECK_DISK_ALL="$(df -h | tee "$DEMYX_HEALTHCHECK_TRANSIENT")"
    DEMYX_HEALTHCHECK_DISK="$(df "${DEMYX_HEALTHCHECK_DISK:-/}" | head -n2 | tail -n1 | awk '{print $5}' | sed 's|%||g')"
    local DEMYX_HEALTHCHECK_DISK_SUBJECT="Disk ${DEMYX_HEALTHCHECK_DISK}% full"

    if (( "$DEMYX_HEALTHCHECK_DISK" > "$DEMYX_HEALTHCHECK_DISK_THRESHOLD" )); then
        demyx_notification healthcheck "$DEMYX_HEALTHCHECK_DISK_SUBJECT"
    fi

    demyx_divider_title "HEALTHCHECK - DISK" "$DEMYX_HEALTHCHECK_DISK_SUBJECT"
    echo "$DEMYX_HEALTHCHECK_DISK_ALL"
}
#
#   Checks for high load average.
#
demyx_healthcheck_load() {
    local DEMYX_HEALTHCHECK_LOAD_AVERAGE=
    DEMYX_HEALTHCHECK_LOAD_AVERAGE="$(cat < /proc/loadavg | awk '{print $1 " " $2 " " $3}')"
    local DEMYX_HEALTHCHECK_LOAD_AVERAGE_TARGET=
    DEMYX_HEALTHCHECK_LOAD_AVERAGE_TARGET="$(echo "$DEMYX_HEALTHCHECK_LOAD_AVERAGE" | awk '{print $2}' | awk -F '.' '{print $1}')"

    {
        demyx_divider_title "HEALTHCHECK - LOAD" "top ($DEMYX_HEALTHCHECK_LOAD_AVERAGE)"
        top -b -n 1

        demyx_divider_title "HEALTHCHECK - LOAD" "docker stats --no-stream"
        docker stats --no-stream
    } | tee "$DEMYX_HEALTHCHECK_TRANSIENT"

    if (( "$DEMYX_HEALTHCHECK_LOAD_AVERAGE_TARGET" >= "$DEMYX_HEALTHCHECK_LOAD" )); then
        demyx_notification healthcheck "Load average has hit the threshold - $DEMYX_HEALTHCHECK_LOAD_AVERAGE"
    fi
}
