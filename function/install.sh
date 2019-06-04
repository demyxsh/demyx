# Demyx
# https://demyx.sh
# 
# demyx install <args>
#
function demyx_install() {
    while :; do
        case "$2" in
            --domain=?*)
                DEMYX_INSTALL_DOMAIN=${2#*=}
                ;;
            --domain=)
                demyx_die '"--domain" cannot be empty'
                ;;
            --email=?*)
                DEMYX_INSTALL_EMAIL=${2#*=}
                ;;
            --email=)
                demyx_die '"--email" cannot be empty'
                ;;
            --force)
                DEMYX_INSTALL_FORCE=1
                ;;
            --pass=?*)
                DEMYX_INSTALL_PASS=${2#*=}
                ;;
            --pass=)
                demyx_die '"--pass" cannot be empty'
                ;;
            --user=?*)
                DEMYX_INSTALL_USER=${2#*=}
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

    if [[ -z "$DEMYX_INSTALL_DOMAIN" ]] || [[ -z "$DEMYX_INSTALL_EMAIL" ]] || [[ -z "$DEMYX_INSTALL_USER" ]] || [[ -z "$DEMYX_INSTALL_PASS" ]]; then
        demyx_die 'Missing required flags: --domain --email --user --pass'
    elif [[ -f "$DEMYX_STACK"/docker-compose.yml  ]]; then
        [[ -z "$DEMYX_INSTALL_FORCE" ]] && demyx_die 'Demyx is already installed'
    fi

    DEMYX_WILDCARD_CHECK=$(demyx util dig +short "*.$DEMYX_INSTALL_DOMAIN")
    [[ -z "$DEMYX_WILDCARD_CHECK" ]] && demyx_die "Wildcard CNAME not detected, please add * as a CNAME to your domain's DNS and rerun installation"
    
    source "$DEMYX_FUNCTION"/env.sh
    source "$DEMYX_FUNCTION"/yml.sh

    DEMYX_STACK_AUTH=$(demyx util --user="$DEMYX_INSTALL_USER" --htpasswd="$DEMYX_INSTALL_PASS" --raw)

    demyx_echo 'Creating stack .env'
    demyx_execute demyx_stack_env

    demyx_echo 'Creating stack .yml'
    demyx_execute demyx_stack_yml

    demyx_echo 'Creating stack config volume'
    demyx_execute docker volume create demyx_traefik

    demyx_echo 'Creating stack log volume'
    demyx_execute docker volume create demyx_traefik_log

    demyx_echo 'Creating stack container'
    demyx_execute docker run -dt --rm \
        --name demyx_install_container \
        -v demyx_traefik:/demyx \
        demyx/utilities bash

    demyx_echo 'Creating stack acme.json'
    demyx_execute docker exec -t demyx_install_container bash -c "touch /demyx/acme.json && chmod 600 /demyx/acme.json"

    demyx_echo 'Stopping stack container'
    demyx_execute docker stop demyx_install_container

    demyx stack up -d --remove-orphans
}
