# Demyx
# https://demyx.sh
#
#   demyx config <app> <args>
#
demyx_config() {
    DEMYX_ARG_2="${1:-$DEMYX_ARG_2}"
    shift && local DEMYX_CONFIG_ARGS="$*"
    local DEMYX_CONFIG=
    local DEMYX_CONFIG_COMPOSE=
    local DEMYX_CONFIG_FLAG=
    local DEMYX_CONFIG_FLAG_AUTH=
    local DEMYX_CONFIG_FLAG_AUTH_WP=
    local DEMYX_CONFIG_FLAG_BEDROCK=
    local DEMYX_CONFIG_FLAG_CACHE=
    local DEMYX_CONFIG_FLAG_CLEAN=
    local DEMYX_CONFIG_FLAG_DEV=
    local DEMYX_CONFIG_FLAG_HEALTHCHECK=
    local DEMYX_CONFIG_FLAG_NO_COMPOSE=
    local DEMYX_CONFIG_FLAG_OPCACHE=
    local DEMYX_CONFIG_FLAG_PHP=
    local DEMYX_CONFIG_FLAG_PHP_MAX_CHILDREN=
    local DEMYX_CONFIG_FLAG_PHP_MAX_REQUESTS=
    local DEMYX_CONFIG_FLAG_PHP_MAX_SPARE_SERVERS=
    local DEMYX_CONFIG_FLAG_PHP_MIN_SPARE_SERVERS=
    local DEMYX_CONFIG_FLAG_PHP_PM=
    local DEMYX_CONFIG_FLAG_PHP_PROCESS_IDLE_TIMEOUT=
    local DEMYX_CONFIG_FLAG_PHP_START_SERVERS=
    local DEMYX_CONFIG_FLAG_PHP_VERSION=
    local DEMYX_CONFIG_FLAG_PMA=
    local DEMYX_CONFIG_FLAG_RATE_LIMIT=
    local DEMYX_CONFIG_FLAG_RESOURCES=
    local DEMYX_CONFIG_FLAG_RESOURCES_DB_CPU=
    local DEMYX_CONFIG_FLAG_RESOURCES_DB_MEM=
    local DEMYX_CONFIG_FLAG_RESOURCES_WP_CPU=
    local DEMYX_CONFIG_FLAG_RESOURCES_WP_MEM=
    local DEMYX_CONFIG_FLAG_RESTART=
    local DEMYX_CONFIG_FLAG_SFTP=
    local DEMYX_CONFIG_FLAG_SSL=
    local DEMYX_CONFIG_FLAG_STACK=
    local DEMYX_CONFIG_FLAG_WHITELIST=
    local DEMYX_CONFIG_FLAG_WP_UPDATE=
    local DEMYX_CONFIG_FLAG_WWW=
    local DEMYX_CONFIG_FLAG_XMLRPC=
    local DEMYX_CONFIG_TRANSIENT="$DEMYX_TMP"/demyx_transient

    demyx_source "
        compose
        exec
        maldet
        utility
        wp
        yml
    "

    while :; do
        DEMYX_CONFIG_FLAG="${1:-}"
        case "$DEMYX_CONFIG_FLAG" in
            --auth|--auth=true)
                DEMYX_CONFIG_FLAG_AUTH=true
            ;;
            --auth=false)
                DEMYX_CONFIG_FLAG_AUTH=false
            ;;
            --auth-wp|--auth-wp=true)
                DEMYX_CONFIG_FLAG_AUTH_WP=true
            ;;
            --auth-wp=false)
                DEMYX_CONFIG_FLAG_AUTH_WP=false
            ;;
            --bedrock|--bedrock=production)
                DEMYX_CONFIG_FLAG_BEDROCK=production
            ;;
            --bedrock=development)
                DEMYX_CONFIG_FLAG_BEDROCK=development
            ;;
            --cache|--cache=true)
                DEMYX_CONFIG_FLAG_CACHE=true
            ;;
            --cache=false)
                DEMYX_CONFIG_FLAG_CACHE=false
            ;;
            --clean)
                DEMYX_CONFIG_FLAG_CLEAN=true
            ;;
            --db-cpu=0|--db-cpu=?*)
                DEMYX_CONFIG_FLAG_RESOURCES=true
                DEMYX_CONFIG_FLAG_RESOURCES_DB_CPU="${DEMYX_CONFIG_FLAG#*=}"
            ;;
            --db-mem=0|--db-mem=?*)
                DEMYX_CONFIG_FLAG_RESOURCES=true
                DEMYX_CONFIG_FLAG_RESOURCES_DB_MEM="${DEMYX_CONFIG_FLAG#*=}"
            ;;
            --dev|--dev=true)
                DEMYX_CONFIG_FLAG_DEV=true
            ;;
            --dev=false)
                DEMYX_CONFIG_FLAG_DEV=false
            ;;
            --healthcheck|--healthcheck=true)
                DEMYX_CONFIG_FLAG_HEALTHCHECK=true
            ;;
            --healthcheck=false)
                DEMYX_CONFIG_FLAG_HEALTHCHECK=false
            ;;
            --no-compose)
                DEMYX_CONFIG_FLAG_NO_COMPOSE=true
            ;;
            --opcache|--opcache=true)
                DEMYX_CONFIG_FLAG_OPCACHE=true
            ;;
            --opcache=false)
                DEMYX_CONFIG_FLAG_OPCACHE=false
            ;;
            --php=8|--php=8.0|--php=8.1)
                DEMYX_CONFIG_FLAG_PHP=true
                DEMYX_CONFIG_FLAG_PHP_VERSION="${DEMYX_CONFIG_FLAG#*=}"
            ;;
            --php-max-children=?*)
                DEMYX_CONFIG_FLAG_PHP=true
                DEMYX_CONFIG_FLAG_PHP_MAX_CHILDREN="${DEMYX_CONFIG_FLAG#*=}"
            ;;
            --php-max-requests=?*)
                DEMYX_CONFIG_FLAG_PHP=true
                DEMYX_CONFIG_FLAG_PHP_MAX_REQUESTS="${DEMYX_CONFIG_FLAG#*=}"
            ;;
            --php-max-spare-servers=?*)
                DEMYX_CONFIG_FLAG_PHP=true
                DEMYX_CONFIG_FLAG_PHP_MAX_SPARE_SERVERS="${DEMYX_CONFIG_FLAG#*=}"
            ;;
            --php-min-spare-servers=?*)
                DEMYX_CONFIG_FLAG_PHP=true
                DEMYX_CONFIG_FLAG_PHP_MIN_SPARE_SERVERS="${DEMYX_CONFIG_FLAG#*=}"
            ;;
            --php-pm=?*)
                DEMYX_CONFIG_FLAG_PHP=true
                DEMYX_CONFIG_FLAG_PHP_PM="${DEMYX_CONFIG_FLAG#*=}"
            ;;
            --php-process-idle-timeout=?*)
                DEMYX_CONFIG_FLAG_PHP=true
                DEMYX_CONFIG_FLAG_PHP_PROCESS_IDLE_TIMEOUT="${DEMYX_CONFIG_FLAG#*=}"
            ;;
            --php-start-servers=?*)
                DEMYX_CONFIG_FLAG_PHP=true
                DEMYX_CONFIG_FLAG_PHP_START_SERVERS="${DEMYX_CONFIG_FLAG#*=}"
            ;;
            --pma|--pma=true)
                DEMYX_CONFIG_FLAG_PMA=true
            ;;
            --pma=false)
                DEMYX_CONFIG_FLAG_PMA=false
            ;;
            --rate-limit|--rate-limit=true)
                DEMYX_CONFIG_FLAG_RATE_LIMIT=true
            ;;
            --rate-limit=false)
                DEMYX_CONFIG_FLAG_RATE_LIMIT=false
            ;;
            --sftp|--sftp=true)
                DEMYX_CONFIG_FLAG_SFTP=true
            ;;
            --sftp=false)
                DEMYX_CONFIG_FLAG_SFTP=false
            ;;
            --ssl|--ssl=true)
                DEMYX_CONFIG_FLAG_SSL=true
            ;;
            --ssl=false)
                DEMYX_CONFIG_FLAG_SSL=false
            ;;
            --stack=bedrock|--stack=nginx-php|--stack=ols|--stack=ols-bedrock)
                DEMYX_CONFIG_FLAG_STACK="${DEMYX_CONFIG_FLAG#*=}"
            ;;
            --whitelist|--whitelist=all|--whitelist=login)
                DEMYX_CONFIG_FLAG_WHITELIST="${DEMYX_CONFIG_FLAG#*=}"
            ;;
            --whitelist=false)
                DEMYX_CONFIG_FLAG_WHITELIST=false
            ;;
            --wp-cpu=0|--wp-cpu=?*)
                DEMYX_CONFIG_FLAG_RESOURCES=true
                DEMYX_CONFIG_FLAG_RESOURCES_WP_CPU="${DEMYX_CONFIG_FLAG#*=}"
            ;;
            --wp-mem=0|--wp-mem=?*)
                DEMYX_CONFIG_FLAG_RESOURCES=true
                DEMYX_CONFIG_FLAG_RESOURCES_WP_MEM="${DEMYX_CONFIG_FLAG#*=}"
            ;;
            --wp-update|--wp-update=true)
                DEMYX_CONFIG_FLAG_WP_UPDATE=true
            ;;
            --wp-update=false)
                DEMYX_CONFIG_FLAG_WP_UPDATE=false
            ;;
            --www)
                DEMYX_CONFIG_FLAG_WWW=true
            ;;
            --www=false)
                DEMYX_CONFIG_FLAG_WWW=false
            ;;
            --xmlrpc|--xmlrpc=true)
                DEMYX_CONFIG_FLAG_XMLRPC=true
            ;;
            --xmlrpc=false)
                DEMYX_CONFIG_FLAG_XMLRPC=false
            ;;
            --) shift
                break
            ;;
            -?*)
                demyx_error flag "$DEMYX_CONFIG_FLAG"
            ;;
            *) break
        esac
        shift
    done

    case "$DEMYX_ARG_2" in
        all)
            demyx_config_all
        ;;
        *)
            if [[ -n "$DEMYX_ARG_2" ]]; then
                demyx_arg_valid

                if [[ -n "$DEMYX_CONFIG_FLAG_AUTH" ]]; then
                    demyx_config_auth
                fi
                if [[ -n "$DEMYX_CONFIG_FLAG_AUTH_WP" ]]; then
                    demyx_config_auth_wp
                fi
                if [[ -n "$DEMYX_CONFIG_FLAG_BEDROCK" ]]; then
                    demyx_config_bedrock
                fi
                if [[ -n "$DEMYX_CONFIG_FLAG_CACHE" ]]; then
                    demyx_config_cache
                fi
                if [[ -n "$DEMYX_CONFIG_FLAG_CLEAN" ]]; then
                    demyx_config_clean
                fi
                if [[ -n "$DEMYX_CONFIG_FLAG_DEV" ]]; then
                    demyx_config_dev
                fi
                if [[ -n "$DEMYX_CONFIG_FLAG_HEALTHCHECK" ]]; then
                    demyx_config_healthcheck
                fi
                if [[ -n "$DEMYX_CONFIG_FLAG_OPCACHE" ]]; then
                    demyx_config_opcache
                fi
                if [[ -n "$DEMYX_CONFIG_FLAG_PHP" ]]; then
                    demyx_config_php
                fi
                if [[ -n "$DEMYX_CONFIG_FLAG_PMA" ]]; then
                    demyx_config_pma
                fi
                if [[ -n "$DEMYX_CONFIG_FLAG_RATE_LIMIT" ]]; then
                    demyx_config_rate_limit
                fi
                if [[ -n "$DEMYX_CONFIG_FLAG_RESOURCES" ]]; then
                    demyx_config_resources
                fi
                if [[ -n "$DEMYX_CONFIG_FLAG_RESTART" ]]; then
                    demyx_config_restart
                fi
                if [[ -n "$DEMYX_CONFIG_FLAG_SFTP" ]]; then
                    demyx_config_sftp
                fi
                if [[ -n "$DEMYX_CONFIG_FLAG_SSL" ]]; then
                    demyx_config_ssl
                fi
                if [[ -n "$DEMYX_CONFIG_FLAG_STACK" ]]; then
                    demyx_config_stack
                fi
                if [[ -n "$DEMYX_CONFIG_FLAG_WP_UPDATE" ]]; then
                    demyx_config_wp_update
                fi
                if [[ -n "$DEMYX_CONFIG_FLAG_WHITELIST" ]]; then
                    demyx_config_whitelist
                fi
                if [[ -n "$DEMYX_CONFIG_FLAG_WWW" ]]; then
                    demyx_config_www
                fi
                if [[ -n "$DEMYX_CONFIG_FLAG_XMLRPC" ]]; then
                    demyx_config_xmlrpc
                fi
                if [[ -z "$DEMYX_ARG_2" ]]; then
                    demyx_help config
                fi
                if [[ "$DEMYX_CONFIG_COMPOSE" = true && "$DEMYX_CONFIG_FLAG_NO_COMPOSE" != true ]]; then
                    demyx_compose "$DEMYX_ARG_2" up -d --remove-orphans
                fi
                if [[ -n "$DEMYX_CONFIG" ]]; then
                    demyx_execute false "demyx_divider_title \"DEMYX - CONFIG\" \"${DEMYX_CONFIG}\"; \
                        cat < $DEMYX_CONFIG_TRANSIENT"
                fi
            else
                demyx_help config
            fi
        ;;
    esac
}
#
#   Loop arguments for all sites.
#
demyx_config_all() {
    local DEMYX_CONFIG_ALL=

    cd "$DEMYX_WP" || exit

    for DEMYX_CONFIG_ALL in *; do
        demyx_echo "Configuring $DEMYX_CONFIG_ALL"
        eval demyx_config "$DEMYX_CONFIG_ALL" "$DEMYX_CONFIG_ARGS"
    done
}
#
#   Configures app's basic auth labels.
#
demyx_config_auth() {
    demyx_app_env wp "
        DEMYX_APP_AUTH
        DEMYX_APP_AUTH_USERNAME
        DEMYX_APP_AUTH_PASSWORD
        DEMYX_APP_STACK
    "

    DEMYX_CONFIG="Basic Auth"
    DEMYX_CONFIG_COMPOSE=true

    demyx_execute "Setting $DEMYX_CONFIG_FLAG_AUTH to basic auth" \
        "demyx_app_env_update DEMYX_APP_AUTH=${DEMYX_CONFIG_FLAG_AUTH}; \
        demyx_yml $DEMYX_APP_STACK"

    if [[ "$DEMYX_CONFIG_FLAG_AUTH" = true ]]; then
        {
            echo "Username      $DEMYX_APP_AUTH_USERNAME"
            echo "Password      $DEMYX_APP_AUTH_PASSWORD"
        } > "$DEMYX_CONFIG_TRANSIENT"
    fi
}
#
#   Configures app's basic auth for WordPress login page.
#
demyx_config_auth_wp() {
    demyx_app_env wp "
        DEMYX_APP_AUTH_WP
        DEMYX_APP_AUTH_USERNAME
        DEMYX_APP_AUTH_PASSWORD
        DEMYX_APP_STACK
    "

    DEMYX_CONFIG="WordPress Login Basic Auth"
    DEMYX_CONFIG_COMPOSE=true

    demyx_execute "Setting $DEMYX_CONFIG_FLAG_AUTH_WP to WordPress basic auth" \
        "demyx_app_env_update DEMYX_APP_AUTH_WP=${DEMYX_CONFIG_FLAG_AUTH_WP}; \
        demyx_yml $DEMYX_APP_STACK"

    if [[ "$DEMYX_CONFIG_FLAG_AUTH_WP" = true ]]; then
        {
            echo "Username      $DEMYX_APP_AUTH_USERNAME"
            echo "Password      $DEMYX_APP_AUTH_PASSWORD"
        } > "$DEMYX_CONFIG_TRANSIENT"
    fi
}
#
#   Configures app's bedrock .env mode.
#
demyx_config_bedrock() {
    demyx_app_env wp "
        DEMYX_APP_BEDROCK_MODE
        DEMYX_APP_WP_CONTAINER
    "

    demyx_execute "Setting Bedrock config to $DEMYX_CONFIG_FLAG_BEDROCK" \
        "docker exec -t $DEMYX_APP_WP_CONTAINER sh -c \"sed -i 's|WP_ENV=.*|WP_ENV=$DEMYX_CONFIG_FLAG_BEDROCK|g' /demyx/.env\"; \
        demyx_app_env_update DEMYX_APP_BEDROCK_MODE=$DEMYX_CONFIG_FLAG_BEDROCK"
}
#
#   Configures app's cache plugin.
#
demyx_config_cache() {
    demyx_app_env wp "
        DEMYX_APP_CACHE
        DEMYX_APP_DOMAIN
        DEMYX_APP_STACK
    "

    local DEMYX_CONFIG_CACHE_CHECK=
    local DEMYX_CONFIG_CACHE_PLUGIN=
    DEMYX_CONFIG_COMPOSE=true

    case "$DEMYX_APP_STACK" in
        bedrock|nginx-php)
            DEMYX_CONFIG_CACHE_PLUGIN=nginx-helper
            if [[ "$DEMYX_CONFIG_FLAG_CACHE" = true ]]; then
                demyx_execute "Configuring nginx-helper" \
                    "demyx_config_cache_helper"
            fi
        ;;
        ols|ols-bedrock)
            DEMYX_CONFIG_CACHE_PLUGIN=litespeed-cache
        ;;
    esac

    if [[ "$DEMYX_CONFIG_FLAG_CACHE" = true ]]; then
        DEMYX_CONFIG_CACHE_CHECK="$(demyx_wp "$DEMYX_APP_DOMAIN" plugin list --format=csv)"

        if [[ "$DEMYX_CONFIG_CACHE_CHECK" == *"$DEMYX_CONFIG_CACHE_PLUGIN,inactive"* ]]; then
            demyx_execute "Activating $DEMYX_CONFIG_CACHE_PLUGIN" \
                "demyx_wp $DEMYX_APP_DOMAIN plugin activate $DEMYX_CONFIG_CACHE_PLUGIN"
        else
            demyx_execute "Installing $DEMYX_CONFIG_CACHE_PLUGIN" \
                "demyx_wp $DEMYX_APP_DOMAIN plugin install $DEMYX_CONFIG_CACHE_PLUGIN --activate"
        fi

        # Delete old cache plugin when switching stacks.
        if [[   "$DEMYX_APP_STACK" = bedrock && "$DEMYX_CONFIG_CACHE_CHECK" == *"litespeed-cache"* ||
                "$DEMYX_APP_STACK" = nginx-php && "$DEMYX_CONFIG_CACHE_CHECK" == *"litespeed-cache"* ]]; then
            demyx_execute "Deleting litespeed-cache" \
                "demyx_wp $DEMYX_APP_DOMAIN plugin delete litespeed-cache"
        elif [[   "$DEMYX_APP_STACK" = ols && "$DEMYX_CONFIG_CACHE_CHECK" == *"nginx-helper"* ||
                "$DEMYX_APP_STACK" = ols-bedrock && "$DEMYX_CONFIG_CACHE_CHECK" == *"nginx-helper"* ]]; then
            demyx_execute "Deleting nginx-helper" \
                "demyx_wp $DEMYX_APP_DOMAIN plugin delete nginx-helper"
        fi
    elif [[ "$DEMYX_CONFIG_FLAG_CACHE" = false ]]; then
        demyx_execute "Deactivating $DEMYX_CONFIG_CACHE_PLUGIN" \
            "demyx_wp $DEMYX_APP_DOMAIN plugin deactivate $DEMYX_CONFIG_CACHE_PLUGIN"
    fi

    demyx_execute "Updating .env" \
        "demyx_app_env_update DEMYX_APP_CACHE=$DEMYX_CONFIG_FLAG_CACHE"
}
#
#   Option updater for nginx-helper plugin.
#
demyx_config_cache_helper() {
    demyx_wp "$DEMYX_APP_DOMAIN" "option update rt_wp_nginx_helper_options '{\"enable_purge\":\"1\",\"cache_method\":\"enable_fastcgi\",\"purge_method\":\"get_request\",\"enable_map\":null,\"enable_log\":null,\"log_level\":\"INFO\",\"log_filesize\":\"5\",\"enable_stamp\":null,\"purge_homepage_on_edit\":\"1\",\"purge_homepage_on_del\":\"1\",\"purge_archive_on_edit\":\"1\",\"purge_archive_on_del\":\"1\",\"purge_archive_on_new_comment\":\"1\",\"purge_archive_on_deleted_comment\":\"1\",\"purge_page_on_mod\":\"1\",\"purge_page_on_new_comment\":\"1\",\"purge_page_on_deleted_comment\":\"1\",\"redis_hostname\":\"127.0.0.1\",\"redis_port\":\"6379\",\"redis_prefix\":\"nginx-cache:\",\"purge_url\":\"\",\"redis_enabled_by_constant\":0}' --format=json"
}
#
#   Reconfigures an app's MariaDB credentials and reinstall WordPress core files.
#
demyx_config_clean() {
    demyx_app_env wp "
        DEMYX_APP_CONTAINER
        DEMYX_APP_DB_CONTAINER
        DEMYX_APP_DOMAIN
        DEMYX_APP_ID
        DEMYX_APP_WP_CONTAINER
        WORDPRESS_DB_PASSWORD
        WORDPRESS_DB_USER
    "

    local DEMYX_CONFIG_CLEAN_MARIADB_ROOT_PASSWORD=
    local DEMYX_CONFIG_CLEAN_WORDPRESS_DB_PASSWORD=
    local DEMYX_CONFIG_CLEAN_WORDPRESS_DB_USER=

    demyx_config "$DEMYX_APP_DOMAIN" --healthcheck=false

    demyx_execute "Putting WordPress into maintenance mode" \
        "docker exec -t $DEMYX_APP_WP_CONTAINER sh -c \"echo '<?php \\\$upgrading = time(); ?>' > .maintenance\""

    demyx_execute "Exporting database" \
        "demyx_wp $DEMYX_APP_DOMAIN db export ${DEMYX_APP_CONTAINER}.sql"

    DEMYX_CONFIG_CLEAN_WORDPRESS_DB_PASSWORD="$(demyx_utility password -r)"
    DEMYX_CONFIG_CLEAN_WORDPRESS_DB_USER="$(demyx_utility username -r)"
    DEMYX_CONFIG_CLEAN_MARIADB_ROOT_PASSWORD="$(demyx_utility password -r)"

    demyx_execute "Genearting new MariaDB credentials" \
        "docker exec -t $DEMYX_APP_WP_CONTAINER sh -c \"sed -i 's|$WORDPRESS_DB_USER|$DEMYX_CONFIG_CLEAN_WORDPRESS_DB_USER|g' /demyx/wp-config.php; sed -i 's|$WORDPRESS_DB_PASSWORD|$DEMYX_CONFIG_CLEAN_WORDPRESS_DB_PASSWORD|g' /demyx/wp-config.php\"; \
        demyx_app_env_update \"
            WORDPRESS_DB_PASSWORD=$DEMYX_CONFIG_CLEAN_WORDPRESS_DB_PASSWORD
            WORDPRESS_DB_USER=$DEMYX_CONFIG_CLEAN_WORDPRESS_DB_USER
            MARIADB_ROOT_PASSWORD=$DEMYX_CONFIG_CLEAN_MARIADB_ROOT_PASSWORD
        \""

    demyx_app_env wp "
        MARIADB_ROOT_PASSWORD
        WORDPRESS_DB_PASSWORD
        WORDPRESS_DB_USER
    "

    demyx_execute "Bringing down MariaDB container" \
        "docker stop ${DEMYX_APP_DB_CONTAINER}; \
        docker rm $DEMYX_APP_DB_CONTAINER"

    demyx_execute "Recreating MariaDB volume" \
        "docker volume rm wp_${DEMYX_APP_ID}_db; \
        docker volume create wp_${DEMYX_APP_ID}_db"

    demyx_compose "$DEMYX_APP_DOMAIN" up -d

    demyx_execute "Initializing MariaDB" \
        "demyx_mariadb_ready"

    demyx_execute "Replacing WordPress core files" \
        "demyx_wp $DEMYX_APP_DOMAIN core download --force"

    demyx_execute "Importing database" \
        "demyx_wp $DEMYX_APP_DOMAIN db import ${DEMYX_APP_CONTAINER}.sql"

    demyx_execute "Refreshing salts" \
        "demyx_wp $DEMYX_APP_DOMAIN config shuffle-salts"

    demyx_execute "Cleaning up" \
        "docker exec -t $DEMYX_APP_WP_CONTAINER sh -c 'rm ${DEMYX_APP_CONTAINER}.sql; rm .maintenance'"

    demyx_compose "$DEMYX_APP_DOMAIN" fr
    demyx_config "$DEMYX_APP_DOMAIN" --healthcheck
}
#
#   Configures an app for development mode.
#
demyx_config_dev() {
    demyx_app_env wp "
        DEMYX_APP_DOMAIN
        DEMYX_APP_DEV_PASSWORD
        DEMYX_APP_ID
        DEMYX_APP_OLS_ADMIN_PASSWORD
        DEMYX_APP_OLS_ADMIN_USERNAME
        DEMYX_APP_STACK
        DEMYX_APP_TYPE
        DEMYX_APP_WP_CONTAINER
        WORDPRESS_USER
        WORDPRESS_USER_PASSWORD
    "

    local DEMYX_CONFIG_DEV_OLD_VOLUME=
    DEMYX_CONFIG="Development Mode"
    DEMYX_CONFIG_COMPOSE=true

    # TEMPORARY - Import old files to new volume
    DEMYX_CONFIG_DEV_OLD_VOLUME="$(docker volume ls -q --filter=name=wp_"$DEMYX_APP_ID"_cs_)"

    if [[ -n "$DEMYX_CONFIG_DEV_OLD_VOLUME" && "$DEMYX_CONFIG_FLAG_DEV" = true ]]; then
        demyx_execute "Transferring old files to new volume" \
            "docker pull demyx/code-server:wp; \
            docker volume create ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_code; \
            docker run -t --rm \
                -v /var/lib/docker/volumes/${DEMYX_CONFIG_DEV_OLD_VOLUME}:/tmp/${DEMYX_CONFIG_DEV_OLD_VOLUME} \
                -v /var/lib/docker/volumes/${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_code:/tmp/${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_code \
                --user=root \
                --entrypoint=cp \
                demyx/demyx -rp /tmp/${DEMYX_CONFIG_DEV_OLD_VOLUME}/_data/. /tmp/${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_code/_data; \
            docker run -it --rm \
                --user=root \
                --entrypoint=chown \
                -v ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_code:/tmp/demyx \
                demyx/demyx -R demyx:demyx /tmp/demyx; \
            docker stop ${DEMYX_APP_WP_CONTAINER}; \
            docker rm ${DEMYX_APP_WP_CONTAINER}; \
            docker volume rm $DEMYX_CONFIG_DEV_OLD_VOLUME"
    fi

    demyx_execute "Setting development mode to $DEMYX_CONFIG_FLAG_DEV" \
        "demyx_app_env_update DEMYX_APP_DEV=${DEMYX_CONFIG_FLAG_DEV}; \
        demyx_yml ${DEMYX_APP_STACK}"

    if [[ "$DEMYX_CONFIG_FLAG_DEV" = true ]]; then
        {
            if [[ "$DEMYX_APP_STACK" = nginx-php || "$DEMYX_APP_STACK" = ols ]]; then
                echo "Browsersync               $(demyx_app_proto)://$(demyx_app_domain)/demyx/bs/"
                echo
            fi

            echo "Code Server               $(demyx_app_proto)://$(demyx_app_domain)/demyx/cs/"
            echo "Password                  $DEMYX_APP_DEV_PASSWORD"
            echo
            echo "WordPress Login           $(demyx_app_login)"
            echo "WordPress Username        $WORDPRESS_USER"
            echo "WordPress Password        $WORDPRESS_USER_PASSWORD"

            if [[ "$DEMYX_APP_STACK" = ols || "$DEMYX_APP_STACK" = ols-bedrock ]]; then
                echo
                echo "OLS Admin Username        $DEMYX_APP_OLS_ADMIN_USERNAME"
                echo "OLS Admin Password        $DEMYX_APP_OLS_ADMIN_PASSWORD"
            fi

        } > "$DEMYX_CONFIG_TRANSIENT"
    fi
}
#
#   Configures an app's healthcheck.
#
demyx_config_healthcheck() {
    demyx_app_env wp "
        DEMYX_APP_HEALTHCHECK
    "

    demyx_execute "Setting healthcheck to $DEMYX_CONFIG_FLAG_HEALTHCHECK" \
        "demyx_app_env_update DEMYX_APP_HEALTHCHECK=$DEMYX_CONFIG_FLAG_HEALTHCHECK"
}
#
#   Configures an app's opcache setting.
#
demyx_config_opcache() {
    demyx_app_env wp "
        DEMYX_APP_STACK
        DEMYX_APP_PHP_OPCACHE
    "

    DEMYX_CONFIG_COMPOSE=true

    demyx_execute "Setting $DEMYX_CONFIG_FLAG_OPCACHE to opcache" \
        "demyx_app_env_update DEMYX_APP_PHP_OPCACHE=$DEMYX_CONFIG_FLAG_OPCACHE"
}
#
#   Configures an app's php-fpm settings.
#
demyx_config_php() {
    DEMYX_CONFIG_COMPOSE=true

    if [[ -n "$DEMYX_CONFIG_FLAG_PHP_PM" ]]; then
        demyx_ols_not_supported
        demyx_execute "Updating pm $DEMYX_CONFIG_FLAG_PHP_PM" \
            "demyx_app_env_update DEMYX_APP_PHP_PM=$DEMYX_CONFIG_FLAG_PHP_PM"
    fi
    if [[ -n "$DEMYX_CONFIG_FLAG_PHP_MAX_CHILDREN" ]]; then
        demyx_ols_not_supported
        demyx_execute "Updating pm.max_children $DEMYX_CONFIG_FLAG_PHP_MAX_CHILDREN" \
            "demyx_app_env_update DEMYX_APP_PHP_PM_MAX_CHILDREN=$DEMYX_CONFIG_FLAG_PHP_MAX_CHILDREN"
    fi
    if [[ -n "$DEMYX_CONFIG_FLAG_PHP_MAX_REQUESTS" ]]; then
        demyx_ols_not_supported
        demyx_execute "Updating pm.max_requests $DEMYX_CONFIG_FLAG_PHP_MAX_REQUESTS" \
            "demyx_app_env_update DEMYX_APP_PHP_PM_MAX_REQUESTS=$DEMYX_CONFIG_FLAG_PHP_MAX_REQUESTS"
    fi
    if [[ -n "$DEMYX_CONFIG_FLAG_PHP_MAX_SPARE_SERVERS" ]]; then
        demyx_ols_not_supported
        demyx_execute "Updating pm.max_spare_servers $DEMYX_CONFIG_FLAG_PHP_MAX_SPARE_SERVERS" \
            "demyx_app_env_update DEMYX_APP_PHP_PM_MAX_SPARE_SERVERS=$DEMYX_CONFIG_FLAG_PHP_MAX_SPARE_SERVERS"
    fi
    if [[ -n "$DEMYX_CONFIG_FLAG_PHP_MIN_SPARE_SERVERS" ]]; then
        demyx_ols_not_supported
        demyx_execute "Updating pm.min_spare_servers $DEMYX_CONFIG_FLAG_PHP_MIN_SPARE_SERVERS" \
            "demyx_app_env_update DEMYX_APP_PHP_PM_MIN_SPARE_SERVERS=$DEMYX_CONFIG_FLAG_PHP_MIN_SPARE_SERVERS"
    fi
    if [[ -n "$DEMYX_CONFIG_FLAG_PHP_PROCESS_IDLE_TIMEOUT" ]]; then
        demyx_ols_not_supported
        demyx_execute "Updating pm.process_idle_timeout $DEMYX_CONFIG_FLAG_PHP_PROCESS_IDLE_TIMEOUT" \
            "demyx_app_env_update DEMYX_APP_PHP_PM_PROCESS_IDLE_TIMEOUT=$DEMYX_CONFIG_FLAG_PHP_PROCESS_IDLE_TIMEOUT"
    fi
    if [[ -n "$DEMYX_CONFIG_FLAG_PHP_START_SERVERS" ]]; then
        demyx_ols_not_supported
        demyx_execute "Updating pm.start_servers $DEMYX_CONFIG_FLAG_PHP_START_SERVERS" \
            "demyx_app_env_update DEMYX_APP_PHP_PM_START_SERVERS=$DEMYX_CONFIG_FLAG_PHP_START_SERVERS"
    fi
    if [[ -n "$DEMYX_CONFIG_FLAG_PHP_VERSION" ]]; then
        demyx_execute "Updating php to version $DEMYX_CONFIG_FLAG_PHP_VERSION" \
            "demyx_app_env_update DEMYX_APP_PHP=$DEMYX_CONFIG_FLAG_PHP_VERSION"
    fi
}
#
#   Configures a phpMyAdmin container for an app.
#
demyx_config_pma() {
    # TODO - needs to work with IP address
    demyx_app_env wp "
        DEMYX_APP_COMPOSE_PROJECT
        DEMYX_APP_DOMAIN
        DEMYX_APP_ID
        DEMYX_APP_PMA
        DEMYX_APP_STACK
        MARIADB_ROOT_PASSWORD
        WORDPRESS_DB_PASSWORD
        WORDPRESS_DB_USER
    "

    DEMYX_CONFIG="phpMyAdmin"
    DEMYX_CONFIG_COMPOSE=true

    demyx_execute "Setting pma to $DEMYX_CONFIG_FLAG_PMA" \
        "demyx_app_env_update DEMYX_APP_PMA=${DEMYX_CONFIG_FLAG_PMA}; \
        demyx_yml $DEMYX_APP_STACK"

    if [[ "$DEMYX_CONFIG_FLAG_PMA" = true ]]; then
        {
            echo "phpMyAdmin        $(demyx_app_proto)://$(demyx_app_domain)/demyx/pma/"
            echo "Username          $WORDPRESS_DB_USER"
            echo "Password          $WORDPRESS_DB_PASSWORD"
        } > "$DEMYX_CONFIG_TRANSIENT"
    fi
}
#
#   Configures an app's rate limit.
#
demyx_config_rate_limit() {
    demyx_ols_not_supported
    demyx_app_env wp "
        DEMYX_APP_RATE_LIMIT
    "

    DEMYX_CONFIG_COMPOSE=true

    demyx_execute "Setting rate limit to $DEMYX_CONFIG_FLAG_RATE_LIMIT" \
        "demyx_app_env_update DEMYX_APP_RATE_LIMIT=$DEMYX_CONFIG_FLAG_RATE_LIMIT"
}
#
#   Configure an app's container resources.
#
demyx_config_resources() {
    demyx_app_env wp "
        DEMYX_APP_DOMAIN
        DEMYX_APP_DB_CONTAINER
        DEMYX_APP_WP_CONTAINER
    "

    DEMYX_CONFIG_COMPOSE=true

    if [[ -n "$DEMYX_CONFIG_FLAG_RESOURCES_DB_CPU" ]]; then
        demyx_execute "Setting $DEMYX_APP_DB_CONTAINER cpu to $DEMYX_CONFIG_FLAG_RESOURCES_DB_CPU" \
            "demyx_app_env_update DEMYX_APP_DB_CPU=$DEMYX_CONFIG_FLAG_RESOURCES_DB_CPU"
    fi
    if [[ -n "$DEMYX_CONFIG_FLAG_RESOURCES_DB_MEM" ]]; then
        demyx_execute "Setting $DEMYX_APP_DB_CONTAINER mem to $DEMYX_CONFIG_FLAG_RESOURCES_DB_MEM" \
            "demyx_app_env_update DEMYX_APP_DB_MEM=$DEMYX_CONFIG_FLAG_RESOURCES_DB_MEM"
    fi
    if [[ -n "$DEMYX_CONFIG_FLAG_RESOURCES_WP_CPU" ]]; then
        demyx_execute "Setting $DEMYX_APP_WP_CONTAINER cpu to $DEMYX_CONFIG_FLAG_RESOURCES_WP_CPU" \
            "demyx_app_env_update DEMYX_APP_WP_CPU=$DEMYX_CONFIG_FLAG_RESOURCES_WP_CPU"
    fi
    if [[ -n "$DEMYX_CONFIG_FLAG_RESOURCES_WP_MEM" ]]; then
        demyx_execute "Setting $DEMYX_APP_WP_CONTAINER cpu to $DEMYX_CONFIG_FLAG_RESOURCES_WP_MEM" \
            "demyx_app_env_update DEMYX_APP_WP_MEM=$DEMYX_CONFIG_FLAG_RESOURCES_WP_MEM"
    fi
}

                    if [[ "$DEMYX_CONFIG_WP_CPU" = null ]]; then
                        demyx_execute sed -i "s|DEMYX_APP_WP_CPU=.*|DEMYX_APP_WP_CPU=|g" "$DEMYX_APP_PATH"/.env
                    else
                        demyx_execute sed -i "s|DEMYX_APP_WP_CPU=.*|DEMYX_APP_WP_CPU=$DEMYX_CONFIG_WP_CPU|g" "$DEMYX_APP_PATH"/.env
                    fi
                fi
                if [[ -n "$DEMYX_CONFIG_WP_MEM" ]]; then
                    demyx_echo "Updating $DEMYX_APP_DOMAIN MEM"

                    if [[ "$DEMYX_CONFIG_WP_MEM" = null ]]; then
                        demyx_execute sed -i "s|DEMYX_APP_WP_MEM=.*|DEMYX_APP_WP_MEM=|g" "$DEMYX_APP_PATH"/.env
                    else
                        demyx_execute sed -i "s|DEMYX_APP_WP_MEM=.*|DEMYX_APP_WP_MEM=$DEMYX_CONFIG_WP_MEM|g" "$DEMYX_APP_PATH"/.env
                    fi
                fi

                demyx compose "$DEMYX_APP_DOMAIN" up -d --remove-orphans
            fi
            if [[ -n "$DEMYX_CONFIG_RESTART" ]]; then
                demyx_app_is_up

                if [[ "$DEMYX_CONFIG_RESTART" = nginx-php ]]; then
                    demyx config "$DEMYX_APP_DOMAIN" --restart=nginx
                    demyx config "$DEMYX_APP_DOMAIN" --restart=php
                elif [ "$DEMYX_CONFIG_RESTART" = nginx ]; then
                    demyx_echo "Restarting NGINX"
                    demyx_execute docker exec -t "$DEMYX_APP_NX_CONTAINER" sh -c 'rm -rf /tmp/nginx-cache; sudo demyx-reload'
                elif [ "$DEMYX_CONFIG_RESTART" = ols ]; then
                    demyx_echo "Restarting OpenLiteSpeed"
                    demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c 'demyx-lsws restart'
                elif [ "$DEMYX_CONFIG_RESTART" = php ]; then
                    demyx_echo "Restarting PHP"
                    demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c 'kill -USR2 9'
                fi
            fi
            if [[ "$DEMYX_CONFIG_SFTP" = true ]]; then
                demyx_app_is_up

                DEMYX_SFTP_VOLUME_CHECK="$(docker volume ls | grep demyx_sftp || true)"
                DEMYX_SFTP_CONTAINER_CHECK="$(echo "$DEMYX_DOCKER_PS" | grep "$DEMYX_APP_COMPOSE_PROJECT"_sftp || true)"
                DEMYX_SFTP_PORT="$(demyx_open_port)"

                [[ -n "$DEMYX_SFTP_CONTAINER_CHECK" ]] && demyx_die 'SFTP container is already running'

                demyx_echo 'Creating SFTP container'
                demyx_execute docker run -dit --rm \
                    --name="$DEMYX_APP_COMPOSE_PROJECT"_sftp \
                    --cpus="$DEMYX_CPU" \
                    --memory="$DEMYX_MEM" \
                    --workdir="/demyx" \
                    --volumes-from="$DEMYX_APP_WP_CONTAINER" \
                    -v demyx_sftp:/home/demyx/.ssh \
                    -p "$DEMYX_SFTP_PORT":2222 \
                    demyx/ssh 2>/dev/null

                if [[ -z "$(docker exec -t "$DEMYX_APP_COMPOSE_PROJECT"_sftp ls /home/demyx/.ssh | grep authorized_keys || true)" ]]; then
                    demyx_warning "No authorized_keys found; please run the command: docker cp \"\$HOME\"/.ssh/authorized_keys ${DEMYX_APP_COMPOSE_PROJECT}_sftp:/home/demyx/.ssh; docker exec -t ${DEMYX_APP_COMPOSE_PROJECT}_sftp demyx-permission"
                fi

                PRINT_TABLE="DEMYX^ SFTP\n"
                PRINT_TABLE+="SFTP^ $DEMYX_APP_DOMAIN\n"
                PRINT_TABLE+="SFTP USER^ demyx\n"
                PRINT_TABLE+="SFTP PORT^ $DEMYX_SFTP_PORT\n"
                demyx_execute -v demyx_table "$PRINT_TABLE"
            elif [[ "$DEMYX_CONFIG_SFTP" = false ]]; then
                demyx_app_is_up

                DEMYX_SFTP_CONTAINER_CHECK="$(echo "$DEMYX_DOCKER_PS" | grep "$DEMYX_APP_COMPOSE_PROJECT"_sftp || true)"
                [[ -z "$DEMYX_SFTP_CONTAINER_CHECK" ]] && demyx_die 'No SFTP container running'

                demyx_echo 'Stopping SFTP container'
                demyx_execute docker stop "$DEMYX_APP_COMPOSE_PROJECT"_sftp
            fi
            if [[ "$DEMYX_CONFIG_SSL" = true ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_SSL" = true ]] && demyx_die 'SSL is already turned on'
                fi

                demyx_source yml

                demyx_echo 'Updating .env'
                demyx_execute sed -i "s|DEMYX_APP_SSL=.*|DEMYX_APP_SSL=true|g" "$DEMYX_APP_PATH"/.env

                demyx_echo 'Turning on SSL'
                demyx_execute demyx_app_config; demyx_yml

                demyx_echo 'Replacing URLs to HTTPS'
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" search-replace http://"$DEMYX_APP_DOMAIN" https://"$DEMYX_APP_DOMAIN"

                demyx compose "$DEMYX_APP_DOMAIN" up -d --remove-orphans
            elif [[ "$DEMYX_CONFIG_SSL" = false ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_SSL" = false ]] && demyx_die 'SSL is already turned off'
                fi

                demyx_source yml

                demyx_echo 'Updating .env'
                demyx_execute sed -i "s|DEMYX_APP_SSL=.*|DEMYX_APP_SSL=false|g" "$DEMYX_APP_PATH"/.env

                demyx_echo 'Turning off SSL'
                demyx_execute demyx_app_config; demyx_yml

                demyx_echo 'Replacing URLs to HTTP'
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" search-replace https://"$DEMYX_APP_DOMAIN" http://"$DEMYX_APP_DOMAIN"

                demyx compose "$DEMYX_APP_DOMAIN" up -d --remove-orphans
            fi
            if [[ -n "$DEMYX_CONFIG_STACK" ]]; then
                [[ "$DEMYX_APP_STACK" = "$DEMYX_CONFIG_STACK" ]] && demyx_die "$DEMYX_APP_DOMAIN is already using the $DEMYX_CONFIG_STACK stack"

                if [[ "$DEMYX_APP_CACHE" = true ]]; then
                    DEMYX_CONFIG_STACK_CACHE=true
                    demyx config "$DEMYX_APP_DOMAIN" --cache=false
                fi

                demyx_echo "Converting $DEMYX_APP_DOMAIN to the $DEMYX_CONFIG_STACK stack"

                if [[ "$DEMYX_CONFIG_STACK" = bedrock ]]; then
                    [[ "$DEMYX_APP_STACK" = nginx-php || "$DEMYX_APP_STACK" = ols ]] && demyx_die "$DEMYX_APP_DOMAIN can't be converted"
                    demyx_execute sed -i "s|DEMYX_APP_WP_IMAGE=.*|DEMYX_APP_WP_IMAGE=demyx/wordpress:bedrock|g" "$DEMYX_APP_PATH"/.env; \
                        sed -i "s|DEMYX_APP_STACK=.*|DEMYX_APP_STACK=bedrock|g" "$DEMYX_APP_PATH"/.env
                elif [[ "$DEMYX_CONFIG_STACK" = nginx-php ]]; then
                    [[ "$DEMYX_APP_STACK" = bedrock || "$DEMYX_APP_STACK" = ols-bedrock ]] && demyx_die "$DEMYX_APP_DOMAIN can't be converted"
                    demyx_execute sed -i "s|DEMYX_APP_WP_IMAGE=.*|DEMYX_APP_WP_IMAGE=demyx/wordpress|g" "$DEMYX_APP_PATH"/.env; \
                        sed -i "s|DEMYX_APP_STACK=.*|DEMYX_APP_STACK=nginx-php|g" "$DEMYX_APP_PATH"/.env
                elif [[ "$DEMYX_CONFIG_STACK" = ols ]]; then
                    [[ "$DEMYX_APP_STACK" = bedrock || "$DEMYX_APP_STACK" = ols-bedrock ]] && demyx_die "$DEMYX_APP_DOMAIN can't be converted"
                    demyx_execute sed -i "s|DEMYX_APP_WP_IMAGE=.*|DEMYX_APP_WP_IMAGE=demyx/openlitespeed|g" "$DEMYX_APP_PATH"/.env; \
                        sed -i "s|DEMYX_APP_STACK=.*|DEMYX_APP_STACK=ols|g" "$DEMYX_APP_PATH"/.env
                elif [[ "$DEMYX_CONFIG_STACK" = ols-bedrock ]]; then
                    [[ "$DEMYX_APP_STACK" = nginx-php || "$DEMYX_APP_STACK" = ols ]] && demyx_die "$DEMYX_APP_DOMAIN can't be converted"
                    demyx_execute sed -i "s|DEMYX_APP_WP_IMAGE=.*|DEMYX_APP_WP_IMAGE=demyx/openlitespeed:bedrock|g" "$DEMYX_APP_PATH"/.env; \
                        sed -i "s|DEMYX_APP_STACK=.*|DEMYX_APP_STACK=ols-bedrock|g" "$DEMYX_APP_PATH"/.env
                fi

                demyx refresh "$DEMYX_APP_DOMAIN"
                [[ "$DEMYX_CONFIG_STACK_CACHE" = true ]] && demyx config "$DEMYX_APP_DOMAIN" --cache
            fi
            if [[ -n "$DEMYX_CONFIG_UPGRADE" ]]; then
                demyx_app_is_up

                DEMYX_CHECK_APP_IMAGE="$(demyx info "$DEMYX_APP_DOMAIN" --filter=DEMYX_APP_WP_IMAGE)"
                [[ "$DEMYX_CHECK_APP_IMAGE" = demyx/wordpress || "$DEMYX_CHECK_APP_IMAGE" = demyx/wordpress:bedrock ]] && demyx_die 'Already upgraded.'

                demyx config "$DEMYX_APP_DOMAIN" --healthcheck=false

                demyx_echo "Upgrading $DEMYX_APP_DOMAIN"
                if [[ "$DEMYX_CHECK_APP_IMAGE" = demyx/nginx-php-wordpress ]]; then
                    demyx_execute sed -i "s|DEMYX_APP_WP_IMAGE=.*|DEMYX_APP_WP_IMAGE=demyx/wordpress|g" "$DEMYX_APP_PATH"/.env; \
                        docker run --rm --user=root --volumes-from="$DEMYX_APP_WP_CONTAINER" demyx/utilities "chown -R demyx:demyx /demyx; chown -R demyx:demyx /var/log/demyx"
                elif [[ "$DEMYX_CHECK_APP_IMAGE" = demyx/nginx-php-wordpress:bedrock ]]; then
                    demyx_execute sed -i "s|DEMYX_APP_WP_IMAGE=.*|DEMYX_APP_WP_IMAGE=demyx/wordpress:bedrock|g" "$DEMYX_APP_PATH"/.env; \
                        docker run --rm --user=root --volumes-from="$DEMYX_APP_WP_CONTAINER" demyx/utilities "chown -R demyx:demyx /demyx; chown -R demyx:demyx /var/log/demyx"
                fi

                demyx refresh "$DEMYX_APP_DOMAIN"
                demyx config "$DEMYX_APP_DOMAIN" --healthcheck

                if [[ -n "$(demyx_upgrade_apps)" ]]; then
                    demyx_execute -v echo -e '\n\e[33m[WARNING]\e[39m These sites needs upgrading:'; \
                        demyx_upgrade_apps
                fi
            fi
            if [[ "$DEMYX_CONFIG_WP_UPDATE" = true ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_WP_UPDATE" = true ]] && demyx_die 'WordPress auto update is already turned on'
                fi

                demyx_echo 'Turning on WordPress auto update'
                demyx_execute sed -i "s|DEMYX_APP_WP_UPDATE=.*|DEMYX_APP_WP_UPDATE=true|g" "$DEMYX_APP_PATH"/.env
            elif [[ "$DEMYX_CONFIG_WP_UPDATE" = false ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_WP_UPDATE" = false ]] && demyx_die 'WordPress auto update is already turned off'
                fi

                demyx_echo 'Turning off WordPress auto update'
                demyx_execute sed -i "s|DEMYX_APP_WP_UPDATE=.*|DEMYX_APP_WP_UPDATE=false|g" "$DEMYX_APP_PATH"/.env
            fi
            if [[ -n "$DEMYX_CONFIG_WHITELIST" ]]; then
                demyx_source yml

                # TEMPORARY CODE
                if [[ -z "$DEMYX_APP_IP_WHITELIST" ]]; then
                    demyx_echo "Updating .env and .yml"
                    demyx_execute demyx_source env; \
                        demyx_env
                fi

                demyx_echo "Setting whitelist type to $DEMYX_CONFIG_WHITELIST"
                demyx_execute sed -i "s|DEMYX_APP_IP_WHITELIST=.*|DEMYX_APP_IP_WHITELIST=$DEMYX_CONFIG_WHITELIST|g" "$DEMYX_APP_PATH"/.env; \
                    demyx_yml

                demyx compose "$DEMYX_APP_DOMAIN" up -d --remove-orphans
            elif [[ "$DEMYX_CONFIG_WHITELIST" = false ]]; then
                demyx_source yml

                # TEMPORARY CODE
                if [[ -z "$DEMYX_APP_IP_WHITELIST" ]]; then
                    demyx_echo "Updating .env and .yml"
                    demyx_execute demyx_source env; \
                        demyx_env
                fi

                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_IP_WHITELIST" = false ]] && demyx_die 'IP whitelist is already off'
                fi

                demyx_echo 'Disabling IP whitelist'
                demyx_execute sed -i "s|DEMYX_APP_IP_WHITELIST=.*|DEMYX_APP_IP_WHITELIST=false|g" "$DEMYX_APP_PATH"/.env; \
                    demyx_yml

                demyx compose "$DEMYX_APP_DOMAIN" up -d --remove-orphans
            fi
            if [[ "$DEMYX_CONFIG_XMLRPC" = true ]]; then
                demyx_app_is_up

                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_XMLRPC" = true ]] && demyx_die 'WordPress xmlrpc is already turned on'
                fi

                demyx_echo 'Turning on WordPress xmlrpc'
                demyx_execute docker exec -t "$DEMYX_APP_NX_CONTAINER" sh -c 'mv "$NGINX_CONFIG"/common/xmlrpc.conf "$NGINX_CONFIG"/common/xmlrpc.on; demyx-reload'; \
                    sed -i "s|DEMYX_APP_XMLRPC=.*|DEMYX_APP_XMLRPC=true|g" "$DEMYX_APP_PATH"/.env

                demyx config "$DEMYX_APP_DOMAIN" --restart=nginx
            elif [[ "$DEMYX_CONFIG_XMLRPC" = false ]]; then
                demyx_app_is_up

                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_XMLRPC" = false ]] && demyx_die 'WordPress xmlrpc is already turned off'
                fi

                demyx_echo 'Turning off WordPress xmlrpc'
                demyx_execute docker exec -t "$DEMYX_APP_NX_CONTAINER" sh -c 'mv "$NGINX_CONFIG"/common/xmlrpc.on "$NGINX_CONFIG"/common/xmlrpc.conf; demyx-reload'; \
                    sed -i "s|DEMYX_APP_XMLRPC=.*|DEMYX_APP_XMLRPC=false|g" "$DEMYX_APP_PATH"/.env
            fi
        else
            demyx_die --not-found
        fi
    fi
}
