# Demyx
# https://demyx.sh
# 
# demyx maldet <app> <args>

demyx_maldet() {
    demyx_app_config
    demyx_app_is_up

    if [[ "$DEMYX_APP_TYPE" = wp ]]; then
        echo -e "\e[34m[INFO]\e[39m Scanning has initiated, this may take a while ... "
        if [[ "$3" = db ]]; then
            demyx_execute -v docker run -it --rm \
            --user=root \
            --volumes-from="$DEMYX_APP_DB_CONTAINER" \
            -e UTILITIES_ROOT=/demyx \
            demyx/utilities demyx-maldet db
        else
            demyx_execute -v docker run -it --rm \
            --user=root \
            --volumes-from="$DEMYX_APP_WP_CONTAINER" \
            -e UTILITIES_ROOT=/demyx \
            demyx/utilities demyx-maldet wp
        fi
    else
        demyx_die --not-found
    fi
}
