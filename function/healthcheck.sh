# Demyx
# https://demyx.sh
# 
# demyx healthcheck
#
demyx_healthcheck() {
    if [[ "$DEMYX_HEALTHCHECK_ENABLE" = true && ! -f "$DEMYX"/.healthcheck_running ]]; then
        # Create file to prevent demyx healthcheck from 
        # executing again when the next minute hits
        demyx_execute -v touch "$DEMYX"/.healthcheck_running
        
        cd "$DEMYX_WP" || exit

        for i in *
        do
            if [[ -d "$i" ]]; then
                source "$DEMYX_WP"/"$i"/.env
                [[ "$DEMYX_APP_HEALTHCHECK" = false ]] && continue

                if [[ "$DEMYX_APP_STACK" = ols || "$DEMYX_APP_STACK" = ols-bedrock ]]; then
                    DEMYX_HEALTHCHECK_CONTAINER="$DEMYX_APP_WP_CONTAINER"
                else
                    DEMYX_HEALTHCHECK_CONTAINER="$DEMYX_APP_NX_CONTAINER"
                fi

                DEMYX_HEALTHCHECK_STATUS="$(curl -s -m "$DEMYX_HEALTHCHECK_TIMEOUT" "$DEMYX_HEALTHCHECK_CONTAINER" > /dev/null; echo "$?")"

                if [[ "$DEMYX_HEALTHCHECK_STATUS" != 0 ]]; then
                    if [[ ! -f "$DEMYX_WP"/"$i"/.healthcheck ]]; then
                        demyx_execute -v echo "DEMYX_APP_HEALTHCHECK_COUNT=0" > "$DEMYX_WP"/"$i"/.healthcheck
                    fi

                    source "$DEMYX_WP"/"$i"/.healthcheck

                    if [[ "$DEMYX_APP_HEALTHCHECK_COUNT" != 3 ]]; then
                        DEMYX_APP_MONITOR_COUNT_UP="$((DEMYX_APP_HEALTHCHECK_COUNT+1))"
                        demyx_execute -v echo "DEMYX_APP_HEALTHCHECK_COUNT=$DEMYX_APP_MONITOR_COUNT_UP" > "$DEMYX_WP"/"$i"/.healthcheck
                        demyx compose "$i" fr
                    else
                        if [[ ! -f "$DEMYX_WP"/"$i"/.healthcheck-lock ]]; then
                            DEMYX_HEALTHCHECK_IP="$(dig +short "$DEMYX_APP_DOMAIN" | tr '\r\n' ' ')"
                            DEMYX_HEALTHCHECK_NS="$(dig +short NS "$DEMYX_APP_DOMAIN" | tr '\r\n' ' ')"
                            DEMYX_HEALTHCHECK_HTTP_STATUS="$(curl -sL -o /dev/null -w %{http_code} "$DEMYX_HEALTHCHECK_CONTAINER")"
                            touch "$DEMYX_WP"/"$i"/.healthcheck-lock
                            if [[ -f "$DEMYX"/custom/callback.sh ]]; then
                                bash "$DEMYX"/custom/callback.sh "healthcheck" "$i" "$DEMYX_HEALTHCHECK_HTTP_STATUS" "$DEMYX_SERVER_IP" "$DEMYX_HEALTHCHECK_IP" "$DEMYX_HEALTHCHECK_NS"
                            fi
                        fi
                    fi
                else
                    if [[ -f "$DEMYX_WP"/"$i"/.healthcheck ]]; then
                        demyx_execute -v rm "$DEMYX_WP"/"$i"/.healthcheck
                    fi
                    if [[ -f "$DEMYX_WP"/"$i"/.healthcheck-lock ]]; then
                        demyx_execute -v rm "$DEMYX_WP"/"$i"/.healthcheck-lock
                    fi
                fi
            fi
        done

        demyx_execute -v rm -f "$DEMYX"/.healthcheck_running
    fi
}
