# Demyx
# https://demyx.sh

if [[ -z "$DEMYX_CONFIG_REFRESH" ]] && [[ "$DEMYX_APP_TYPE" = wp ]]; then
    [[ -z "$DEMYX_APP_COMPOSE_PROJECT" ]] && demyx_die --no-help "This app has an outdated config file, please run: demyx config $DEMYX_APP_DOMAIN --refresh"
fi

# Convert on/off to true/false
sed -i "s|=on|=true|g" "$DEMYX_APP_PATH"/.env
sed -i "s|=off|=false|g" "$DEMYX_APP_PATH"/.env
