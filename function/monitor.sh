# Demyx
# https://demyx.sh
# 
# demyx monitor
#
demyx_monitor() {
    demyx_wp_check_empty
    if [[ "$DEMYX_MONITOR_ENABLE" = true ]]; then
        DEMYX_APP_MONITOR_STATS="$(docker stats --no-stream)"
        cd "$DEMYX_WP" || exit

        for i in *
        do
            source "$DEMYX_WP"/"$i"/.env

            # Skip WordPress app if it isn't running
            DEMYX_MONITOR_CONTAINER_IS_UP="$(echo "$DEMYX_APP_MONITOR_STATS" | grep "$DEMYX_APP_WP_CONTAINER")"
            [[ -z "$DEMYX_MONITOR_CONTAINER_IS_UP" ]] && continue

            if [[ ! -f "$DEMYX_WP"/"$i"/.monitor ]]; then
                demyx_execute -v echo "DEMYX_APP_MONITOR_COUNT=0" > "$DEMYX_WP"/"$i"/.monitor
            fi

            source "$DEMYX_WP"/"$i"/.monitor

            DEMYX_APP_MONITOR_WP_CHECK="$(echo "$DEMYX_APP_MONITOR_STATS" | grep "$DEMYX_APP_WP_CONTAINER" | awk '{print $3}' | awk -F '[.]' '{print $1}')"
            DEMYX_APP_MONITOR_DB_CHECK="$(echo "$DEMYX_APP_MONITOR_STATS" | grep "$DEMYX_APP_DB_CONTAINER" | awk '{print $3}' | awk -F '[.]' '{print $1}')"

            if (( "$DEMYX_APP_MONITOR_WP_CHECK" >= "$DEMYX_APP_MONITOR_CPU" || "$DEMYX_APP_MONITOR_DB_CHECK" >= "$DEMYX_APP_MONITOR_CPU" )); then
                if [[ "$DEMYX_APP_MONITOR_COUNT" != "$DEMYX_APP_MONITOR_THRESHOLD" ]]; then
                    DEMYX_APP_MONITOR_COUNT_UP="$((DEMYX_APP_MONITOR_COUNT+1))"
                    demyx_execute -v echo "DEMYX_APP_MONITOR_COUNT=${DEMYX_APP_MONITOR_COUNT_UP}" > "$DEMYX_WP"/"$i"/.monitor
                else
                    if [[ "$DEMYX_APP_MONITOR_COUNT" = 3 ]]; then
                        if [[ ! -f "$DEMYX_WP"/"$i"/.monitor_lock ]]; then
                            demyx_execute -v touch "$DEMYX_WP"/"$i"/.monitor_lock
                            #[[ "$DEMYX_APP_STACK" = nginx-php || "$DEMYX_APP_STACK" = bedrock ]] && demyx config "$i" --rate-limit=true
                            [[ -f "$DEMYX"/custom/callback.sh ]] && demyx_execute -v /bin/bash "$DEMYX"/custom/callback.sh "monitor-on" "$i" "$DEMYX_APP_MONITOR_WP_CHECK" "$DEMYX_APP_MONITOR_DB_CHECK"
                        fi
                    fi
                fi
            elif (( "$DEMYX_APP_MONITOR_WP_CHECK" <= "$DEMYX_APP_MONITOR_CPU" || "$DEMYX_APP_MONITOR_DB_CHECK" <= "$DEMYX_APP_MONITOR_CPU" )); then
                if (( "$DEMYX_APP_MONITOR_COUNT" > 0 )); then
                    DEMYX_APP_MONITOR_COUNT_DOWN="$((DEMYX_APP_MONITOR_COUNT-1))"
                    demyx_execute -v echo "DEMYX_APP_MONITOR_COUNT=${DEMYX_APP_MONITOR_COUNT_DOWN}" > "$DEMYX_WP"/"$i"/.monitor
                else
                    if [[ "$DEMYX_APP_MONITOR_COUNT" = 0 ]]; then
                        if [[ -f "$DEMYX_WP"/"$i"/.monitor_lock ]]; then
                            demyx_execute -v rm "$DEMYX_WP"/"$i"/.monitor_lock
                            #[[ "$DEMYX_APP_STACK" = nginx-php || "$DEMYX_APP_STACK" = bedrock ]] && demyx config "$i" --rate-limit=false
                            [[ -f "$DEMYX"/custom/callback.sh ]] && demyx_execute -v /bin/bash "$DEMYX"/custom/callback.sh "monitor-off" "$i" "$DEMYX_APP_MONITOR_WP_CHECK" "$DEMYX_APP_MONITOR_DB_CHECK"
                        fi
                    fi
                fi
            fi
        done
    fi
}
