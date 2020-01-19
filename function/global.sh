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

    [[ -z "$DEMYX_DIE_NO_HELP" ]] && echo -e "\e[34m[INFO]\e[39m demyx help $DEMYX_COMMAND"

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

        # Log wp commands for cron
        if [[ "$DEMYX_COMMAND" = wp ]]; then
            DEMYX_EXECUTE=$("$@")
            echo "$DEMYX_EXECUTE"
        else
            "$@"
        fi
    else
        echo -n "$DEMYX_ECHO ... "
        DEMYX_EXECUTE=$("$@")
        echo -en "\e[32mdone\e[39m\n"
    fi

    [[ "$DEMYX_EXECUTE" == *"WARNING"* ]] && echo -e "\e[33m[WARNING]\e[39m Proceeding without SSL, see \"demyx log\" for more info"

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
    demyx_source table
    printTable '^' "$@"
}
demyx_permission() {
    chown -R demyx:demyx "$DEMYX"
    chown -R demyx:demyx "$DEMYX_LOG"
}
demyx_app_config() {
    DEMYX_GET_APP="$(find "$DEMYX_APP" -name "$DEMYX_TARGET")"
    [[ -f "$DEMYX_GET_APP"/.env ]] && source "$DEMYX_GET_APP"/.env
}
demyx_app_is_up() {
    DEMYX_APP_IS_UP_CHECK_DB="$(echo "$DEMYX_DOCKER_PS" | grep "$DEMYX_APP_DB_CONTAINER")"
    DEMYX_APP_IS_UP_CHECK_WP="$(echo "$DEMYX_DOCKER_PS" | grep "$DEMYX_APP_WP_CONTAINER")"
    if [[ -z "$DEMYX_APP_IS_UP_CHECK_DB" || -z "$DEMYX_APP_IS_UP_CHECK_WP" ]]; then
        demyx_die "$DEMYX_APP_DOMAIN isn't running"
    fi
}
demyx_open_port() {
    DEMYX_UTILITIES_PORT=22222
    [[ -n "$1" ]] && DEMYX_UTILITIES_PORT="$1"
    
    docker run -it --rm \
    --network=host \
    -e DEMYX_UTILITIES_PORT="$DEMYX_UTILITIES_PORT" \
    demyx/utilities demyx-port | sed 's/\r//g'
}
demyx_mariadb_ready() {
    until docker exec -t "$DEMYX_APP_DB_CONTAINER" mysqladmin -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" status 2>/dev/null
    do
        sleep 1
    done
}
demyx_bedrock_ready() {
    until docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "ls | grep web"
    do
        sleep 1
    done
}
demyx_wordpress_ready() {
    until docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "ls | grep xmlrpc.php"
    do
        sleep 1
    done
}
demyx_generate_password() {
    DEMYX_PASSWORD_1="$(uuidgen | awk -F '[-]' '{print $5}' | head -c $(( ( RANDOM % 10 )  + 4 )) | sed -e 's/\r//g')"
    DEMYX_PASSWORD_2="$(uuidgen | awk -F '[-]' '{print $5}' | head -c $(( ( RANDOM % 10 )  + 4 )) | sed -e 's/\r//g')"
    DEMYX_PASSWORD_3="$(uuidgen | awk -F '[-]' '{print $5}' | head -c $(( ( RANDOM % 10 )  + 4 )) | sed -e 's/\r//g')"
    DEMYX_PASSWORD_4="$(uuidgen | awk -F '[-]' '{print $5}' | head -c $(( ( RANDOM % 10 )  + 4 )) | sed -e 's/\r//g')"
    
    echo "${DEMYX_PASSWORD_1}-${DEMYX_PASSWORD_2}-${DEMYX_PASSWORD_3}-${DEMYX_PASSWORD_4}"
}
demyx_wp_check_empty() {
    DEMYX_COMMON_WP_APPS="$(ls "$DEMYX_WP")"
    if [[ -z "$DEMYX_COMMON_WP_APPS" ]]; then
        if [[ "$1" = true ]]; then
            demyx_die 'There are no WordPress apps installed.'
        else
            exit 1
        fi
    fi
}
demyx_upgrade_apps() {
    demyx_wp_check_empty
    
    cd "$DEMYX_WP"
    for i in *
    do
        DEMYX_CHECK_APP_IMAGE="$(grep DEMYX_APP_WP_IMAGE "$DEMYX_WP"/"$i"/.env | awk -F '[=]' '{print $2}')"
        if [[ "$DEMYX_CHECK_APP_IMAGE" = demyx/nginx-php-wordpress || "$DEMYX_CHECK_APP_IMAGE" = demyx/nginx-php-wordpress:bedrock ]]; then
            demyx_execute -v echo -e "- demyx config $i --upgrade"
        fi
    done
}
demyx_validate_ip() {
    echo "$DEMYX_APP_DOMAIN" | grep -E '(([0-9]{1,3})\.){3}([0-9]{1,3}){1}'  | grep -vE '25[6-9]|2[6-9][0-9]|[3-9][0-9][0-9]' | grep -Eo '(([0-9]{1,2}|1[0-9]{1,2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]{1,2}|1[0-9]{1,2}|2[0-4][0-9]|25[0-5]){1}'
}
demyx_check_docker_sock() {
    DEMYX_GLOBAL_CHECK_DOCKER_SOCK="$(ls /run | grep docker.sock)"
    [[ -n "$DEMYX_GLOBAL_CHECK_DOCKER_SOCK" ]] && echo volume
    [[ -n "$DOCKER_HOST" ]] && echo proxy
}
demyx_get_mode() {
    if [[ -f /tmp/demyx-dev ]]; then
        echo development
    else
        echo production
    fi
}
demyx_socket() {
    docker run -d \
    --privileged \
    --name=demyx_socket \
    --network=demyx_socket \
    --cpus="$DEMYX_CPU" \
    --memory="$DEMYX_MEM" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e CONTAINERS=1 \
    -e EXEC=1 \
    -e IMAGES=1 \
    -e INFO=1 \
    -e NETWORKS=1 \
    -e POST=1 \
    -e VOLUMES=1 \
    demyx/docker-socket-proxy 2>/dev/null
}
demyx_source() {
    if [[ "$1" = stack && -f "$DEMYX_STACK"/.env ]]; then
        source "$DEMYX_STACK"/.env
    else
        source "$DEMYX_FUNCTION"/"$1".sh
    fi
}
demyx_alpine_check() {
    [[ -n "$(uname -a | grep Alpine || true)" ]] && echo true
}
demyx_ols_not_supported() {
    [[ "$DEMYX_APP_STACK" = ols ]] && demyx_die "OpenLiteSpeed doesn't support feature"
}
demyx_warning() {
    demyx_execute -v echo -e "\e[33m[WARNING]\e[39m $1"
}

if [[ -n "$(demyx_check_docker_sock)" ]]; then
    # Global environment variables
    DEMYX_DOCKER_PS="$(docker ps)"
fi
