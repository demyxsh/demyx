# Demyx
# https://demyx.sh
# 
# demyx config <app> <args>
#

DEMYX_SFTP_PORT_DEFAULT=2223

function demyx_config() {
    while :; do
        case "$3" in
            --auth|--auth=on)
                DEMYX_CONFIG_AUTH=on
                ;;
            --auth=off)
                DEMYX_CONFIG_AUTH=off
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
            --update)
                DEMYX_CONFIG_UPDATE=1
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
                demyx config "$i" --refresh
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
            source "$DEMYX_FUNCTION"/plugin.sh
            
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

                demyx_echo 'Configuring NGINX' 
                demyx_execute demyx exec "$DEMYX_APP_DOMAIN" sed -i "s|#include /etc/nginx/cache|include /etc/nginx/cache|g" /demyx/nginx.conf

                demyx_echo 'Reloading NGINX'
                demyx_execute demyx exec "$DEMYX_APP_DOMAIN" nginx -s reload && \
                    sed -i "s/DEMYX_APP_CACHE=off/DEMYX_APP_CACHE=on/g" "$DEMYX_APP_PATH"/.env
            elif [[ "$DEMYX_CONFIG_CACHE" = off ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_CACHE" = off ]] && demyx_die 'Cache is already turned off'
                fi

                demyx_echo 'Deactivating nginx-helper' 
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" plugin deactivate nginx-helper
                
                demyx_echo 'Configuring NGINX' 
                demyx_execute demyx exec "$DEMYX_APP_DOMAIN" sed -i "s|include /etc/nginx/cache|#include /etc/nginx/cache|g" /demyx/nginx.conf

                demyx_echo 'Reloading NGINX'
                demyx_execute demyx exec "$DEMYX_APP_DOMAIN" nginx -s reload && \
                    sed -i "s/DEMYX_APP_CACHE=on/DEMYX_APP_CACHE=off/g" "$DEMYX_APP_PATH"/.env
            fi
            if [[ "$DEMYX_CONFIG_CDN" = on ]]; then
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
                demyx_echo 'Deactivating cdn-enabler' 
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" plugin deactivate cdn-enabler && \
                    sed -i "s/DEMYX_APP_CDN=on/DEMYX_APP_CDN=off/g" "$DEMYX_APP_PATH"/.env
            fi
            if [[ "$DEMYX_CONFIG_DEV" = on ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    DEMYX_APP_DEV_CHECK=$(demyx info "$DEMYX_APP_DOMAIN" --filter=DEMYX_APP_DEV)
                    [[ "$DEMYX_APP_DEV_CHECK" = on ]] && demyx_die 'Dev mode is already turned on'
                fi
 
                DEMYX_CONFIG_WILDCARD_CHECK=$(docker run -t --rm demyx/utilities "dig +short '*.$DEMYX_APP_DOMAIN'")
                [[ -z "$DEMYX_CONFIG_WILDCARD_CHECK" ]] && demyx_die "Wildcard CNAME not detected, please add * as a CNAME to your domain's DNS"

                source "$DEMYX_STACK"/.env

                DEMYX_SFTP_PORT=$(demyx_open_port)
                DEMYX_SFTP_VOLUME_CHECK=$(docker volume ls | grep demyx_sftp || true)
                DEMYX_SFTP_CONTAINER_CHECK=$(docker ps | grep "$DEMYX_APP_ID"_sftp || true)
                DEMYX_PARSE_BASIC_AUTH=$(grep -s DEMYX_STACK_AUTH "$DEMYX_STACK"/.env | awk -F '[=]' '{print $2}' || true)
                DEMYX_BROWSERSYNC_SUB="$DEMYX_APP_ID"
                DEMYX_BROWSERSYNC_SUB_UI="$DEMYX_APP_ID"-ui
                DEMYX_PHPMYADMIN_SUB="$DEMYX_APP_ID"-pma

                if [[ -n "$DEMYX_SFTP_CONTAINER_CHECK" ]]; then
                    demyx_echo 'Stopping SFTP container' 
                    demyx_execute docker stop "$DEMYX_APP_ID"_sftp
                fi

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
                demyx_execute docker run -d --rm \
                    --name "$DEMYX_APP_ID"_sftp \
                    -v demyx_sftp:/home/www-data/.ssh \
                    --volumes-from "$DEMYX_APP_WP_CONTAINER" \
                    --workdir /var/www/html \
                    -p "$DEMYX_SFTP_PORT":22 \
                    demyx/ssh

                if [ "$DEMYX_CONFIG_FILES" = themes ]; then
                    DEMYX_BS_FILES="/var/www/html/wp-content/themes/**/*"
                elif [ "$DEMYX_CONFIG_FILES" = plugins ]; then
                    DEMYX_BS_FILES="/var/www/html/wp-content/plugins/**/*"
                elif [ -z "$DEMYX_CONFIG_FILES" ]; then
                    DEMYX_BS_FILES="/var/www/html/wp-content/**/*"
                else
                    DEMYX_BS_FILES="$DEMYX_CONFIG_FILES/**/*"
                fi

                demyx_echo 'Creating BrowserSync config'
                demyx_execute -v echo "module.exports={rewriteRules:[{match:/${DEMYX_APP_DOMAIN}/g,fn:function(e,r,t){return'${DEMYX_BROWSERSYNC_SUB}.${DEMYX_APP_DOMAIN}'}}],socket:{domain:'${DEMYX_BROWSERSYNC_SUB}.${DEMYX_APP_DOMAIN}'}};" > "$DEMYX_APP_CONFIG"/bs.js; \
                    docker cp "$DEMYX_APP_CONFIG"/bs.js "$DEMYX_APP_WP_CONTAINER":/var/www/html; \
                    rm "$DEMYX_APP_CONFIG"/bs.js

                demyx_echo 'Creating BrowserSync container' 
                demyx_execute docker run -d --rm \
                    --name "$DEMYX_APP_ID"_bs \
                    --net demyx \
                    --volumes-from "$DEMYX_APP_WP_CONTAINER" \
                    -l "traefik.enable=true" \
                    -l "traefik.bs.frontend.rule=Host:${DEMYX_BROWSERSYNC_SUB}.${DEMYX_APP_DOMAIN}" \
                    -l "traefik.bs.port=3000" \
                    -l "traefik.bs.frontend.redirect.entryPoint=https" \
                    -l "traefik.bs.frontend.headers.forceSTSHeader=${DEMYX_APP_FORCE_STS_HEADER}" \
                    -l "traefik.bs.frontend.headers.STSSeconds=${DEMYX_APP_STS_SECONDS}" \
                    -l "traefik.bs.frontend.headers.STSIncludeSubdomains=${DEMYX_APP_STS_INCLUDE_SUBDOMAINS}" \
                    -l "traefik.bs.frontend.headers.STSPreload=${DEMYX_APP_STS_PRELOAD}" \
                    -l "traefik.bs.frontend.auth.basic.users=${DEMYX_PARSE_BASIC_AUTH}" \
                    -l "traefik.ui.frontend.rule=Host:${DEMYX_BROWSERSYNC_SUB_UI}.${DEMYX_APP_DOMAIN}" \
                    -l "traefik.ui.port=3001" \
                    -l "traefik.ui.frontend.redirect.entryPoint=https" \
                    -l "traefik.ui.frontend.headers.forceSTSHeader=${DEMYX_APP_FORCE_STS_HEADER}" \
                    -l "traefik.ui.frontend.headers.STSSeconds=${DEMYX_APP_STS_SECONDS}" \
                    -l "traefik.ui.frontend.headers.STSIncludeSubdomains=${DEMYX_APP_STS_INCLUDE_SUBDOMAINS}" \
                    -l "traefik.ui.frontend.headers.STSPreload=${DEMYX_APP_STS_PRELOAD}" \
                    -l "traefik.ui.frontend.auth.basic.users=${DEMYX_PARSE_BASIC_AUTH}" \
                    demyx/browsersync start \
                    --config "/var/www/html/bs.js" \
                    --proxy "$DEMYX_APP_WP_CONTAINER" \
                    --files "$DEMYX_BS_FILES" \
                    --port 3000 \
                    --ui-port 3001

                demyx_echo 'Creating phpMyAdmin container' 
                demyx_execute docker run -d --rm \
                    --name "$DEMYX_APP_ID"_pma \
                    --network demyx \
                    -e PMA_HOST=db_"$DEMYX_APP_ID" \
                    -e PMA_USER="$WORDPRESS_DB_USER" \
                    -e PMA_PASSWORD="$WORDPRESS_DB_PASSWORD" \
                    -e MYSQL_ROOT_PASSWORD="${MARIADB_ROOT_PASSWORD}" \
                    -l "traefik.enable=true" \
                    -l "traefik.frontend.rule=Host:${DEMYX_PHPMYADMIN_SUB}.${DEMYX_APP_DOMAIN}" \
                    -l "traefik.port=80" \
                    -l "traefik.frontend.redirect.entryPoint=https" \
                    -l "traefik.frontend.headers.forceSTSHeader=${DEMYX_APP_FORCE_STS_HEADER}" \
                    -l "traefik.frontend.headers.STSSeconds=${DEMYX_APP_STS_SECONDS}" \
                    -l "traefik.frontend.headers.STSIncludeSubdomains=${DEMYX_APP_STS_INCLUDE_SUBDOMAINS}" \
                    -l "traefik.frontend.headers.STSPreload=${DEMYX_APP_STS_PRELOAD}" \
                    -l "traefik.frontend.auth.basic.users=${DEMYX_PARSE_BASIC_AUTH}" \
                    phpmyadmin/phpmyadmin

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
                    docker cp "$DEMYX_APP_CONFIG"/demyx_browsersync.php "$DEMYX_APP_WP_CONTAINER":/var/www/html/wp-content/plugins; \
                    rm "$DEMYX_APP_CONFIG"/demyx_browsersync.php
                
                    demyx_echo 'Activating demyx_browsersync plugin'
                    demyx_execute demyx wp "$DEMYX_APP_DOMAIN" plugin activate demyx_browsersync
                fi

                if [[ "$DEMYX_CONFIG_CACHE_CHECK" = on ]]; then
                    touch "$DEMYX_APP_CONFIG"/.cache
                    demyx config "$DEMYX_APP_DOMAIN" --cache=off
                fi

                PRINT_TABLE="DEMYX, DEVELOPMENT MODE\n"
                PRINT_TABLE+="SFTP, $DEMYX_APP_DOMAIN\n"
                PRINT_TABLE+="SFTP USER, www-data\n"
                PRINT_TABLE+="SFTP PORT, $DEMYX_SFTP_PORT\n"
                PRINT_TABLE+="PHPMYADMIN, https://${DEMYX_PHPMYADMIN_SUB}.${DEMYX_APP_DOMAIN}\n"
                PRINT_TABLE+="BROWSERSYNC, https://${DEMYX_BROWSERSYNC_SUB}.${DEMYX_APP_DOMAIN}\n"
                PRINT_TABLE+="BROWSERSYNC UI, https://${DEMYX_BROWSERSYNC_SUB_UI}.${DEMYX_APP_DOMAIN}\n"
                PRINT_TABLE+="BROWSERSYNC FILES, $DEMYX_BS_FILES"
                demyx_execute -v sed -i "s/DEMYX_APP_DEV=off/DEMYX_APP_DEV=on/g" "$DEMYX_APP_PATH"/.env && \
                demyx_table "$PRINT_TABLE"
            elif [[ "$DEMYX_CONFIG_DEV" = off ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    DEMYX_APP_DEV_CHECK=$(demyx info "$DEMYX_APP_DOMAIN" --filter=DEMYX_APP_DEV)
                    [[ "$DEMYX_APP_DEV_CHECK" = off ]] && demyx_die 'Dev mode is already turned off'
                fi

                demyx_echo 'Stopping SFTP container' 
                demyx_execute docker stop "$DEMYX_APP_ID"_sftp
                
                demyx_echo 'Stopping phpMyAdmin container'
                demyx_execute docker stop "$DEMYX_APP_ID"_pma

                demyx_echo 'Stopping BrowserSync container'
                demyx_execute docker stop "$DEMYX_APP_ID"_bs

                demyx_echo 'Deactivating autover' 
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" plugin deactivate autover

                demyx_echo 'Deactivating demyx_browsersync' 
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" plugin deactivate demyx_browsersync; \
                    sed -i "s/DEMYX_APP_DEV=on/DEMYX_APP_DEV=off/g" "$DEMYX_APP_PATH"/.env

                if [[ -f "$DEMYX_APP_CONFIG"/.cache ]]; then
                    rm "$DEMYX_APP_CONFIG"/.cache
                    demyx config "$DEMYX_APP_DOMAIN" --cache
                fi
            fi
            if [[ "$DEMYX_CONFIG_RATE_LIMIT" = on ]]; then
                demyx_echo 'Turning on rate limiting'
                demyx_execute demyx exec "$DEMYX_APP_DOMAIN" bash -c "printf ',s/#limit_req/limit_req/g\nw\n' | ed /etc/nginx/nginx.conf; nginx -s reload" && \
                    sed -i "s/DEMYX_APP_RATE_LIMIT=off/DEMYX_APP_RATE_LIMIT=on/g" "$DEMYX_APP_PATH"/.env
            elif [[ "$DEMYX_CONFIG_RATE_LIMIT" = off ]]; then
                demyx_echo 'Turning off rate limiting'
                demyx_execute demyx exec "$DEMYX_APP_DOMAIN" bash -c "printf ',s/limit_req/#limit_req/g\nw\n' | ed /etc/nginx/nginx.conf; nginx -s reload" && \
                    sed -i "s/DEMYX_APP_RATE_LIMIT=on/DEMYX_APP_RATE_LIMIT=off/g" "$DEMYX_APP_PATH"/.env
            fi
            if [[ -n "$DEMYX_CONFIG_REFRESH" ]]; then
                source "$DEMYX_FUNCTION"/nginx.sh
                source "$DEMYX_FUNCTION"/php.sh
                source "$DEMYX_FUNCTION"/php-fpm.sh

                demyx_echo 'Refreshing .env'
                demyx_execute demyx_env

                demyx_echo 'Refreshing .yml'
                demyx_execute demyx_yml

                demyx_echo 'Refreshing nginx.conf'
                demyx_execute demyx_nginx

                demyx_echo 'Refreshing php.ini'
                demyx_execute demyx_php

                demyx_echo 'Refreshing php-fpm.conf'
                demyx_execute demyx_php_fpm

                demyx_echo 'Refreshing configs'
                demyx_execute demyx config "$DEMYX_APP_DOMAIN" --update

                demyx_execute -v demyx compose "$DEMYX_APP_DOMAIN" up -d
            fi
            if [ "$DEMYX_CONFIG_RESTART" = nginx-php ]; then
                demyx_echo "Restarting NGINX"
                demyx_execute demyx exec "$DEMYX_APP_DOMAIN" nginx -s reload

                demyx_echo "Restarting PHP"
                demyx_execute demyx exec "$DEMYX_APP_DOMAIN" bash -c "pkill php-fpm; php-fpm -D"
            elif [ "$DEMYX_CONFIG_RESTART" = nginx ]; then
                demyx_echo "Restarting NGINX"
                demyx_execute demyx exec "$DEMYX_APP_DOMAIN" nginx -s reload
            elif [ "$DEMYX_CONFIG_RESTART" = php ]; then
                demyx_echo "Restarting PHP"
                demyx_execute demyx exec "$DEMYX_APP_DOMAIN" bash -c "pkill php-fpm; php-fpm -D"
            fi
            if [[ "$DEMYX_CONFIG_SFTP" = on ]]; then

                DEMYX_SFTP_PORT=$(demyx_open_port)
                DEMYX_SFTP_VOLUME_CHECK=$(docker volume ls | grep demyx_sftp || true)
                DEMYX_SFTP_CONTAINER_CHECK=$(docker ps | grep "$DEMYX_APP_ID"_sftp || true)

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
                demyx_execute docker run -d --rm \
                    --name "$DEMYX_APP_ID"_sftp \
                    -v demyx_sftp:/home/www-data/.ssh \
                    --volumes-from "$DEMYX_APP_WP_CONTAINER" \
                    --workdir /var/www/html \
                    -p "$DEMYX_SFTP_PORT":22 \
                    demyx/ssh

                PRINT_TABLE="DEMYX, SFTP\n"
                PRINT_TABLE+="SFTP, $DEMYX_APP_DOMAIN\n"
                PRINT_TABLE+="SFTP USER, www-data\n"
                PRINT_TABLE+="SFTP PORT, $DEMYX_SFTP_PORT\n"
                demyx_table "$PRINT_TABLE"
            elif [[ "$DEMYX_CONFIG_SFTP" = off ]]; then
                DEMYX_SFTP_CONTAINER_CHECK=$(docker ps | grep "$DEMYX_APP_ID"_sftp || true)
                [[ -z "$DEMYX_SFTP_CONTAINER_CHECK" ]] && demyx_die 'No SFTP container running'

                demyx_echo 'Stopping SFTP container' 
                demyx_execute docker stop "$DEMYX_APP_ID"_sftp
            fi
            if [[ "$DEMYX_CONFIG_SSL" = on ]]; then
                demyx_echo 'Updating .env'
                demyx_execute sed -i "s/DEMYX_APP_SSL=off/DEMYX_APP_SSL=on/g" "$DEMYX_APP_PATH"/.env

                demyx_echo 'Turning on SSL'
                demyx_execute demyx_yml

                demyx_echo 'Replacing URLs to HTTPS' 
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" search-replace http://"$DEMYX_APP_DOMAIN" https://"$DEMYX_APP_DOMAIN"

                demyx_execute -v demyx compose "$DEMYX_APP_DOMAIN" wp up -d --remove-orphans
            elif [[ "$DEMYX_CONFIG_SSL" = off ]]; then
                demyx_echo 'Updating .env'
                demyx_execute sed -i "s/DEMYX_APP_SSL=on/DEMYX_APP_SSL=off/g" "$DEMYX_APP_PATH"/.env

                demyx_echo 'Turning off SSL'
                demyx_execute demyx_yml

                demyx_echo 'Replacing URLs to HTTP' 
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" search-replace https://"$DEMYX_APP_DOMAIN" http://"$DEMYX_APP_DOMAIN"

                demyx_execute -v demyx compose "$DEMYX_APP_DOMAIN" wp up -d --remove-orphans
            fi
            if [[ -n "$DEMYX_CONFIG_UPDATE" ]]; then
                demyx_echo 'Updating configs'
                demyx_execute docker cp "$DEMYX_APP_CONFIG"/. "$DEMYX_APP_WP_CONTAINER":/demyx

                demyx_echo 'Reloading NGINX and PHP'
                demyx_execute demyx config "$DEMYX_APP_DOMAIN" --restart=nginx-php
            fi
        elif [[ -n "$DEMYX_GET_APP" ]]; then
            if [[ -n "$DEMYX_CONFIG_UPDATE" ]]; then
                DEMYX_APP_ENTRYPOINT_CHECK=$(docker exec -t "$DEMYX_APP_CONTAINER" ls /demyx | grep entrypoint || true)
                
                demyx_echo 'Updating configs'
                demyx_execute docker cp "$DEMYX_APP_CONFIG"/. "$DEMYX_APP_CONTAINER":/demyx

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
