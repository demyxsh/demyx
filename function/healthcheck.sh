# Demyx
# https://demyx.sh
# 
# demyx healthcheck
#
function demyx_healthcheck() {
    cd "$DEMYX_WP" || exit

    for i in *
    do
        source "$DEMYX_WP"/"$i"/.env
        
        [[ "$DEMYX_APP_HEALTHCHECK" = off ]] && continue

        DEMYX_HEALTHCHECK_STATUS=$(curl -sSf "$DEMYX_APP_WP_CONTAINER" > /dev/null; echo "$?")

        if [[ "$DEMYX_HEALTHCHECK_STATUS" != 0 ]]; then
            if [[ ! -f "$DEMYX_WP"/"$i"/.healthcheck ]]; then
                demyx_execute -v echo "DEMYX_APP_HEALTHCHECK_COUNT=0" > "$DEMYX_WP"/"$i"/.healthcheck
            fi

            source "$DEMYX_WP"/"$i"/.healthcheck
        
            if [[ "$DEMYX_APP_HEALTHCHECK_COUNT" != 3 ]]; then
                DEMYX_APP_MONITOR_COUNT_UP=$((DEMYX_APP_HEALTHCHECK_COUNT+1))
                demyx_execute -v echo "DEMYX_APP_HEALTHCHECK_COUNT=${DEMYX_APP_MONITOR_COUNT_UP}" > "$DEMYX_WP"/"$i"/.healthcheck
                demyx compose "$i" du
            else
                if [[ ! -f "$DEMYX_WP"/"$i"/.healthcheck-lock ]]; then
                    DEMYX_HEALTHCHECK_HTTP_CODE=$(curl --write-out %{http_code} --silent --output /dev/null --head "$DEMYX_APP_WP_CONTAINER")
                    touch "$DEMYX_WP"/"$i"/.healthcheck-lock
                    [[ -f "$DEMYX"/custom/callback.sh ]] && demyx_execute -v /bin/bash "$DEMYX"/custom/callback.sh "healthcheck" "$i" "$DEMYX_HEALTHCHECK_HTTP_CODE"
                fi
            fi
        else
            [[ -f "$DEMYX_WP"/"$i"/.healthcheck ]] && demyx_execute -v rm "$DEMYX_WP"/"$i"/.healthcheck
            [[ -f "$DEMYX_WP"/"$i"/.healthcheck-lock ]] && demyx_execute -v rm "$DEMYX_WP"/"$i"/.healthcheck-lock
        fi
    done
}
