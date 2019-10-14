# Demyx
# https://demyx.sh
# 
# demyx monitor
#
demyx_monitor() {
    source "$DEMYX_STACK"/.env
    if [[ "$DEMYX_STACK_MONITOR" = true ]]; then
        DEMYX_APP_MONITOR_STATS=$(docker stats --no-stream)
        cd "$DEMYX_WP" || exit

        for i in *
        do
            source "$DEMYX_WP"/"$i"/.env
            
            if [[ ! -f "$DEMYX_WP"/"$i"/.monitor ]]; then
                demyx_execute -v echo "DEMYX_APP_MONITOR_COUNT=0" > "$DEMYX_WP"/"$i"/.monitor
            fi

            source "$DEMYX_WP"/"$i"/.monitor

            DEMYX_APP_MONITOR_CHECK=$(echo "$DEMYX_APP_MONITOR_STATS" | grep "$DEMYX_APP_WP_CONTAINER" | awk '{print $3}' | awk -F '[.]' '{print $1}')

            if (( "$DEMYX_APP_MONITOR_CHECK" >= "$DEMYX_APP_MONITOR_CPU" )); then
                if [[ "$DEMYX_APP_MONITOR_COUNT" != "$DEMYX_APP_MONITOR_THRESHOLD" ]]; then
                    DEMYX_APP_MONITOR_COUNT_UP=$((DEMYX_APP_MONITOR_COUNT+1))
                    demyx_execute -v echo "DEMYX_APP_MONITOR_COUNT=${DEMYX_APP_MONITOR_COUNT_UP}" > "$DEMYX_WP"/"$i"/.monitor
                else
                    if [[ "$DEMYX_APP_MONITOR_COUNT" = 3 ]]; then
                        if [[ ! -f "$DEMYX_WP"/"$i"/.monitor_lock ]]; then
                            demyx_execute -v touch "$DEMYX_WP"/"$i"/.monitor_lock
                            demyx config "$i" --rate-limit=true
                            #cd "$DEMYX_WP"/"$i" || exit
                            #demyx_execute -v demyx compose "$i" up -d --scale wp_"$DEMYX_APP_ID"="$DEMYX_APP_MONITOR_SCALE" wp_"$DEMYX_APP_ID"
                            #demyx_execute -v demyx compose "$i" up -d --scale db_"$DEMYX_APP_ID"="$DEMYX_APP_MONITOR_SCALE" db_"$DEMYX_APP_ID"
                            [[ -f "$DEMYX"/custom/callback.sh ]] && demyx_execute -v /bin/bash "$DEMYX"/custom/callback.sh "monitor-on" "$i" "$DEMYX_APP_MONITOR_CHECK"
                        fi
                    fi
                fi
            elif (( "$DEMYX_APP_MONITOR_CHECK" <= "$DEMYX_APP_MONITOR_CPU" )); then
                if (( "$DEMYX_APP_MONITOR_COUNT" > 0 )); then
                    DEMYX_APP_MONITOR_COUNT_DOWN=$((DEMYX_APP_MONITOR_COUNT-1))
                    demyx_execute -v echo "DEMYX_APP_MONITOR_COUNT=${DEMYX_APP_MONITOR_COUNT_DOWN}" > "$DEMYX_WP"/"$i"/.monitor
                else
                    if [[ "$DEMYX_APP_MONITOR_COUNT" = 0 ]]; then
                        if [[ -f "$DEMYX_WP"/"$i"/.monitor_lock ]]; then
                            demyx_execute -v rm "$DEMYX_WP"/"$i"/.monitor_lock
                            demyx config "$i" --rate-limit=false
                            #cd "$DEMYX_WP"/"$i" || exit
                            #demyx_execute -v demyx compose "$i" up -d --scale wp_"$DEMYX_APP_ID"=1 wp_"$DEMYX_APP_ID"
                            #demyx_execute -v demyx compose "$i" up -d --scale db_"$DEMYX_APP_ID"=1 db_"$DEMYX_APP_ID"
                            [[ -f "$DEMYX"/custom/callback.sh ]] && demyx_execute -v /bin/bash "$DEMYX"/custom/callback.sh "monitor-off" "$i" "$DEMYX_APP_MONITOR_CHECK"
                        fi
                    fi
                fi
            fi
        done
    fi
}
