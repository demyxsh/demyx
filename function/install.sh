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

    [[ -z "$DEMYX_STACK_RECENT_ERRORS" ]] && DEMYX_STACK_RECENT_ERRORS=100
    [[ -z "$DEMYX_STACK_DOCKER_WATCH" ]] && DEMYX_STACK_DOCKER_WATCH=true
    [[ -z "$DEMYX_STACK_DOCKER_EXPOSED_BY_DEFAULT" ]] && DEMYX_STACK_DOCKER_EXPOSED_BY_DEFAULT=false
    [[ -z "$DEMYX_STACK_ENTRYPOINT_DEFAULTENTRYPOINTS" ]] && DEMYX_STACK_ENTRYPOINT_DEFAULTENTRYPOINTS=http,https
    [[ -z "$DEMYX_STACK_ACME_ONHOSTRULE" ]] && DEMYX_STACK_ACME_ONHOSTRULE=true
    [[ -z "$DEMYX_STACK_ACME_STORAGE" ]] && DEMYX_STACK_ACME_STORAGE=/demyx/acme.json
    [[ -z "$DEMYX_STACK_ACME_ENTRYPOINT" ]] && DEMYX_STACK_ACME_ENTRYPOINT=https
    [[ -z "$DEMYX_STACK_ACME_HTTPCHALLENGE_ENTRYPOINT" ]] && DEMYX_STACK_ACME_HTTPCHALLENGE_ENTRYPOINT=http
    [[ -z "$DEMYX_STACK_LOG_LEVEL" ]] && DEMYX_STACK_LOG_LEVEL=INFO
    [[ -z "$DEMYX_STACK_LOG_ACCESS" ]] && DEMYX_STACK_LOG_ACCESS=/var/log/demyx/access.log
    [[ -z "$DEMYX_STACK_LOG_ERROR" ]] && DEMYX_STACK_LOG_ERROR=/var/log/demyx/error.log

    cat > "$DEMYX_STACK"/.env <<-EOF
        # AUTO GENERATED
        DEMYX_STACK_DOMAIN=$DEMYX_INSTALL_DOMAIN
        DEMYX_STACK_AUTH=$DEMYX_STACK_AUTH
        DEMYX_STACK_RECENT_ERRORS=$DEMYX_STACK_RECENT_ERRORS
        DEMYX_STACK_DOCKER_WATCH=$DEMYX_STACK_DOCKER_WATCH
        DEMYX_STACK_DOCKER_EXPOSED_BY_DEFAULT=$DEMYX_STACK_DOCKER_EXPOSED_BY_DEFAULT
        DEMYX_STACK_ENTRYPOINT_DEFAULTENTRYPOINTS=$DEMYX_STACK_ENTRYPOINT_DEFAULTENTRYPOINTS
        DEMYX_STACK_ACME_ONHOSTRULE=$DEMYX_STACK_ACME_ONHOSTRULE
        DEMYX_STACK_ACME_EMAIL=$DEMYX_INSTALL_EMAIL
        DEMYX_STACK_ACME_STORAGE=$DEMYX_STACK_ACME_STORAGE
        DEMYX_STACK_ACME_ENTRYPOINT=$DEMYX_STACK_ACME_ENTRYPOINT
        DEMYX_STACK_ACME_HTTPCHALLENGE_ENTRYPOINT=$DEMYX_STACK_ACME_HTTPCHALLENGE_ENTRYPOINT
        DEMYX_STACK_LOG_LEVEL=$DEMYX_STACK_LOG_LEVEL
        DEMYX_STACK_LOG_ACCESS=$DEMYX_STACK_LOG_ACCESS
        DEMYX_STACK_LOG_ERROR=$DEMYX_STACK_LOG_ERROR
        DEMYX_FORCE_STS_HEADER=$DEMYX_FORCE_STS_HEADER
        DEMYX_STS_SECONDS=$DEMYX_STS_SECONDS
        DEMYX_STS_INCLUDE_SUBDOMAINS=$DEMYX_STS_INCLUDE_SUBDOMAINS
        DEMYX_STS_PRELOAD=$DEMYX_STS_PRELOAD
EOF
    sed -i 's/        //' "$DEMYX_STACK"/.env

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
