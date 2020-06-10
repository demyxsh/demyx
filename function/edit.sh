# Demyx
# https://demyx.sh
# 
# demyx edit <app> <args>
#
demyx_edit() {
    while :; do
        case "$2" in
            stack)
                DEMYX_EDIT=stack
                ;;
            --up)
                DEMYX_EDIT_UP=1
                ;;
            --)
                shift
                break
                ;;
            -?*)
                printf '\e[31m[CRITICAL]\e[39m Unknown option: %s\n' "$2" >&2
                exit 1
                ;;
            *)
                break
        esac
        shift
    done

    if [[ "$DEMYX_EDIT" = traefik ]]; then
        nano "$DEMYX_TRAEFIK"/.env
        [[ -n "$DEMYX_EDIT_UP" ]] && demyx compose stack up -d
    else
        demyx_app_config
        nano "$DEMYX_APP_PATH"/.env
        [[ -n "$DEMYX_EDIT_UP" ]] && demyx compose "$DEMYX_APP_DOMAIN" up -d
    fi
}
