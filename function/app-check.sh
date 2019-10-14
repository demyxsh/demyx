# Demyx
# https://demyx.sh

DEMYX_CHECK_APP_MESSAGE="This app has an outdated config file, please run: demyx config $DEMYX_APP_DOMAIN --refresh"

if [[ -z "$DEMYX_CONFIG_REFRESH" ]] && [[ "$DEMYX_APP_TYPE" = wp ]]; then
    [[ -z "$DEMYX_APP_COMPOSE_PROJECT" ]] && demyx_die --no-help "$DEMYX_CHECK_APP_MESSAGE"
fi
