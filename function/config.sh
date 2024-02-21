# Demyx
# https://demyx.sh
# shellcheck shell=bash

#
#   demyx config <app> <args>
#
demyx_config() {
    demyx_event
    DEMYX_ARG_2="${1:-$DEMYX_ARG_2}"
    shift && local DEMYX_CONFIG_ARGS="$*"
    local DEMYX_CONFIG=
    local DEMYX_CONFIG_COMPOSE=
    local DEMYX_CONFIG_FLAG=
    local DEMYX_CONFIG_FLAG_AUTH=
    local DEMYX_CONFIG_FLAG_AUTH_WP=
    local DEMYX_CONFIG_FLAG_BACKUP=
    local DEMYX_CONFIG_FLAG_BEDROCK=
    local DEMYX_CONFIG_FLAG_CACHE=
    local DEMYX_CONFIG_FLAG_CACHE_TYPE=
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
    local DEMYX_CONFIG_FLAG_PHP_PM_CALC=
    local DEMYX_CONFIG_FLAG_PHP_PROCESS_IDLE_TIMEOUT=
    local DEMYX_CONFIG_FLAG_PHP_START_SERVERS=
    local DEMYX_CONFIG_FLAG_PHP_VERSION=
    local DEMYX_CONFIG_FLAG_PMA=
    local DEMYX_CONFIG_FLAG_RATE_LIMIT=
    local DEMYX_CONFIG_FLAG_REDIS=
    local DEMYX_CONFIG_FLAG_RESOURCES=
    local DEMYX_CONFIG_FLAG_RESOURCES_DB_CPU=
    local DEMYX_CONFIG_FLAG_RESOURCES_DB_MEM=
    local DEMYX_CONFIG_FLAG_RESOURCES_WP_CPU=
    local DEMYX_CONFIG_FLAG_RESOURCES_WP_MEM=
    #local DEMYX_CONFIG_FLAG_RESTART=
    local DEMYX_CONFIG_FLAG_SFTP=
    local DEMYX_CONFIG_FLAG_SSL=
    local DEMYX_CONFIG_FLAG_SSL_WILDCARD=
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
            --backup|--backup=true)
                DEMYX_CONFIG_FLAG_BACKUP=true
            ;;
            --backup=false)
                DEMYX_CONFIG_FLAG_BACKUP=false
            ;;
            --bedrock|--bedrock=production)
                DEMYX_CONFIG_FLAG_BEDROCK=production
            ;;
            --bedrock=development)
                DEMYX_CONFIG_FLAG_BEDROCK=development
            ;;
            --cache|--cache=default|--cache=rocket|--cache=true)
                DEMYX_CONFIG_FLAG_CACHE="${DEMYX_CONFIG_FLAG#*=}"
                DEMYX_CONFIG_FLAG_CACHE_TYPE=default
                [[ "$DEMYX_CONFIG_FLAG_CACHE" = rocket ]] && DEMYX_CONFIG_FLAG_CACHE_TYPE=rocket
                DEMYX_CONFIG_FLAG_CACHE=true
            ;;
            --cache=false)
                DEMYX_CONFIG_FLAG_CACHE=false
                DEMYX_CONFIG_FLAG_CACHE_TYPE=default
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
            --php=8.1|--php=8.2)
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
            --php-pm-calc)
                DEMYX_CONFIG_FLAG_PHP_PM_CALC=true
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
            # TODO
            #--restart=nginx-php|--restart=nginx|--restart=ols|--restart=php)
            #    DEMYX_CONFIG_FLAG_RESTART="${DEMYX_CONFIG_FLAG#*=}"
            #;;
            --redis|--redis=true)
                DEMYX_CONFIG_FLAG_REDIS=true
            ;;
            --redis=false)
                DEMYX_CONFIG_FLAG_REDIS=false
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
            --ssl-wildcard|--ssl-wildcard=true)
                DEMYX_CONFIG_FLAG_SSL_WILDCARD=true
            ;;
            --ssl-wildcard=false)
                DEMYX_CONFIG_FLAG_SSL_WILDCARD=false
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
                if [[ -n "$DEMYX_CONFIG_FLAG_BACKUP" ]]; then
                    demyx_config_backup
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
                if [[ -n "$DEMYX_CONFIG_FLAG_PHP_PM_CALC" ]]; then
                    demyx_config_pm
                fi
                if [[ -n "$DEMYX_CONFIG_FLAG_PMA" ]]; then
                    demyx_config_pma
                fi
                if [[ -n "$DEMYX_CONFIG_FLAG_RATE_LIMIT" ]]; then
                    demyx_config_rate_limit
                fi
                if [[ -n "$DEMYX_CONFIG_FLAG_REDIS" ]]; then
                    demyx_config_redis
                fi
                if [[ -n "$DEMYX_CONFIG_FLAG_RESOURCES" ]]; then
                    demyx_config_resources
                fi
                # TODO
                #if [[ -n "$DEMYX_CONFIG_FLAG_RESTART" ]]; then
                #    demyx_config_restart
                #fi
                if [[ -n "$DEMYX_CONFIG_FLAG_SFTP" ]]; then
                    demyx_config_sftp
                fi
                if [[ -n "$DEMYX_CONFIG_FLAG_SSL" ]]; then
                    demyx_config_ssl
                fi
                if [[ -n "$DEMYX_CONFIG_FLAG_SSL_WILDCARD" ]]; then
                    demyx_config_ssl_wildcard
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
                    demyx_divider_title "DEMYX - CONFIG" "$DEMYX_CONFIG"
                    cat < "$DEMYX_CONFIG_TRANSIENT"
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
        demyx_event
        demyx_echo "Configuring $DEMYX_CONFIG_ALL"
        eval demyx_config "$DEMYX_CONFIG_ALL" "$DEMYX_CONFIG_ARGS"
    done
}
#
#   Configures app's basic auth labels.
#
demyx_config_auth() {
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_AUTH
        DEMYX_APP_AUTH_USERNAME
        DEMYX_APP_AUTH_PASSWORD
        DEMYX_APP_STACK
    "

    DEMYX_CONFIG_COMPOSE=true

    demyx_execute "Setting $DEMYX_CONFIG_FLAG_AUTH to basic auth" \
        "demyx_app_env_update DEMYX_APP_AUTH=${DEMYX_CONFIG_FLAG_AUTH}; \
        demyx_yml $DEMYX_APP_STACK"

    if [[ "$DEMYX_CONFIG_FLAG_AUTH" = true ]]; then
        DEMYX_CONFIG="Basic Auth"
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
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_AUTH_WP
        DEMYX_APP_AUTH_USERNAME
        DEMYX_APP_AUTH_PASSWORD
        DEMYX_APP_STACK
    "

    DEMYX_CONFIG_COMPOSE=true

    demyx_execute "Setting $DEMYX_CONFIG_FLAG_AUTH_WP to WordPress basic auth" \
        "demyx_app_env_update DEMYX_APP_AUTH_WP=${DEMYX_CONFIG_FLAG_AUTH_WP}; \
        demyx_yml $DEMYX_APP_STACK"

    if [[ "$DEMYX_CONFIG_FLAG_AUTH_WP" = true ]]; then
        DEMYX_CONFIG="WordPress Login Basic Auth"
        {
            echo "Username      $DEMYX_APP_AUTH_USERNAME"
            echo "Password      $DEMYX_APP_AUTH_PASSWORD"
        } > "$DEMYX_CONFIG_TRANSIENT"
    fi
}
#
#   Configures an app's backup status.
#
demyx_config_backup() {
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_BACKUP
    "

    demyx_execute "Setting backup to $DEMYX_CONFIG_FLAG_BACKUP" \
        "demyx_app_env_update DEMYX_APP_BACKUP=$DEMYX_CONFIG_FLAG_BACKUP"
}
#
#   Configures app's bedrock .env mode.
#
demyx_config_bedrock() {
    demyx_event
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
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_DOMAIN
        DEMYX_APP_STACK
    "

    local DEMYX_CONFIG_CACHE_CHECK=
    DEMYX_CONFIG_CACHE_CHECK="$(demyx_wp "$DEMYX_APP_DOMAIN" plugin list --format=csv)"
    local DEMYX_CONFIG_CACHE_PLUGIN=
    DEMYX_CONFIG_COMPOSE=true

     # WP Rocket check
    [[ "$DEMYX_CONFIG_CACHE_CHECK" != *"wp-rocket"* && "$DEMYX_CONFIG_FLAG_CACHE_TYPE" = rocket ]] && \
        demyx_error custom "This app does not have wp-rocket installed, please upload it first"

    case "$DEMYX_APP_STACK" in
        bedrock|nginx-php)
            DEMYX_CONFIG_CACHE_PLUGIN=nginx-helper
            [[ "$DEMYX_CONFIG_FLAG_CACHE_TYPE" = rocket ]] && DEMYX_CONFIG_CACHE_PLUGIN=wp-rocket
        ;;
        ols|ols-bedrock)
            DEMYX_CONFIG_CACHE_PLUGIN=litespeed-cache
        ;;
    esac

    if [[ "$DEMYX_CONFIG_FLAG_CACHE" = true ]]; then
        [[ "$DEMYX_CONFIG_CACHE_PLUGIN" = nginx-helper ]] && \
                demyx_execute "Configuring nginx-helper" \
                    "demyx_config_cache_helper"

        if [[ "$DEMYX_CONFIG_CACHE_PLUGIN" = nginx-helper && "$DEMYX_CONFIG_CACHE_CHECK" == *"wp-rocket,active"* ]]; then
            demyx_execute "Deactivating wp-rocket" \
                "demyx_wp $DEMYX_APP_DOMAIN plugin deactivate wp-rocket"
        elif [[ "$DEMYX_CONFIG_CACHE_PLUGIN" = wp-rocket && "$DEMYX_CONFIG_CACHE_CHECK" == *"nginx-helper,active"* ]]; then
            demyx_execute "Deleting nginx-helper" \
                "demyx_wp $DEMYX_APP_DOMAIN plugin uninstall nginx-helper --deactivate"
        fi

        if [[ "$DEMYX_CONFIG_CACHE_PLUGIN" = wp-rocket ]]; then
            if [[ "$DEMYX_CONFIG_CACHE_CHECK" == *"$DEMYX_CONFIG_CACHE_PLUGIN,inactive"* ]]; then
                demyx_execute "Activating $DEMYX_CONFIG_CACHE_PLUGIN" \
                    "demyx_wp $DEMYX_APP_DOMAIN plugin activate $DEMYX_CONFIG_CACHE_PLUGIN"
            fi
        else
            if [[ "$DEMYX_CONFIG_CACHE_CHECK" == *"$DEMYX_CONFIG_CACHE_PLUGIN,inactive"* ]]; then
                demyx_execute "Activating $DEMYX_CONFIG_CACHE_PLUGIN" \
                    "demyx_wp $DEMYX_APP_DOMAIN plugin activate $DEMYX_CONFIG_CACHE_PLUGIN"
            else
                demyx_execute "Installing $DEMYX_CONFIG_CACHE_PLUGIN" \
                    "demyx_wp $DEMYX_APP_DOMAIN plugin install $DEMYX_CONFIG_CACHE_PLUGIN --activate"

                [[ "$DEMYX_CONFIG_CACHE_PLUGIN" = litespeed-cache ]] && \
                    demyx_execute "Configuring litespeed-cache" \
                        "demyx_wp $DEMYX_APP_DOMAIN option update litespeed.conf.cache-browser 1"
            fi
        fi

        # Delete old cache plugin when switching stacks.
        if [[   "$DEMYX_APP_STACK" = bedrock && "$DEMYX_CONFIG_CACHE_CHECK" == *"litespeed-cache"* ||
                "$DEMYX_APP_STACK" = nginx-php && "$DEMYX_CONFIG_CACHE_CHECK" == *"litespeed-cache"* ]]; then
            demyx_execute "Deleting litespeed-cache" \
                "demyx_wp $DEMYX_APP_DOMAIN plugin uninstall litespeed-cache --deactivate"
        elif [[   "$DEMYX_APP_STACK" = ols && "$DEMYX_CONFIG_CACHE_CHECK" == *"nginx-helper"* ||
                "$DEMYX_APP_STACK" = ols-bedrock && "$DEMYX_CONFIG_CACHE_CHECK" == *"nginx-helper"* ]]; then
            demyx_execute "Deleting nginx-helper" \
                "demyx_wp $DEMYX_APP_DOMAIN plugin uninstall nginx-helper --deactivate"
        elif [[   "$DEMYX_APP_STACK" = ols && "$DEMYX_CONFIG_CACHE_CHECK" == *"wp-rocket"* ||
                "$DEMYX_APP_STACK" = ols-bedrock && "$DEMYX_CONFIG_CACHE_CHECK" == *"wp-rocket"* ]]; then
            demyx_execute "Deactivating wp-rocket" \
                "demyx_wp $DEMYX_APP_DOMAIN plugin deactivate wp-rocket"
        fi
    elif [[ "$DEMYX_CONFIG_FLAG_CACHE" = false ]]; then
        if [[ "$DEMYX_CONFIG_CACHE_CHECK" == *"wp-rocket"* ]]; then
            DEMYX_CONFIG_CACHE_PLUGIN=wp-rocket
        fi

        demyx_execute "Deactivating $DEMYX_CONFIG_CACHE_PLUGIN" \
            "demyx_wp $DEMYX_APP_DOMAIN plugin deactivate $DEMYX_CONFIG_CACHE_PLUGIN"
    fi

    demyx_execute "Updating .env" \
        "demyx_app_env_update DEMYX_APP_CACHE=${DEMYX_CONFIG_FLAG_CACHE}; \
        demyx_app_env_update DEMYX_APP_CACHE_TYPE=${DEMYX_CONFIG_FLAG_CACHE_TYPE}"
}
#
#   Option updater for nginx-helper plugin.
#
demyx_config_cache_helper() {
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_DOMAIN
        DEMYX_APP_WP_CONTAINER
    "

    demyx_wp "$DEMYX_APP_DOMAIN" "option update rt_wp_nginx_helper_options '{\"enable_purge\":\"1\",\"cache_method\":\"enable_fastcgi\",\"purge_method\":\"get_request\",\"enable_map\":null,\"enable_log\":null,\"log_level\":\"INFO\",\"log_filesize\":\"5\",\"enable_stamp\":null,\"purge_homepage_on_edit\":\"1\",\"purge_homepage_on_del\":\"1\",\"purge_archive_on_edit\":\"1\",\"purge_archive_on_del\":\"1\",\"purge_archive_on_new_comment\":\"1\",\"purge_archive_on_deleted_comment\":\"1\",\"purge_page_on_mod\":\"1\",\"purge_page_on_new_comment\":\"1\",\"purge_page_on_deleted_comment\":\"1\",\"redis_hostname\":\"127.0.0.1\",\"redis_port\":\"6379\",\"redis_prefix\":\"nginx-cache:\",\"purge_url\":\"\",\"redis_enabled_by_constant\":0}' --format=json"
}
#
#   Reconfigures an app's MariaDB credentials and reinstall WordPress core files.
#
demyx_config_clean() {
    demyx_event
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
    demyx_event
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
        DEMYX_CONFIG="Development Mode"
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
    demyx_event
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
    demyx_event
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
    demyx_event
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
#   Configure php-fpm values based on app's defined memory.
#
demyx_config_pm() {
    demyx_event
    demyx_ols_not_supported
    DEMYX_CONFIG_COMPOSE=true

    demyx_execute "Configuring php-fpm values" \
        "demyx_app_env_update DEMYX_APP_PHP_PM_MAX_CHILDREN=$(demyx_pm_calc max-children); \
        demyx_app_env_update DEMYX_APP_PHP_PM_MAX_SPARE_SERVERS=$(demyx_pm_calc max-spare); \
        demyx_app_env_update DEMYX_APP_PHP_PM_MIN_SPARE_SERVERS=$(demyx_pm_calc min-spare); \
        demyx_app_env_update DEMYX_APP_PHP_PM_START_SERVERS=$(demyx_pm_calc start-server)"
}
#
#   Configures a phpMyAdmin container for an app.
#
demyx_config_pma() {
    demyx_event
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

    DEMYX_CONFIG_COMPOSE=true

    demyx_execute "Setting pma to $DEMYX_CONFIG_FLAG_PMA" \
        "demyx_app_env_update DEMYX_APP_PMA=${DEMYX_CONFIG_FLAG_PMA}; \
        demyx_yml $DEMYX_APP_STACK"

    if [[ "$DEMYX_CONFIG_FLAG_PMA" = true ]]; then
        DEMYX_CONFIG="phpMyAdmin"
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
    demyx_event
    demyx_ols_not_supported
    demyx_app_env wp "
        DEMYX_APP_RATE_LIMIT
    "

    DEMYX_CONFIG_COMPOSE=true

    demyx_execute "Setting rate limit to $DEMYX_CONFIG_FLAG_RATE_LIMIT" \
        "demyx_app_env_update DEMYX_APP_RATE_LIMIT=$DEMYX_CONFIG_FLAG_RATE_LIMIT"
}
#
#   Configures a Redis container for an app.
#
demyx_config_redis() {
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_DOMAIN
        DEMYX_APP_ID
        DEMYX_APP_STACK
        DEMYX_APP_WP_CONTAINER
    "

    demyx_execute "Setting redis to $DEMYX_CONFIG_FLAG_REDIS" \
        "demyx_app_env_update DEMYX_APP_REDIS=$DEMYX_CONFIG_FLAG_REDIS"

    if [[ "$DEMYX_CONFIG_FLAG_REDIS" = true ]]; then
        demyx_execute "Waiting for redis" \
            "demyx_yml ${DEMYX_APP_STACK}; \
            demyx_compose $DEMYX_APP_DOMAIN up -d 2>&1"

        if [[ "$DEMYX_APP_STACK" = nginx-php || "$DEMYX_APP_STACK" = bedrock ]]; then
            demyx_execute "Configuring redis" \
                "demyx_wp $DEMYX_APP_DOMAIN plugin install redis-cache --activate --force; \
                docker stop ${DEMYX_APP_WP_CONTAINER}; \
                docker rm ${DEMYX_APP_WP_CONTAINER}; \
                demyx_compose $DEMYX_APP_DOMAIN up -d 2>&1; \
                demyx_wp $DEMYX_APP_DOMAIN redis enable"
        elif [[ "$DEMYX_APP_STACK" = ols || "$DEMYX_APP_STACK" = ols-bedrock ]]; then
            demyx_execute "Configuring redis" \
                "demyx_config $DEMYX_APP_DOMAIN --cache plugin install litespeed-cache --activate --force; \
                demyx_wp $DEMYX_APP_DOMAIN option update litespeed.conf.object 1; \
                demyx_wp $DEMYX_APP_DOMAIN option update litespeed.conf.object-kind 1; \
                demyx_wp $DEMYX_APP_DOMAIN option update litespeed.conf.object-host rd_${DEMYX_APP_ID}; \
                demyx_wp $DEMYX_APP_DOMAIN option update litespeed.conf.object-port 6379; \
                demyx_app_env_update DEMYX_APP_CACHE=true"
        fi
    elif [[ "$DEMYX_CONFIG_FLAG_REDIS" = false ]]; then
        if [[ "$DEMYX_APP_STACK" = nginx-php || "$DEMYX_APP_STACK" = bedrock ]]; then
            demyx_execute "Configuring redis" \
                "demyx_wp $DEMYX_APP_DOMAIN redis disable; \
                demyx_wp $DEMYX_APP_DOMAIN plugin uninstall redis-cache --deactivate; \
                docker exec $DEMYX_APP_WP_CONTAINER rm -f wp-content/object-cache.php"
        elif [[ "$DEMYX_APP_STACK" = ols || "$DEMYX_APP_STACK" = ols-bedrock ]]; then
            demyx_execute "Configuring redis" \
                "demyx_wp $DEMYX_APP_DOMAIN option update litespeed.conf.object 0"
        fi

        demyx_compose "$DEMYX_APP_DOMAIN" stop rd_"$DEMYX_APP_ID"
        demyx_compose "$DEMYX_APP_DOMAIN" rm -f rd_"$DEMYX_APP_ID"
        demyx_yml "$DEMYX_APP_STACK"
    fi
}
#
#   Configure an app's container resources.
#
demyx_config_resources() {
    demyx_event
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
#
#   # TODO - Configures an app's restart process without bringing down the container.
#
demyx_config_restart() {
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_DOMAIN
        DEMYX_APP_NX_CONTAINER
        DEMYX_APP_STACK
        DEMYX_APP_WP_CONTAINER
    "

    case "$DEMYX_CONFIG_FLAG_RESTART" in
        nginx-php)
            if [[ "$DEMYX_APP_STACK" = ols || "$DEMYX_APP_STACK" = ols-bedrock ]]; then
                demyx_error custom "This app isn't using an ols or ols-bedrock stack"
            fi
            demyx_execute "Restarting NGINX and PHP" \
                "docker exec -t --user=root $DEMYX_APP_NX_CONTAINER bash -c 'rm -rf /tmp/nginx-cache && sudo -E demyx-reload'; \
                docker exec -t --user=root $DEMYX_APP_WP_CONTAINER bash -c 'kill -9 \$(pidof php-fpm)'"
        ;;
        nginx)
            if [[ "$DEMYX_APP_STACK" = ols || "$DEMYX_APP_STACK" = ols-bedrock ]]; then
                demyx_error custom "This app isn't using an ols or ols-bedrock stack"
            fi
            demyx_execute "Restarting NGINX" \
                "docker exec -t --user=root $DEMYX_APP_NX_CONTAINER bash -c 'rm -rf /tmp/nginx-cache && sudo -E demyx-reload'"
        ;;
        ols)
            if [[ "$DEMYX_APP_STACK" = bedrock || "$DEMYX_APP_STACK" = nginx-php ]]; then
                demyx_error custom "This app isn't using an ols or ols-bedrock stack"
            fi
            demyx_execute "Restarting OLS" \
                "docker exec -t --user=root $DEMYX_APP_WP_CONTAINER demyx-lsws restart"
        ;;
        php)
            if [[ "$DEMYX_APP_STACK" = ols || "$DEMYX_APP_STACK" = ols-bedrock ]]; then
                demyx_error custom "This app isn't using an ols or ols-bedrock stack"
            fi
            demyx_execute "Restarting PHP" \
                "docker exec -t --user=root $DEMYX_APP_WP_CONTAINER bash -c 'kill -9 \$(pidof php-fpm)'"
        ;;
    esac
}
#
#   Configures an SFTP container for an app.
#
demyx_config_sftp() {
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_COMPOSE_PROJECT
        DEMYX_APP_DOMAIN
        DEMYX_APP_ID
        DEMYX_APP_SFTP
        DEMYX_APP_SFTP_PASSWORD
        DEMYX_APP_SFTP_USERNAME
        DEMYX_APP_STACK
        DEMYX_APP_TYPE
    "

    # TODO
    #local DEMYX_CONFIG_SFTP_VOLUME=
    DEMYX_CONFIG_COMPOSE=true

    demyx_execute "Setting SFTP to $DEMYX_CONFIG_FLAG_SFTP" \
        "demyx_app_env_update DEMYX_APP_SFTP=${DEMYX_CONFIG_FLAG_SFTP}; \
        demyx_yml $DEMYX_APP_STACK"

    if [[ "$DEMYX_CONFIG_FLAG_SFTP" = true ]]; then
        DEMYX_CONFIG=SFTP

        demyx_execute "Configuring SFTP container" \
            "demyx_open_port"

        # TODO
        #DEMYX_CONFIG_SFTP_VOLUME="$(docker run -t --rm \
        #    -v "$DEMYX_APP_TYPE"_"$DEMYX_APP_ID"_sftp:/home/demyx \
        #    --entrypoint=bash \
        #    demyx/ssh -c 'if [[ -f /home/demyx/.ssh/authorized_keys ]]; then echo true; fi')"

        {
            echo "IP            $DEMYX_SERVER_IP"
            echo "Port          $(cat < "$DEMYX_TMP"/"$DEMYX_APP_DOMAIN"_sftp)"
            echo "Username      demyx"
            echo "Password      $DEMYX_APP_SFTP_PASSWORD"
        } > "$DEMYX_CONFIG_TRANSIENT"

        # TODO
        #if [[ -z "$DEMYX_CONFIG_SFTP_VOLUME" ]]; then
        #    demyx_warning "No authorized_keys found"
        #    demyx_echo "Please run the command: docker cp \"\$HOME\"/.ssh/authorized_keys ${DEMYX_APP_COMPOSE_PROJECT}_sftp_${DEMYX_APP_ID}_1:/home/demyx/.ssh && docker exec -t ${DEMYX_APP_COMPOSE_PROJECT}_sftp_${DEMYX_APP_ID}_1 sudo demyx-permission"
        #fi
    fi
}
#
#   Configures an app's SSL.
#
demyx_config_ssl() {
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_DOMAIN
        DEMYX_APP_SSL
        DEMYX_APP_SSL_WILDCARD
        DEMYX_APP_STACK
    "
    [[ "$DEMYX_APP_SSL_WILDCARD" = true ]] && demyx_app_env_update DEMYX_APP_SSL_WILDCARD=false
    [[ -n "$DEMYX_CONFIG_FLAG_SSL_WILDCARD" ]] && demyx_error custom "You can't use --ssl-wildcard with this flag"

    DEMYX_CONFIG_COMPOSE=true

    case "$DEMYX_CONFIG_FLAG_SSL" in
        false)
            demyx_execute "Replacing URLs to HTTP" \
                "demyx_wp $DEMYX_APP_DOMAIN search-replace --precise --all-tables https://${DEMYX_APP_DOMAIN} http://${DEMYX_APP_DOMAIN}"
        ;;
        true)
            demyx_execute "Replacing URLs to HTTPS" \
                "demyx_wp $DEMYX_APP_DOMAIN search-replace --precise --all-tables http://${DEMYX_APP_DOMAIN} https://${DEMYX_APP_DOMAIN}"
        ;;
    esac

    demyx_execute "Setting SSL to $DEMYX_CONFIG_FLAG_SSL" \
        "demyx_app_env_update DEMYX_APP_SSL=${DEMYX_CONFIG_FLAG_SSL}; \
        demyx_yml $DEMYX_APP_STACK"
}
#
#   Configures an app's wildcard SSL.
#
demyx_config_ssl_wildcard() {
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_DOMAIN
        DEMYX_APP_SSL
        DEMYX_APP_SSL_WILDCARD
        DEMYX_APP_STACK
    "

    [[ "$DEMYX_DOMAIN" = localhost || "$DEMYX_EMAIL" = info@localhost || "$DEMYX_CF_KEY" = false ]] && demyx_error custom "Please update DEMYX_DOMAIN, DEMYX_EMAIL, and/or DEMYX_CF_KEY on the host"
    [[ -n "$DEMYX_CONFIG_FLAG_SSL" ]] && demyx_error custom "You can't use --ssl with this flag'"

    if [[ "$DEMYX_CONFIG_FLAG_SSL_WILDCARD" = true ]]; then
        [[ "$DEMYX_APP_SSL" = true ]] && demyx_app_env_update DEMYX_APP_SSL=false
        DEMYX_CONFIG_COMPOSE=true
        demyx_execute "Setting wildcard SSL to true" \
            "demyx_wp $DEMYX_APP_DOMAIN search-replace --precise --all-tables http://${DEMYX_APP_DOMAIN} https://${DEMYX_APP_DOMAIN}; \
            demyx_app_env_update DEMYX_APP_SSL_WILDCARD=true; \
            demyx_yml $DEMYX_APP_STACK"
    else
        demyx_execute "Enabling regular SSL" \
            "demyx_app_env_update DEMYX_APP_SSL_WILDCARD=false"
        demyx_config "$DEMYX_APP_DOMAIN" --ssl
    fi
}
#
#   Configures an app's stack switching.
#
demyx_config_stack() {
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_CACHE
        DEMYX_APP_DOMAIN
        DEMYX_APP_OLS_ADMIN_PASSWORD
        DEMYX_APP_OLS_ADMIN_USERNAME
        DEMYX_APP_REDIS
        DEMYX_APP_STACK
        WORDPRESS_USER
        WORDPRESS_USER_PASSWORD
    "

    DEMYX_CONFIG=Stack
    DEMYX_CONFIG_COMPOSE=true
    local DEMYX_CONFIG_STACK_CACHE=
    local DEMYX_CONFIG_STACK_REDIS=
    # TODO
    #local DEMYX_CONFIG_STACK_IMAGE=

    case "$DEMYX_CONFIG_FLAG_STACK" in
        bedrock)
            #DEMYX_CONFIG_STACK_IMAGE=demyx/wordpress:bedrock

            if [[ "$DEMYX_APP_STACK" = nginx-php || "$DEMYX_APP_STACK" = ols ]]; then
                demyx_error custom "$DEMYX_APP_DOMAIN is using $DEMYX_APP_STACK and can't be converted to $DEMYX_CONFIG_FLAG_STACK"
            fi
        ;;
        nginx-php)
            #DEMYX_CONFIG_STACK_IMAGE=demyx/wordpress

            if [[ "$DEMYX_APP_STACK" = bedrock || "$DEMYX_APP_STACK" = ols-bedrock ]]; then
                demyx_error custom "$DEMYX_APP_DOMAIN is using $DEMYX_APP_STACK and can't be converted to $DEMYX_CONFIG_FLAG_STACK"
            fi
        ;;
        ols)
            #DEMYX_CONFIG_STACK_IMAGE=demyx/openlitespeed

            if [[ "$DEMYX_APP_STACK" = bedrock || "$DEMYX_APP_STACK" = ols-bedrock ]]; then
                demyx_error custom "$DEMYX_APP_DOMAIN is using $DEMYX_APP_STACK and can't be converted to $DEMYX_CONFIG_FLAG_STACK"
            fi
        ;;
        ols-bedrock)
            #DEMYX_CONFIG_STACK_IMAGE=demyx/openlitespeed:bedrock

            if [[ "$DEMYX_APP_STACK" = nginx-php || "$DEMYX_APP_STACK" = ols ]]; then
                demyx_error custom "$DEMYX_APP_DOMAIN is using $DEMYX_APP_STACK and can't be converted to $DEMYX_CONFIG_FLAG_STACK"
            fi
        ;;
    esac

    if [[ "$DEMYX_APP_CACHE" = true ]]; then
        DEMYX_CONFIG_STACK_CACHE=true
        demyx_config "$DEMYX_APP_DOMAIN" --cache=false --no-compose
    fi

    if [[ "$DEMYX_APP_REDIS" = true ]]; then
        DEMYX_CONFIG_STACK_REDIS=true
        demyx_config "$DEMYX_APP_DOMAIN" --redis=false --no-compose
    fi

    # TODO
    #demyx_execute "Updating app's image to $DEMYX_CONFIG_STACK_IMAGE" \
    #    "demyx_app_env_update DEMYX_APP_WP_IMAGE=$DEMYX_CONFIG_STACK_IMAGE"

    demyx_execute "Setting stack to $DEMYX_CONFIG_FLAG_STACK" \
        "demyx_app_env_update DEMYX_APP_STACK=$DEMYX_CONFIG_FLAG_STACK &&
        demyx_yml $DEMYX_CONFIG_FLAG_STACK"

    if [[ "$DEMYX_CONFIG_STACK_CACHE" = true ]]; then
        demyx_config "$DEMYX_APP_DOMAIN" --cache --no-compose
    fi

    if [[ "$DEMYX_CONFIG_STACK_REDIS" = true ]]; then
        demyx_config "$DEMYX_APP_DOMAIN" --redis --no-compose
    fi

    {
        echo "WordPress Login           $(demyx_app_login)"
        echo "WordPress Username        $WORDPRESS_USER"
        echo "WordPress Password        $WORDPRESS_USER_PASSWORD"

        if [[ "$DEMYX_APP_STACK" = ols || "$DEMYX_APP_STACK" = ols-bedrock ]]; then
            echo
            echo "OLS Admin Username        $DEMYX_APP_OLS_ADMIN_USERNAME"
            echo "OLS Admin Password        $DEMYX_APP_OLS_ADMIN_PASSWORD"
        fi
    } > "$DEMYX_CONFIG_TRANSIENT"
}
#
#   Configures an app's auto updating of WordPress core, theme, and plugin files.
#
demyx_config_wp_update() {
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_WP_UPDATE
    "

    demyx_execute "Setting WP auto update to $DEMYX_CONFIG_FLAG_WP_UPDATE" \
        "demyx_app_env_update DEMYX_APP_WP_UPDATE=$DEMYX_CONFIG_FLAG_WP_UPDATE"
}
#
#   Configures an app's whitelist mode.
#
demyx_config_whitelist() {
    demyx_event
    # TODO - make this work with OLS
    demyx_ols_not_supported
    demyx_app_env wp "
        DEMYX_APP_IP_WHITELIST
        DEMYX_APP_STACK
    "

    DEMYX_CONFIG_COMPOSE=true

    if [[ "$DEMYX_CONFIG_FLAG_WHITELIST" = --whitelist ]]; then
        DEMYX_CONFIG_FLAG_WHITELIST=all
    fi

    demyx_execute "Setting whitelist to $DEMYX_CONFIG_FLAG_WHITELIST" \
        "demyx_app_env_update DEMYX_APP_IP_WHITELIST=$DEMYX_CONFIG_FLAG_WHITELIST &&
        demyx_yml $DEMYX_APP_STACK"
}
#
#   Configures app's WordPress URL.
#
demyx_config_www() {
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_DOMAIN
        DEMYX_APP_DOMAIN_WWW
        DEMYX_APP_STACK
    "

    DEMYX_CONFIG_COMPOSE=true

    if [[ -n "$(demyx_subdomain "$DEMYX_APP_DOMAIN")" ]]; then
        demyx_error custom "Not allowed with subdomains"
    fi

    case "$DEMYX_CONFIG_FLAG_WWW" in
        false)
            demyx_execute "Updating domain to ${DEMYX_APP_DOMAIN}" \
                "demyx_wordpress_ready; \
                    demyx_wp $DEMYX_APP_DOMAIN search-replace --precise --all-tables $(demyx_app_proto)://www.${DEMYX_APP_DOMAIN} $(demyx_app_proto)://${DEMYX_APP_DOMAIN}"
        ;;
        true)
            demyx_execute "Updating domain to www.${DEMYX_APP_DOMAIN}" \
                "demyx_wordpress_ready; \
                    demyx_wp $DEMYX_APP_DOMAIN search-replace --precise --all-tables $(demyx_app_proto)://${DEMYX_APP_DOMAIN} $(demyx_app_proto)://www.${DEMYX_APP_DOMAIN}"
        ;;
    esac

    demyx_execute "Setting www to $DEMYX_CONFIG_FLAG_WWW" \
        "demyx_app_env_update DEMYX_APP_DOMAIN_WWW=${DEMYX_CONFIG_FLAG_WWW}; \
        demyx_yml $DEMYX_APP_STACK"
}
#
#   Configures an app's xmlrpc setting.
#
demyx_config_xmlrpc() {
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_XMLRPC
    "

    DEMYX_CONFIG_COMPOSE=true

    demyx_execute "Setting xmlrpc.php to $DEMYX_CONFIG_FLAG_XMLRPC" \
        "demyx_app_env_update DEMYX_APP_XMLRPC=$DEMYX_CONFIG_FLAG_XMLRPC"
}
