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
}
