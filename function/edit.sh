# Demyx
# https://demyx.sh
# 
# demyx edit <app> <args>
#
demyx_edit() {
    while :; do
        case "$1" in
            --up)
                DEMYX_EDIT_UP=1
                ;;
            --yml)
                DEMYX_EDIT=yml
                ;;
            --)
                shift
                break
                ;;
            -?*)
                printf '\e[31m[CRITICAL]\e[39m Unknown option: %s\n' "$1" >&2
                exit 1
                ;;
            *)
                break
        esac
        shift
    done

    demyx_app_config

    if [[ "$DEMYX_EDIT" = yml ]]; then
        nano "$DEMYX_APP_PATH"/docker-compose.yml
    else
        nano "$DEMYX_APP_PATH"/.env
    fi

    [[ -n "$DEMYX_EDIT_UP" ]] && demyx compose "$DEMYX_APP_DOMAIN" up -d
}
