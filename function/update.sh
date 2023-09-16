# Demyx
# https://demyx.sh
#
#   demyx update <args>
#
demyx_update() {
    local DEMYX_UPDATE_FLAG=
    local DEMYX_UPDATE_FLAG_IMAGE=
    local DEMYX_UPDATE_FLAG_LIST=
    local DEMYX_UPDATE_FILE_LOCAL="$DEMYX"/.update_local
    local DEMYX_UPDATE_FILE_IMAGE="$DEMYX"/.update_image
    local DEMYX_UPDATE_FILE_REMOTE="$DEMYX"/.update_remote
    local DEMYX_UPDATE_IMAGES=
    DEMYX_UPDATE_IMAGES="$(demyx_images cat)"
    local DEMYX_UPDATE_TRANSIENT="$DEMYX_TMP"/demyx_transient

    while :; do
        DEMYX_UPDATE_FLAG="${1:-}"
        case "$DEMYX_UPDATE_FLAG" in
            -i)
                DEMYX_UPDATE_FLAG_IMAGE=true
            ;;
            -l)
                DEMYX_UPDATE_FLAG_LIST=true
            ;;
            --)
                shift
                break
                ;;
            -?*)
                demyx_error flag "$DEMYX_UPDATE_FLAG"
                ;;
            *)
                break
        esac
        shift
    done

    if [[ "$DEMYX_UPDATE_FLAG_LIST" = true ]]; then
        demyx_update_list
    else
        rm -f "$DEMYX"/.update*

        demyx_execute "Updating demyx image cache" \
            "demyx_images update"

        demyx_execute "Updating local cache" \
            "demyx_update_local"

        demyx_execute "Updating remote cache" \
            "demyx_update_remote"

        demyx_execute "Updating image cache" \
            "demyx_update_image"

        if [[ -z "$DEMYX_UPDATE_FLAG_IMAGE" ]]; then
            demyx_execute "Updating demyx helper on the host" \
                "docker run -t --rm \
                    -v /usr/local/bin:/tmp \
                    --user=root \
                    --entrypoint=bash \
                    demyx/demyx -c \"cp -f /etc/demyx/host.sh /tmp/demyx; chmod +x /tmp/demyx\""
        fi

        demyx_update_list
    fi
}
#
#   Generates demyx updater's local versions.
#
demyx_update_local() {
    echo "DEMYX_LOCAL_BROWSERSYNC_VERSION=$(docker run --rm --entrypoint=browser-sync demyx/browsersync --version)
    DEMYX_LOCAL_CODE_VERSION=$(docker run --rm --entrypoint=code-server demyx/code-server:browse --version | awk -F '[ ]' '{print $1}' | awk '{line=$0} END{print line}')
    DEMYX_LOCAL_DOCKER_COMPOSE_VERSION=$(docker run -it --rm --entrypoint=docker-compose demyx/demyx -v | awk -F ' ' '{print $3}' | sed 's|,||g')
    DEMYX_LOCAL_DOCKER_VERSION=$(docker run -it --rm --entrypoint=docker --user=root demyx/demyx -v | awk -F ' ' '{print $3}' | sed 's|,||g')
    DEMYX_LOCAL_HAPROXY_VERSION=$(docker run --rm --user=root --entrypoint=haproxy demyx/docker-socket-proxy -v | grep HA-Proxy | awk '{print $3}')
    DEMYX_LOCAL_MARIADB_VERSION=$(docker run --rm --entrypoint=mariadb demyx/mariadb --version | awk -F '[ ]' '{print $6}' | awk -F '[,]' '{print $1}' | sed 's/-MariaDB//g')
    DEMYX_LOCAL_NGINX_VERSION=$(docker run --rm --entrypoint=nginx demyx/nginx -V 2>&1 > /dev/null | head -n 1 | cut -c 22-)
    DEMYX_LOCAL_OPENLITESPEED_VERSION=$(docker run --rm --entrypoint=cat demyx/openlitespeed /usr/local/lsws/VERSION)
    DEMYX_LOCAL_OPENLITESPEED_LSPHP_LATEST_VERSION=$(docker run --rm --entrypoint=bash demyx/openlitespeed -c '/usr/local/lsws/lsphp81/bin/php -v' | head -1 | awk '{print $2}')
    DEMYX_LOCAL_OPENLITESPEED_LSPHP_VERSION=$(docker run --rm --entrypoint=bash demyx/openlitespeed -c '/usr/local/lsws/${DEMYX_LSPHP}/bin/php -v' | head -1 | awk '{print $2}')
    DEMYX_LOCAL_OPENSSH_VERSION=$(docker run --rm --entrypoint=ssh demyx/ssh -V  2>&1 | cut -c -13 | awk -F '[_]' '{print $2}')
    DEMYX_LOCAL_TRAEFIK_VERSION=$(docker run --rm --user=root --entrypoint=traefik demyx/traefik version | sed -n 1p | awk '{print $2}')
    DEMYX_LOCAL_UTILITIES_VERSION=$(docker run --rm demyx/utilities cat /etc/debian_version)
    DEMYX_LOCAL_WORDPRESS_BEDROCK_VERSION=$(curl -sL https://api.github.com/repos/roots/bedrock/releases/latest | jq -r '.tag_name')
    DEMYX_LOCAL_WORDPRESS_PHP_LATEST_VERSION=$(docker run --rm --entrypoint=php81 demyx/wordpress -v | grep cli | awk -F '[ ]' '{print $2}')
    DEMYX_LOCAL_WORDPRESS_PHP_VERSION=$(docker run --rm --entrypoint=php demyx/wordpress -v | grep cli | awk -F '[ ]' '{print $2}')
    DEMYX_LOCAL_WORDPRESS_VERSION=$(docker run --rm --entrypoint=sh demyx/wordpress -c "grep '\$wp_version =' /demyx/wp-includes/version.php | cut -d\"'\" -f 2")
    DEMYX_LOCAL_VERSION=$DEMYX_VERSION" > "$DEMYX_UPDATE_FILE_LOCAL"

    sed -i 's/[[:blank:]]//g' "$DEMYX_UPDATE_FILE_LOCAL"
}
#
#   Generates demyx updater's images that needs to be updated.
#
demyx_update_image() {
    local DEMYX_LOCAL_BROWSERSYNC_VERSION=
    local DEMYX_LOCAL_CODE_VERSION=
    local DEMYX_LOCAL_DOCKER_VERSION=
    local DEMYX_LOCAL_DOCKER_COMPOSE_VERSION=
    local DEMYX_LOCAL_HAPROXY_VERSION=
    local DEMYX_LOCAL_MARIADB_VERSION=
    local DEMYX_LOCAL_NGINX_VERSION=
    local DEMYX_LOCAL_OPENLITESPEED_LSPHP_LATEST_VERSION=
    local DEMYX_LOCAL_OPENLITESPEED_LSPHP_VERSION=
    local DEMYX_LOCAL_OPENLITESPEED_VERSION=
    local DEMYX_LOCAL_OPENSSH_VERSION=
    local DEMYX_LOCAL_TRAEFIK_VERSION=
    local DEMYX_LOCAL_UTILITIES_VERSION=
    local DEMYX_LOCAL_VERSION=
    local DEMYX_LOCAL_WORDPRESS_BEDROCK_VERSION=
    local DEMYX_LOCAL_WORDPRESS_PHP_LATEST_VERSION=
    local DEMYX_LOCAL_WORDPRESS_PHP_VERSION=
    local DEMYX_LOCAL_WORDPRESS_VERSION=
    local DEMYX_REMOTE_BROWSERSYNC_VERSION=
    local DEMYX_REMOTE_CODE_VERSION=
    local DEMYX_REMOTE_DOCKER_VERSION=
    local DEMYX_REMOTE_DOCKER_COMPOSE_VERSION=
    local DEMYX_REMOTE_HAPROXY_VERSION=
    local DEMYX_REMOTE_MARIADB_VERSION=
    local DEMYX_REMOTE_NGINX_VERSION=
    local DEMYX_REMOTE_OPENLITESPEED_LSPHP_LATEST_VERSION=
    local DEMYX_REMOTE_OPENLITESPEED_LSPHP_VERSION=
    local DEMYX_REMOTE_OPENLITESPEED_VERSION=
    local DEMYX_REMOTE_OPENSSH_VERSION=
    local DEMYX_REMOTE_TRAEFIK_VERSION=
    local DEMYX_REMOTE_UTILITIES_VERSION=
    local DEMYX_REMOTE_VERSION=
    local DEMYX_REMOTE_WORDPRESS_BEDROCK_VERSION=
    local DEMYX_REMOTE_WORDPRESS_PHP_LATEST_VERSION=
    local DEMYX_REMOTE_WORDPRESS_PHP_VERSION=
    local DEMYX_REMOTE_WORDPRESS_VERSION=

    . "$DEMYX_UPDATE_FILE_LOCAL"
    . "$DEMYX_UPDATE_FILE_REMOTE"

    touch "$DEMYX_UPDATE_FILE_IMAGE"

    if [[ -n "$DEMYX_LOCAL_VERSION" && -n "$DEMYX_REMOTE_VERSION" ]]; then
        if [[ "$(demyx_compare "$DEMYX_LOCAL_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_VERSION")" ]]; then
            echo "demyx" > "$DEMYX_UPDATE_FILE_IMAGE"
        fi
    fi

    if [[ -n "$DEMYX_LOCAL_DOCKER_VERSION" && -n "$DEMYX_REMOTE_DOCKER_VERSION" ]]; then
        if [[ "$(demyx_compare "$DEMYX_LOCAL_DOCKER_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_DOCKER_VERSION")" ]]; then
            echo "demyx" > "$DEMYX_UPDATE_FILE_IMAGE"
        fi
    fi

    if [[ -n "$DEMYX_LOCAL_DOCKER_COMPOSE_VERSION" && -n "$DEMYX_REMOTE_DOCKER_COMPOSE_VERSION" ]]; then
        if [[ "$(demyx_compare "$DEMYX_LOCAL_DOCKER_COMPOSE_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_DOCKER_COMPOSE_VERSION")" ]]; then
            echo "demyx" > "$DEMYX_UPDATE_FILE_IMAGE"
        fi
    fi

    if [[ -n "$DEMYX_LOCAL_BROWSERSYNC_VERSION" && -n "$DEMYX_REMOTE_BROWSERSYNC_VERSION" ]]; then
        if [[ "$(demyx_compare "$DEMYX_LOCAL_BROWSERSYNC_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_BROWSERSYNC_VERSION")" ]]; then
            echo "browsersync" >> "$DEMYX_UPDATE_FILE_IMAGE"
        fi
    fi

    if [[ -n "$DEMYX_LOCAL_CODE_VERSION" && -n "$DEMYX_REMOTE_CODE_VERSION" ]]; then
        if [[ "$(demyx_compare "$DEMYX_LOCAL_CODE_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_CODE_VERSION")" ]]; then
            echo "code-server" >> "$DEMYX_UPDATE_FILE_IMAGE"
        fi
    fi

    if [[ -n "$DEMYX_LOCAL_HAPROXY_VERSION" && -n "$DEMYX_REMOTE_HAPROXY_VERSION" ]]; then
        if [[ "$(demyx_compare "$DEMYX_LOCAL_HAPROXY_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_HAPROXY_VERSION")" ]]; then
            echo "docker-socket-proxy" >> "$DEMYX_UPDATE_FILE_IMAGE"
        fi
    fi

    if [[ -n "$DEMYX_LOCAL_MARIADB_VERSION" && -n "$DEMYX_REMOTE_MARIADB_VERSION" ]]; then
        if [[ "$(demyx_compare "$DEMYX_LOCAL_MARIADB_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_MARIADB_VERSION")" ]]; then
            echo "mariadb" >> "$DEMYX_UPDATE_FILE_IMAGE"
        fi
    fi

    if [[ -n "$DEMYX_LOCAL_NGINX_VERSION" && -n "$DEMYX_REMOTE_NGINX_VERSION" ]]; then
        if [[ "$(demyx_compare "$DEMYX_LOCAL_NGINX_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_NGINX_VERSION")" ]]; then
            echo "nginx" >> "$DEMYX_UPDATE_FILE_IMAGE"
        fi
    fi

    if [[ -n "$DEMYX_LOCAL_OPENLITESPEED_VERSION" && -n "$DEMYX_REMOTE_OPENLITESPEED_VERSION" ]]; then
        if [[ "$(demyx_compare "$DEMYX_LOCAL_OPENLITESPEED_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_OPENLITESPEED_VERSION")" ]]; then
            echo "openlitespeed" >> "$DEMYX_UPDATE_FILE_IMAGE"
        fi

        if [[ "$(demyx_compare "$DEMYX_LOCAL_OPENLITESPEED_LSPHP_LATEST_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_OPENLITESPEED_LSPHP_LATEST_VERSION")" ]]; then
            echo "openlitespeed" >> "$DEMYX_UPDATE_FILE_IMAGE"
        fi

        if [[ "$(demyx_compare "$DEMYX_LOCAL_OPENLITESPEED_LSPHP_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_OPENLITESPEED_LSPHP_VERSION")" ]]; then
            echo "openlitespeed" >> "$DEMYX_UPDATE_FILE_IMAGE"
        fi
    fi

    if [[ -n "$DEMYX_LOCAL_OPENSSH_VERSION" && -n "$DEMYX_REMOTE_OPENSSH_VERSION" ]]; then
        if [[ "$(demyx_compare "$DEMYX_LOCAL_OPENSSH_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_OPENSSH_VERSION")" ]]; then
            echo "ssh" >> "$DEMYX_UPDATE_FILE_IMAGE"
        fi
    fi

    if [[ -n "$DEMYX_LOCAL_TRAEFIK_VERSION" && -n "$DEMYX_REMOTE_TRAEFIK_VERSION" ]]; then
        if [[ "$(demyx_compare "$DEMYX_LOCAL_TRAEFIK_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_TRAEFIK_VERSION")" ]]; then
            echo "traefik" >> "$DEMYX_UPDATE_FILE_IMAGE"
        fi
    fi

    if [[ -n "$DEMYX_LOCAL_UTILITIES_VERSION" && -n "$DEMYX_REMOTE_UTILITIES_VERSION" ]]; then
        if [[ "$(demyx_compare "$DEMYX_LOCAL_UTILITIES_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_UTILITIES_VERSION")" ]]; then
            echo "utilities" >> "$DEMYX_UPDATE_FILE_IMAGE"
        fi
    fi

    if [[ -n "$DEMYX_LOCAL_WORDPRESS_VERSION" && -n "$DEMYX_REMOTE_WORDPRESS_VERSION" ]]; then
        if [[ "$(demyx_compare "$DEMYX_LOCAL_WORDPRESS_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_WORDPRESS_VERSION")" ]]; then
            echo "wordpress" >> "$DEMYX_UPDATE_FILE_IMAGE"
        fi

        if [[ "$(demyx_compare "$DEMYX_LOCAL_WORDPRESS_PHP_LATEST_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_WORDPRESS_PHP_LATEST_VERSION")" ]]; then
            echo "wordpress" >> "$DEMYX_UPDATE_FILE_IMAGE"
        fi

        if [[ "$(demyx_compare "$DEMYX_LOCAL_WORDPRESS_PHP_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_WORDPRESS_PHP_VERSION")" ]]; then
            echo "wordpress" >> "$DEMYX_UPDATE_FILE_IMAGE"
        fi
    fi

    if [[ -n "$DEMYX_LOCAL_WORDPRESS_BEDROCK_VERSION" && -n "$DEMYX_REMOTE_WORDPRESS_BEDROCK_VERSION" ]]; then
        if [[ "$(demyx_compare "$DEMYX_LOCAL_WORDPRESS_BEDROCK_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_WORDPRESS_BEDROCK_VERSION")" ]]; then
            echo "wordpress:bedrock" >> "$DEMYX_UPDATE_FILE_IMAGE"
        fi
    fi
}
#
#   Shows table of local/remote versions of updates.
#
demyx_update_list() {
    local DEMYX_UPDATE_LIST_COUNT=
    local DEMYX_UPDATE_LIST_TITLE=
    local DEMYX_LOCAL_BROWSERSYNC_VERSION=
    local DEMYX_LOCAL_CODE_VERSION=
    local DEMYX_LOCAL_DOCKER_VERSION=
    local DEMYX_LOCAL_DOCKER_COMPOSE_VERSION=
    local DEMYX_LOCAL_HAPROXY_VERSION=
    local DEMYX_LOCAL_MARIADB_VERSION=
    local DEMYX_LOCAL_NGINX_VERSION=
    local DEMYX_LOCAL_OPENLITESPEED_LSPHP_LATEST_VERSION=
    local DEMYX_LOCAL_OPENLITESPEED_LSPHP_VERSION=
    local DEMYX_LOCAL_OPENLITESPEED_VERSION=
    local DEMYX_LOCAL_OPENSSH_VERSION=
    local DEMYX_LOCAL_TRAEFIK_VERSION=
    local DEMYX_LOCAL_UTILITIES_VERSION=
    local DEMYX_LOCAL_VERSION=
    local DEMYX_LOCAL_WORDPRESS_BEDROCK_VERSION=
    local DEMYX_LOCAL_WORDPRESS_PHP_LATEST_VERSION=
    local DEMYX_LOCAL_WORDPRESS_PHP_VERSION=
    local DEMYX_LOCAL_WORDPRESS_VERSION=
    local DEMYX_REMOTE_BROWSERSYNC_VERSION=
    local DEMYX_REMOTE_DOCKER_VERSION=
    local DEMYX_REMOTE_DOCKER_COMPOSE_VERSION=
    local DEMYX_REMOTE_HAPROXY_VERSION=
    local DEMYX_REMOTE_MARIADB_VERSION=
    local DEMYX_REMOTE_NGINX_VERSION=
    local DEMYX_REMOTE_OPENLITESPEED_LSPHP_LATEST_VERSION=
    local DEMYX_REMOTE_OPENLITESPEED_LSPHP_VERSION=
    local DEMYX_REMOTE_OPENLITESPEED_VERSION=
    local DEMYX_REMOTE_OPENSSH_VERSION=
    local DEMYX_REMOTE_TRAEFIK_VERSION=
    local DEMYX_REMOTE_UTILITIES_VERSION=
    local DEMYX_REMOTE_VERSION=
    local DEMYX_REMOTE_WORDPRESS_BEDROCK_VERSION=
    local DEMYX_REMOTE_WORDPRESS_PHP_LATEST_VERSION=
    local DEMYX_REMOTE_WORDPRESS_PHP_VERSION=
    local DEMYX_REMOTE_WORDPRESS_VERSION=

    if [[ ! -f "$DEMYX"/.update_local || ! -f "$DEMYX"/.update_remote ]]; then
        demyx_echo "Image cache files missing, fetching now ..."
        demyx_source update
        demyx_update -i
    fi

    . "$DEMYX"/.update_local
    . "$DEMYX"/.update_remote

    if [[ -n "$DEMYX_LOCAL_CODE_VERSION" && -n "$DEMYX_REMOTE_CODE_VERSION" ]]; then
        if [[ "$(demyx_compare "$DEMYX_LOCAL_CODE_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_CODE_VERSION")" ]]; then
            DEMYX_REMOTE_CODE_VERSION="$(echo -e "\e[32m(NEW) ${DEMYX_REMOTE_CODE_VERSION}\e[39m")"
        else
            DEMYX_REMOTE_CODE_VERSION=
        fi
    fi

    if [[ -n "$DEMYX_LOCAL_VERSION" && -n "$DEMYX_REMOTE_VERSION" ]]; then
        if [[ "$(demyx_compare "$DEMYX_LOCAL_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_VERSION")" ]]; then
            DEMYX_REMOTE_VERSION="$(echo -e "\e[32m(NEW) ${DEMYX_REMOTE_VERSION}\e[39m")"
        else
            DEMYX_REMOTE_VERSION=
        fi
    fi

    if [[ -n "$DEMYX_LOCAL_DOCKER_VERSION" && -n "$DEMYX_REMOTE_DOCKER_VERSION" ]]; then
        if [[ "$(demyx_compare "$DEMYX_LOCAL_DOCKER_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_DOCKER_VERSION")" ]]; then
            DEMYX_REMOTE_DOCKER_VERSION="$(echo -e "\e[32m(NEW) ${DEMYX_REMOTE_DOCKER_VERSION}\e[39m")"
        else
            DEMYX_REMOTE_DOCKER_VERSION=
        fi
    fi

    if [[ -n "$DEMYX_LOCAL_DOCKER_COMPOSE_VERSION" && -n "$DEMYX_REMOTE_DOCKER_COMPOSE_VERSION" ]]; then
        if [[ "$(demyx_compare "$DEMYX_LOCAL_DOCKER_COMPOSE_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_DOCKER_COMPOSE_VERSION")" ]]; then
            DEMYX_REMOTE_DOCKER_COMPOSE_VERSION="$(echo -e "\e[32m(NEW) ${DEMYX_REMOTE_DOCKER_COMPOSE_VERSION}\e[39m")"
        else
            DEMYX_REMOTE_DOCKER_COMPOSE_VERSION=
        fi
    fi

    if [[ -n "$DEMYX_LOCAL_HAPROXY_VERSION" && -n "$DEMYX_REMOTE_HAPROXY_VERSION" ]]; then
        if [[ "$(demyx_compare "$DEMYX_LOCAL_HAPROXY_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_HAPROXY_VERSION")" ]]; then
            DEMYX_REMOTE_HAPROXY_VERSION="$(echo -e "\e[32m(NEW) ${DEMYX_REMOTE_HAPROXY_VERSION}\e[39m")"
        else
            DEMYX_REMOTE_HAPROXY_VERSION=
        fi
    fi

    if [[ -n "$DEMYX_LOCAL_MARIADB_VERSION" && -n "$DEMYX_REMOTE_MARIADB_VERSION" ]]; then
        if [[ "$(demyx_compare "$DEMYX_LOCAL_MARIADB_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_MARIADB_VERSION")" ]]; then
            DEMYX_REMOTE_MARIADB_VERSION="$(echo -e "\e[32m(NEW) ${DEMYX_REMOTE_MARIADB_VERSION}\e[39m")"
        else
            DEMYX_REMOTE_MARIADB_VERSION=
        fi
    fi

    if [[ -n "$DEMYX_LOCAL_NGINX_VERSION" && -n "$DEMYX_REMOTE_NGINX_VERSION" ]]; then
        if [[ "$(demyx_compare "$DEMYX_LOCAL_NGINX_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_NGINX_VERSION")" ]]; then
            DEMYX_REMOTE_NGINX_VERSION="$(echo -e "\e[32m(NEW) ${DEMYX_REMOTE_NGINX_VERSION}\e[39m")"
        else
            DEMYX_REMOTE_NGINX_VERSION=
        fi
    fi

    if [[ -n "$DEMYX_LOCAL_TRAEFIK_VERSION" && -n "$DEMYX_REMOTE_TRAEFIK_VERSION" ]]; then
        if [[ "$(demyx_compare "$DEMYX_LOCAL_TRAEFIK_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_TRAEFIK_VERSION")" ]]; then
            DEMYX_REMOTE_TRAEFIK_VERSION="$(echo -e "\e[32m(NEW) ${DEMYX_REMOTE_TRAEFIK_VERSION}\e[39m")"
        else
            DEMYX_REMOTE_TRAEFIK_VERSION=
        fi
    fi

    if [[ -n "$DEMYX_LOCAL_UTILITIES_VERSION" && -n "$DEMYX_REMOTE_UTILITIES_VERSION" ]]; then
        if [[ "$(demyx_compare "$DEMYX_LOCAL_UTILITIES_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_UTILITIES_VERSION")" ]]; then
            DEMYX_REMOTE_UTILITIES_VERSION="$(echo -e "\e[32m(NEW) ${DEMYX_REMOTE_UTILITIES_VERSION}\e[39m")"
        else
            DEMYX_REMOTE_UTILITIES_VERSION=
        fi
    fi

    if [[ -n "$DEMYX_LOCAL_WORDPRESS_VERSION" && -n "$DEMYX_REMOTE_WORDPRESS_VERSION" ]]; then
        if [[ "$(demyx_compare "$DEMYX_LOCAL_WORDPRESS_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_WORDPRESS_VERSION")" ]]; then
            DEMYX_REMOTE_WORDPRESS_VERSION="$(echo -e "\e[32m(NEW) ${DEMYX_REMOTE_WORDPRESS_VERSION}\e[39m")"
        else
            DEMYX_REMOTE_WORDPRESS_VERSION=
        fi
    fi

    if [[ -n "$DEMYX_LOCAL_WORDPRESS_PHP_LATEST_VERSION" && -n "$DEMYX_REMOTE_WORDPRESS_PHP_LATEST_VERSION" ]]; then
        if [[ "$(demyx_compare "$DEMYX_LOCAL_WORDPRESS_PHP_LATEST_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_WORDPRESS_PHP_LATEST_VERSION")" ]]; then
            DEMYX_REMOTE_WORDPRESS_PHP_LATEST_VERSION="$(echo -e "\e[32m(NEW) ${DEMYX_REMOTE_WORDPRESS_PHP_LATEST_VERSION}\e[39m")"
        else
            DEMYX_REMOTE_WORDPRESS_PHP_LATEST_VERSION=
        fi
    fi

    if [[ -n "$DEMYX_LOCAL_WORDPRESS_PHP_VERSION" && -n "$DEMYX_REMOTE_WORDPRESS_PHP_VERSION" ]]; then
        if [[ "$(demyx_compare "$DEMYX_LOCAL_WORDPRESS_PHP_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_WORDPRESS_PHP_VERSION")" ]]; then
            DEMYX_REMOTE_WORDPRESS_PHP_VERSION="$(echo -e "\e[32m(NEW) ${DEMYX_REMOTE_WORDPRESS_PHP_VERSION}\e[39m")"
        else
            DEMYX_REMOTE_WORDPRESS_PHP_VERSION=
        fi
    fi

    if [[ -n "$DEMYX_LOCAL_WORDPRESS_BEDROCK_VERSION" && -n "$DEMYX_REMOTE_WORDPRESS_BEDROCK_VERSION" ]]; then
        if [[ "$(demyx_compare "$DEMYX_LOCAL_WORDPRESS_BEDROCK_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_WORDPRESS_BEDROCK_VERSION")" ]]; then
            DEMYX_REMOTE_WORDPRESS_BEDROCK_VERSION="$(echo -e "\e[32m(NEW) ${DEMYX_LOCAL_WORDPRESS_BEDROCK_VERSION}\e[39m")"
        else
            DEMYX_REMOTE_WORDPRESS_BEDROCK_VERSION=
        fi
    fi

    {
        if [[ "$DEMYX_UPDATE_IMAGES" == *"demyx/browsersync"* ]]; then
            if [[ "$(demyx_compare "$DEMYX_LOCAL_BROWSERSYNC_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_BROWSERSYNC_VERSION")" ]]; then
                DEMYX_REMOTE_BROWSERSYNC_VERSION="$(echo -e "\e[32m(NEW) ${DEMYX_REMOTE_BROWSERSYNC_VERSION}\e[39m")"
            else
                DEMYX_REMOTE_BROWSERSYNC_VERSION=
            fi

            echo "Browsersync             $DEMYX_LOCAL_BROWSERSYNC_VERSION $DEMYX_REMOTE_BROWSERSYNC_VERSION"
        fi

        echo "Code Server             $DEMYX_LOCAL_CODE_VERSION $DEMYX_REMOTE_CODE_VERSION"
        echo "Demyx                   $DEMYX_LOCAL_VERSION $DEMYX_REMOTE_VERSION"
        echo " - Docker               $DEMYX_LOCAL_DOCKER_VERSION $DEMYX_REMOTE_DOCKER_VERSION"
        echo " - Docker Compose       $DEMYX_LOCAL_DOCKER_COMPOSE_VERSION $DEMYX_REMOTE_DOCKER_COMPOSE_VERSION"
        echo "Docker Socket Proxy     $DEMYX_LOCAL_HAPROXY_VERSION $DEMYX_REMOTE_HAPROXY_VERSION"
        echo "MariaDB                 $DEMYX_LOCAL_MARIADB_VERSION $DEMYX_REMOTE_MARIADB_VERSION"
        echo "Nginx                   $DEMYX_LOCAL_NGINX_VERSION $DEMYX_REMOTE_NGINX_VERSION"

        if [[ "$DEMYX_UPDATE_IMAGES" == *"demyx/openlitespeed"* ]]; then
            if [[ "$(demyx_compare "$DEMYX_LOCAL_OPENLITESPEED_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_OPENLITESPEED_VERSION")" ]]; then
                DEMYX_REMOTE_OPENLITESPEED_VERSION="$(echo -e "\e[32m(NEW) ${DEMYX_REMOTE_OPENLITESPEED_VERSION}\e[39m")"
            else
                DEMYX_REMOTE_OPENLITESPEED_VERSION=
            fi

            if [[ -n "$DEMYX_LOCAL_OPENLITESPEED_LSPHP_LATEST_VERSION" && -n "$DEMYX_REMOTE_OPENLITESPEED_LSPHP_LATEST_VERSION" ]]; then
                if [[ "$(demyx_compare "$DEMYX_LOCAL_OPENLITESPEED_LSPHP_LATEST_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_OPENLITESPEED_LSPHP_LATEST_VERSION")" ]]; then
                    DEMYX_REMOTE_OPENLITESPEED_LSPHP_LATEST_VERSION="$(echo -e "\e[32m(NEW) ${DEMYX_REMOTE_OPENLITESPEED_LSPHP_LATEST_VERSION}\e[39m")"
                else
                    DEMYX_REMOTE_OPENLITESPEED_LSPHP_LATEST_VERSION=
                fi
            fi

            if [[ -n "$DEMYX_LOCAL_OPENLITESPEED_LSPHP_VERSION" && -n "$DEMYX_REMOTE_OPENLITESPEED_LSPHP_VERSION" ]]; then
                if [[ "$(demyx_compare "$DEMYX_LOCAL_OPENLITESPEED_LSPHP_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_OPENLITESPEED_LSPHP_VERSION")" ]]; then
                    DEMYX_REMOTE_OPENLITESPEED_LSPHP_VERSION="$(echo -e "\e[32m(NEW) ${DEMYX_REMOTE_OPENLITESPEED_LSPHP_VERSION}\e[39m")"
                else
                    DEMYX_REMOTE_OPENLITESPEED_LSPHP_VERSION=
                fi
            fi

            echo "OpenLiteSpeed           $DEMYX_LOCAL_OPENLITESPEED_VERSION $DEMYX_REMOTE_OPENLITESPEED_VERSION"
            echo " - LSPHP                $DEMYX_LOCAL_OPENLITESPEED_LSPHP_VERSION $DEMYX_REMOTE_OPENLITESPEED_LSPHP_VERSION"
            echo " - LSPHP Latest         $DEMYX_LOCAL_OPENLITESPEED_LSPHP_LATEST_VERSION $DEMYX_REMOTE_OPENLITESPEED_LSPHP_LATEST_VERSION"
        fi

        if [[ "$DEMYX_UPDATE_IMAGES" == *"demyx/ssh"* ]]; then
            if [[ "$(demyx_compare "$DEMYX_LOCAL_OPENSSH_VERSION")" -lt "$(demyx_compare "$DEMYX_REMOTE_OPENSSH_VERSION")" ]]; then
                DEMYX_REMOTE_OPENSSH_VERSION="$(echo -e "\e[32m(NEW) ${DEMYX_REMOTE_OPENSSH_VERSION}\e[39m")"
            else
                DEMYX_REMOTE_OPENSSH_VERSION=
            fi

            echo "SSH/SFTP                $DEMYX_LOCAL_OPENSSH_VERSION $DEMYX_REMOTE_OPENSSH_VERSION"
        fi

        echo "Traefik                 $DEMYX_LOCAL_TRAEFIK_VERSION $DEMYX_REMOTE_TRAEFIK_VERSION"
        echo "Utilities               $DEMYX_LOCAL_UTILITIES_VERSION $DEMYX_REMOTE_UTILITIES_VERSION"
        echo "WordPress               $DEMYX_LOCAL_WORDPRESS_VERSION $DEMYX_REMOTE_WORDPRESS_VERSION"
        echo " - PHP                  $DEMYX_LOCAL_WORDPRESS_PHP_VERSION $DEMYX_REMOTE_WORDPRESS_PHP_VERSION"
        echo " - PHP Latest           $DEMYX_LOCAL_WORDPRESS_PHP_LATEST_VERSION $DEMYX_REMOTE_WORDPRESS_PHP_LATEST_VERSION"
        echo " - Bedrock              $DEMYX_LOCAL_WORDPRESS_BEDROCK_VERSION $DEMYX_REMOTE_WORDPRESS_BEDROCK_VERSION"

    } > "$DEMYX_UPDATE_TRANSIENT"

    DEMYX_UPDATE_LIST_COUNT="$(cat < "$DEMYX_UPDATE_FILE_IMAGE" | wc -l)"

    if (( "$DEMYX_UPDATE_LIST_COUNT" > 1 )); then
        DEMYX_UPDATE_LIST_TITLE="$DEMYX_UPDATE_LIST_COUNT Updates"
    else
        DEMYX_UPDATE_LIST_TITLE="$DEMYX_UPDATE_LIST_COUNT Update"
    fi

    demyx_execute false \
        "demyx_divider_title \"DEMYX - UPDATE\" \"${DEMYX_UPDATE_LIST_TITLE}\"; \
            cat < $DEMYX_UPDATE_TRANSIENT"
}
}
