# Demyx
# https://demyx.sh
# 
# demyx install <args>
#
demyx_install() {
    while :; do
        case "$2" in
            --domain=?*)
                DEMYX_INSTALL_DOMAIN="${2#*=}"
                ;;
            --domain=)
                demyx_die '"--domain" cannot be empty'
                ;;
            --email=?*)
                DEMYX_INSTALL_EMAIL="${2#*=}"
                ;;
            --email=)
                demyx_die '"--email" cannot be empty'
                ;;
            --force)
                DEMYX_INSTALL_FORCE=1
                ;;
            --pass=?*)
                DEMYX_INSTALL_PASS="${2#*=}"
                ;;
            --pass=)
                demyx_die '"--pass" cannot be empty'
                ;;
            --user=?*)
                DEMYX_INSTALL_USER="${2#*=}"
                ;;
            --user=)
                demyx_die '"--user" cannot be empty'
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

    # Create stack directory if it doesn't exist
    [[ ! -d "$DEMYX_STACK" ]] && mkdir -p /demyx/app/stack

    if [[ -z "$DEMYX_INSTALL_DOMAIN" || -z "$DEMYX_INSTALL_EMAIL" || -z "$DEMYX_INSTALL_USER" || -z "$DEMYX_INSTALL_PASS" ]]; then
        demyx_die 'Missing required flags: --domain --email --user --pass'
    elif [[ -f "$DEMYX_STACK"/docker-compose.yml  ]]; then
        [[ -z "$DEMYX_INSTALL_FORCE" ]] && demyx_die 'Demyx is already installed'
    fi
    
    demyx_source env
    demyx_source yml

    DEMYX_STACK_AUTH="$(demyx util --user="$DEMYX_INSTALL_USER" --htpasswd="$DEMYX_INSTALL_PASS" --raw)"
    DEMYX_STACK_SERVER_IP="$(curl -m 10 -s https://ipecho.net/plain)"

    echo "# AUTO GENERATED
        DEMYX_STACK_SERVER_IP=$DEMYX_STACK_SERVER_IP
        DEMYX_STACK_SERVER_API=false
        DEMYX_STACK_AUTH=$DEMYX_STACK_AUTH
        DEMYX_STACK_API=false
        DEMYX_STACK_TELEMETRY=true
        DEMYX_STACK_DOMAIN=$DEMYX_INSTALL_DOMAIN
        DEMYX_STACK_MONITOR=true
        DEMYX_STACK_HEALTHCHECK=true
        DEMYX_STACK_CPU=$DEMYX_CPU
        DEMYX_STACK_MEM=$DEMYX_MEM
        DEMYX_STACK_ACME_EMAIL=$DEMYX_INSTALL_EMAIL
        DEMYX_STACK_ACME_STORAGE=/demyx/acme.json
        DEMYX_STACK_CLOUDFLARE=false
        DEMYX_STACK_CLOUDFLARE_EMAIL=
        DEMYX_STACK_CLOUDFLARE_KEY=
        DEMYX_STACK_LOG_LEVEL=INFO
        DEMYX_STACK_LOG_ACCESS=${DEMYX_LOG}/traefik.access.log
        DEMYX_STACK_LOG_ERROR=${DEMYX_LOG}/traefik.error.log
        DEMYX_STACK_TRUSTED_IPS=$DEMYX_TRUSTED_IPS" | sed 's|        ||g' > "$DEMYX_STACK"/.env

    demyx_echo 'Creating stack .yml'
    demyx_execute demyx_stack_yml

    demyx_echo 'Creating stack config volume'
    demyx_execute docker volume create demyx_traefik

    demyx_echo 'Creating stack log volume'
    demyx_execute docker volume create demyx_traefik_log

    demyx compose stack up -d
}
