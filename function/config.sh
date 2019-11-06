# Demyx
# https://demyx.sh
# 
# demyx config <app> <args>
#

DEMYX_SFTP_PORT_DEFAULT=22222

demyx_config() {
    while :; do
        case "$3" in
            --auth|--auth=true)
                DEMYX_CONFIG_AUTH=true
                ;;
            --auth=false)
                DEMYX_CONFIG_AUTH=false
                ;;
            --auth-wp|--auth-wp=true)
                DEMYX_CONFIG_AUTH_WP=true
                ;;
            --auth-wp=false)
                DEMYX_CONFIG_AUTH_WP=false
                ;;
            --bedrock|--bedrock=production)
                DEMYX_CONFIG_BEDROCK=production
                ;;
            --bedrock=development)
                DEMYX_CONFIG_BEDROCK=development
                ;;
            --cache|--cache=true)
                DEMYX_CONFIG_CACHE=true
                ;;
            --cache=false)
                DEMYX_CONFIG_CACHE=false
                ;;
            --cdn|--cdn=true)
                DEMYX_CONFIG_CDN=true
                ;;
            --cdn=false)
                DEMYX_CONFIG_CDN=false
                ;;
            --clean)
                DEMYX_CONFIG_CLEAN=1
                ;;
            --db-cpu=null|--db-cpu=?*)
                DEMYX_CONFIG_DB_CPU=${3#*=}
                ;;
            --db-cpu=)
                demyx_die '"--db-cpu" cannot be empty'
                ;;
            --db-mem=null|--db-mem=?*)
                DEMYX_CONFIG_DB_MEM=${3#*=}
                ;;
            --db-mem=)
                demyx_die '"--wp-db" cannot be empty'
                ;;
            --dev|--dev=true)
                DEMYX_CONFIG_DEV=true
                ;;
            --dev=false)
                DEMYX_CONFIG_DEV=false
                ;;
            --dev-base-path=?*)
                DEMYX_CONFIG_DEV_BASE_PATH=${3#*=}
                ;;
            --dev-base-path=)
                demyx_die '"--dev-base-path" cannot be empty'
                ;;
            --dev-cpu=null|--dev-cpu=?*)
                DEMYX_CONFIG_DEV_CPU=${3#*=}
                ;;
            --dev-cpu=)
                demyx_die '"--dev-cpu" cannot be empty'
                ;;
            --dev-mem=null|--dev-mem=?*)
                DEMYX_CONFIG_DEV_MEM=${3#*=}
                ;;
            --dev-mem=)
                demyx_die '"--dev-mem" cannot be empty'
                ;;
            --dev-standalone)
                DEMYX_CONFIG_DEV_STANDALONE=1
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
            --healthcheck|--healthcheck=true)
                DEMYX_CONFIG_HEALTHCHECK=true
                ;;
            --healthcheck=false)
                DEMYX_CONFIG_HEALTHCHECK=false
                ;;
            --no-backup)
                DEMYX_CONFIG_NO_BACKUP=1
                ;;
            --opcache|--opcache=true)
                DEMYX_CONFIG_OPCACHE=true
                ;;
            --opcache=false)
                DEMYX_CONFIG_OPCACHE=false
                ;;
            --pma|--pma=true)
                DEMYX_CONFIG_PMA=true
                ;;
            --pma=false)
                DEMYX_CONFIG_PMA=false
                ;;
            --rate-limit|--rate-limit=true)
                DEMYX_CONFIG_RATE_LIMIT=true
                ;;
            --rate-limit=false)
                DEMYX_CONFIG_RATE_LIMIT=false
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
            --sftp|--sftp=true)
                DEMYX_CONFIG_SFTP=true
                ;;
            --sftp=false)
                DEMYX_CONFIG_SFTP=false
                ;;
            --skip-checks)
                DEMYX_CONFIG_SKIP_CHECKS=1
                ;;
            --sleep?*)
                DEMYX_CONFIG_SLEEP=${3#*=}
                ;;
            --sleep=)
                demyx_die '"--sleep" cannot be empty'
                ;;
            --ssl|--ssl=true)
                DEMYX_CONFIG_SSL=true
                ;;
            --ssl=false)
                DEMYX_CONFIG_SSL=false
                ;;
            --wp-cpu=null|--wp-cpu=?*)
                DEMYX_CONFIG_WP_CPU=${3#*=}
                ;;
            --wp-cpu=)
                demyx_die '"--wp-cpu" cannot be empty'
                ;;
            --wp-mem=null|--wp-mem=?*)
                DEMYX_CONFIG_WP_MEM=${3#*=}
                ;;
            --wp-mem=)
                demyx_die '"--wp-mem" cannot be empty'
                ;;
            --wp-update|--wp-update=true)
                DEMYX_CONFIG_WP_UPDATE=true
                ;;
            --wp-update=false)
                DEMYX_CONFIG_WP_UPDATE=false
                ;;
            --xmlrpc|--xmlrpc=true)
                DEMYX_CONFIG_XMLRPC=true
                ;;
            --xmlrpc=false)
                DEMYX_CONFIG_XMLRPC=false
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
            if [[ -n "$DEMYX_CONFIG_WP_CPU" || -n "$DEMYX_CONFIG_WP_MEM" ]]; then
                [[ -n "$DEMYX_CONFIG_WP_CPU" ]] && DEMYX_CONFIG_WP_CPU_FLAG="--wp-cpu=$DEMYX_CONFIG_WP_CPU"
                [[ -n "$DEMYX_CONFIG_WP_MEM" ]] && DEMYX_CONFIG_WP_MEM_FLAG="--wp-mem=$DEMYX_CONFIG_WP_MEM"
                demyx config "$i" "$DEMYX_CONFIG_WP_CPU_FLAG" "$DEMYX_CONFIG_WP_MEM_FLAG"
            fi
            if [[ -n "$DEMYX_CONFIG_DB_CPU" || -n "$DEMYX_CONFIG_DB_MEM" ]]; then
                [[ -n "$DEMYX_CONFIG_DB_CPU" ]] && DEMYX_CONFIG_DB_CPU_FLAG="--db-cpu=$DEMYX_CONFIG_DB_CPU"
                [[ -n "$DEMYX_CONFIG_DB_MEM" ]] && DEMYX_CONFIG_DB_MEM_FLAG="--db-mem=$DEMYX_CONFIG_DB_MEM"
                demyx config "$i" "$DEMYX_CONFIG_DB_CPU_FLAG" "$DEMYX_CONFIG_DB_MEM_FLAG"
            fi
            if [[ -n "$DEMYX_CONFIG_REFRESH" ]]; then
                [[ -n "$DEMYX_CONFIG_NO_BACKUP" ]] && DEMYX_CONFIG_NO_BACKUP="--no-backup"
                [[ -n "$DEMYX_CONFIG_SKIP_CHECKS" ]] && DEMYX_CONFIG_SKIP_CHECKS="--skip-checks"
                demyx config "$i" --refresh "$DEMYX_CONFIG_NO_BACKUP" "$DEMYX_CONFIG_SKIP_CHECKS"
            fi
            if [[ -n "$DEMYX_CONFIG_RESTART" ]]; then
                echo -e "\e[34m[INFO]\e[39m Restarting service for $i"
                demyx config "$i" --restart="$DEMYX_CONFIG_RESTART"
            fi
            if [[ -n "$DEMYX_CONFIG_SLEEP" ]]; then
                demyx_echo "Sleep for $DEMYX_CONFIG_SLEEP"
                demyx_execute sleep "$DEMYX_CONFIG_SLEEP"
            fi
        done
    else
        demyx_app_config
        if [[ "$DEMYX_APP_TYPE" = wp ]]; then
            source "$DEMYX_FUNCTION"/env.sh
            source "$DEMYX_FUNCTION"/yml.sh
            
            cd "$DEMYX_APP_PATH" || exit

            if [[ "$DEMYX_CONFIG_AUTH" = true ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_AUTH" = true ]] && demyx_die 'Basic Auth is already turned on'
                fi

                demyx_echo 'Turning on basic auth'
                demyx_execute sed -i "s/DEMYX_APP_AUTH=.*/DEMYX_APP_AUTH=true/g" "$DEMYX_APP_PATH"/.env && demyx_yml

                demyx_execute -v demyx compose "$DEMYX_APP_DOMAIN" wp up -d --remove-orphans
            elif [[ "$DEMYX_CONFIG_AUTH" = false ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_AUTH" = false ]] && demyx_die 'Basic Auth is already turned on'
                fi

                demyx_echo 'Turning off basic auth'
                demyx_execute sed -i "s/DEMYX_APP_AUTH=.*/DEMYX_APP_AUTH=false/g" "$DEMYX_APP_PATH"/.env && demyx_yml

                demyx_execute -v demyx compose "$DEMYX_APP_DOMAIN" wp up -d --remove-orphans
            fi
            if [[ "$DEMYX_CONFIG_AUTH_WP" = true ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_AUTH_WP" != false ]] && demyx_die 'Basic WP Auth is already turned on'
                fi

                DEMYX_PARSE_BASIC_AUTH=$(grep -s DEMYX_STACK_AUTH "$DEMYX_STACK"/.env | awk -F '[=]' '{print $2}' || true)

                if [[ ! -f "$DEMYX_APP_PATH"/.htpasswd ]]; then
                    demyx_echo 'Generating htpasswd'
                    demyx_execute -v -q echo "$DEMYX_PARSE_BASIC_AUTH" > "$DEMYX_APP_PATH"/.htpasswd
                fi

                demyx_echo "Turning on wp-login.php basic auth"
                demyx_execute docker cp "$DEMYX_APP_PATH"/.htpasswd "$DEMYX_APP_WP_CONTAINER":/; \
                    docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "sed -i 's|#auth_basic|auth_basic|g' /etc/nginx/common/wpcommon.conf" && \
                    sed -i "s/DEMYX_APP_AUTH_WP=.*/DEMYX_APP_AUTH_WP=$DEMYX_PARSE_BASIC_AUTH/g" "$DEMYX_APP_PATH"/.env

                demyx config "$DEMYX_APP_DOMAIN" --restart=nginx
            elif [[ "$DEMYX_CONFIG_AUTH_WP" = false ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_AUTH_WP" = false ]] && demyx_die 'Basic WP Auth is already turned off'
                fi
                
                demyx_echo "Turning off wp-login.php basic auth"
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "sed -i 's/auth_basic/#auth_basic/g' /etc/nginx/common/wpcommon.conf; rm /.htpasswd" && \
                    sed -i "s/DEMYX_APP_AUTH_WP=.*/DEMYX_APP_AUTH_WP=false/g" "$DEMYX_APP_PATH"/.env

                if [[ -f "$DEMYX_APP_PATH"/.htpasswd ]]; then
                    demyx_echo 'Cleaning up'
                    demyx_execute rm "$DEMYX_APP_PATH"/.htpasswd
                fi

                demyx config "$DEMYX_APP_DOMAIN" --restart=nginx
            fi
            if [[ "$DEMYX_CONFIG_BEDROCK" = production ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_BEDROCK_MODE" = production ]] && demyx_die "Production mode is already set"
                fi

                demyx_echo 'Setting Bedrock config to production'
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c 'sed -i "s|WP_ENV=.*|WP_ENV=production|g" /var/www/html/.env' && \
                    sed -i "s/DEMYX_APP_BEDROCK_MODE=.*/DEMYX_APP_BEDROCK_MODE=production/g" "$DEMYX_APP_PATH"/.env
            elif [[ "$DEMYX_CONFIG_BEDROCK" = development ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_BEDROCK_MODE" = development ]] && demyx_die "Development mode is already set"
                fi

                demyx_echo 'Setting Bedrock config to development'
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c 'sed -i "s|WP_ENV=.*|WP_ENV=development|g" /var/www/html/.env' && \
                    sed -i "s/DEMYX_APP_BEDROCK_MODE=.*/DEMYX_APP_BEDROCK_MODE=development/g" "$DEMYX_APP_PATH"/.env
            fi
            if [[ "$DEMYX_CONFIG_CACHE" = true ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_CACHE" = true ]] && demyx_die 'Cache is already turned on'
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
                    sed -i "s/DEMYX_APP_CACHE=.*/DEMYX_APP_CACHE=true/g" "$DEMYX_APP_PATH"/.env

                demyx config "$DEMYX_APP_DOMAIN" --restart=nginx
            elif [[ "$DEMYX_CONFIG_CACHE" = false ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_CACHE" = false ]] && demyx_die 'Cache is already turned off'
                fi

                demyx_echo 'Deactivating nginx-helper' 
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" plugin deactivate nginx-helper
                
                demyx_echo 'Updating configs'
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "sed -i 's|include /etc/nginx/cache|#include /etc/nginx/cache|g' /etc/nginx/nginx.conf" && \
                    sed -i "s/DEMYX_APP_CACHE=.*/DEMYX_APP_CACHE=false/g" "$DEMYX_APP_PATH"/.env

                demyx config "$DEMYX_APP_DOMAIN" --restart=nginx
            fi
            if [[ "$DEMYX_CONFIG_CDN" = true ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_CDN" = true ]] && demyx_die 'CDN is already turned on'
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
                    sed -i "s/DEMYX_APP_CDN=.*/DEMYX_APP_CDN=true/g" "$DEMYX_APP_PATH"/.env
            elif [[ "$DEMYX_CONFIG_CDN" = false ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_CDN" = false ]] && demyx_die 'CDN is already turned off'
                fi
                demyx_echo 'Deactivating cdn-enabler' 
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" plugin deactivate cdn-enabler && \
                    sed -i "s/DEMYX_APP_CDN=.*/DEMYX_APP_CDN=false/g" "$DEMYX_APP_PATH"/.env
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

                DEMYX_CONFIG_CLEAN_WORDPRESS_DB_PASSWORD=$(demyx util --pass --raw)
                DEMYX_CONFIG_CLEAN_MARIADB_ROOT_PASSWORD=$(demyx util --pass --raw)

                demyx_echo 'Genearting new MariaDB credentials'
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "sed -i \"s|$WORDPRESS_DB_PASSWORD|$DEMYX_CONFIG_CLEAN_WORDPRESS_DB_PASSWORD|g\" /var/www/html/wp-config.php"; \
                    sed -i "s|$WORDPRESS_DB_PASSWORD|$DEMYX_CONFIG_CLEAN_WORDPRESS_DB_PASSWORD|g" "$DEMYX_APP_PATH"/.env; \
                    sed -i "s|$MARIADB_ROOT_PASSWORD|$DEMYX_CONFIG_CLEAN_MARIADB_ROOT_PASSWORD|g" "$DEMYX_APP_PATH"/.env
                
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

                demyx_echo 'Removing maintenance mode'
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" rm .maintenance

                demyx_execute -v demyx compose "$DEMYX_APP_DOMAIN" du

                demyx maldet "$DEMYX_APP_DOMAIN"
            fi
            if [[ "$DEMYX_CONFIG_DEV" = true || -n "$DEMYX_CONFIG_DEV_STANDALONE" ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_DEV" = true ]] && demyx_die 'Dev mode is already turned on'
                fi

                if [[ "$DEMYX_CONFIG_DEV_CPU" = null ]]; then
                    DEMYX_CONFIG_DEV_RESOURCES+=" "
                elif [[ -n "$DEMYX_CONFIG_DEV_CPU" ]]; then
                    DEMYX_CONFIG_DEV_RESOURCES+="--cpus=$DEMYX_CONFIG_DEV_CPU "
                else
                    DEMYX_CONFIG_DEV_RESOURCES+="--cpus=$DEMYX_CPU "
                fi

                if [[ "$DEMYX_CONFIG_DEV_MEM" = null ]]; then
                    DEMYX_CONFIG_DEV_RESOURCES+=" "
                elif [[ -n "$DEMYX_CONFIG_DEV_MEM" ]]; then
                    DEMYX_CONFIG_DEV_RESOURCES+="--memory=$DEMYX_CONFIG_DEV_MEM"
                else
                    DEMYX_CONFIG_DEV_RESOURCES+="--memory=$DEMYX_MEM"
                fi

                [[ -z "$DEMYX_CONFIG_DEV_BASE_PATH" ]] && DEMYX_CONFIG_DEV_BASE_PATH=/demyx
                DEMYX_CONFIG_DEV_CONTAINER_NAME="$DEMYX_APP_WP_CONTAINER"
                DEMYX_CONFIG_DEV_VOLUME="-v wp_${DEMYX_APP_ID}:/var/www/html"
 
                if [[ "$DEMYX_APP_SSL" = true ]]; then
                    DEMYX_CONFIG_DEV_PROTO="https://$DEMYX_APP_DOMAIN"
                else
                    DEMYX_CONFIG_DEV_PROTO="http://$DEMYX_APP_DOMAIN"
                fi

                if [[ -n "$DEMYX_CONFIG_DEV_STANDALONE" ]]; then
                    DEMYX_CONFIG_DEV_STANDALONE_LABELS="-l traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-http.rule=Host(\`${DEMYX_APP_DOMAIN}\`) 
                            -l traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-http.entrypoints=http 
                            -l traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-http.middlewares=${DEMYX_APP_COMPOSE_PROJECT}-redirect 
                            -l traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-http.service=${DEMYX_APP_COMPOSE_PROJECT}-http 
                            -l traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-https.rule=Host(\`${DEMYX_APP_DOMAIN}\`) 
                            -l traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-https.entrypoints=https 
                            -l traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-https.tls.certresolver=demyx 
                            -l traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-https.service=${DEMYX_APP_COMPOSE_PROJECT}-https 
                            -l traefik.http.services.${DEMYX_APP_COMPOSE_PROJECT}-http.loadbalancer.server.port=80 
                            -l traefik.http.services.${DEMYX_APP_COMPOSE_PROJECT}-https.loadbalancer.server.port=80 
                            -l traefik.http.middlewares.${DEMYX_APP_COMPOSE_PROJECT}-redirect.redirectscheme.scheme=https"
                    demyx config "$DEMYX_APP_DOMAIN" --healthcheck=false
                    demyx compose "$DEMYX_APP_DOMAIN" wp stop
                    demyx compose "$DEMYX_APP_DOMAIN" wp rm -f
                else
                    DEMYX_CONFIG_DEV_CONTAINER_NAME="$DEMYX_APP_COMPOSE_PROJECT"_cs
                    DEMYX_CONFIG_DEV_VOLUME="--volumes-from $DEMYX_APP_WP_CONTAINER"
                    DEMYX_CONFIG_DEV_SERVICES="-e DISABLE_NGINX=true -e DISABLE_PHP=true"
                fi

                if [[ "$DEMYX_APP_WP_IMAGE" = demyx/nginx-php-wordpress ]]; then
                    source "$DEMYX_STACK"/.env

                    if [ "$DEMYX_CONFIG_FILES" = themes ]; then
                        DEMYX_BS_FILES="\"/var/www/html/wp-content/themes/**/*\""
                    elif [ "$DEMYX_CONFIG_FILES" = plugins ]; then
                        DEMYX_BS_FILES="\"/var/www/html/wp-content/plugins/**/*\""
                    elif [ "$DEMYX_CONFIG_FILES" = false ]; then
                        DEMYX_BS_FILES=false
                    else
                        DEMYX_BS_FILES=
                    fi

                    [[ -z "$DEMYX_CONFIG_DEV_STANDALONE" ]] && demyx config "$DEMYX_APP_DOMAIN" --opcache=false
                    demyx_echo 'Creating code-server'
                    demyx_execute docker run -dit --rm \
                        --name "$DEMYX_CONFIG_DEV_CONTAINER_NAME" \
                        --net demyx \
                        --hostname "$DEMYX_APP_COMPOSE_PROJECT" \
                        -v demyx_cs:/home/www-data \
                        $DEMYX_CONFIG_DEV_RESOURCES \
                        $DEMYX_CONFIG_DEV_VOLUME \
                        $DEMYX_CONFIG_DEV_SERVICES \
                        -e PASSWORD="$MARIADB_ROOT_PASSWORD" \
                        -e CODER_BASE_PATH="$DEMYX_CONFIG_DEV_BASE_PATH" \
                        -e CODER_BS_DOMAIN="$DEMYX_APP_DOMAIN" \
                        -e CODER_BS_PROXY="$DEMYX_APP_WP_CONTAINER" \
                        -e CODER_BS_FILES="$DEMYX_BS_FILES" \
                        -e WORDPRESS_SSL="$DEMYX_APP_SSL" \
                        -e WORDPRESS_PHP_OPCACHE=false \
                        -e WORDPRESS_NGINX_CACHE=false \
                        -l "traefik.enable=true" \
                        $DEMYX_CONFIG_DEV_STANDALONE_LABELS \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-cs-https.rule=(Host(\`${DEMYX_APP_DOMAIN}\`) && PathPrefix(\`${DEMYX_CONFIG_DEV_BASE_PATH}/cs/\`))" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-cs-https.middlewares=${DEMYX_APP_COMPOSE_PROJECT}-cs-prefix" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-cs-https.entrypoints=https" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-cs-https.tls.certresolver=demyx" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-cs-https.service=${DEMYX_APP_COMPOSE_PROJECT}-cs" \
                        -l "traefik.http.middlewares.${DEMYX_APP_COMPOSE_PROJECT}-cs-prefix.stripprefix.prefixes=${DEMYX_CONFIG_DEV_BASE_PATH}/cs/" \
                        -l "traefik.http.services.${DEMYX_APP_COMPOSE_PROJECT}-cs.loadbalancer.server.port=8080" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-bs-https.rule=(Host(\`${DEMYX_APP_DOMAIN}\`) && PathPrefix(\`${DEMYX_CONFIG_DEV_BASE_PATH}/bs/\`))" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-bs-https.middlewares=${DEMYX_APP_COMPOSE_PROJECT}-bs-prefix" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-bs-https.entrypoints=https" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-bs-https.tls.certresolver=demyx" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-bs-https.service=${DEMYX_APP_COMPOSE_PROJECT}-bs" \
                        -l "traefik.http.middlewares.${DEMYX_APP_COMPOSE_PROJECT}-bs-prefix.stripprefix.prefixes=${DEMYX_CONFIG_DEV_BASE_PATH}/bs/" \
                        -l "traefik.http.services.${DEMYX_APP_COMPOSE_PROJECT}-bs.loadbalancer.server.port=3000" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-socket-https.rule=(Host(\`${DEMYX_APP_DOMAIN}\`) && PathPrefix(\`/browser-sync/socket.io/\`))" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-socket-https.middlewares=${DEMYX_APP_COMPOSE_PROJECT}-socket-prefix" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-socket-https.entrypoints=https" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-socket-https.tls.certresolver=demyx" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-socket-https.service=${DEMYX_APP_COMPOSE_PROJECT}-socket" \
                        -l "traefik.http.middlewares.${DEMYX_APP_COMPOSE_PROJECT}-socket-prefix.stripprefix.prefixes=${DEMYX_CONFIG_DEV_BASE_PATH}/bs/browser-sync/socket.io/" \
                        -l "traefik.http.services.${DEMYX_APP_COMPOSE_PROJECT}-socket.loadbalancer.server.port=3000" \
                        demyx/code-server:wp 2>/dev/null
                else
                    demyx config "$DEMYX_APP_DOMAIN" --bedrock=development
                    demyx compose "$DEMYX_APP_DOMAIN" wp stop
                    demyx compose "$DEMYX_APP_DOMAIN" wp rm -f
                    
                    demyx_echo 'Creating code-server'
                    demyx_execute docker run -dit --rm \
                        --name "$DEMYX_APP_WP_CONTAINER" \
                        --net demyx \
                        --hostname "$DEMYX_APP_COMPOSE_PROJECT" \
                        $DEMYX_CONFIG_DEV_RESOURCES \
                        -v wp_${DEMYX_APP_ID}:/var/www/html \
                        -v demyx_cs:/home/www-data \
                        -e PASSWORD="$MARIADB_ROOT_PASSWORD" \
                        -e CODER_BASE_PATH="$DEMYX_CONFIG_DEV_BASE_PATH"/cs \
                        -e WORDPRESS_DOMAIN="$DEMYX_APP_DOMAIN" \
                        -e WORDPRESS_PHP_OPCACHE=false \
                        -e WORDPRESS_NGINX_CACHE=false \
                        -l "traefik.enable=true" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-http.rule=Host(\`${DEMYX_APP_DOMAIN}\`)" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-http.entrypoints=http" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-http.middlewares=${DEMYX_APP_COMPOSE_PROJECT}-redirect" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-http.service=${DEMYX_APP_COMPOSE_PROJECT}-http" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-https.rule=Host(\`${DEMYX_APP_DOMAIN}\`)" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-https.entrypoints=https" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-https.tls.certresolver=demyx" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-https.service=${DEMYX_APP_COMPOSE_PROJECT}-https" \
                        -l "traefik.http.services.${DEMYX_APP_COMPOSE_PROJECT}-http.loadbalancer.server.port=80" \
                        -l "traefik.http.services.${DEMYX_APP_COMPOSE_PROJECT}-https.loadbalancer.server.port=80" \
                        -l "traefik.http.middlewares.${DEMYX_APP_COMPOSE_PROJECT}-redirect.redirectscheme.scheme=https" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-cs-https.rule=(Host(\`${DEMYX_APP_DOMAIN}\`) && PathPrefix(\`${DEMYX_CONFIG_DEV_BASE_PATH}/cs/\`))" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-cs-https.middlewares=${DEMYX_APP_COMPOSE_PROJECT}-cs-prefix" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-cs-https.entrypoints=https" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-cs-https.tls.certresolver=demyx" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-cs-https.service=${DEMYX_APP_COMPOSE_PROJECT}-cs" \
                        -l "traefik.http.middlewares.${DEMYX_APP_COMPOSE_PROJECT}-cs-prefix.stripprefix.prefixes=${DEMYX_CONFIG_DEV_BASE_PATH}/cs/" \
                        -l "traefik.http.services.${DEMYX_APP_COMPOSE_PROJECT}-cs.loadbalancer.server.port=8080" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-bs-https.rule=(Host(\`${DEMYX_APP_DOMAIN}\`) && PathPrefix(\`${DEMYX_CONFIG_DEV_BASE_PATH}/bs/\`))" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-bs-https.middlewares=${DEMYX_APP_COMPOSE_PROJECT}-bs-prefix" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-bs-https.entrypoints=https" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-bs-https.tls.certresolver=demyx" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-bs-https.service=${DEMYX_APP_COMPOSE_PROJECT}-bs" \
                        -l "traefik.http.middlewares.${DEMYX_APP_COMPOSE_PROJECT}-bs-prefix.stripprefix.prefixes=${DEMYX_CONFIG_DEV_BASE_PATH}/bs/" \
                        -l "traefik.http.services.${DEMYX_APP_COMPOSE_PROJECT}-bs.loadbalancer.server.port=3000" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-socket-https.rule=(Host(\`${DEMYX_APP_DOMAIN}\`) && PathPrefix(\`/browser-sync/socket.io/\`))" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-socket-https.middlewares=${DEMYX_APP_COMPOSE_PROJECT}-socket-prefix" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-socket-https.entrypoints=https" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-socket-https.tls.certresolver=demyx" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-socket-https.service=${DEMYX_APP_COMPOSE_PROJECT}-socket" \
                        -l "traefik.http.middlewares.${DEMYX_APP_COMPOSE_PROJECT}-socket-prefix.stripprefix.prefixes=${DEMYX_CONFIG_DEV_BASE_PATH}/bs/browser-sync/socket.io/" \
                        -l "traefik.http.services.${DEMYX_APP_COMPOSE_PROJECT}-socket.loadbalancer.server.port=3000" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-webpack-https.rule=(Host(\`${DEMYX_APP_DOMAIN}\`) && PathPrefix(\`/__webpack_hmr\`))" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-webpack-https.middlewares=${DEMYX_APP_COMPOSE_PROJECT}-webpack-prefix" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-webpack-https.entrypoints=https" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-webpack-https.tls.certresolver=demyx" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-webpack-https.service=${DEMYX_APP_COMPOSE_PROJECT}-webpack" \
                        -l "traefik.http.middlewares.${DEMYX_APP_COMPOSE_PROJECT}-webpack-prefix.stripprefix.prefixes=${DEMYX_CONFIG_DEV_BASE_PATH}/bs/__webpack_hmr" \
                        -l "traefik.http.services.${DEMYX_APP_COMPOSE_PROJECT}-webpack.loadbalancer.server.port=3000" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js-https.rule=(Host(\`${DEMYX_APP_DOMAIN}\`) && PathPrefix(\`/app/themes/{path:[a-z0-9]+}/dist/{hash:[a-z.0-9]+}.hot-update.js\`))" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js-https.middlewares=${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js-prefix" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js-https.entrypoints=https" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js-https.tls.certresolver=demyx" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js-https.service=${DEMYX_APP_COMPOSE_PROJECT}-webpack" \
                        -l "traefik.http.middlewares.${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-js-prefix.stripprefix.prefixes=${DEMYX_CONFIG_DEV_BASE_PATH}/bs/app/themes/[a-z0-9]/dist/[a-z.0-9].hot-update.js" \
                        -l "traefik.http.services.${DEMYX_APP_COMPOSE_PROJECT}-webpack.loadbalancer.server.port=3000" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json-https.rule=(Host(\`${DEMYX_APP_DOMAIN}\`) && PathPrefix(\`/app/themes/{path:[a-z0-9]+}/dist/{hash:[a-z.0-9]+}.hot-update.json\`))" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json-https.middlewares=${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json-prefix" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json-https.entrypoints=https" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json-https.tls.certresolver=demyx" \
                        -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json-https.service=${DEMYX_APP_COMPOSE_PROJECT}-webpack" \
                        -l "traefik.http.middlewares.${DEMYX_APP_COMPOSE_PROJECT}-hotupdate-json-prefix.stripprefix.prefixes=${DEMYX_CONFIG_DEV_BASE_PATH}/bs/app/themes/[a-z0-9]/dist/[a-z.0-9].hot-update.json" \
                        -l "traefik.http.services.${DEMYX_APP_COMPOSE_PROJECT}-webpack.loadbalancer.server.port=3000" \
                    demyx/code-server:sage 2>/dev/null
                fi

                demyx_execute -v sed -i "s/DEMYX_APP_DEV=.*/DEMYX_APP_DEV=true/g" "$DEMYX_APP_PATH"/.env

                PRINT_TABLE="DEMYX^ DEVELOPMENT\n"
                PRINT_TABLE+="CODE-SERVER^ ${DEMYX_CONFIG_DEV_PROTO}${DEMYX_CONFIG_DEV_BASE_PATH}/cs/\n"
                PRINT_TABLE+="BROWSERSYNC^ ${DEMYX_CONFIG_DEV_PROTO}${DEMYX_CONFIG_DEV_BASE_PATH}/bs/\n"
                PRINT_TABLE+="PASSWORD^ $MARIADB_ROOT_PASSWORD"
                demyx_execute -v demyx_table "$PRINT_TABLE"
            elif [[ "$DEMYX_CONFIG_DEV" = false ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_DEV" = false ]] && demyx_die 'Dev mode is already turned off'
                fi

                DEMYX_CONFIG_DEV_CONTAINER_CHECK="$(docker ps | grep "$DEMYX_APP_COMPOSE_PROJECT"_cs)"

                if [[ "$DEMYX_APP_WP_IMAGE" = demyx/nginx-php-wordpress:bedrock ]]; then
                    demyx config "$DEMYX_APP_DOMAIN" --bedrock=production
                fi

                if [[ -n "$DEMYX_CONFIG_DEV_CONTAINER_CHECK" ]]; then
                    demyx_echo 'Stopping code-server'
                    demyx_execute docker stop "$DEMYX_APP_COMPOSE_PROJECT"_cs
                    demyx config "$DEMYX_APP_DOMAIN" --opcache
                else
                    demyx_echo 'Stopping code-server'
                    demyx_execute docker stop "$DEMYX_APP_WP_CONTAINER"

                    demyx compose "$DEMYX_APP_DOMAIN" up -d
                    demyx config "$DEMYX_APP_DOMAIN" --healthcheck
                fi
                demyx_execute -v sed -i "s/DEMYX_APP_DEV=.*/DEMYX_APP_DEV=false/g" "$DEMYX_APP_PATH"/.env
            fi
            if [[ -n "$DEMYX_CONFIG_DB_CPU" ]]; then
                demyx_echo "Setting ${DEMYX_APP_DB_CONTAINER}'s CPU to $DEMYX_CONFIG_DB_CPU"

                if [[ "$DEMYX_CONFIG_DB_CPU" = null ]]; then
                    demyx_execute sed -i "s/DEMYX_APP_DB_CPU=.*/DEMYX_APP_DB_CPU=/g" "$DEMYX_APP_PATH"/.env
                else
                    demyx_execute sed -i "s/DEMYX_APP_DB_CPU=.*/DEMYX_APP_DB_CPU=$DEMYX_CONFIG_DB_CPU/g" "$DEMYX_APP_PATH"/.env
                fi
            fi
            if [[ -n "$DEMYX_CONFIG_DB_MEM" ]]; then
                demyx_echo "Setting ${DEMYX_APP_DB_CONTAINER}'s MEM to $DEMYX_CONFIG_DB_MEM"

                if [[ "$DEMYX_CONFIG_DB_MEM" = null ]]; then
                    demyx_execute sed -i "s/DEMYX_APP_DB_MEM=.*/DEMYX_APP_DB_MEM=/g" "$DEMYX_APP_PATH"/.env
                else
                    demyx_execute sed -i "s/DEMYX_APP_DB_MEM=.*/DEMYX_APP_DB_MEM=$DEMYX_CONFIG_DB_MEM/g" "$DEMYX_APP_PATH"/.env
                fi
            fi
            if [[ "$DEMYX_CONFIG_HEALTHCHECK" = true ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_HEALTHCHECK" = true ]] && demyx_die 'Healthcheck is already turned on'
                fi
                demyx_echo 'Turning on healthcheck'
                demyx_execute sed -i "s/DEMYX_APP_HEALTHCHECK=.*/DEMYX_APP_HEALTHCHECK=true/g" "$DEMYX_APP_PATH"/.env
            elif [[ "$DEMYX_CONFIG_HEALTHCHECK" = false ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_HEALTHCHECK" = false ]] && demyx_die 'Healthcheck is already turned off'
                fi
                demyx_echo 'Turning off healthcheck'
                demyx_execute sed -i "s/DEMYX_APP_HEALTHCHECK=.*/DEMYX_APP_HEALTHCHECK=false/g" "$DEMYX_APP_PATH"/.env
            fi
            if [[ "$DEMYX_CONFIG_OPCACHE" = true ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_PHP_OPCACHE" = true ]] && demyx_die 'PHP opcache is already turned on'
                fi

                demyx_echo 'Turning on PHP opcache'
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "sed -i 's|opcache.enable=0|opcache.enable=1|g' /etc/php7/php.ini; sed -i 's|opcache.enable_cli=0|opcache.enable_cli=1|g' /etc/php7/php.ini" && \
                    sed -i "s/DEMYX_APP_PHP_OPCACHE=.*/DEMYX_APP_PHP_OPCACHE=true/g" "$DEMYX_APP_PATH"/.env

                demyx config "$DEMYX_APP_DOMAIN" --restart=php
            elif [[ "$DEMYX_CONFIG_OPCACHE" = false ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_PHP_OPCACHE" = false ]] && demyx_die 'PHP opcache is already turned off'
                fi
                
                demyx_echo 'Turning off PHP opcache'
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "sed -i 's|opcache.enable=1|opcache.enable=0|g' /etc/php7/php.ini; sed -i 's|opcache.enable_cli=1|opcache.enable_cli=0|g' /etc/php7/php.ini" && \
                    sed -i "s/DEMYX_APP_PHP_OPCACHE=.*/DEMYX_APP_PHP_OPCACHE=false/g" "$DEMYX_APP_PATH"/.env

                demyx config "$DEMYX_APP_DOMAIN" --restart=php
            fi
            if [[ "$DEMYX_CONFIG_PMA" = true ]]; then
                DEMYX_CONFIG_PMA_CONTAINER_CHECK=$(docker ps | grep "$DEMYX_APP_COMPOSE_PROJECT"_pma || true)
                [[ -n "$DEMYX_CONFIG_PMA_CONTAINER_CHECK" ]] && demyx_die 'phpMyAdmin container is already running'

                if [[ "$DEMYX_APP_SSL" = true ]]; then
                    DEMYX_CONFIG_PMA_PROTO="https://$DEMYX_APP_DOMAIN"
                else
                    DEMYX_CONFIG_PMA_PROTO="http://$DEMYX_APP_DOMAIN"
                fi

                demyx_echo 'Creating phpMyAdmin container'
                demyx_execute docker run -d --rm \
                    --name "$DEMYX_APP_COMPOSE_PROJECT"_pma \
                    --network demyx \
                    --cpus="$DEMYX_CPU" \
                    --memory="$DEMYX_MEM" \
                    -e PMA_HOST=db_"$DEMYX_APP_ID" \
                    -e MYSQL_ROOT_PASSWORD="$MARIADB_ROOT_PASSWORD" \
                    -e PMA_ABSOLUTE_URI=${DEMYX_CONFIG_PMA_PROTO}/demyx/pma/ \
                    -l "traefik.enable=true" \
                    -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-pma-https.rule=(Host(\`${DEMYX_APP_DOMAIN}\`) && PathPrefix(\`/demyx/pma/\`))" \
                    -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-pma-https.middlewares=${DEMYX_APP_COMPOSE_PROJECT}-pma-prefix" \
                    -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-pma-https.entrypoints=https" \
                    -l "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-pma-https.tls.certresolver=demyx" \
                    -l "traefik.http.middlewares.${DEMYX_APP_COMPOSE_PROJECT}-pma-prefix.stripprefix.prefixes=/demyx/pma/" \
                    phpmyadmin/phpmyadmin 2>/dev/null

                PRINT_TABLE="DEMYX^ PHPMYADMIN\n"
                PRINT_TABLE+="URL^ $DEMYX_CONFIG_PMA_PROTO/demyx/pma/\n"
                PRINT_TABLE+="USERNAME^ $WORDPRESS_DB_USER\n"
                PRINT_TABLE+="PASSWORD^ $WORDPRESS_DB_PASSWORD\n"
                demyx_execute -v demyx_table "$PRINT_TABLE"
            elif [[ "$DEMYX_CONFIG_PMA" = false ]]; then
                DEMYX_CONFIG_PMA_CONTAINER_CHECK=$(docker ps | grep "$DEMYX_APP_COMPOSE_PROJECT"_pma || true)
                [[ -z "$DEMYX_CONFIG_PMA_CONTAINER_CHECK" ]] && demyx_die 'No phpMyAdmin container running'

                demyx_echo 'Stopping phpMyAdmin container'
                demyx_execute docker stop "$DEMYX_APP_COMPOSE_PROJECT"_pma
            fi
            if [[ "$DEMYX_CONFIG_RATE_LIMIT" = true ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_RATE_LIMIT" = true ]] && demyx_die 'Rate limit is already turned on'
                fi

                demyx_echo 'Turning on rate limiting'
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "sed -i 's|#limit_req|limit_req|g' /etc/nginx/nginx.conf; sed -i 's|#limit_conn|limit_conn|g' /etc/nginx/nginx.conf"; \
                    sed -i "s/DEMYX_APP_RATE_LIMIT=.*/DEMYX_APP_RATE_LIMIT=true/g" "$DEMYX_APP_PATH"/.env

                demyx config "$DEMYX_APP_DOMAIN" --restart=nginx
            elif [[ "$DEMYX_CONFIG_RATE_LIMIT" = false ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_RATE_LIMIT" = false ]] && demyx_die 'Rate limit is already turned off'
                fi

                demyx_echo 'Turning off rate limiting'
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "sed -i 's|limit_req|#limit_req|g' /etc/nginx/nginx.conf; sed -i 's|limit_conn|#limit_conn|g' /etc/nginx/nginx.conf"; \
                    sed -i "s/DEMYX_APP_RATE_LIMIT=.*/DEMYX_APP_RATE_LIMIT=false/g" "$DEMYX_APP_PATH"/.env

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

                if [[ -z "$DEMYX_CONFIG_SKIP_CHECKS" ]]; then
                    [[ "$DEMYX_APP_RATE_LIMIT" = true ]] && demyx config "$DEMYX_APP_DOMAIN" --rate-limit -f
                    [[ "$DEMYX_APP_CACHE" = true ]] && demyx config "$DEMYX_APP_DOMAIN" --cache -f
                    [[ "$DEMYX_APP_AUTH" = true ]] && demyx config "$DEMYX_APP_DOMAIN" --auth -f
                    [[ "$DEMYX_APP_AUTH_WP" = true ]] && demyx config "$DEMYX_APP_DOMAIN" --auth-wp -f
                    [[ "$DEMYX_APP_CDN" = true ]] && demyx config "$DEMYX_APP_DOMAIN" --cdn -f
                    [[ "$DEMYX_APP_HEALTHCHECK" = true ]] && demyx config "$DEMYX_APP_DOMAIN" --healthcheck -f
                fi
            fi
            if [ "$DEMYX_CONFIG_RESTART" = nginx-php ]; then
                demyx_echo "Restarting NGINX"
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "rm -rf /var/run/nginx-fastcgi-cache; nginx -s reload"
                
                demyx_echo "Restarting php-fpm"
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "pkill php-fpm"
            elif [ "$DEMYX_CONFIG_RESTART" = nginx ]; then
                demyx_echo "Restarting NGINX"
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "rm -rf /var/run/nginx-fastcgi-cache; nginx -s reload"
            elif [ "$DEMYX_CONFIG_RESTART" = php ]; then
                demyx_echo "Restarting php-fpm"
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "pkill php-fpm"
            fi
            if [[ "$DEMYX_CONFIG_SFTP" = true ]]; then
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
                    --cpus="$DEMYX_CPU" \
                    --memory="$DEMYX_MEM" \
                    --workdir /var/www/html \
                    --volumes-from "$DEMYX_APP_WP_CONTAINER" \
                    -v demyx_sftp:/home/www-data/.ssh \
                    -p "$DEMYX_SFTP_PORT":22 \
                    demyx/ssh 2>/dev/null

                PRINT_TABLE="DEMYX^ SFTP\n"
                PRINT_TABLE+="SFTP^ $DEMYX_APP_DOMAIN\n"
                PRINT_TABLE+="SFTP USER^ www-data\n"
                PRINT_TABLE+="SFTP PORT^ $DEMYX_SFTP_PORT\n"
                demyx_execute -v demyx_table "$PRINT_TABLE"
            elif [[ "$DEMYX_CONFIG_SFTP" = false ]]; then
                DEMYX_SFTP_CONTAINER_CHECK=$(docker ps | grep "$DEMYX_APP_COMPOSE_PROJECT"_sftp || true)
                [[ -z "$DEMYX_SFTP_CONTAINER_CHECK" ]] && demyx_die 'No SFTP container running'

                demyx_echo 'Stopping SFTP container' 
                demyx_execute docker stop "$DEMYX_APP_COMPOSE_PROJECT"_sftp
            fi
            if [[ "$DEMYX_CONFIG_SSL" = true ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_SSL" = true ]] && demyx_die 'SSL is already turned on'
                fi

                demyx_echo 'Updating .env'
                demyx_execute sed -i "s/DEMYX_APP_SSL=.*/DEMYX_APP_SSL=true/g" "$DEMYX_APP_PATH"/.env

                demyx_echo 'Turning on SSL'
                demyx_execute demyx_app_config; demyx_yml

                demyx_echo 'Replacing URLs to HTTPS' 
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" search-replace http://"$DEMYX_APP_DOMAIN" https://"$DEMYX_APP_DOMAIN"

                demyx_execute -v demyx compose "$DEMYX_APP_DOMAIN" up -d --remove-orphans
            elif [[ "$DEMYX_CONFIG_SSL" = false ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_SSL" = false ]] && demyx_die 'SSL is already turned off'
                fi

                demyx_echo 'Updating .env'
                demyx_execute sed -i "s/DEMYX_APP_SSL=.*/DEMYX_APP_SSL=false/g" "$DEMYX_APP_PATH"/.env

                demyx_echo 'Turning off SSL'
                demyx_execute demyx_app_config; demyx_yml

                demyx_echo 'Replacing URLs to HTTP' 
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" search-replace https://"$DEMYX_APP_DOMAIN" http://"$DEMYX_APP_DOMAIN"

                demyx_execute -v demyx compose "$DEMYX_APP_DOMAIN" up -d --remove-orphans
            fi
            if [[ -n "$DEMYX_CONFIG_WP_CPU" ]]; then
                demyx_echo "Setting ${DEMYX_APP_WP_CONTAINER}'s CPU to $DEMYX_CONFIG_WP_CPU"

                if [[ "$DEMYX_CONFIG_WP_CPU" = null ]]; then
                    demyx_execute sed -i "s/DEMYX_APP_WP_CPU=.*/DEMYX_APP_WP_CPU=/g" "$DEMYX_APP_PATH"/.env
                else
                    demyx_execute sed -i "s/DEMYX_APP_WP_CPU=.*/DEMYX_APP_WP_CPU=$DEMYX_CONFIG_WP_CPU/g" "$DEMYX_APP_PATH"/.env
                fi
            fi
            if [[ -n "$DEMYX_CONFIG_WP_MEM" ]]; then
                demyx_echo "Setting ${DEMYX_APP_WP_CONTAINER}'s MEM to $DEMYX_CONFIG_WP_MEM"

                if [[ "$DEMYX_CONFIG_WP_MEM" = null ]]; then
                    demyx_execute sed -i "s/DEMYX_APP_WP_MEM=.*/DEMYX_APP_WP_MEM=/g" "$DEMYX_APP_PATH"/.env
                else
                    demyx_execute sed -i "s/DEMYX_APP_WP_MEM=.*/DEMYX_APP_WP_MEM=$DEMYX_CONFIG_WP_MEM/g" "$DEMYX_APP_PATH"/.env
                fi
            fi
            if [[ "$DEMYX_CONFIG_WP_UPDATE" = true ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_WP_UPDATE" = true ]] && demyx_die 'WordPress auto update is already turned on'
                fi

                demyx_echo 'Turning on WordPress auto update'
                demyx_execute sed -i "s/DEMYX_APP_WP_UPDATE=.*/DEMYX_APP_WP_UPDATE=true/g" "$DEMYX_APP_PATH"/.env
            elif [[ "$DEMYX_CONFIG_WP_UPDATE" = false ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_WP_UPDATE" = false ]] && demyx_die 'WordPress auto update is already turned off'
                fi

                demyx_echo 'Turning off WordPress auto update'
                demyx_execute sed -i "s/DEMYX_APP_WP_UPDATE=.*/DEMYX_APP_WP_UPDATE=false/g" "$DEMYX_APP_PATH"/.env
            fi
            if [[ "$DEMYX_CONFIG_XMLRPC" = true ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_XMLRPC" = true ]] && demyx_die 'WordPress xmlrpc is already turned on'
                fi

                demyx_echo 'Turning on WordPress xmlrpc'
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "mv /etc/nginx/common/xmlrpc.conf /etc/nginx/common/xmlrpc.on; nginx -s reload"; \
                    sed -i "s/DEMYX_APP_XMLRPC=.*/DEMYX_APP_XMLRPC=true/g" "$DEMYX_APP_PATH"/.env

                #demyx config "$DEMYX_APP_DOMAIN" --restart=nginx
            elif [[ "$DEMYX_CONFIG_XMLRPC" = false ]]; then
                if [[ -z "$DEMYX_CONFIG_FORCE" ]]; then
                    [[ "$DEMYX_APP_XMLRPC" = false ]] && demyx_die 'WordPress xmlrpc is already turned off'
                fi

                demyx_echo 'Turning off WordPress xmlrpc'
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "mv /etc/nginx/common/xmlrpc.on /etc/nginx/common/xmlrpc.conf; nginx -s reload"; \
                    sed -i "s/DEMYX_APP_XMLRPC=.*/DEMYX_APP_XMLRPC=false/g" "$DEMYX_APP_PATH"/.env
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
