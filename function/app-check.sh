# Demyx
# https://demyx.sh

DEMYX_CHECK_APP_MESSAGE="This app has an outdated config file, please run: demyx config $DEMYX_APP_DOMAIN --refresh"

if [[ -z "$DEMYX_CONFIG_REFRESH" ]] && [[ "$DEMYX_APP_TYPE" = wp ]]; then
    [[ -z "$DEMYX_APP_COMPOSE_PROJECT" ]] && demyx_die --no-help "$DEMYX_CHECK_APP_MESSAGE"
    
    # Convert on/off to true/false for WordPress apps
    DEMYX_CHECK_APP_ON_CHECK=$(grep -c "=on" "$DEMYX_APP_PATH"/.env || true)
    DEMYX_CHECK_APP_OFF_CHECK=$(grep -c "=off" "$DEMYX_APP_PATH"/.env || true)
    if [[ "$DEMYX_CHECK_APP_ON_CHECK" > 0 || "$DEMYX_CHECK_APP_OFF_CHECK" > 0 ]]; then 
        sed -i "s|=on|=true|g" "$DEMYX_APP_PATH"/.env
        sed -i "s|=off|=false|g" "$DEMYX_APP_PATH"/.env
    fi
fi
