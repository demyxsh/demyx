# Demyx
# https://demyx.sh
# 
# demyx config <app> <args>
#

DEMYX_SFTP_PORT_DEFAULT=22222

demyx_config() {
    while :; do
        case "$3" in
            --auth|--auth=on)
                DEMYX_CONFIG_AUTH=on
                ;;
            --auth=off)
                DEMYX_CONFIG_AUTH=off
                ;;
            --auth-wp|--auth-wp=on)
                DEMYX_CONFIG_AUTH_WP=on
                ;;
            --auth-wp=off)
                DEMYX_CONFIG_AUTH_WP=off
                ;;
            --cache|--cache=on)
                DEMYX_CONFIG_CACHE=on
                ;;
            --cache=off)
                DEMYX_CONFIG_CACHE=off
                ;;
            --cdn|--cdn=on)
                DEMYX_CONFIG_CDN=on
                ;;
            --cdn=off)
                DEMYX_CONFIG_CDN=off
                ;;
            --clean)
                DEMYX_CONFIG_CLEAN=1
                ;;
            --dev|--dev=on)
                DEMYX_CONFIG_DEV=on
                ;;
            --dev=off)
                DEMYX_CONFIG_DEV=off
                ;;
            --files=?*)
                DEMYX_CONFIG_FILES=${3#*=}
                ;;
            --files=)
                demyx_die '"--files" cannot be empty'
                ;;
            -f|--force)
                DEMYX_CONFIG_FORCE=1
                ;;
            --healthcheck|--healthcheck=on)
                DEMYX_CONFIG_HEALTHCHECK=on
                ;;
            --healthcheck=off)
                DEMYX_CONFIG_HEALTHCHECK=off
                ;;
            --no-backup)
                DEMYX_CONFIG_NO_BACKUP=1
                ;;
            --opcache|--opcache=on)
                DEMYX_CONFIG_OPCACHE=on
                ;;
            --opcache=off)
                DEMYX_CONFIG_OPCACHE=off
                ;;
            --pma|--pma=on)
                DEMYX_CONFIG_PMA=on
                ;;
            --pma=off)
                DEMYX_CONFIG_PMA=off
                ;;
            --rate-limit|--rate-limit=on)
                DEMYX_CONFIG_RATE_LIMIT=on
                ;;
            --rate-limit=off)
                DEMYX_CONFIG_RATE_LIMIT=off
                ;;
            --refresh)
                DEMYX_CONFIG_REFRESH=1
                ;;
            --restart=?*)
                DEMYX_CONFIG_RESTART=${3#*=}
                ;;
            --restart=)
                demyx_die '"--restart" cannot be empty'
                ;;
            --sftp|--sftp=on)
                DEMYX_CONFIG_SFTP=on
                ;;
            --sftp=off)
                DEMYX_CONFIG_SFTP=off
                ;;
            --ssl|--ssl=on)
                DEMYX_CONFIG_SSL=on
                ;;
            --ssl=off)
                DEMYX_CONFIG_SSL=off
                ;;
            --wp-update|--wp-update=on)
                DEMYX_CONFIG_WP_UPDATE=on
                ;;
            --wp-update=off)
                DEMYX_CONFIG_WP_UPDATE=off
                ;;
            --)
                shift
                break
                ;;
            -?*)
                printf '\e[31m[CRITICAL]\e[39m Unknown option: %s\n' "$3" >&2
                exit 1
                ;;
            *)
                break
        esac
        shift
    done

    if [[ "$DEMYX_TARGET" = all ]]; then
        cd "$DEMYX_WP" || exit
        for i in *
        do
            if [[ -n "$DEMYX_CONFIG_REFRESH" ]]; then
                if [[ -n "$DEMYX_CONFIG_NO_BACKUP" ]]; then
                    demyx config "$i" --refresh --no-backup
                else
                    demyx config "$i" --refresh
                fi
            fi
            if [[ -n "$DEMYX_CONFIG_RESTART" ]]; then
                echo -e "\e[34m[INFO]\e[39m Restarting service for $i"
                demyx config "$i" --restart="$DEMYX_CONFIG_RESTART"
            fi
        done
    else
        demyx_app_config
        if [[ "$DEMYX_APP_TYPE" = wp ]]; then
            source "$DEMYX_FUNCTION"/env.sh
            source "$DEMYX_FUNCTION"/yml.sh
            
            cd "$DEMYX_APP_PATH" || exit

            if [[ "$DEMYX_CONFIG_AUTH" = on ]]; then
                demyx_echo 'Turning on basic auth'
                demyx_execute sed -i "s/DEMYX_APP_AUTH=off/DEMYX_APP_AUTH=on/g" "$DEMYX_APP_PATH"/.env && \
                    demyx_yml
                
                demyx_execute -v demyx compose "$DEMYX_APP_DOMAIN" wp up -d --remove-orphans
            elif [[ "$DEMYX_CONFIG_AUTH" = off ]]; then
                demyx_echo 'Turning off basic auth'
                demyx_execute sed -i "s/DEMYX_APP_AUTH=on/DEMYX_APP_AUTH=off/g" "$DEMYX_APP_PATH"/.env && \
                    demyx_yml

                demyx_execute -v demyx compose "$DEMYX_APP_DOMAIN" wp up -d --remove-orphans
            fi
            if [[ "$DEMYX_CONFIG_AUTH_WP" = on ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_AUTH_WP" != off ]] && demyx_die 'Basic WP Auth is already turned on'
                fi

                DEMYX_PARSE_BASIC_AUTH=$(grep -s DEMYX_STACK_AUTH "$DEMYX_STACK"/.env | awk -F '[=]' '{print $2}' || true)

                if [[ ! -f "$DEMYX_APP_PATH"/.htpasswd ]]; then
                    demyx_echo 'Generating htpasswd'
                    demyx_execute -v -q echo "$DEMYX_PARSE_BASIC_AUTH" > "$DEMYX_APP_PATH"/.htpasswd
                fi

                demyx_echo "Turning on wp-login.php basic auth"
                demyx_execute docker cp "$DEMYX_APP_PATH"/.htpasswd "$DEMYX_APP_WP_CONTAINER":/; \
                    docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "sed -i 's|#auth_basic|auth_basic|g' /etc/nginx/nginx.conf" && \
                    sed -i "s/DEMYX_APP_AUTH_WP=.*/DEMYX_APP_AUTH_WP=$DEMYX_PARSE_BASIC_AUTH/g" "$DEMYX_APP_PATH"/.env

                demyx config "$DEMYX_APP_DOMAIN" --restart=nginx
            elif [[ "$DEMYX_CONFIG_AUTH_WP" = off ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_AUTH_WP" = off ]] && demyx_die 'Basic WP Auth is already turned off'
                fi
                
                demyx_echo "Turning off wp-login.php basic auth"
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "sed -i 's/auth_basic/#auth_basic/g' /etc/nginx/nginx.conf; rm /.htpasswd" && \
                    sed -i "s/DEMYX_APP_AUTH_WP=.*/DEMYX_APP_AUTH_WP=off/g" "$DEMYX_APP_PATH"/.env

                if [[ -f "$DEMYX_APP_PATH"/.htpasswd ]]; then
                    demyx_echo 'Cleaning up'
                    demyx_execute rm "$DEMYX_APP_PATH"/.htpasswd
                fi

                demyx config "$DEMYX_APP_DOMAIN" --restart=nginx
            fi
            if [[ "$DEMYX_CONFIG_CACHE" = on ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_CACHE" = on ]] && demyx_die 'Cache is already turned on'
                fi

                DEMYX_CONFIG_NGINX_HELPER_CHECK=$(demyx exec "$DEMYX_APP_DOMAIN" ls wp-content/plugins | grep nginx-helper || true)

                if [[ -n "$DEMYX_CONFIG_NGINX_HELPER_CHECK" ]]; then
                    demyx_echo 'Activating nginx-helper'
                    demyx_execute demyx wp "$DEMYX_APP_DOMAIN" plugin activate nginx-helper
                else
                    demyx_echo 'Installing nginx-helper'
                    demyx_execute demyx wp "$DEMYX_APP_DOMAIN" plugin install nginx-helper --activate
                fi
                
                demyx_echo 'Configuring nginx-helper' 
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" option update rt_wp_nginx_helper_options '{"enable_purge":"1","cache_method":"enable_fastcgi","purge_method":"get_request","enable_map":null,"enable_log":null,"log_level":"INFO","log_filesize":"5","enable_stamp":null,"purge_homepage_on_edit":"1","purge_homepage_on_del":"1","purge_archive_on_edit":"1","purge_archive_on_del":"1","purge_archive_on_new_comment":"1","purge_archive_on_deleted_comment":"1","purge_page_on_mod":"1","purge_page_on_new_comment":"1","purge_page_on_deleted_comment":"1","redis_hostname":"127.0.0.1","redis_port":"6379","redis_prefix":"nginx-cache:","purge_url":"","redis_enabled_by_constant":0}' --format=json

                demyx_echo 'Updating configs'
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "sed -i 's|#include /etc/nginx/cache|include /etc/nginx/cache|g' /etc/nginx/nginx.conf" && \
                    sed -i "s/DEMYX_APP_CACHE=off/DEMYX_APP_CACHE=on/g" "$DEMYX_APP_PATH"/.env

                demyx config "$DEMYX_APP_DOMAIN" --restart=nginx
            elif [[ "$DEMYX_CONFIG_CACHE" = off ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_CACHE" = off ]] && demyx_die 'Cache is already turned off'
                fi

                demyx_echo 'Deactivating nginx-helper' 
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" plugin deactivate nginx-helper
                
                demyx_echo 'Updating configs'
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "sed -i 's|include /etc/nginx/cache|#include /etc/nginx/cache|g' /etc/nginx/nginx.conf" && \
                    sed -i "s/DEMYX_APP_CACHE=on/DEMYX_APP_CACHE=off/g" "$DEMYX_APP_PATH"/.env

                demyx config "$DEMYX_APP_DOMAIN" --restart=nginx
            fi
            if [[ "$DEMYX_CONFIG_CDN" = on ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_CDN" = on ]] && demyx_die 'CDN is already turned on'
                fi

                DEMYX_CONFIG_CDN_ENABLER_CHECK=$(demyx exec "$DEMYX_APP_DOMAIN" ls wp-content/plugins | grep cdn-enabler || true)

                if [[ -n "$DEMYX_CONFIG_CDN_ENABLER_CHECK" ]]; then
                    demyx_echo 'Activating cdn-enabler'
                    demyx_execute demyx wp "$DEMYX_APP_DOMAIN" plugin activate cdn-enabler
                else
                    demyx_echo 'Installing cdn-enabler'
                    demyx_execute demyx wp "$DEMYX_APP_DOMAIN" plugin install cdn-enabler --activate
                fi
                
                demyx_echo 'Configuring cdn-enabler' 
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" option update cdn_enabler "{\"url\":\"https:\/\/cdn.staticaly.com\/img\/$DEMYX_APP_DOMAIN\",\"dirs\":\"wp-content,wp-includes\",\"excludes\":\".3g2, .3gp, .aac, .aiff, .alac, .apk, .avi, .css, .doc, .docx, .flac, .flv, .h264, .js, .json, .m4v, .mkv, .mov, .mp3, .mp4, .mpeg, .mpg, .ogg, .pdf, .php, .rar, .rtf, .svg, .tex, .ttf, .txt, .wav, .wks, .wma, .wmv, .woff, .woff2, .wpd, .wps, .xml, .zip, wp-content\/plugins, wp-content\/themes\",\"relative\":1,\"https\":1,\"keycdn_api_key\":\"\",\"keycdn_zone_id\":0}" --format=json && \
                    sed -i "s/DEMYX_APP_CDN=off/DEMYX_APP_CDN=on/g" "$DEMYX_APP_PATH"/.env
            elif [[ "$DEMYX_CONFIG_CDN" = off ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_CDN" = off ]] && demyx_die 'CDN is already turned off'
                fi
                demyx_echo 'Deactivating cdn-enabler' 
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" plugin deactivate cdn-enabler && \
                    sed -i "s/DEMYX_APP_CDN=on/DEMYX_APP_CDN=off/g" "$DEMYX_APP_PATH"/.env
            fi
            if [[ -n "$DEMYX_CONFIG_CLEAN" ]]; then
                if [[ -z "$DEMYX_CONFIG_NO_BACKUP" ]]; then
                    demyx backup "$DEMYX_APP_DOMAIN"
                fi
                demyx config "$DEMYX_APP_DOMAIN" --healthcheck=off

                demyx_echo 'Stopping php-fpm'
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" pkill php-fpm

                demyx_echo 'Exporting database'
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" db export "$DEMYX_APP_CONTAINER".sql

                DEMYX_CONFIG_CLEAN_WORDPRESS_DB_PASSWORD=$(demyx util --pass --raw)
                DEMYX_CONFIG_CLEAN_MARIADB_ROOT_PASSWORD=$(demyx util --pass --raw)

                demyx_echo 'Genearting new MariaDB credentials'
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "sed -i \"s|$WORDPRESS_DB_PASSWORD|$DEMYX_CONFIG_CLEAN_WORDPRESS_DB_PASSWORD|g\" /var/www/html/wp-config.php"
                demyx_execute -v -q sed -i "s|$WORDPRESS_DB_PASSWORD|$DEMYX_CONFIG_CLEAN_WORDPRESS_DB_PASSWORD|g" "$DEMYX_APP_PATH"/.env; \
                    demyx_execute -v -q sed -i "s|$MARIADB_ROOT_PASSWORD|$DEMYX_CONFIG_CLEAN_MARIADB_ROOT_PASSWORD|g" "$DEMYX_APP_PATH"/.env
                demyx_app_config

                demyx_execute -v demyx compose "$DEMYX_APP_DOMAIN" db stop
                demyx_execute -v demyx compose "$DEMYX_APP_DOMAIN" db rm -f

                demyx_echo 'Deleting old MariaDB volume'
                demyx_execute docker volume rm wp_"$DEMYX_APP_ID"_db

                demyx_echo 'Creating new MariaDB volume'
                demyx_execute docker volume create wp_"$DEMYX_APP_ID"_db

                demyx_echo 'Replacing WordPress core files'
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" core download --force

                demyx_execute -v demyx compose "$DEMYX_APP_DOMAIN" db up -d

                demyx_echo 'Initializing MariaDB'
                demyx_execute demyx_mariadb_ready

                demyx_echo 'Importing database'
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" db import "$DEMYX_APP_CONTAINER".sql

                demyx_echo 'Deleting exported database'
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" rm "$DEMYX_APP_CONTAINER".sql

                demyx config "$DEMYX_APP_DOMAIN" --restart=nginx-php
                demyx config "$DEMYX_APP_DOMAIN" --healthcheck

                demyx_echo 'Cleaning salts'
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" config shuffle-salts

                demyx_execute -v demyx compose "$DEMYX_APP_DOMAIN" du
            fi
            if [[ "$DEMYX_CONFIG_DEV" = on ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_DEV" = on ]] && demyx_die 'Dev mode is already turned on'
                fi
 
                if [[ "$DEMYX_APP_SSL" = on ]]; then
                    DEMYX_CONFIG_DEV_PROTO="https://$DEMYX_APP_DOMAIN"
                else
                    DEMYX_CONFIG_DEV_PROTO="http://$DEMYX_APP_DOMAIN"
                fi

                source "$DEMYX_STACK"/.env
                source "$DEMYX_FUNCTION"/plugin.sh

                if [ "$DEMYX_CONFIG_FILES" = themes ]; then
                    DEMYX_BS_FILES="\"/var/www/html/wp-content/themes/**/*\""
                elif [ "$DEMYX_CONFIG_FILES" = plugins ]; then
                    DEMYX_BS_FILES="\"/var/www/html/wp-content/plugins/**/*\""
                elif [ -z "$DEMYX_CONFIG_FILES" ]; then
                    DEMYX_BS_FILES='["/var/www/html/wp-content/themes/**/*", "/var/www/html/wp-content/plugins/**/*"]'
                else
                    DEMYX_BS_FILES="\"$DEMYX_CONFIG_FILES/**/*\""
                fi

                demyx_echo 'Creating code-server'
                demyx_execute docker run -dit --rm \
                    --name "$DEMYX_APP_COMPOSE_PROJECT"_cs \
                    --net demyx \
                    --volumes-from "$DEMYX_APP_WP_CONTAINER" \
                    -e PASSWORD="$MARIADB_ROOT_PASSWORD" \
                    -e DEMYX=true \
                    -e DEMYX_APP_DOMAIN="$DEMYX_APP_DOMAIN" \
                    -e DEMYX_APP_WP_CONTAINER="$DEMYX_APP_WP_CONTAINER" \
                    -e DEMYX_BS_FILES="$DEMYX_BS_FILES" \
                    -l "traefik.enable=true" \
                    -l "traefik.coder.frontend.rule=Host:${DEMYX_APP_DOMAIN}; PathPrefixStrip: /demyx-cs/" \
                    -l "traefik.coder.port=8080" \
                    -l "traefik.bs.frontend.rule=Host:${DEMYX_APP_DOMAIN}; PathPrefixStrip: /demyx-bs/" \
                    -l "traefik.bs.port=3000" \
                    -l "traefik.socket.frontend.rule=Host:${DEMYX_APP_DOMAIN}; PathPrefix: /browser-sync/socket.io/" \
                    -l "traefik.socket.port=3000" \
                    demyx/code-server:wp

                DEMYX_CONFIG_PLUGINS_CHECK=$(demyx wp "$DEMYX_APP_DOMAIN" plugin list --format=csv)
                DEMYX_CONFIG_AUTOVER_CHECK=$(echo "$DEMYX_CONFIG_PLUGINS_CHECK" | grep -s autover || true)
                DEMYX_CONFIG_CACHE_CHECK=$(demyx info "$DEMYX_APP_DOMAIN" --filter=DEMYX_APP_CACHE)
                DEMYX_CONFIG_BS_PLUGIN_CHECK=$(echo "$DEMYX_CONFIG_PLUGINS_CHECK" | grep -s demyx_browsersync || true)

                if [ -n "$DEMYX_CONFIG_AUTOVER_CHECK" ]; then
                    demyx_echo 'Activating autover plugin'
                    demyx_execute demyx wp "$DEMYX_APP_DOMAIN" plugin activate autover
                else
                    demyx_echo 'Installing autover plugin'
                    demyx_execute demyx wp "$DEMYX_APP_DOMAIN" plugin install autover --activate
                fi

                if [ -n "$DEMYX_CONFIG_BS_PLUGIN_CHECK" ]; then
                    demyx_echo 'Activating demyx_browsersync plugin'
                    demyx_execute demyx wp "$DEMYX_APP_DOMAIN" plugin activate demyx_browsersync
                else
                    demyx_echo 'Creating demyx_browsersync plugin'
                    demyx_execute demyx_plugin; \
                        docker cp "$DEMYX_APP_PATH"/demyx_browsersync.php "$DEMYX_APP_WP_CONTAINER":/var/www/html/wp-content/plugins; \
                        rm "$DEMYX_APP_PATH"/demyx_browsersync.php
                
                    demyx_echo 'Activating demyx_browsersync plugin'
                    demyx_execute demyx wp "$DEMYX_APP_DOMAIN" plugin activate demyx_browsersync
                fi

                if [[ "$DEMYX_CONFIG_CACHE_CHECK" = on ]]; then
                    touch "$DEMYX_APP_PATH"/.cache
                    demyx config "$DEMYX_APP_DOMAIN" --cache=off
                fi

                demyx config "$DEMYX_APP_DOMAIN" --opcache=off

                demyx_execute -v sed -i "s/DEMYX_APP_DEV=off/DEMYX_APP_DEV=on/g" "$DEMYX_APP_PATH"/.env

                PRINT_TABLE="DEMYX^ DEVELOPMENT MODE\n"

                PRINT_TABLE="DEMYX^ DEVELOPMENT\n"
                PRINT_TABLE+="CODE-SERVER^ $DEMYX_CONFIG_DEV_PROTO/demyx-cs/\n"
                PRINT_TABLE+="CODE-SERVER PASSWORD^ $MARIADB_ROOT_PASSWORD\n"
                PRINT_TABLE+="BROWSERSYNC^ $DEMYX_CONFIG_DEV_PROTO/demyx-bs/\n"
                PRINT_TABLE+="BROWSERSYNC INSTRUCTION^ Type demyx-bs in the terminal of coder-server to start BrowserSync."
                demyx_execute -v demyx_table "$PRINT_TABLE"
            elif [[ "$DEMYX_CONFIG_DEV" = off ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_DEV" = off ]] && demyx_die 'Dev mode is already turned off'
                fi

                demyx_echo 'Deactivating autover' 
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" plugin deactivate autover

                demyx_echo 'Deactivating demyx_browsersync' 
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" plugin deactivate demyx_browsersync; \

                demyx config "$DEMYX_APP_DOMAIN" --opcache

                demyx_echo 'Stopping coder-server'
                demyx_execute docker stop "$DEMYX_APP_COMPOSE_PROJECT"_cs
                
                demyx_execute -v sed -i "s/DEMYX_APP_DEV=on/DEMYX_APP_DEV=off/g" "$DEMYX_APP_PATH"/.env

                if [[ -f "$DEMYX_APP_PATH"/.cache ]]; then
                    rm "$DEMYX_APP_PATH"/.cache
                    demyx config "$DEMYX_APP_DOMAIN" --cache
                fi
            fi
            if [[ "$DEMYX_CONFIG_HEALTHCHECK" = on ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_HEALTHCHECK" = on ]] && demyx_die 'Healthcheck is already turned on'
                fi
                demyx_echo 'Turning on healthcheck'
                demyx_execute sed -i "s/DEMYX_APP_HEALTHCHECK=off/DEMYX_APP_HEALTHCHECK=on/g" "$DEMYX_APP_PATH"/.env
            elif [[ "$DEMYX_CONFIG_HEALTHCHECK" = off ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_HEALTHCHECK" = off ]] && demyx_die 'Healthcheck is already turned off'
                fi
                demyx_echo 'Turning off healthcheck'
                demyx_execute sed -i "s/DEMYX_APP_HEALTHCHECK=on/DEMYX_APP_HEALTHCHECK=off/g" "$DEMYX_APP_PATH"/.env
            fi
            if [[ "$DEMYX_CONFIG_OPCACHE" = on ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_PHP_OPCACHE" = on ]] && demyx_die 'PHP opcache is already turned on'
                fi

                demyx_echo 'Turning on PHP opcache'
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "sed -i 's|opcache.enable=0|opcache.enable=1|g' /etc/php7/php.ini; sed -i 's|opcache.enable_cli=0|opcache.enable_cli=1|g' /etc/php7/php.ini" && \
                    sed -i "s/DEMYX_APP_PHP_OPCACHE=off/DEMYX_APP_PHP_OPCACHE=on/g" "$DEMYX_APP_PATH"/.env

                demyx config "$DEMYX_APP_DOMAIN" --restart=php
            elif [[ "$DEMYX_CONFIG_OPCACHE" = off ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_PHP_OPCACHE" = off ]] && demyx_die 'PHP opcache is already turned off'
                fi
                
                demyx_echo 'Turning off PHP opcache'
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "sed -i 's|opcache.enable=1|opcache.enable=0|g' /etc/php7/php.ini; sed -i 's|opcache.enable_cli=1|opcache.enable_cli=0|g' /etc/php7/php.ini" && \
                    sed -i "s/DEMYX_APP_PHP_OPCACHE=on/DEMYX_APP_PHP_OPCACHE=off/g" "$DEMYX_APP_PATH"/.env

                demyx config "$DEMYX_APP_DOMAIN" --restart=php
            fi
            if [[ "$DEMYX_CONFIG_PMA" = on ]]; then
                DEMYX_CONFIG_PMA_CONTAINER_CHECK=$(docker ps | grep "$DEMYX_APP_COMPOSE_PROJECT"_pma || true)
                [[ -n "$DEMYX_CONFIG_PMA_CONTAINER_CHECK" ]] && demyx_die 'phpMyAdmin container is already running'

                if [[ "$DEMYX_APP_SSL" = on ]]; then
                    DEMYX_CONFIG_PMA_PROTO="https://$DEMYX_APP_DOMAIN"
                else
                    DEMYX_CONFIG_PMA_PROTO="http://$DEMYX_APP_DOMAIN"
                fi

                demyx_echo 'Creating phpMyAdmin container'
                demyx_execute docker run -d --rm \
                    --name "$DEMYX_APP_COMPOSE_PROJECT"_pma \
                    --network demyx \
                    -e PMA_HOST=db_"$DEMYX_APP_ID" \
                    -e MYSQL_ROOT_PASSWORD="$MARIADB_ROOT_PASSWORD" \
                    -e PMA_ABSOLUTE_URI=${DEMYX_CONFIG_PMA_PROTO}/demyx-pma/ \
                    -l "traefik.enable=true" \
                    -l "traefik.frontend.rule=Host:${DEMYX_APP_DOMAIN}; PathPrefixStrip: /demyx-pma/" \
                    -l "traefik.port=80" \
                    phpmyadmin/phpmyadmin

                PRINT_TABLE="DEMYX^ PHPMYADMIN\n"
                PRINT_TABLE+="URL^ $DEMYX_CONFIG_PMA_PROTO/demyx-pma/\n"
                PRINT_TABLE+="USERNAME^ $WORDPRESS_DB_USER\n"
                PRINT_TABLE+="PASSWORD^ $WORDPRESS_DB_PASSWORD\n"
                demyx_execute -v demyx_table "$PRINT_TABLE"
            elif [[ "$DEMYX_CONFIG_PMA" = off ]]; then
                DEMYX_CONFIG_PMA_CONTAINER_CHECK=$(docker ps | grep "$DEMYX_APP_COMPOSE_PROJECT"_pma || true)
                [[ -z "$DEMYX_CONFIG_PMA_CONTAINER_CHECK" ]] && demyx_die 'No phpMyAdmin container running'

                demyx_echo 'Stopping phpMyAdmin container'
                demyx_execute docker stop "$DEMYX_APP_COMPOSE_PROJECT"_pma
            fi
            if [[ "$DEMYX_CONFIG_RATE_LIMIT" = on ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_RATE_LIMIT" = on ]] && demyx_die 'Rate limit is already turned on'
                fi

                demyx_echo 'Turning on rate limiting'
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "sed -i 's|#limit_req|limit_req|g' /etc/nginx/nginx.conf"; \
                    sed -i "s/DEMYX_APP_RATE_LIMIT=off/DEMYX_APP_RATE_LIMIT=on/g" "$DEMYX_APP_PATH"/.env

                demyx config "$DEMYX_APP_DOMAIN" --restart=nginx
            elif [[ "$DEMYX_CONFIG_RATE_LIMIT" = off ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_RATE_LIMIT" = off ]] && demyx_die 'Rate limit is already turned off'
                fi

                demyx_echo 'Turning off rate limiting'
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "sed -i 's|limit_req|#limit_req|g' /etc/nginx/nginx.conf"; \
                    sed -i "s/DEMYX_APP_RATE_LIMIT=on/DEMYX_APP_RATE_LIMIT=off/g" "$DEMYX_APP_PATH"/.env

                demyx config "$DEMYX_APP_DOMAIN" --restart=nginx
            fi
            if [[ -n "$DEMYX_CONFIG_REFRESH" ]]; then
                if [[ -z "$DEMYX_CONFIG_NO_BACKUP" ]]; then
                    demyx backup "$DEMYX_APP_DOMAIN" --config
                fi

                demyx_echo 'Refreshing .env'
                demyx_execute demyx_env

                demyx_echo 'Refreshing .yml'
                demyx_execute demyx_yml

                demyx_execute -v demyx compose "$DEMYX_APP_DOMAIN" up -d

                [[ "$DEMYX_APP_RATE_LIMIT" = on ]] && demyx config "$DEMYX_APP_DOMAIN" --rate-limit -f
                [[ "$DEMYX_APP_CACHE" = on ]] && demyx config "$DEMYX_APP_DOMAIN" --cache -f
                [[ "$DEMYX_APP_AUTH" = on ]] && demyx config "$DEMYX_APP_DOMAIN" --auth -f
                [[ "$DEMYX_APP_AUTH_WP" = on ]] && demyx config "$DEMYX_APP_DOMAIN" --auth-wp -f
                [[ "$DEMYX_APP_CDN" = on ]] && demyx config "$DEMYX_APP_DOMAIN" --cdn -f
                [[ "$DEMYX_APP_HEALTHCHECK" = on ]] && demyx config "$DEMYX_APP_DOMAIN" --healthcheck -f
            fi
            if [ "$DEMYX_CONFIG_RESTART" = nginx-php ]; then
                demyx_echo "Restarting NGINX"
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "rm -rf /var/run/nginx-fastcgi-cache; nginx -s reload"
                
                demyx_echo "Restarting PHP"
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "pkill php-fpm; php-fpm -D"
            elif [ "$DEMYX_CONFIG_RESTART" = nginx ]; then
                demyx_echo "Restarting NGINX"
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "rm -rf /var/run/nginx-fastcgi-cache; nginx -s reload"
            elif [ "$DEMYX_CONFIG_RESTART" = php ]; then
                demyx_echo "Restarting PHP"
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "pkill php-fpm; php-fpm -D"
            fi
            if [[ "$DEMYX_CONFIG_SFTP" = on ]]; then
                DEMYX_SFTP_VOLUME_CHECK=$(docker volume ls | grep demyx_sftp || true)
                DEMYX_SFTP_CONTAINER_CHECK=$(docker ps | grep "$DEMYX_APP_COMPOSE_PROJECT"_sftp || true)

                [[ -n "$DEMYX_SFTP_CONTAINER_CHECK" ]] && demyx_die 'SFTP container is already running'
                
                if [ -z "$DEMYX_SFTP_VOLUME_CHECK" ]; then
                    demyx_echo 'SFTP volume not found, creating now' 
                    demyx_execute docker volume create demyx_sftp
                    
                    demyx_echo 'Creating temporary SSH container'
                    demyx_execute docker run -d --rm \
                        --name demyx_sftp \
                        -v demyx_sftp:/home/www-data/.ssh \
                        demyx/ssh

                    demyx_echo 'Copying authorized_keys to SSH volume' 
                    demyx_execute docker cp /home/demyx/.ssh/authorized_keys demyx_sftp:/home/www-data/.ssh/authorized_keys
                    
                    demyx_echo 'Stopping temporary SSH container'
                    demyx_execute docker stop demyx_sftp
                fi
                
                demyx_echo 'Creating SFTP container' 
                DEMYX_SFTP_PORT=$(demyx_open_port)
                demyx_execute docker run -d --rm \
                    --name "$DEMYX_APP_COMPOSE_PROJECT"_sftp \
                    -v demyx_sftp:/home/www-data/.ssh \
                    --volumes-from "$DEMYX_APP_WP_CONTAINER" \
                    --workdir /var/www/html \
                    -p "$DEMYX_SFTP_PORT":22 \
                    demyx/ssh

                PRINT_TABLE="DEMYX^ SFTP\n"
                PRINT_TABLE+="SFTP^ $DEMYX_APP_DOMAIN\n"
                PRINT_TABLE+="SFTP USER^ www-data\n"
                PRINT_TABLE+="SFTP PORT^ $DEMYX_SFTP_PORT\n"
                demyx_execute -v demyx_table "$PRINT_TABLE"
            elif [[ "$DEMYX_CONFIG_SFTP" = off ]]; then
                DEMYX_SFTP_CONTAINER_CHECK=$(docker ps | grep "$DEMYX_APP_COMPOSE_PROJECT"_sftp || true)
                [[ -z "$DEMYX_SFTP_CONTAINER_CHECK" ]] && demyx_die 'No SFTP container running'

                demyx_echo 'Stopping SFTP container' 
                demyx_execute docker stop "$DEMYX_APP_COMPOSE_PROJECT"_sftp
            fi
            if [[ "$DEMYX_CONFIG_SSL" = on ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_SSL" = on ]] && demyx_die 'SSL is already turned on'
                fi

                demyx_echo 'Updating .env'
                demyx_execute sed -i "s/DEMYX_APP_SSL=off/DEMYX_APP_SSL=on/g" "$DEMYX_APP_PATH"/.env

                demyx_echo 'Turning on SSL'
                demyx_execute demyx_app_config; demyx_yml

                demyx_echo 'Replacing URLs to HTTPS' 
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" search-replace http://"$DEMYX_APP_DOMAIN" https://"$DEMYX_APP_DOMAIN"

                demyx_execute -v demyx compose "$DEMYX_APP_DOMAIN" up -d --remove-orphans
            elif [[ "$DEMYX_CONFIG_SSL" = off ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_SSL" = off ]] && demyx_die 'SSL is already turned off'
                fi

                demyx_echo 'Updating .env'
                demyx_execute sed -i "s/DEMYX_APP_SSL=on/DEMYX_APP_SSL=off/g" "$DEMYX_APP_PATH"/.env

                demyx_echo 'Turning off SSL'
                demyx_execute demyx_app_config; demyx_yml

                demyx_echo 'Replacing URLs to HTTP' 
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" search-replace https://"$DEMYX_APP_DOMAIN" http://"$DEMYX_APP_DOMAIN"

                demyx_execute -v demyx compose "$DEMYX_APP_DOMAIN" up -d --remove-orphans
            fi
            if [[ "$DEMYX_CONFIG_WP_UPDATE" = on ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_WP_UPDATE" = on ]] && demyx_die 'WordPress auto update is already turned on'
                fi

                demyx_echo 'Turning on WordPress auto update'
                demyx_execute sed -i "s/DEMYX_APP_WP_UPDATE=off/DEMYX_APP_WP_UPDATE=on/g" "$DEMYX_APP_PATH"/.env
            elif [[ "$DEMYX_CONFIG_WP_UPDATE" = off ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_WP_UPDATE" = off ]] && demyx_die 'WordPress auto update is already turned off'
                fi

                demyx_echo 'Turning off WordPress auto update'
                demyx_execute sed -i "s/DEMYX_APP_WP_UPDATE=on/DEMYX_APP_WP_UPDATE=off/g" "$DEMYX_APP_PATH"/.env
            fi
        elif [[ -n "$DEMYX_GET_APP" ]]; then
            if [[ -n "$DEMYX_CONFIG_UPDATE" ]]; then
                DEMYX_APP_ENTRYPOINT_CHECK=$(docker exec -t "$DEMYX_APP_CONTAINER" ls /demyx | grep entrypoint || true)
                
                demyx_echo 'Updating configs'
                demyx_execute docker cp "$DEMYX_APP_PATH"/. "$DEMYX_APP_CONTAINER":/demyx

                if [[ -n "$DEMYX_APP_ENTRYPOINT_CHECK" ]]; then
                    demyx_echo 'Making custom entrypoint executable'
                    demyx_execute docker exec -t "$DEMYX_APP_CONTAINER" chmod +x /demyx/entrypoint
                fi

                demyx_execute -v demyx compose "$DEMYX_TARGET" up -d --remove-orphans
            fi
        else
            demyx_die --not-found
        fi
    fi
}
