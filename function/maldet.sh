# Demyx
# https://demyx.sh
# 
# demyx maldet <app> <args>

function demyx_maldet() {
    demyx_app_config

    if [[ "$DEMYX_APP_TYPE" = wp ]]; then
        echo -e "\e[34m[INFO]\e[39m Scanning has initiated, this may take a while ... "
        if [[ "$3" = db ]]; then
            demyx_execute -v docker run -it --rm \
            --volumes-from "$DEMYX_APP_DB_CONTAINER" \
            demyx/utilities "/maldet.sh db"
        else
            demyx_execute -v docker run -it --rm \
            --volumes-from "$DEMYX_APP_WP_CONTAINER" \
            demyx/utilities "/maldet.sh wp"
        fi
    else
        demyx_die --not-found
    fi
}
