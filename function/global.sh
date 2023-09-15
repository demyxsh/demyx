# Demyx
# https://demyx.sh

#
#   Checks if main app domain is www or not.
#
demyx_app_domain() {
    local DEMYX_APP_DOMAIN_ARG="${1:-$DEMYX_ARG_2}"
    local DEMYX_APP_DOMAIN_ARG_FIND=
    DEMYX_APP_DOMAIN_ARG_FIND="$(find "$DEMYX_APP" -name "$DEMYX_APP_DOMAIN_ARG")"
    local DEMYX_APP_DOMAIN_ARG_SUBDOMAIN_CHECK=
    local DEMYX_APP_DOMAIN_ARG_WWW=
    DEMYX_APP_DOMAIN_ARG_WWW="$(grep DEMYX_APP_DOMAIN_WWW "$DEMYX_APP_DOMAIN_ARG_FIND"/.env | awk -F '=' '{print $2}' || true)"

    if [[ "$DEMYX_APP_DOMAIN_ARG_WWW" = true ]]; then
        DEMYX_APP_DOMAIN_ARG_SUBDOMAIN_CHECK="$(awk -F '.' '{print $3}' <<< "$DEMYX_APP_DOMAIN_ARG")"

        if [[ -n "$DEMYX_APP_DOMAIN_ARG_SUBDOMAIN_CHECK" ]]; then
            echo "${DEMYX_APP_DOMAIN_ARG}"
        else
            echo "www.${DEMYX_APP_DOMAIN_ARG}"
        fi
    else
        echo "$DEMYX_APP_DOMAIN_ARG"
    fi
}
#
#   Get variable from app's .env file.
#
demyx_app_env() {
    local DEMYX_APP_ENV_1="${1:-}"
    local DEMYX_APP_ENV_2="${2:-}"
    local DEMYX_APP_FILE=

    case "$DEMYX_APP_ENV_1" in
        code)
            # TODO
        ;;
        html)
            # TODO
        ;;
        php)
            # TODO
        ;;
        wp)
            DEMYX_APP_FILE="$DEMYX_WP"/"$DEMYX_ARG_2"/.env
        ;;
    esac

    if [[ -f "$DEMYX_APP_FILE" ]]; then
        local DEMYX_APP_ENV_GREP="${DEMYX_APP_ENV_2:-}"
        local DEMYX_APP_ENV_I=
        local DEMYX_APP_ENV_I_VAL=
        local DEMYX_APP_ENV_REMOVE_ENV=
        local DEMYX_APP_ENV_REMOVE_COMPOSE=

        # TEMPORARY
        DEMYX_APP_ENV_REMOVE_ENV="$(grep DEMYX_APP_AUTH_HTPASSWD "$DEMYX_APP_FILE" || true)"
        if [[ -n "$DEMYX_APP_ENV_REMOVE_ENV" ]]; then
            sed -i "/DEMYX_APP_AUTH_HTPASSWD/d" "$DEMYX_WP"/"$DEMYX_ARG_2"/.env
        fi

        # TEMPORARY
        if [[ -f "$DEMYX_WP"/"$DEMYX_ARG_2"/docker-compose.yml ]]; then
            DEMYX_APP_ENV_REMOVE_COMPOSE="$(grep DEMYX_APP_AUTH_HTPASSWD "$DEMYX_WP"/"$DEMYX_ARG_2"/docker-compose.yml || true)"
            if [[ -n "$DEMYX_APP_ENV_REMOVE_COMPOSE" ]]; then
                sed -i "/DEMYX_APP_AUTH_HTPASSWD/d" "$DEMYX_WP"/"$DEMYX_ARG_2"/docker-compose.yml
            fi
        fi

        for DEMYX_APP_ENV_I in $DEMYX_APP_ENV_GREP; do
            DEMYX_APP_ENV_I_VAL="$(grep -w "$DEMYX_APP_ENV_I" "$DEMYX_APP_FILE" | awk -F '=' '{print $2}' || true)"

            # Refresh app's .env if variable doesn't exist.
            if [[ -z "$DEMYX_APP_ENV_I_VAL" ]]; then
                demyx_source env
                demyx_env

                # Grep again.
                DEMYX_APP_ENV_I_VAL="$(grep -w "$DEMYX_APP_ENV_I" "$DEMYX_APP_FILE" | awk -F '=' '{print $2}' || true)"
            fi

            # shellcheck disable=SC2316
            export local "$DEMYX_APP_ENV_I"="$DEMYX_APP_ENV_I_VAL"
        done
    else
        demyx_error custom "Invalid app or missing app's .env"
    fi
}
#
#   Update an app's specific environment variable.
#
demyx_app_env_update() {
    local DEMYX_APP_ENV_UPDATE="${1:-}"
    local DEMYX_APP_ENV_UPDATE_I=
    local DEMYX_APP_ENV_UPDATE_I_VAL=
    local DEMYX_APP_ENV_UPDATE_I_VAR=

    demyx_app_env wp "
        DEMYX_APP_PATH
        DEMYX_APP_STACK
    "

    demyx_source "
        env
        yml
    "

    demyx_env
    demyx_yml "$DEMYX_APP_STACK"

    for DEMYX_APP_ENV_UPDATE_I in $DEMYX_APP_ENV_UPDATE; do
        DEMYX_APP_ENV_UPDATE_I_VAL="${DEMYX_APP_ENV_UPDATE_I//*=/}"
        DEMYX_APP_ENV_UPDATE_I_VAR="${DEMYX_APP_ENV_UPDATE_I//=*/}"

        sed -i "s|${DEMYX_APP_ENV_UPDATE_I_VAR}=.*|${DEMYX_APP_ENV_UPDATE_I_VAR}=${DEMYX_APP_ENV_UPDATE_I_VAL}|g" "$DEMYX_APP_PATH"/.env
    done
}
#
#   Check if a WordPress or MariaDB container is running.
#
demyx_app_is_up() {
    local DEMYX_APP_IS_UP=
    DEMYX_APP_IS_UP="$(demyx_ps)"

    local DEMYX_APP_IS_UP_CHECK_DB=
    DEMYX_APP_IS_UP_CHECK_DB="$(echo "$DEMYX_APP_IS_UP" | grep "${DEMYX_APP_DB_CONTAINER:-}" || true)"
    local DEMYX_APP_IS_UP_CHECK_WP=
    DEMYX_APP_IS_UP_CHECK_WP="$(echo "$DEMYX_APP_IS_UP" | grep "${DEMYX_APP_WP_CONTAINER:-}" || true)"

    if [[ -z "$DEMYX_APP_IS_UP_CHECK_DB" || -z "$DEMYX_APP_IS_UP_CHECK_WP" ]]; then
        demyx_error "$DEMYX_APP_DOMAIN isn't running"
    fi
}
#
#   Output WordPress login URL.
#
#
demyx_app_login() {
    local DEMYX_APP_LOGIN=

    demyx_app_env wp "
        DEMYX_APP_WP_CONTAINER
        WORDPRESS_USER
    "

    while true; do
        DEMYX_APP_LOGIN="$(docker exec "$DEMYX_APP_WP_CONTAINER" wp login as "$WORDPRESS_USER" --url-only 2>&1 | tr '\r' ' ' || true)"

        if [[ "$DEMYX_APP_LOGIN" == *"Error:"* ]]; then
            sleep 1
        else
            echo "$DEMYX_APP_LOGIN"
            break
        fi
    done
}
#   Get app's path using find.
#
demyx_app_path() {
    local DEMYX_APP_PATH="${1:-$DEMYX_ARG_2}"
    find "$DEMYX_APP" -name "$DEMYX_APP_PATH" -type d
}
#
#   Echo out protocol based on DEMYX_APP_SSL.
#
demyx_app_proto() {
    local DEMYX_APP_PROTO=
    local DEMYX_APP_PROTO_ENV=
    DEMYX_APP_PROTO_ENV="$(demyx_app_path "$DEMYX_ARG_2")"/.env
    local DEMYX_APP_PROTO_SSL=

    if [[ -f "$DEMYX_APP_PROTO_ENV" ]]; then
        DEMYX_APP_PROTO_SSL="$(grep DEMYX_APP_SSL=false "$DEMYX_APP_PROTO_ENV" || true)"
    fi

    if [[ -n "$DEMYX_APP_PROTO_SSL" ]]; then
        DEMYX_APP_PROTO=http
    else
        DEMYX_APP_PROTO=https
    fi

    echo "$DEMYX_APP_PROTO"
}
#
#   Validates $DEMYX_ARG_2.
#
demyx_arg_valid() {
    if [[ "$DEMYX_ARG_2" == *"://"* ]]; then
        demyx_error custom "${DEMYX_ARG_2//:\/\/*/}:// is not allowed"
    fi

    if [[ "$DEMYX_ARG_2" == "www."* ]]; then
        demyx_error custom "www. is not allowed"
    fi

    if [[ "$DEMYX_ARG_2" == "code."* || "$DEMYX_ARG_2" == "traefik."* ]]; then
        demyx_error custom "That domain is reserved"
    fi

    local DEMYX_ARG_PATH_CHECK=
    DEMYX_ARG_PATH_CHECK="$(find "$DEMYX_APP" -name "$DEMYX_ARG_2" || true)"

    # shellcheck disable=SC2153
    if [[ "$DEMYX_ARG_1" != run && "$DEMYX_ARG_1" != restore ]]; then
        if [[ ! -d "$DEMYX_ARG_PATH_CHECK" && ! -f "$DEMYX_ARG_PATH_CHECK"/.env && ! -f "$DEMYX_ARG_PATH_CHECK"/docker-compose.yml ]]; then
            demyx_error app
        fi
    fi
}
#
#   Compare versions.
#
demyx_compare() {
    echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }';
}
#
#   Count all WP sites.
#
demyx_count_wp() {
    if [[ -d "$DEMYX_WP" ]]; then
        find "$DEMYX_WP" -mindepth 1 -maxdepth 1 -type d | wc -l
    else
        echo 0
    fi
}
#
#   Print a divider as long as the current terminal width. Defaults to 100.
#
demyx_divider() {
    local DEMYX_DIVIDER="${1:-}"
    local DEMYX_DIVIDER_COUNT="${DEMYX_DIVIDER:-50}"

    if [[ -t 0 && -z "$DEMYX_DIVIDER" ]]; then
        DEMYX_DIVIDER_COUNT="$(stty size | awk -F ' ' '{print $2}')"
    fi

    printf %"${DEMYX_DIVIDER_COUNT}"s | tr " " "="
    echo
}
#
#   Print divider title.
#
demyx_divider_title() {
    local DEMYX_DIVIDER_TITLE="${1:-}"
    local DEMYX_DIVIDER_TITLE_BODY="${2:-}"
    local DEMYX_DIVIDER_TITLE_COUNT="${3:-}"

    demyx_divider "$DEMYX_DIVIDER_TITLE_COUNT"
    echo "[$DEMYX_DIVIDER_TITLE] $DEMYX_DIVIDER_TITLE_BODY"
    demyx_divider "$DEMYX_DIVIDER_TITLE_COUNT"
}
#
#   Echos INFO messages
#
demyx_echo() {
    local DEMYX_ECHO="\e[34m[INFO]\e[39m ${1:-}"
    echo -e "$DEMYX_ECHO"
    demyx_logger false "demyx_echo" "$DEMYX_ECHO"
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
    echo "DEMYX_LOCAL_VERSION=$DEMYX_VERSION
    DEMYX_LOCAL_CODE_VERSION=$(docker run --rm --entrypoint=code-server demyx/code-server:browse --version 2>&1 | awk -F '[ ]' '{print $1}' | awk '{line=$0} END{print line}' | sed 's/\r//g')
    DEMYX_LOCAL_DOCKER_COMPOSE_VERSION=$(docker run --rm --entrypoint=docker-compose demyx/docker-compose --version 2>&1 | awk -F '[ ]' '{print $3}' | cut -c -6 | sed 's/\r//g')
    DEMYX_LOCAL_HAPROXY_VERSION=$(docker run --rm --user=root --entrypoint=haproxy demyx/docker-socket-proxy -v 2>&1 | head -1 | awk '{print $3}' | sed 's/\r//g')
    DEMYX_LOCAL_LOGROTATE_VERSION=$(docker run --rm --entrypoint=logrotate demyx/logrotate --version 2>&1 | head -n 1 | awk -F '[ ]' '{print $2}' | sed 's/\r//g')
    DEMYX_LOCAL_MARIADB_VERSION=$(docker run --rm --entrypoint=mariadb demyx/mariadb --version 2>&1 | awk -F '[ ]' '{print $6}' | awk -F '[,]' '{print $1}' | sed 's/-MariaDB//g' | sed 's/\r//g')
    DEMYX_LOCAL_NGINX_VERSION=$(docker run --rm --entrypoint=nginx demyx/nginx -V 2>&1 > /dev/null | head -n 1 | cut -c 22- | sed 's/\r//g')
    DEMYX_LOCAL_TRAEFIK_VERSION=$(docker run --rm --user=root --entrypoint=traefik demyx/traefik version 2>&1 | sed -n 1p | awk '{print $2}' | sed 's/\r//g')
    DEMYX_LOCAL_UTILITIES_VERSION=$(docker run --rm demyx/utilities cat /etc/debian_version 2>&1 | sed 's/\r//g')
    DEMYX_LOCAL_WORDPRESS_VERSION=$(docker run --rm --entrypoint=sh demyx/wordpress -c "grep '\$wp_version =' /demyx/wp-includes/version.php | cut -d\"'\" -f 2" 2>&1 | sed 's/\r//g')
    DEMYX_LOCAL_WORDPRESS_BEDROCK_VERSION=$(curl -sL https://api.github.com/repos/roots/bedrock/releases/latest 2>&1 | jq -r '.tag_name' | sed 's/\r//g')
    DEMYX_LOCAL_WORDPRESS_CLI_VERSION=$(docker run --rm demyx/wordpress:cli --version 2>&1 | awk -F '[ ]' '{print $2}' | sed 's/\r//g')
    DEMYX_LOCAL_WORDPRESS_PHP_VERSION=$(docker run --rm --entrypoint=php demyx/wordpress -v 2>&1 | grep cli | awk -F '[ ]' '{print $2}' | sed 's/\r//g')" | sed "s|    ||g" > "$DEMYX"/.update_local

    if [[ -n "$(docker images demyx/browsersync:latest -q)" ]]; then
        echo "DEMYX_LOCAL_BROWSERSYNC_VERSION=$(docker run --rm --entrypoint=browser-sync demyx/browsersync --version 2>&1 | sed 's/\r//g')" >> "$DEMYX"/.update_local
    fi

    if [[ -n "$(docker images demyx/openlitespeed:latest -q)" ]]; then
        echo "DEMYX_LOCAL_OPENLITESPEED_VERSION=$(docker run --rm --entrypoint=cat demyx/openlitespeed /usr/local/lsws/VERSION 2>&1 | sed 's/\r//g')" >> "$DEMYX"/.update_local
        echo "DEMYX_LOCAL_OPENLITESPEED_LSPHP_VERSION=$(docker run --rm --entrypoint=bash demyx/openlitespeed -c '/usr/local/lsws/lsphp74/bin/lsphp -v' 2>&1 | head -1 | awk '{print $2}' | sed 's/\r//g')" >> "$DEMYX"/.update_local
    fi

    if [[ -n "$(docker images demyx/ssh:latest -q)" ]]; then
        echo "DEMYX_LOCAL_OPENSSH_VERSION=$(docker run --rm --entrypoint=ssh demyx/ssh -V 2>&1 | cut -c -13 | awk -F '[_]' '{print $2}' | sed 's/\r//g')" >> "$DEMYX"/.update_local
    fi
}
demyx_update_remote() {
    for i in $DEMYX_GLOBAL_UPDATE_LIST
    do
        curl -sL https://raw.githubusercontent.com/demyxsh/"$i"/master/VERSION -o /tmp/"$i"
        source /tmp/"$i"
    done

    echo "DEMYX_REMOTE_VERSION=$DEMYX_VERSION
    DEMYX_REMOTE_CODE_VERSION=$DEMYX_CODE_VERSION
    DEMYX_REMOTE_DOCKER_COMPOSE_VERSION=$DEMYX_DOCKER_COMPOSE_VERSION
    DEMYX_REMOTE_HAPROXY_VERSION=$DEMYX_DOCKER_SOCKET_PROXY_HAPROXY_VERSION
    DEMYX_REMOTE_LOGROTATE_VERSION=$DEMYX_LOGROTATE_VERSION
    DEMYX_REMOTE_MARIADB_VERSION=$DEMYX_MARIADB_VERSION
    DEMYX_REMOTE_NGINX_VERSION=$DEMYX_NGINX_VERSION
    DEMYX_REMOTE_TRAEFIK_VERSION=$DEMYX_TRAEFIK_VERSION
    DEMYX_REMOTE_UTILITIES_VERSION=$DEMYX_UTILITIES_DEBIAN_VERSION
    DEMYX_REMOTE_WORDPRESS_VERSION=$DEMYX_WORDPRESS_VERSION
    DEMYX_REMOTE_WORDPRESS_BEDROCK_VERSION=$DEMYX_WORDPRESS_BEDROCK_VERSION
    DEMYX_REMOTE_WORDPRESS_CLI_VERSION=$DEMYX_WORDPRESS_CLI_VERSION
    DEMYX_REMOTE_WORDPRESS_PHP_VERSION=$DEMYX_WORDPRESS_PHP_VERSION" | sed "s|    ||g" > "$DEMYX"/.update_remote

    if [[ -n "$(docker images demyx/browsersync:latest -q)" ]]; then
        echo "DEMYX_REMOTE_BROWSERSYNC_VERSION=$DEMYX_BROWSERSYNC_VERSION" >> "$DEMYX"/.update_remote
    fi

    if [[ -n "$(docker images demyx/openlitespeed:latest -q)" ]]; then
        echo "DEMYX_REMOTE_OPENLITESPEED_VERSION=$DEMYX_OPENLITESPEED_VERSION" >> "$DEMYX"/.update_remote
        echo "DEMYX_REMOTE_OPENLITESPEED_LSPHP_VERSION=$DEMYX_OPENLITESPEED_LSPHP_VERSION"  >> "$DEMYX"/.update_remote
    fi

    if [[ -n "$(docker images demyx/ssh:latest -q)" ]]; then
        echo "DEMYX_REMOTE_OPENSSH_VERSION=$DEMYX_SSH_OPENSSH_VERSION" >> "$DEMYX"/.update_remote
    fi
}
demyx_update_image() {
    source "$DEMYX"/.update_local
    source "$DEMYX"/.update_remote

    # Remove old images list to prevent duplicates
    [[ -f "$DEMYX"/.update_image ]] && rm -f "$DEMYX"/.update_image

    # Generate image cache
    (( ${DEMYX_LOCAL_VERSION//./} < ${DEMYX_REMOTE_VERSION//./} )) && echo "demyx" > "$DEMYX"/.update_image
    if [[ -n "$DEMYX_LOCAL_BROWSERSYNC_VERSION" ]]; then
        (( "${DEMYX_LOCAL_BROWSERSYNC_VERSION//./}" < "${DEMYX_REMOTE_BROWSERSYNC_VERSION//./}" )) && echo "browsersync" >> "$DEMYX"/.update_image
    fi
    (( "${DEMYX_LOCAL_CODE_VERSION//./}" < "${DEMYX_REMOTE_CODE_VERSION//./}" )) && echo "code-server" >> "$DEMYX"/.update_image
    (( "${DEMYX_LOCAL_DOCKER_COMPOSE_VERSION//./}" < "${DEMYX_REMOTE_DOCKER_COMPOSE_VERSION//./}" )) && echo "docker-compose" >> "$DEMYX"/.update_image
    (( "${DEMYX_LOCAL_HAPROXY_VERSION//./}" < "${DEMYX_REMOTE_HAPROXY_VERSION//./}" )) && echo "docker-socket-proxy" >> "$DEMYX"/.update_image
    (( "${DEMYX_LOCAL_LOGROTATE_VERSION//./}" < "${DEMYX_REMOTE_LOGROTATE_VERSION//./}" )) && echo "logrotate" >> "$DEMYX"/.update_image
    (( "${DEMYX_LOCAL_MARIADB_VERSION//./}" < "${DEMYX_REMOTE_MARIADB_VERSION//./}" )) && echo "mariadb" >> "$DEMYX"/.update_image
    (( "${DEMYX_LOCAL_NGINX_VERSION//./}" < "${DEMYX_REMOTE_NGINX_VERSION//./}" )) && echo "nginx" >> "$DEMYX"/.update_image
    if [[ -n "$DEMYX_LOCAL_OPENLITESPEED_VERSION" ]]; then
        (( "${DEMYX_LOCAL_OPENLITESPEED_VERSION//./}" < "${DEMYX_REMOTE_OPENLITESPEED_VERSION//./}" || "${DEMYX_LOCAL_OPENLITESPEED_LSPHP_VERSION//./}" < "${DEMYX_REMOTE_OPENLITESPEED_LSPHP_VERSION//./}" )) && echo "openlitespeed" >> "$DEMYX"/.update_image
    fi
    if [[ -n "$DEMYX_LOCAL_OPENSSH_VERSION" ]]; then
        (( "${DEMYX_LOCAL_OPENSSH_VERSION//[.p]/}" < "${DEMYX_REMOTE_OPENSSH_VERSION//[.p]/}" )) && echo "ssh" >> "$DEMYX"/.update_image
    fi
    (( "${DEMYX_LOCAL_TRAEFIK_VERSION//./}" < "${DEMYX_REMOTE_TRAEFIK_VERSION//./}" )) && echo "traefik" >> "$DEMYX"/.update_image
    (( "${DEMYX_LOCAL_UTILITIES_VERSION//./}" < "${DEMYX_REMOTE_UTILITIES_VERSION//./}" )) && echo "utilities" >> "$DEMYX"/.update_image
    (( "${DEMYX_LOCAL_WORDPRESS_VERSION//./}" < "${DEMYX_REMOTE_WORDPRESS_VERSION//./}" || "${DEMYX_LOCAL_WORDPRESS_PHP_VERSION//./}" < "${DEMYX_REMOTE_WORDPRESS_PHP_VERSION//./}" )) && echo "wordpress" >> "$DEMYX"/.update_image
    (( "${DEMYX_LOCAL_WORDPRESS_BEDROCK_VERSION//./}" < "${DEMYX_REMOTE_WORDPRESS_BEDROCK_VERSION//./}" )) && echo "wordpress:bedrock" >> "$DEMYX"/.update_image
    (( "${DEMYX_LOCAL_WORDPRESS_CLI_VERSION//./}" < "${DEMYX_REMOTE_WORDPRESS_CLI_VERSION//./}" )) && echo "wordpress:cli" >> "$DEMYX"/.update_image
}
demyx_certificate_challenge() {
    if [[ "$DEMYX_APP_CLOUDFLARE" = true ]]; then
      echo "demyx-cf"
    else
      echo "demyx"
    fi
}
