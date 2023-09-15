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

                    demyx_echo 'Configuring nginx-helper'
                    demyx_execute demyx wp "$DEMYX_APP_DOMAIN" option update rt_wp_nginx_helper_options '{"enable_purge":"1","cache_method":"enable_fastcgi","purge_method":"get_request","enable_map":null,"enable_log":null,"log_level":"INFO","log_filesize":"5","enable_stamp":null,"purge_homepage_on_edit":"1","purge_homepage_on_del":"1","purge_archive_on_edit":"1","purge_archive_on_del":"1","purge_archive_on_new_comment":"1","purge_archive_on_deleted_comment":"1","purge_page_on_mod":"1","purge_page_on_new_comment":"1","purge_page_on_deleted_comment":"1","redis_hostname":"127.0.0.1","redis_port":"6379","redis_prefix":"nginx-cache:","purge_url":"","redis_enabled_by_constant":0}' --format=json; \
                        docker exec -t -e NGINX_CACHE=true "$DEMYX_APP_NX_CONTAINER" demyx-wp; \
                        demyx config "$DEMYX_APP_DOMAIN" --restart=nginx
                else
                    DEMYX_CONFIG_NGINX_HELPER_CHECK="$(demyx exec "$DEMYX_APP_DOMAIN" ls wp-content/plugins | grep nginx-helper || true)"

                    if [[ -n "$DEMYX_CONFIG_NGINX_HELPER_CHECK" ]]; then
                        demyx_echo 'Activating nginx-helper'
                        demyx_execute demyx wp "$DEMYX_APP_DOMAIN" plugin activate nginx-helper
                    else
                        demyx_echo 'Installing nginx-helper'
                        demyx_execute demyx wp "$DEMYX_APP_DOMAIN" plugin install nginx-helper --activate
                    fi

                    demyx_echo 'Configuring nginx-helper'
                    demyx_execute demyx wp "$DEMYX_APP_DOMAIN" option update rt_wp_nginx_helper_options '{"enable_purge":"1","cache_method":"enable_fastcgi","purge_method":"get_request","enable_map":null,"enable_log":null,"log_level":"INFO","log_filesize":"5","enable_stamp":null,"purge_homepage_on_edit":"1","purge_homepage_on_del":"1","purge_archive_on_edit":"1","purge_archive_on_del":"1","purge_archive_on_new_comment":"1","purge_archive_on_deleted_comment":"1","purge_page_on_mod":"1","purge_page_on_new_comment":"1","purge_page_on_deleted_comment":"1","redis_hostname":"127.0.0.1","redis_port":"6379","redis_prefix":"nginx-cache:","purge_url":"","redis_enabled_by_constant":0}' --format=json; \
                        docker exec -t -e NGINX_CACHE=true "$DEMYX_APP_NX_CONTAINER" demyx-wp; \
                        demyx config "$DEMYX_APP_DOMAIN" --restart=nginx
                fi

                demyx_echo 'Updating configs'
                demyx_execute sed -i "s|DEMYX_APP_CACHE=.*|DEMYX_APP_CACHE=true|g" "$DEMYX_APP_PATH"/.env

                demyx compose "$DEMYX_APP_DOMAIN" up -d --remove-orphans
            elif [[ "$DEMYX_CONFIG_CACHE" = false ]]; then
                demyx_app_is_up

                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_CACHE" = false ]] && demyx_die 'Cache is already turned off'
                fi

                if [[ "$DEMYX_APP_STACK" = ols || "$DEMYX_APP_STACK" = ols-bedrock ]]; then
                    demyx_echo 'Deactivating litespeed-cache'
                    demyx_execute demyx wp "$DEMYX_APP_DOMAIN" plugin deactivate litespeed-cache

                    demyx_echo 'Configuring lsws'
                    demyx_execute docker exec -t -e OPENLITESPEED_CACHE=false "$DEMYX_APP_WP_CONTAINER" sh -c 'demyx-config'; \
                        demyx config "$DEMYX_APP_DOMAIN" --restart=ols
                else
                    demyx_echo 'Deactivating nginx-helper'
                    demyx_execute demyx wp "$DEMYX_APP_DOMAIN" plugin deactivate nginx-helper

                    demyx_echo 'Configuring nginx-helper'
                    demyx_execute docker exec -t -e NGINX_CACHE=false "$DEMYX_APP_NX_CONTAINER" demyx-wp; \
                        demyx config "$DEMYX_APP_DOMAIN" --restart=nginx
                fi

                demyx_echo 'Updating configs'
                demyx_execute sed -i "s|DEMYX_APP_CACHE=.*|DEMYX_APP_CACHE=false|g" "$DEMYX_APP_PATH"/.env

                demyx compose "$DEMYX_APP_DOMAIN" up -d --remove-orphans
            fi
            if [[ "$DEMYX_CONFIG_CLOUDFLARE" = true ]]; then
                # Exit if these two variables are missing
                [[ -z "$DEMYX_EMAIL" || -z "$DEMYX_CF_KEY" ]] && demyx_die 'Missing Cloudflare key and/or email, please run demyx help stack'

                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_CLOUDFLARE" = true ]] && demyx_die 'Cloudflare is already set'
                fi

                demyx_echo 'Setting SSL/TLS resolver to Cloudflare'
                demyx_execute sed -i "s|DEMYX_APP_CLOUDFLARE=.*|DEMYX_APP_CLOUDFLARE=true|g" "$DEMYX_APP_PATH"/.env; \
                    demyx refresh "$DEMYX_APP_DOMAIN"
            elif [[ "$DEMYX_CONFIG_CLOUDFLARE" = false ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_CLOUDFLARE" = false ]] && demyx_die 'Cloudflare is already off'
                fi

                demyx_echo 'Setting SSL/TLS resolver to HTTP'
                demyx_execute sed -i "s|DEMYX_APP_CLOUDFLARE=.*|DEMYX_APP_CLOUDFLARE=false|g" "$DEMYX_APP_PATH"/.env; \
                    demyx refresh "$DEMYX_APP_DOMAIN"
            fi
            if [[ -n "$DEMYX_CONFIG_CLEAN" ]]; then
                if [[ -z "$DEMYX_CONFIG_NO_BACKUP" ]]; then
                    demyx backup "$DEMYX_APP_DOMAIN"
                fi
                demyx config "$DEMYX_APP_DOMAIN" --healthcheck=false

                demyx_echo 'Putting WordPress into maintenance mode'
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "echo '<?php \$upgrading = time(); ?>' > .maintenance"

                demyx_echo 'Exporting database'
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" db export "$DEMYX_APP_CONTAINER".sql

                DEMYX_CONFIG_CLEAN_WORDPRESS_DB_USER="$(demyx util --user --raw)"
                DEMYX_CONFIG_CLEAN_WORDPRESS_DB_PASSWORD="$(demyx util --pass --raw)"
                DEMYX_CONFIG_CLEAN_MARIADB_ROOT_PASSWORD="$(demyx util --pass --raw)"

                demyx_echo 'Genearting new MariaDB credentials'
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "sed -i 's|$WORDPRESS_DB_USER|$DEMYX_CONFIG_CLEAN_WORDPRESS_DB_USER|g' /demyx/wp-config.php; sed -i 's|$WORDPRESS_DB_PASSWORD|$DEMYX_CONFIG_CLEAN_WORDPRESS_DB_PASSWORD|g' /demyx/wp-config.php"; \
                    sed -i "s|$WORDPRESS_DB_USER|$DEMYX_CONFIG_CLEAN_WORDPRESS_DB_USER|g" "$DEMYX_APP_PATH"/.env; \
                    sed -i "s|$WORDPRESS_DB_PASSWORD|$DEMYX_CONFIG_CLEAN_WORDPRESS_DB_PASSWORD|g" "$DEMYX_APP_PATH"/.env; \
                    sed -i "s|$MARIADB_ROOT_PASSWORD|$DEMYX_CONFIG_CLEAN_MARIADB_ROOT_PASSWORD|g" "$DEMYX_APP_PATH"/.env

                demyx_app_config

                demyx compose "$DEMYX_APP_DOMAIN" db stop
                demyx compose "$DEMYX_APP_DOMAIN" db rm -f

                demyx_echo 'Deleting old MariaDB volume'
                demyx_execute docker volume rm wp_"$DEMYX_APP_ID"_db

                demyx_echo 'Creating new MariaDB volume'
                demyx_execute docker volume create wp_"$DEMYX_APP_ID"_db

                demyx_echo 'Replacing WordPress core files'
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" core download --force

                demyx compose "$DEMYX_APP_DOMAIN" db up -d

                demyx_echo 'Initializing MariaDB'
                demyx_execute demyx_mariadb_ready

                demyx_echo 'Importing database'
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" db import "$DEMYX_APP_CONTAINER".sql

                demyx_echo 'Deleting exported database'
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" rm "$DEMYX_APP_CONTAINER".sql

                demyx_echo 'Cleaning salts'
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" config shuffle-salts

                demyx_echo 'Removing maintenance mode'
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" rm .maintenance

                demyx compose "$DEMYX_APP_DOMAIN" fr
                demyx maldet "$DEMYX_APP_DOMAIN"
                demyx config "$DEMYX_APP_DOMAIN" --healthcheck
            fi
            if [[ "$DEMYX_CONFIG_DEV" = true ]]; then
                demyx_app_is_up
                demyx_source yml

                [[ -n "$DEMYX_CONFIG_EXPOSE" ]] && demyx_die '--expose is not supported'

                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_DEV" = true ]] && demyx_die 'Dev mode is already turned on'
                fi

                if [[ "$DEMYX_APP_SSL" = false ]]; then
                    DEMYX_CONFIG_DEV_PROTO="http://$DEMYX_APP_DOMAIN"
                else
                    DEMYX_CONFIG_DEV_PROTO="https://$DEMYX_APP_DOMAIN"
                fi

                DEMYX_CONFIG_DEV_BASE_PATH="${DEMYX_CONFIG_DEV_BASE_PATH:-/demyx}"
                DEMYX_CONFIG_DEV_CS_URI="${DEMYX_CONFIG_DEV_PROTO}${DEMYX_CONFIG_DEV_BASE_PATH}/cs/"
                DEMYX_CONFIG_DEV_BS_URI="${DEMYX_CONFIG_DEV_PROTO}${DEMYX_CONFIG_DEV_BASE_PATH}/bs/"

                if [ "$DEMYX_CONFIG_FILES" = plugins ]; then
                    DEMYX_BS_FILES="\"/demyx/wp-content/plugins/**/*\""
                elif [ "$DEMYX_CONFIG_FILES" = false ]; then
                    DEMYX_BS_FILES=
                else
                    DEMYX_BS_FILES="\"/demyx/wp-content/themes/**/*\""
                fi

                demyx_echo 'Updating configs'
                demyx_execute sed -i "s|DEMYX_APP_DEV=.*|DEMYX_APP_DEV=true|g" "$DEMYX_APP_PATH"/.env; \
                    demyx_yml

                demyx config "$DEMYX_APP_DOMAIN" --healthcheck=false
                demyx compose "$DEMYX_APP_DOMAIN" up -d --remove-orphans

                PRINT_TABLE="DEMYX^ DEVELOPMENT\n"
                PRINT_TABLE+="CODE-SERVER^ $DEMYX_CONFIG_DEV_CS_URI\n"
                PRINT_TABLE+="BROWSERSYNC^ $DEMYX_CONFIG_DEV_BS_URI\n"
                PRINT_TABLE+="PASSWORD^ $(demyx_dev_password)"
                demyx_execute -v demyx_table "$PRINT_TABLE"
            elif [[ "$DEMYX_CONFIG_DEV" = false ]]; then
                demyx_app_is_up
                demyx_source yml

                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_DEV" = false ]] && demyx_die 'Dev mode is already turned off'
                fi

                demyx_echo 'Cleaning up'

                if [[ "$DEMYX_APP_STACK" = bedrock || "$DEMYX_APP_STACK" = ols-bedrock ]]; then
                    demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "rm -f \${CODE_SERVER_ROOT}/web/app/mu-plugins/bs.php"
                    demyx config "$DEMYX_APP_DOMAIN" --bedrock=production -f
                elif [[ "$DEMYX_APP_STACK" = nginx-php ]]; then
                    demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "rm -f \${CODE_SERVER_ROOT}/wp-content/mu-plugins/bs.php; sed -i \"s|'WP_DEBUG', true|'WP_DEBUG', false|g\" \${CODE_SERVER_ROOT}/wp-config.php"
                else
                    demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "rm -f \${OPENLITESPEED_ROOT}/wp-content/mu-plugins/bs.php; sed -i \"s|'WP_DEBUG', true|'WP_DEBUG', false|g\" \${OPENLITESPEED_ROOT}/wp-config.php"
                fi

                demyx_echo 'Updating configs'
                demyx_execute sed -i "s|DEMYX_APP_DEV=.*|DEMYX_APP_DEV=false|g" "$DEMYX_APP_PATH"/.env; \
                    demyx_yml

                demyx compose "$DEMYX_APP_DOMAIN" up -d --remove-orphans
                demyx config "$DEMYX_APP_DOMAIN" --healthcheck
            fi
            if [[ "$DEMYX_CONFIG_FIX_INNODB" = true ]]; then
                demyx_echo "Backing up and deleting ib_logfile*"
                demyx_execute docker run -t --rm -v wp_"$DEMYX_APP_ID"_db:/tmp/wp_"$DEMYX_APP_ID"_db demyx/utilities bash -c "cp /tmp/wp_${DEMYX_APP_ID}_db/ib_logfile0 /tmp/wp_${DEMYX_APP_ID}_db/ib_logfile0.bak; cp /tmp/wp_${DEMYX_APP_ID}_db/ib_logfile1 /tmp/wp_${DEMYX_APP_ID}_db/ib_logfile1.bak; rm -f /tmp/wp_${DEMYX_APP_ID}_db/ib_logfile0; rm -f /tmp/wp_${DEMYX_APP_ID}_db/ib_logfile1"; \
                    docker restart "$DEMYX_APP_DB_CONTAINER"
            fi
            if [[ "$DEMYX_CONFIG_HEALTHCHECK" = true ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_HEALTHCHECK" = true ]] && demyx_die 'Healthcheck is already turned on'
                fi
                demyx_echo 'Turning on healthcheck'
                demyx_execute sed -i "s|DEMYX_APP_HEALTHCHECK=.*|DEMYX_APP_HEALTHCHECK=true|g" "$DEMYX_APP_PATH"/.env
            elif [[ "$DEMYX_CONFIG_HEALTHCHECK" = false ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_HEALTHCHECK" = false ]] && demyx_die 'Healthcheck is already turned off'
                fi
                demyx_echo 'Turning off healthcheck'
                demyx_execute sed -i "s|DEMYX_APP_HEALTHCHECK=.*|DEMYX_APP_HEALTHCHECK=false|g" "$DEMYX_APP_PATH"/.env
            fi
            if [[ "$DEMYX_CONFIG_OPCACHE" = true ]]; then
                demyx_app_is_up

                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_PHP_OPCACHE" = true ]] && demyx_die 'PHP opcache is already turned on'
                fi

                demyx_echo 'Turning on PHP opcache'

                if [[ "$DEMYX_APP_WP_IMAGE" = demyx/openlitespeed ]]; then
                    demyx_execute sed -i "s|DEMYX_APP_PHP_OPCACHE=.*|DEMYX_APP_PHP_OPCACHE=true|g" "$DEMYX_APP_PATH"/.env; \
                        docker exec -t -e OPENLITESPEED_PHP_OPCACHE=true "$DEMYX_APP_WP_CONTAINER" demyx-config

                    demyx config "$DEMYX_APP_DOMAIN" --restart=ols; \
                else
                    demyx_execute sed -i "s|DEMYX_APP_PHP_OPCACHE=.*|DEMYX_APP_PHP_OPCACHE=true|g" "$DEMYX_APP_PATH"/.env
                    demyx config "$DEMYX_APP_DOMAIN" --restart=php
                fi
            elif [[ "$DEMYX_CONFIG_OPCACHE" = false ]]; then
                demyx_app_is_up

                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_PHP_OPCACHE" = false ]] && demyx_die 'PHP opcache is already turned off'
                fi

                demyx_echo 'Turning off PHP opcache'

                if [[ "$DEMYX_APP_WP_IMAGE" = demyx/openlitespeed ]]; then
                    demyx_execute sed -i "s|DEMYX_APP_PHP_OPCACHE=.*|DEMYX_APP_PHP_OPCACHE=false|g" "$DEMYX_APP_PATH"/.env; \
                        docker exec -t -e OPENLITESPEED_PHP_OPCACHE=false "$DEMYX_APP_WP_CONTAINER" demyx-config

                    demyx config "$DEMYX_APP_DOMAIN" --restart=ols
                else
                    demyx_execute sed -i "s|DEMYX_APP_PHP_OPCACHE=.*|DEMYX_APP_PHP_OPCACHE=false|g" "$DEMYX_APP_PATH"/.env
                    demyx config "$DEMYX_APP_DOMAIN" --restart=php
                fi
            fi
            if [[ -n "$DEMYX_CONFIG_PHP" ]]; then
                demyx_ols_not_supported

                if [[ -n "$DEMYX_CONFIG_PHP_MAX_CHILDREN" ]]; then
                    demyx_echo "Updating pm.max_children $DEMYX_CONFIG_PHP_MAX_CHILDREN"
                    demyx_execute sed -i "s|DEMYX_APP_PHP_PM_MAX_CHILDREN=.*|DEMYX_APP_PHP_PM_MAX_CHILDREN=$DEMYX_CONFIG_PHP_MAX_CHILDREN|g" "$DEMYX_APP_PATH"/.env
                fi
                if [[ -n "$DEMYX_CONFIG_PHP_MAX_REQUESTS" ]]; then
                    demyx_echo "Updating pm.max_requests $DEMYX_CONFIG_PHP_MAX_REQUESTS"
                    demyx_execute sed -i "s|DEMYX_APP_PHP_PM_MAX_REQUESTS=.*|DEMYX_APP_PHP_PM_MAX_REQUESTS=$DEMYX_CONFIG_PHP_MAX_REQUESTS|g" "$DEMYX_APP_PATH"/.env
                fi
                if [[ -n "$DEMYX_CONFIG_PHP_MAX_SPARE_SERVERS" ]]; then
                    demyx_echo "Updating pm.max_spare_servers $DEMYX_CONFIG_PHP_MAX_SPARE_SERVERS"
                    demyx_execute sed -i "s|DEMYX_APP_PHP_PM_MAX_SPARE_SERVERS=.*|DEMYX_APP_PHP_PM_MAX_SPARE_SERVERS=$DEMYX_CONFIG_PHP_MAX_SPARE_SERVERS|g" "$DEMYX_APP_PATH"/.env
                fi
                if [[ -n "$DEMYX_CONFIG_PHP_MIN_SPARE_SERVERS" ]]; then
                    demyx_echo "Updating pm.min_spare_servers $DEMYX_CONFIG_PHP_MIN_SPARE_SERVERS"
                    demyx_execute sed -i "s|DEMYX_APP_PHP_PM_MIN_SPARE_SERVERS=.*|DEMYX_APP_PHP_PM_MIN_SPARE_SERVERS=$DEMYX_CONFIG_PHP_MIN_SPARE_SERVERS|g" "$DEMYX_APP_PATH"/.env
                fi
                if [[ -n "$DEMYX_CONFIG_PHP_PM" ]]; then
                    demyx_echo "Updating pm $DEMYX_CONFIG_PHP_PM"
                    demyx_execute sed -i "s|DEMYX_APP_PHP_PM=.*|DEMYX_APP_PHP_PM=$DEMYX_CONFIG_PHP_PM|g" "$DEMYX_APP_PATH"/.env
                fi
                if [[ -n "$DEMYX_CONFIG_PHP_PROCESS_IDLE_TIMEOUT" ]]; then
                    demyx_echo "Updating pm.process_idle_timeout $DEMYX_CONFIG_PHP_PROCESS_IDLE_TIMEOUT"
                    demyx_execute sed -i "s|DEMYX_APP_PHP_PM_PROCESS_IDLE_TIMEOUT=.*|DEMYX_APP_PHP_PM_PROCESS_IDLE_TIMEOUT=$DEMYX_CONFIG_PHP_PROCESS_IDLE_TIMEOUT|g" "$DEMYX_APP_PATH"/.env
                fi
                if [[ -n "$DEMYX_CONFIG_PHP_START_SERVERS" ]]; then
                    demyx_echo "Updating pm.start_servers $DEMYX_CONFIG_PHP_START_SERVERS"
                    demyx_execute sed -i "s|DEMYX_APP_PHP_PM_START_SERVERS=.*|DEMYX_APP_PHP_PM_START_SERVERS=$DEMYX_CONFIG_PHP_START_SERVERS|g" "$DEMYX_APP_PATH"/.env
                fi

                demyx compose "$DEMYX_APP_DOMAIN" up -d wp_"$DEMYX_APP_ID"
            fi
            if [[ "$DEMYX_CONFIG_PMA" = true ]]; then
                demyx_app_is_up

                DEMYX_CONFIG_PMA_CONTAINER_CHECK="$(echo "$DEMYX_DOCKER_PS" | grep "$DEMYX_APP_COMPOSE_PROJECT"_pma || true)"
                [[ -n "$DEMYX_CONFIG_PMA_CONTAINER_CHECK" ]] && demyx_die 'phpMyAdmin container is already running'

                if [[ -n "$DEMYX_CONFIG_EXPOSE" || "$DEMYX_APP_SSL" = false ]]; then
                    [[ -n "$DEMYX_CONFIG_EXPOSE" ]] && DEMYX_APP_DOMAIN="$DEMYX_SERVER_IP"
                    DEMYX_CONFIG_PMA_PROTO="http://$DEMYX_APP_DOMAIN"
                    DEMYX_CONFIG_PMA_LABELS="-l traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-pma.entrypoints=http"
                else
                    DEMYX_CONFIG_PMA_PROTO="https://$DEMYX_APP_DOMAIN"
                    DEMYX_CONFIG_PMA_LABELS="-l traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-pma.entrypoints=https
                            -l traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-pma.tls.certresolver=demyx"
                fi

                DEMYX_CONFIG_PMA_ABSOLUTE_URI="$DEMYX_CONFIG_PMA_PROTO"/demyx/pma/

                demyx_echo 'Creating phpMyAdmin container'

                if [[ -n "$DEMYX_CONFIG_EXPOSE" || -n "$(demyx_validate_ip)" ]]; then
                    DEMYX_CONFIG_PMA_PORT="$(demyx_open_port 8080)"
                    DEMYX_CONFIG_PMA_ABSOLUTE_URI="$DEMYX_CONFIG_PMA_PROTO":"$DEMYX_CONFIG_PMA_PORT"

                    demyx_execute docker run -d --rm \
                        --name="$DEMYX_APP_COMPOSE_PROJECT"_pma \
                        --network=demyx \
                        --cpus="$DEMYX_CPU" \
                        --memory="$DEMYX_MEM" \
                        -p "$DEMYX_CONFIG_PMA_PORT":80 \
                        -e PMA_HOST=db_"$DEMYX_APP_ID" \
                        -e MYSQL_ROOT_PASSWORD="$MARIADB_ROOT_PASSWORD" \
                        -e PMA_ABSOLUTE_URI="$DEMYX_CONFIG_PMA_ABSOLUTE_URI" \
                        phpmyadmin/phpmyadmin 2>/dev/null
                else
                    demyx_execute docker run -d --rm \
                        --name="$DEMYX_APP_COMPOSE_PROJECT"_pma \
                        --network=demyx \
                        --cpus="$DEMYX_CPU" \
                        --memory="$DEMYX_MEM" \
                        -p "$DEMYX_CONFIG_PMA_PORT":80 \
                        -e PMA_HOST=db_"$DEMYX_APP_ID" \
                        -e MYSQL_ROOT_PASSWORD="$MARIADB_ROOT_PASSWORD" \
                        -e PMA_ABSOLUTE_URI="$DEMYX_CONFIG_PMA_ABSOLUTE_URI" \
                        -l "traefik.enable=true" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-pma.rule=(Host(\`${DEMYX_APP_DOMAIN}\`) && PathPrefix(\`/demyx/pma/\`))" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-pma.middlewares=${DEMYX_APP_COMPOSE_PROJECT}-pma-prefix" \
                        -l "traefik.http.middlewares.${DEMYX_APP_COMPOSE_PROJECT}-pma-prefix.stripprefix.prefixes=/demyx/pma/" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-pma.priority=99" \
                        $DEMYX_CONFIG_PMA_LABELS \
                        phpmyadmin/phpmyadmin 2>/dev/null
                fi

                PRINT_TABLE="DEMYX^ PHPMYADMIN\n"
                PRINT_TABLE+="URL^ $DEMYX_CONFIG_PMA_ABSOLUTE_URI\n"
                PRINT_TABLE+="USERNAME^ $WORDPRESS_DB_USER\n"
                PRINT_TABLE+="PASSWORD^ $WORDPRESS_DB_PASSWORD\n"
                demyx_execute -v demyx_table "$PRINT_TABLE"
            elif [[ "$DEMYX_CONFIG_PMA" = false ]]; then
                demyx_app_is_up

                DEMYX_CONFIG_PMA_CONTAINER_CHECK="$(echo "$DEMYX_DOCKER_PS" | grep "$DEMYX_APP_COMPOSE_PROJECT"_pma || true)"
                [[ -z "$DEMYX_CONFIG_PMA_CONTAINER_CHECK" ]] && demyx_die 'No phpMyAdmin container running'

                demyx_echo 'Stopping phpMyAdmin container'
                demyx_execute docker stop "$DEMYX_APP_COMPOSE_PROJECT"_pma
            fi
            if [[ "$DEMYX_CONFIG_RATE_LIMIT" = true ]]; then
                demyx_app_is_up
                demyx_ols_not_supported

                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_RATE_LIMIT" = true ]] && demyx_die 'Rate limit is already turned on'
                fi

                demyx_echo 'Turning on rate limiting'
                demyx_execute docker exec -t -e NGINX_RATE_LIMIT=true "$DEMYX_APP_NX_CONTAINER" demyx-wp; \
                    sed -i "s|DEMYX_APP_RATE_LIMIT=.*|DEMYX_APP_RATE_LIMIT=true|g" "$DEMYX_APP_PATH"/.env

                demyx config "$DEMYX_APP_DOMAIN" --restart=nginx
            elif [[ "$DEMYX_CONFIG_RATE_LIMIT" = false ]]; then
                demyx_app_is_up
                demyx_ols_not_supported

                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_RATE_LIMIT" = false ]] && demyx_die 'Rate limit is already turned off'
                fi

                demyx_echo 'Turning off rate limiting'
                demyx_execute docker exec -t -e NGINX_RATE_LIMIT=false "$DEMYX_APP_NX_CONTAINER" demyx-wp; \
                    sed -i "s|DEMYX_APP_RATE_LIMIT=.*|DEMYX_APP_RATE_LIMIT=false|g" "$DEMYX_APP_PATH"/.env

                demyx config "$DEMYX_APP_DOMAIN" --restart=nginx
            fi
            if [[ -n "$DEMYX_CONFIG_RESOURCE" ]]; then
                if [[ -n "$DEMYX_CONFIG_DB_CPU" ]]; then
                    demyx_echo "Updating $DEMYX_APP_DOMAIN database CPU"

                    if [[ "$DEMYX_CONFIG_DB_CPU" = null ]]; then
                        demyx_execute sed -i "s|DEMYX_APP_DB_CPU=.*|DEMYX_APP_DB_CPU=|g" "$DEMYX_APP_PATH"/.env
                    else
                        demyx_execute sed -i "s|DEMYX_APP_DB_CPU=.*|DEMYX_APP_DB_CPU=$DEMYX_CONFIG_DB_CPU|g" "$DEMYX_APP_PATH"/.env
                    fi
                fi
                if [[ -n "$DEMYX_CONFIG_DB_MEM" ]]; then
                    demyx_echo "Updating $DEMYX_APP_DOMAIN database MEM"

                    if [[ "$DEMYX_CONFIG_DB_MEM" = null ]]; then
                        demyx_execute sed -i "s|DEMYX_APP_DB_MEM=.*|DEMYX_APP_DB_MEM=|g" "$DEMYX_APP_PATH"/.env
                    else
                        demyx_execute sed -i "s|DEMYX_APP_DB_MEM=.*|DEMYX_APP_DB_MEM=$DEMYX_CONFIG_DB_MEM|g" "$DEMYX_APP_PATH"/.env
                    fi
                fi
                if [[ -n "$DEMYX_CONFIG_WP_CPU" ]]; then
                    demyx_echo "Updating $DEMYX_APP_DOMAIN CPU"

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
