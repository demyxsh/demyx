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
demyx_check_docker_sock() {
    DEMYX_GLOBAL_CHECK_DOCKER_SOCK="$(ls /run | grep docker.sock)"
    [[ -n "$DEMYX_GLOBAL_CHECK_DOCKER_SOCK" ]] && echo volume
    [[ -n "$DOCKER_HOST" ]] && echo proxy
}
# Global variables
DEMYX_GLOBAL_UPDATE_LIST="demyx browsersync code-server docker-compose docker-socket-proxy logrotate mariadb nginx openlitespeed ssh traefik utilities wordpress"
if [[ -n "$(demyx_check_docker_sock)" ]]; then
    # Global environment variables
    DEMYX_DOCKER_PS="$(docker ps)"
fi
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
demyx_dev_password() {
    if [[ -n "$DEMYX_APP_DEV_PASSWORD" ]]; then
        echo "$DEMYX_APP_DEV_PASSWORD"
    else
        echo "$(demyx util --pass --raw)"
    fi
}
demyx_update_local() {
    echo "DEMYX_LOCAL_VERSION=$DEMYX_BUILD
    DEMYX_LOCAL_BROWSERSYNC_VERSION=$(docker run --rm --entrypoint=browser-sync demyx/browsersync --version | sed 's/\r//g')
    DEMYX_LOCAL_CODE_VERSION=$(docker run --rm --entrypoint=code-server demyx/code-server --version | awk -F '[ ]' '{print $1}' | sed 's/\r//g')
    DEMYX_LOCAL_DOCKER_COMPOSE_VERSION=$(docker run --rm --entrypoint=docker-compose demyx/docker-compose --version | awk -F '[ ]' '{print $3}' | cut -c -6 | sed 's/\r//g')
    DEMYX_LOCAL_HAPROXY_VERSION=$(docker run --rm --user=root --entrypoint=haproxy demyx/docker-socket-proxy -v | awk '{print $3}' | sed 's/\r//g')
    DEMYX_LOCAL_LOGROTATE_VERSION=$(docker run --rm --entrypoint=logrotate demyx/logrotate --version | head -n 1 | awk -F '[ ]' '{print $2}' | sed 's/\r//g')
    DEMYX_LOCAL_MARIADB_VERSION=$(docker run --rm --entrypoint=mariadb demyx/mariadb --version | awk -F '[ ]' '{print $6}' | awk -F '[,]' '{print $1}' | sed 's/-MariaDB//g' | sed 's/\r//g')
    DEMYX_LOCAL_NGINX_VERSION=$(docker run --rm --entrypoint=nginx demyx/nginx -V 2>&1 | head -n 1 | cut -c 22- | sed 's/\r//g')
    DEMYX_LOCAL_OPENLITESPEED_VERSION=$(docker run --rm --entrypoint=cat demyx/openlitespeed /usr/local/lsws/VERSION | sed 's/\r//g')
    DEMYX_LOCAL_OPENLITESPEED_LSPHP_VERSION=$(docker run --rm --entrypoint=bash demyx/openlitespeed -c '/usr/local/lsws/${OPENLITESPEED_LSPHP_VERSION}/bin/lsphp -v' | head -1 | awk '{print $2}' | sed 's/\r//g')
    DEMYX_LOCAL_OPENSSH_VERSION=$(docker run --rm --entrypoint=ssh demyx/ssh -V  2>&1 | cut -c -13 | awk -F '[_]' '{print $2}' | sed 's/\r//g')
    DEMYX_LOCAL_TRAEFIK_VERSION=$(docker run --rm --user=root --entrypoint=traefik demyx/traefik version | sed -n 1p | awk '{print $2}' | sed 's/\r//g')
    DEMYX_LOCAL_UTILITIES_VERSION=$(docker run --rm demyx/utilities cat /etc/debian_version | sed 's/\r//g')
    DEMYX_LOCAL_WORDPRESS_VERSION=$(docker run --rm --entrypoint=sh demyx/wordpress -c "grep '\$wp_version =' /etc/demyx/wordpress/wp-includes/version.php | cut -d\"'\" -f 2" | sed 's/\r//g')
    DEMYX_LOCAL_WORDPRESS_CLI_VERSION=$(docker run --rm demyx/wordpress:cli --version | awk -F '[ ]' '{print $2}' | sed 's/\r//g')
    DEMYX_LOCAL_WORDPRESS_PHP_VERSION=$(docker run --rm --entrypoint=php demyx/wordpress -v | grep cli | awk -F '[ ]' '{print $2}' | sed 's/\r//g')
    DEMYX_LOCAL_WORDPRESS_BEDROCK_VERSION=$(curl -sL https://api.github.com/repos/roots/bedrock/releases/latest | jq -r '.tag_name' | sed 's/\r//g')" | sed "s|    ||g" > "$DEMYX"/.update_local
}
demyx_update_remote() {
    for i in $DEMYX_GLOBAL_UPDATE_LIST
    do
        curl -sL https://raw.githubusercontent.com/demyxco/"$i"/master/VERSION -o /tmp/"$i"
        source /tmp/"$i"
    done

    echo "DEMYX_REMOTE_VERSION=$DEMYX_VERSION
    DEMYX_REMOTE_BROWSERSYNC_VERSION=$DEMYX_BROWSERSYNC_VERSION
    DEMYX_REMOTE_CODE_VERSION=$DEMYX_CODE_VERSION
    DEMYX_REMOTE_DOCKER_COMPOSE_VERSION=$DEMYX_DOCKER_COMPOSE_VERSION
    DEMYX_REMOTE_HAPROXY_VERSION=$DEMYX_DOCKER_SOCKET_PROXY_HAPROXY_VERSION
    DEMYX_REMOTE_LOGROTATE_VERSION=$DEMYX_LOGROTATE_VERSION
    DEMYX_REMOTE_MARIADB_VERSION=$DEMYX_MARIADB_VERSION
    DEMYX_REMOTE_NGINX_VERSION=$DEMYX_NGINX_VERSION
    DEMYX_REMOTE_OPENLITESPEED_VERSION=$DEMYX_OPENLITESPEED_VERSION
    DEMYX_REMOTE_OPENLITESPEED_LSPHP_VERSION=$DEMYX_OPENLITESPEED_LSPHP_VERSION
    DEMYX_REMOTE_OPENSSH_VERSION=$DEMYX_SSH_OPENSSH_VERSION
    DEMYX_REMOTE_TRAEFIK_VERSION=$DEMYX_TRAEFIK_VERSION
    DEMYX_REMOTE_UTILITIES_VERSION=$DEMYX_UTILITIES_DEBIAN_VERSION
    DEMYX_REMOTE_WORDPRESS_VERSION=$DEMYX_WORDPRESS_VERSION
    DEMYX_REMOTE_WORDPRESS_CLI_VERSION=$DEMYX_WORDPRESS_CLI_VERSION
    DEMYX_REMOTE_WORDPRESS_PHP_VERSION=$DEMYX_WORDPRESS_PHP_VERSION
    DEMYX_REMOTE_WORDPRESS_BEDROCK_VERSION=$DEMYX_WORDPRESS_BEDROCK_VERSION" | sed "s|    ||g" > "$DEMYX"/.update_remote
}
demyx_update_count() {
    if [[ -f "$DEMYX"/.update_local && -f "$DEMYX"/.update_remote ]]; then
        DEMYX_UPDATE_LOCAL="$(cat "$DEMYX"/.update_local | awk -F '[=]' '{print $2}')"
        DEMYX_UPDATE_REMOTE="$(cat "$DEMYX"/.update_remote | awk -F '[=]' '{print $2}')"
        DEMYX_UPDATE_COUNT="$(diff <(echo "$DEMYX_UPDATE_LOCAL") <(echo "$DEMYX_UPDATE_REMOTE") | grep ^+ | sed '1d' | wc -l)"

        if (( "$DEMYX_UPDATE_COUNT" > 0 )); then
            echo "$DEMYX_UPDATE_COUNT" > "$DEMYX"/.update_count
            demyx_update_image
        else
            echo 0 > "$DEMYX"/.update_count
            [[ -f "$DEMYX"/.update_image ]] && rm "$DEMYX"/.update_image
        fi
    fi
}
demyx_update_image() {
    source "$DEMYX"/.update_local
    source "$DEMYX"/.update_remote
    
    # Delete iamge first
    [[ -f "$DEMYX"/.update_image ]] && rm "$DEMYX"/.update_image

    [[ "$DEMYX_LOCAL_VERSION" != "$DEMYX_REMOTE_VERSION" ]] && echo "demyx" >> "$DEMYX"/.update_image
    [[ "$DEMYX_LOCAL_BROWSERSYNC_VERSION" != "$DEMYX_REMOTE_BROWSERSYNC_VERSION" ]] && echo "browsersync" >> "$DEMYX"/.update_image
    [[ "$DEMYX_LOCAL_CODE_VERSION" != "$DEMYX_REMOTE_CODE_VERSION" ]] && echo "code-server" >> "$DEMYX"/.update_image
    [[ "$DEMYX_LOCAL_DOCKER_COMPOSE_VERSION" != "$DEMYX_REMOTE_DOCKER_COMPOSE_VERSION" ]] && echo "docker-compose" >> "$DEMYX"/.update_image
    [[ "$DEMYX_LOCAL_HAPROXY_VERSION" != "$DEMYX_REMOTE_HAPROXY_VERSION" ]] && echo "docker-socket-proxy" >> "$DEMYX"/.update_image
    [[ "$DEMYX_LOCAL_LOGROTATE_VERSION" != "$DEMYX_REMOTE_LOGROTATE_VERSION" ]] && echo "logrotate" >> "$DEMYX"/.update_image
    [[ "$DEMYX_LOCAL_MARIADB_VERSION" != "$DEMYX_REMOTE_MARIADB_VERSION" ]] && echo "mariadb" >> "$DEMYX"/.update_image
    [[ "$DEMYX_LOCAL_NGINX_VERSION" != "$DEMYX_REMOTE_NGINX_VERSION" ]] && echo "nginx" >> "$DEMYX"/.update_image
    [[ "$DEMYX_LOCAL_OPENLITESPEED_VERSION" != "$DEMYX_REMOTE_OPENLITESPEED_VERSION" || "$DEMYX_LOCAL_OPENLITESPEED_LSPHP_VERSION" != "$DEMYX_REMOTE_OPENLITESPEED_LSPHP_VERSION" ]] && echo "openlitespeed" >> "$DEMYX"/.update_image
    [[ "$DEMYX_LOCAL_OPENSSH_VERSION" != "$DEMYX_REMOTE_OPENSSH_VERSION" ]] && echo "ssh" >> "$DEMYX"/.update_image
    [[ "$DEMYX_LOCAL_TRAEFIK_VERSION" != "$DEMYX_REMOTE_TRAEFIK_VERSION" ]] && echo "traefik" >> "$DEMYX"/.update_image
    [[ "$DEMYX_LOCAL_UTILITIES_VERSION" != "$DEMYX_REMOTE_UTILITIES_VERSION" ]] && echo "utilities" >> "$DEMYX"/.update_image
    [[ "$DEMYX_LOCAL_WORDPRESS_VERSION" != "$DEMYX_REMOTE_WORDPRESS_VERSION" || "$DEMYX_LOCAL_WORDPRESS_PHP_VERSION" != "$DEMYX_REMOTE_WORDPRESS_PHP_VERSION" ]] && echo "wordpress" >> "$DEMYX"/.update_image
    [[ "$DEMYX_LOCAL_WORDPRESS_CLI_VERSION" != "$DEMYX_REMOTE_WORDPRESS_CLI_VERSION" ]] && echo "wordpress:cli" >> "$DEMYX"/.update_image
    [[ "$DEMYX_LOCAL_WORDPRESS_BEDROCK_VERSION" != "$DEMYX_REMOTE_WORDPRESS_BEDROCK_VERSION" ]] && echo "wordpress:bedrock" >> "$DEMYX"/.update_image
}
demyx_certificate_challenge() {
    if [[ "$DEMYX_APP_CLOUDFLARE" = true ]]; then
      echo "demyx-cf"
    else
      echo "demyx"
    fi
}
