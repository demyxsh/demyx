# Demyx
# https://demyx.sh

demyx_die() {
    while :; do
        case "$1" in
            --command-not-found)
                DEMYX_DIE_COMMAND_NOT_FOUND=1
                ;;
            --not-found)
                DEMYX_DIE_NOT_FOUND=1
                ;;
            --no-help)
                DEMYX_DIE_NO_HELP=1
                ;;
            --restore-not-found)
                DEMYX_DIE_RESTORE_NOT_FOUND=1
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

    if [[ -n "$DEMYX_DIE_NOT_FOUND" ]]; then
        printf '\e[31m[CRITICAL]\e[39m Not a valid app\n'
    elif [[ -n "$DEMYX_DIE_COMMAND_NOT_FOUND" ]]; then
        printf '\e[31m[CRITICAL]\e[39m Not a valid command\n'
    elif [[ -n "$DEMYX_DIE_RESTORE_NOT_FOUND" ]]; then
        printf "\e[31m[CRITICAL]\e[39m Directory doesn't exist, try: demyx restore "$DEMYX_TARGET" -f\n"
    else
        printf '\e[31m[CRITICAL]\e[39m %s\n' "$1" >&2
    fi

    [[ -z "$DEMYX_DIE_NO_HELP" ]] && demyx help "$DEMYX_COMMAND"

    exit 1
}
demyx_echo() {
    DEMYX_ECHO="$1"
}
demyx_execute() {
    while :; do
        case "$1" in
            -q)
                DEMYX_EXECUTE_QUIET=1
                ;;
            -v)
                DEMYX_EXECUTE_VERBOSE=1
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

    if [[ -n "$DEMYX_EXECUTE_VERBOSE" ]]; then
        DEMYX_ECHO=""
        DEMYX_EXECUTE_VERBOSE=""
        DEMYX_EXECUTE=""
        "$@"
    else
        echo -n "$DEMYX_ECHO ... "
        DEMYX_EXECUTE=$("$@")
        echo -en "\e[32mdone\e[39m\n"
    fi

    [[ "$DEMYX_EXECUTE" == *"WARNING"* ]] && echo -e "\e[33m[WARNING]\e[39m \"demyx log\" for more info"

    # Remove passwords from log
    DEMYX_COMMON_LOG="$(echo -e "[$(date +%F-%T)] ========================================")\n"
    if [[ "$@" == *"pass"* ]]; then
        DEMYX_COMMON_LOG+="$(echo -e "[$(date +%F-%T)] DEMYX: $DEMYX_COMMAND $DEMYX_TARGET")\n"
        DEMYX_COMMON_LOG+="$(echo -e "[$(date +%F-%T)] ECHO: $DEMYX_ECHO")\n"
        DEMYX_COMMON_LOG+="$(echo -e "[$(date +%F-%T)] COMMAND: ${@%%*pass*=*}")\n"
        DEMYX_COMMON_LOG+="$(echo -e "[$(date +%F-%T)] STDOUT: $(echo ${DEMYX_EXECUTE%%*pass*=*} | tr -d "\n\r")")\n"
    elif [[ "$@" == *"PASS"* ]]; then
        DEMYX_COMMON_LOG+="$(echo -e "[$(date +%F-%T)] DEMYX: $DEMYX_COMMAND $DEMYX_TARGET")\n"
        DEMYX_COMMON_LOG+="$(echo -e "[$(date +%F-%T)] ECHO: $DEMYX_ECHO")\n"
        DEMYX_COMMON_LOG+="$(echo -e "[$(date +%F-%T)] COMMAND: $1")\n"
        DEMYX_COMMON_LOG+="$(echo -e "[$(date +%F-%T)] STDOUT: $(echo ${2%%*PASS*} | tr -d "\n\r")")\n"
    elif [[ -n "$DEMYX_EXECUTE_QUIET" ]]; then
        DEMYX_COMMON_LOG+="$(echo -e "[$(date +%F-%T)] DEMYX: $DEMYX_COMMAND $DEMYX_TARGET")\n"
        DEMYX_COMMON_LOG+="$(echo -e "[$(date +%F-%T)] ECHO: $DEMYX_ECHO")\n"
        DEMYX_COMMON_LOG+="$(echo -e "[$(date +%F-%T)] EXECUTE: ***")\n"
        DEMYX_COMMON_LOG+="$(echo -e "[$(date +%F-%T)] STDOUT: ***")\n"
        DEMYX_EXECUTE_QUIET=
    elif [[ "$DEMYX_COMMAND" = monitor ]]; then
        DEMYX_COMMON_LOG+="$(echo -e "[$(date +%F-%T)] DEMYX: $DEMYX_COMMAND $DEMYX_APP_DOMAIN")\n"
        DEMYX_COMMON_LOG+="$(echo -e "[$(date +%F-%T)] ECHO: $DEMYX_ECHO")\n"
        DEMYX_COMMON_LOG+="$(echo -e "[$(date +%F-%T)] EXECUTE: $(echo "$@" | tr -d "\n\r")")\n"
        DEMYX_COMMON_LOG+="$(echo -e "[$(date +%F-%T)] STDOUT: $(echo "$DEMYX_EXECUTE" | tr -d "\n\r")")\n"
    else
        DEMYX_COMMON_LOG+="$(echo -e "[$(date +%F-%T)] DEMYX: $DEMYX_COMMAND $DEMYX_TARGET")\n"
        DEMYX_COMMON_LOG+="$(echo -e "[$(date +%F-%T)] ECHO: $DEMYX_ECHO")\n"
        DEMYX_COMMON_LOG+="$(echo -e "[$(date +%F-%T)] EXECUTE: $(echo "$@" | tr -d "\n\r")")\n"
        DEMYX_COMMON_LOG+="$(echo -e "[$(date +%F-%T)] STDOUT: $(echo "$DEMYX_EXECUTE" | tr -d "\n\r")")\n"
    fi
    DEMYX_COMMON_LOG+="$(echo -e "[$(date +%F-%T)] ========================================")"
    echo -e "$DEMYX_COMMON_LOG" >> /var/log/demyx/demyx.log
}
demyx_table() {
    docker run -t --rm demyx/utilities "demyx-table '$@'"
}
demyx_permission() {
    chown -R demyx:demyx "$DEMYX"
}
demyx_app_config() {
    DEMYX_GET_APP=$(find "$DEMYX_APP" -name "$DEMYX_TARGET")
    [[ -f "$DEMYX_GET_APP"/.env ]] && source "$DEMYX_GET_APP"/.env && source "$DEMYX_FUNCTION"/app-check.sh
}
demyx_open_port() {
    DEMYX_SFTP_PORT=$(docker run -it --rm \
    --network host \
    -e DEMYX_SFTP_PORT="$DEMYX_SFTP_PORT_DEFAULT" \
    demyx/utilities demyx-port)
    
    echo "$DEMYX_SFTP_PORT" | sed -e 's/\r//g'
}
demyx_mariadb_ready() {
    DEMYX_MARIADB_READY_PASSWORD=$(echo "$MARIADB_ROOT_PASSWORD" | sed -e 's/\r//g')
    until docker exec -t "$DEMYX_APP_DB_CONTAINER" mysqladmin -u root -p"$DEMYX_MARIADB_READY_PASSWORD" status
    do
        sleep 1
    done
}
demyx_generate_password() {
    DEMYX_PASSWORD_1=$(tr -dc "[:xdigit:]" < /dev/urandom | head -c 10 | sed -e 's/\r//g')
    DEMYX_PASSWORD_2=$(tr -dc "[:xdigit:]" < /dev/urandom | head -c 10 | sed -e 's/\r//g')
    DEMYX_PASSWORD_3=$(tr -dc "[:xdigit:]" < /dev/urandom | head -c 10 | sed -e 's/\r//g')
    DEMYX_PASSWORD_4=$(tr -dc "[:xdigit:]" < /dev/urandom | head -c 10 | sed -e 's/\r//g')
    
    echo "${DEMYX_PASSWORD_1}-${DEMYX_PASSWORD_2}-${DEMYX_PASSWORD_3}-${DEMYX_PASSWORD_4}"
}
demyx_nginx_cloudflare_check() {
    DEMYX_CLOUDFLARE_CHECK=$(curl -svo /dev/null "$DEMYX_APP_DOMAIN" 2>&1 | grep "Server: cloudflare" || true)
    if [[ -n "$DEMYX_CLOUDFLARE_CHECK" ]]; then
        DEMYX_NGINX_REAL_IP='real_ip_header CF-Connecting-IP;'
    else
        DEMYX_NGINX_REAL_IP='real_ip_header X-Forwarded-For;'
    fi
}
