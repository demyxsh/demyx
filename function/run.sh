# Demyx
# https://demyx.sh
# 
# demyx run <app> <args>
#
function demyx_run() {
    while :; do
        case "$3" in
            --auth)
                DEMYX_RUN_AUTH=on
                ;;
            --cache)
                DEMYX_RUN_CACHE=on
                ;;
            --cdn)
                DEMYX_RUN_CDN=on
                ;;
            --clone=?*)
                DEMYX_RUN_CLONE=${3#*=}
                ;;
            --clone=)
                demyx_die '"--clone" cannot be empty'
                ;;
            --email=?*)
                DEMYX_RUN_EMAIL=${3#*=}
                ;;
            --email=)
                demyx_die '"--email" cannot be empty'
                ;;
            -f|--force)
                DEMYX_RUN_FORCE=1
                ;;
            --pass=?*)
                DEMYX_RUN_PASSWORD=${3#*=}
                ;;
            --pass=)
                demyx_die '"--password" cannot be empty'
                ;;
            --rate-limit|--rate-limit=on)
                DEMYX_RUN_RATE_LIMIT=on
                ;;
            --rate-limit=off)
                DEMYX_RUN_RATE_LIMIT=off
                ;;
            --ssl|--ssl=on)
                DEMYX_RUN_SSL=on
                ;;
            --ssl=off)
                DEMYX_RUN_SSL=off
                ;;
            --type=wp|--type=php|--type=html)
                DEMYX_RUN_TYPE=${3#*=}
                ;;
            --type=)
                demyx_die '"--type" cannot be empty'
                ;;
            --user=?*)
                DEMYX_RUN_USER=${3#*=}
                ;;
            --user=)
                demyx_die '"--user" cannot be empty'
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

    DEMYX_RUN_CHECK=$(find "$DEMYX_APP" -name "$DEMYX_TARGET" || true)

    if [[ -n "$DEMYX_RUN_CLONE" ]]; then
        DEMYX_CLONE_CHECK=$(find "$DEMYX_APP" -name "$DEMYX_RUN_CLONE" || true)
        [[ -z "$DEMYX_CLONE_CHECK" ]] && demyx_die "App doesn't exist"
    fi

    if [[ -n "$DEMYX_RUN_CHECK" ]]; then
        if [[ -n "$DEMYX_RUN_FORCE" ]]; then
            DEMYX_RM_CONFIRM=y
        else
            echo -en "\e[33m"
            read -rep "[WARNING] Delete $DEMYX_TARGET? [yY]: " DEMYX_RM_CONFIRM
            echo -en "\e[39m"
        fi
        if [[ "$DEMYX_RM_CONFIRM" != [yY] ]]; then
            demyx_die 'Cancel deletion'
        else
            demyx rm "$DEMYX_TARGET" -f
        fi
    fi

    [[ -z "$DEMYX_RUN_TYPE" ]] && DEMYX_RUN_TYPE=wp
    [[ -z "$DEMYX_RUN_RATE_LIMIT" ]] && DEMYX_RUN_RATE_LIMIT=off
    [[ -z "$DEMYX_RUN_CDN" ]] && DEMYX_RUN_CDN=off
    [[ -z "$DEMYX_RUN_CACHE" ]] && DEMYX_RUN_CACHE=off
    [[ -z "$DEMYX_RUN_AUTH" ]] && DEMYX_RUN_AUTH=off
    [[ -n "$DEMYX_RUN_CLONE" ]] && DEMYX_RUN_CLONE_APP=$(demyx info "$DEMYX_RUN_CLONE" --filter=DEMYX_APP_WP_CONTAINER)

    if [[ "$DEMYX_RUN_SSL" = on ]]; then 
        DEMYX_RUN_SSL=on
        DEMYX_RUN_PROTO="https://$DEMYX_TARGET"
    elif [[ "$DEMYX_RUN_SSL" = off ]]; then 
        DEMYX_RUN_SSL=off
        DEMYX_RUN_PROTO="$DEMYX_TARGET"
    else
        [[ -z "$DEMYX_RUN_SSL" ]] && DEMYX_RUN_SSL=on
        DEMYX_RUN_PROTO="https://$DEMYX_TARGET"
    fi

    source "$DEMYX_FUNCTION"/env.sh
    source "$DEMYX_FUNCTION"/yml.sh

    if [[ "$DEMYX_RUN_TYPE" = wp ]]; then
        source "$DEMYX_FUNCTION"/nginx.sh
        source "$DEMYX_FUNCTION"/php.sh
        source "$DEMYX_FUNCTION"/php-fpm.sh

        demyx_echo 'Creating directory'
        demyx_execute mkdir -p "$DEMYX_WP"/"$DEMYX_TARGET"/config

        demyx_echo 'Creating .env'
        demyx_execute demyx_env

        demyx_app_config

        demyx config "$DEMYX_APP_DOMAIN" --healthcheck=off

        demyx_echo 'Creating .yml'
        demyx_execute demyx_yml

        if [[ -z "$DEMYX_RUN_CLONE" ]]; then
            demyx_echo 'Creating nginx.conf'
            demyx_execute demyx_nginx

            demyx_echo 'Creating php.ini'
            demyx_execute demyx_php

            demyx_echo 'Creating php-fpm.conf'
            demyx_execute demyx_php_fpm
        else
            demyx_echo 'Cloning config'
            demyx_execute docker cp "$DEMYX_RUN_CLONE_APP":/demyx/. "$DEMYX_APP_PATH"/config

            demyx_echo 'Cloning database'
            demyx_execute demyx wp "$DEMYX_RUN_CLONE" db export clone.sql --exclude_tables=wp_users,wp_usermeta
            
            demyx_echo 'Cloning files'
            demyx_execute docker cp "$DEMYX_RUN_CLONE_APP":/var/www/html "$DEMYX_APP_PATH"

            demyx_echo 'Removing exported clone database'
            demyx_execute demyx exec "$DEMYX_RUN_CLONE_APP" rm clone.sql
        fi

        demyx_echo 'Creating WordPress volume'
        demyx_execute docker volume create wp_"$DEMYX_APP_ID"

        demyx_echo 'Creating MariaDB volume'
        demyx_execute docker volume create wp_"$DEMYX_APP_ID"_db
        
        demyx_echo 'Creating config volume'
        demyx_execute docker volume create wp_"$DEMYX_APP_ID"_config

        demyx_echo 'Creating log volume'
        demyx_execute docker volume create wp_"$DEMYX_APP_ID"_log
        
        demyx_execute -v demyx compose "$DEMYX_APP_DOMAIN" up -d db_"$DEMYX_APP_ID"

        demyx_echo 'Initializing MariaDB'
        demyx_execute demyx_mariadb_ready

        if [[ -z "$DEMYX_RUN_CLONE" ]]; then
            demyx_echo 'Creating temporary container'
            demyx_execute docker run -dt --rm \
                --name "$DEMYX_APP_ID" \
                -v wp_"$DEMYX_APP_ID"_config:/demyx \
                -v wp_"$DEMYX_APP_ID"_log:/var/log/demyx \
                demyx/utilities bash
        else
            demyx_echo 'Creating temporary container'
            demyx_execute docker run -dt --rm \
                --name "$DEMYX_APP_ID" \
                --network demyx \
                -v wp_"$DEMYX_APP_ID":/var/www/html \
                -v wp_"$DEMYX_APP_ID"_config:/demyx \
                -v wp_"$DEMYX_APP_ID"_log:/var/log/demyx \
                demyx/utilities bash
        fi

        if [[ -z "$DEMYX_RUN_CLONE" ]]; then
            demyx_echo 'Copying configs'
            demyx_execute docker cp "$DEMYX_APP_CONFIG"/. "$DEMYX_APP_ID":/demyx
        else
            demyx_echo 'Copying files' 
            demyx_execute docker cp "$DEMYX_APP_PATH"/html "$DEMYX_APP_ID":/var/www; \
                docker cp "$DEMYX_APP_CONFIG"/. "$DEMYX_APP_ID":/demyx

            demyx_echo 'Removing old wp-config.php'
            demyx_execute docker exec -t "$DEMYX_APP_ID" rm /var/www/html/wp-config.php
        fi

        demyx_echo 'Stopping temporary container' 
        demyx_execute docker stop "$DEMYX_APP_ID"

        demyx_execute -v demyx compose "$DEMYX_APP_DOMAIN" up -d wp_"$DEMYX_APP_ID"

        if [[ -z "$DEMYX_RUN_CLONE" ]]; then
            demyx_echo 'Configuring wp-config.php'
            demyx_execute demyx wp "$DEMYX_APP_DOMAIN" core install \
                --url="$DEMYX_RUN_PROTO" \
                --title="$DEMYX_APP_DOMAIN" \
                --admin_user="$WORDPRESS_USER" \
                --admin_password="$WORDPRESS_USER_PASSWORD" \
                --admin_email="$WORDPRESS_USER_EMAIL" \
                --skip-email

            demyx_echo 'Configuring permalinks'
            demyx_execute demyx wp "$DEMYX_APP_DOMAIN" rewrite structure '/%category%/%postname%/'
        else
            demyx_echo 'Creating new wp-config.php' 
            demyx_execute demyx wp "$DEMYX_APP_DOMAIN" config create \
                --dbhost="$WORDPRESS_DB_HOST" \
                --dbname="$WORDPRESS_DB_NAME" \
                --dbuser="$WORDPRESS_DB_USER" \
                --dbpass="$WORDPRESS_DB_PASSWORD"

            demyx_echo 'Configuring wp-config.php for reverse proxy'
            demyx_execute docker run -t \
                --volumes-from "$DEMYX_APP_WP_CONTAINER" \
                demyx/utilities demyx-proxy
        
            demyx_echo 'Installing WordPress' 
            demyx_execute demyx wp "$DEMYX_APP_DOMAIN" core install \
                --url="$DEMYX_RUN_PROTO" \
                --title="$DEMYX_APP_DOMAIN" \
                --admin_user="$WORDPRESS_USER" \
                --admin_password="$WORDPRESS_USER_PASSWORD" \
                --admin_email="$WORDPRESS_USER_EMAIL" \
                --skip-email

            demyx_echo 'Importing clone database' 
            demyx_execute demyx wp "$DEMYX_APP_DOMAIN" db import clone.sql

            demyx_echo 'Replacing old URLs' 
            demyx_execute demyx wp "$DEMYX_APP_DOMAIN" search-replace "$DEMYX_RUN_CLONE" "$DEMYX_APP_DOMAIN"

            demyx_echo 'Removing clone database'
            demyx_execute demyx exec "$DEMYX_APP_DOMAIN" rm clone.sql

            demyx_echo 'Cleaning up'
            demyx_execute rm -rf "$DEMYX_APP_PATH"/html
        fi

        if [[ -z "$DEMYX_RUN_CLONE" ]]; then
            [[ "$DEMYX_RUN_CACHE" = on ]] && demyx config "$DEMYX_APP_DOMAIN" --cache
            [[ "$DEMYX_RUN_CDN" = on ]] && demyx config "$DEMYX_APP_DOMAIN" --cdn
            [[ "$DEMYX_RUN_AUTH" = on ]] && demyx config "$DEMYX_APP_DOMAIN" --auth
        else
            DEMYX_RUN_CLONE_ENV_AUTH_CHECK="$(demyx info "$DEMYX_RUN_CLONE" --filter=DEMYX_APP_AUTH)"
            DEMYX_RUN_CLONE_ENV_CDN_CHECK="$(demyx info "$DEMYX_RUN_CLONE" --filter=DEMYX_APP_CDN)"
            DEMYX_RUN_CLONE_ENV_CACHE_CHECK="$(demyx info "$DEMYX_RUN_CLONE" --filter=DEMYX_APP_CACHE)"
            
            [[ "$DEMYX_RUN_CLONE_ENV_CACHE_CHECK" = on ]] && demyx config "$DEMYX_APP_DOMAIN" --cache && DEMYX_RUN_CACHE=on
            [[ "$DEMYX_RUN_CLONE_ENV_CDN_CHECK" = on ]] && demyx config "$DEMYX_APP_DOMAIN" --cdn && DEMYX_RUN_CDN=on
            [[ "$DEMYX_RUN_CLONE_ENV_AUTH_CHECK" = on ]] && demyx config "$DEMYX_APP_DOMAIN" --auth && DEMYX_RUN_AUTH=on
        fi

        demyx config "$DEMYX_APP_DOMAIN" --healthcheck

        PRINT_TABLE="DEMYX^ $DEMYX_RUN_PROTO/wp-admin\n"
        PRINT_TABLE+="WORDPRESS USER^ $WORDPRESS_USER\n"
        PRINT_TABLE+="WORDPRESS PASSWORD^ $WORDPRESS_USER_PASSWORD\n"
        PRINT_TABLE+="WORDPRESS EMAIL^ $WORDPRESS_USER_EMAIL\n"
        PRINT_TABLE+="WP CONTAINER^ $DEMYX_APP_WP_CONTAINER\n"
        PRINT_TABLE+="DP CONTAINER^ $DEMYX_APP_DB_CONTAINER\n"
        PRINT_TABLE+="SSL^ $DEMYX_RUN_SSL\n"
        PRINT_TABLE+="RATE LIMIT^ $DEMYX_RUN_RATE_LIMIT\n"
        PRINT_TABLE+="BASIC AUTH^ $DEMYX_RUN_AUTH\n"
        PRINT_TABLE+="CACHE^ $DEMYX_RUN_CACHE\n"
        PRINT_TABLE+="CDN^ $DEMYX_RUN_CDN\n"
        demyx_execute -v demyx_table "$PRINT_TABLE"
    fi
}
