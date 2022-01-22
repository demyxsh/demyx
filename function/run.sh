# Demyx
# https://demyx.sh
#
# demyx run <app> <args>
#
demyx_run() {
    # Make sure domain isn't a flag
    if [[ "$2" == *"--"*"="* ]]; then
        demyx_die "$2 isn't a valid domain"
    fi

    while :; do
        case "$3" in
            --archive=?*)
                DEMYX_RUN_ARCHIVE="${3#*=}"
                ;;
            --archive=)
                demyx_die '"--archive" cannot be empty'
                ;;
            --auth)
                DEMYX_RUN_AUTH=true
                ;;
            --cache)
                DEMYX_RUN_CACHE=true
                ;;
            --cf)
                DEMYX_RUN_CLOUDFLARE=true
                ;;
            --clone=?*)
                DEMYX_RUN_CLONE="${3#*=}"
                ;;
            --clone=)
                demyx_die '"--clone" cannot be empty'
                ;;
            --email=?*)
                DEMYX_RUN_EMAIL="${3#*=}"
                ;;
            --email=)
                demyx_die '"--email" cannot be empty'
                ;;
            -f|--force)
                DEMYX_RUN_FORCE=true
                ;;
            --pass=?*)
                DEMYX_RUN_PASSWORD="${3#*=}"
                ;;
            --pass=)
                demyx_die '"--password" cannot be empty'
                ;;
            --rate-limit|--rate-limit=true)
                DEMYX_RUN_RATE_LIMIT=true
                ;;
            --rate-limit=false)
                DEMYX_RUN_RATE_LIMIT=false
                ;;
            --skip-init)
                DEMYX_RUN_SKIP_INIT=true
                ;;
            --ssl|--ssl=true)
                DEMYX_RUN_SSL=true
                ;;
            --ssl=false)
                DEMYX_RUN_SSL=false
                ;;
            --stack=bedrock|--stack=nginx-php|--stack=ols|--stack=ols-bedrock)
                DEMYX_RUN_STACK="${3#*=}"
                ;;
            --stack=)
                demyx_die '"--stack" cannot be empty'
                ;;
            --type=wp|--type=php|--type=html)
                DEMYX_RUN_TYPE="${3#*=}"
                ;;
            --type=)
                demyx_die '"--type" cannot be empty'
                ;;
            --user=?*)
                DEMYX_RUN_USER="${3#*=}"
                ;;
            --user=)
                demyx_die '"--user" cannot be empty'
                ;;
            --whitelist=all|--whitelist=login)
                DEMYX_RUN_WHITELIST="${3#*=}"
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

    DEMYX_RUN_CHECK="$(find "$DEMYX_APP" -name "$DEMYX_TARGET" || true)"
    DEMYX_RUN_TODAYS_DATE="$(date +%Y-%m-%d)"

    if [[ ! -f "$DEMYX_BACKUP_WP"/"$DEMYX_TARGET"/"$DEMYX_RUN_TODAYS_DATE"-"$DEMYX_RUN_ARCHIVE".tgz && -n "$DEMYX_RUN_ARCHIVE" ]]; then
        demyx_die "${DEMYX_BACKUP_WP}/${DEMYX_TARGET}/${DEMYX_RUN_TODAYS_DATE}-${DEMYX_RUN_ARCHIVE}.tgz doesn't exist"
    fi

    if [[ -n "$DEMYX_RUN_CLONE" ]]; then
        DEMYX_RUN_CLONE_CHECK="$(find "$DEMYX_APP" -name "$DEMYX_RUN_CLONE" || true)"
        [[ -z "$DEMYX_RUN_CLONE_CHECK" ]] && demyx_die "App doesn't exist"
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
        if [[ -n "$DEMYX_RUN_CLOUDFLARE" && -z "$DEMYX_EMAIL" && -z "$DEMYX_CF_KEY" ]]; then
            demyx_die 'Missing Cloudflare key and/or email, please run demyx help stack'
        fi
    fi

    DEMYX_RUN_TYPE="${DEMYX_RUN_TYPE:-wp}"
    DEMYX_RUN_RATE_LIMIT="${DEMYX_RUN_RATE_LIMIT:-false}"
    DEMYX_RUN_CACHE="${DEMYX_RUN_CACHE:-false}"
    DEMYX_RUN_AUTH="${DEMYX_RUN_AUTH:-false}"
    DEMYX_RUN_CLOUDFLARE="${DEMYX_RUN_CLOUDFLARE:-false}"
    DEMYX_RUN_WHITELIST="${DEMYX_RUN_WHITELIST:-false}"

    [[ -n "$DEMYX_RUN_CLONE" ]] && DEMYX_RUN_CLONE_APP="$(demyx info "$DEMYX_RUN_CLONE" --filter=DEMYX_APP_WP_CONTAINER)"

    if [[ "$DEMYX_RUN_STACK" = bedrock ]]; then
        DEMYX_APP_WP_IMAGE=demyx/wordpress:bedrock
    elif [[ "$DEMYX_RUN_STACK" = ols ]]; then
        DEMYX_APP_WP_IMAGE=demyx/openlitespeed
    elif [[ "$DEMYX_RUN_STACK" = ols-bedrock ]]; then
        DEMYX_APP_WP_IMAGE=demyx/openlitespeed:bedrock
    else
        DEMYX_APP_WP_IMAGE=demyx/wordpress
        DEMYX_RUN_STACK=nginx-php
    fi

    if [[ "$DEMYX_RUN_SSL" = true ]]; then
        DEMYX_RUN_SSL=true
        DEMYX_RUN_PROTO="https://$DEMYX_TARGET"
    elif [[ "$DEMYX_RUN_SSL" = false ]]; then
        DEMYX_RUN_SSL=false
        DEMYX_RUN_PROTO="$DEMYX_TARGET"
    else
        [[ -z "$DEMYX_RUN_SSL" ]] && DEMYX_RUN_SSL=true
        DEMYX_RUN_PROTO="https://$DEMYX_TARGET"
    fi

    demyx_source env
    demyx_source yml

    if [[ "$DEMYX_RUN_TYPE" = wp ]]; then
        demyx_echo 'Creating directory'
        demyx_execute mkdir -p "$DEMYX_WP"/"$DEMYX_TARGET"

        demyx_echo 'Creating .env'
        demyx_execute demyx_env

        if [[ -n "$DEMYX_RUN_CLONE" ]]; then
            DEMYX_RUN_CLONE_STACK="$(grep DEMYX_APP_STACK "$DEMYX_RUN_CLONE_CHECK"/.env | awk -F '[=]' '{print $2}')"
            demyx_execute -v sed -i "s|DEMYX_APP_STACK=.*|DEMYX_APP_STACK=${DEMYX_RUN_CLONE_STACK}|g" "$DEMYX_RUN_CHECK"/.env
        fi

        demyx_app_config

        demyx config "$DEMYX_APP_DOMAIN" --healthcheck=false

        demyx_echo 'Creating .yml'
        demyx_execute demyx_yml

        # Recheck SSL
        DEMYX_RUN_SSL_RECHECK="$(grep DEMYX_APP_SSL "$DEMYX_APP_PATH"/.env | awk -F '[=]' '{print $2}')"
        [[ "$DEMYX_RUN_SSL_RECHECK" = false ]] && DEMYX_RUN_PROTO="http://$DEMYX_TARGET"

        if [[ -n "$DEMYX_RUN_CLONE" ]]; then
            demyx_echo 'Cloning database'
            demyx_execute demyx wp "$DEMYX_RUN_CLONE" db export /demyx/clone.sql

            demyx_echo 'Cloning files'
            demyx_execute docker cp "$DEMYX_RUN_CLONE_APP":/demyx "$DEMYX_APP_PATH"

            demyx_echo 'Removing exported clone database'
            demyx_execute docker exec -t "$DEMYX_RUN_CLONE_APP" rm /demyx/clone.sql
        fi

        demyx_echo 'Creating WordPress volume'
        demyx_execute docker volume create wp_"$DEMYX_APP_ID"

        demyx_echo 'Creating MariaDB volume'
        demyx_execute docker volume create wp_"$DEMYX_APP_ID"_db

        demyx_echo 'Creating log volume'
        demyx_execute docker volume create wp_"$DEMYX_APP_ID"_log

        demyx compose "$DEMYX_APP_DOMAIN" up -d db_"$DEMYX_APP_ID"

        if [[ -z "$DEMYX_RUN_SKIP_INIT" ]]; then
            demyx_echo 'Initializing MariaDB'
            demyx_execute demyx_mariadb_ready
        fi

        if [[ -n "$DEMYX_RUN_CLONE" ]]; then
            demyx_echo 'Creating temporary container'
            demyx_execute docker run -dt --rm \
                --name "$DEMYX_APP_ID" \
                --network demyx \
                -v wp_"$DEMYX_APP_ID":/demyx \
                demyx/utilities sh

            if [[ "$DEMYX_RUN_CLONE_STACK" = nginx-php || "$DEMYX_RUN_CLONE_STACK" = ols ]]; then
                demyx_echo 'Removing old wp-config.php'
                demyx_execute rm -f "$DEMYX_APP_PATH"/demyx/wp-config.php
            fi

            demyx_echo 'Copying files'
            demyx_execute docker cp "$DEMYX_APP_PATH"/demyx "$DEMYX_APP_ID":/

            demyx_echo 'Stopping temporary container'
            demyx_execute docker stop "$DEMYX_APP_ID"
        fi

        if [[ -n "$DEMYX_RUN_ARCHIVE" ]]; then
            demyx_echo 'Extracting archive'
            demyx_execute tar -xzf "$DEMYX_BACKUP_WP"/"$DEMYX_TARGET"/"$DEMYX_RUN_TODAYS_DATE"-"$DEMYX_RUN_ARCHIVE".tgz -C "$DEMYX_BACKUP_WP"/"$DEMYX_APP_DOMAIN"

            demyx_echo 'Creating temporary container'
            demyx_execute docker run -dt --rm \
                --name "$DEMYX_APP_ID" \
                --network demyx \
                -v wp_"$DEMYX_APP_ID":/demyx \
                -v wp_"$DEMYX_APP_ID"_log:/var/log/demyx \
                demyx/utilities sh

            demyx_echo 'Copying files'
            demyx_execute docker cp "$DEMYX_BACKUP_WP"/"$DEMYX_APP_DOMAIN"/"$DEMYX_RUN_ARCHIVE"/demyx-wp/. "$DEMYX_APP_ID":/demyx; \
                docker cp "$DEMYX_BACKUP_WP"/"$DEMYX_APP_DOMAIN"/"$DEMYX_RUN_ARCHIVE"/demyx-log/. "$DEMYX_APP_ID":/var/log/demyx

            demyx_echo 'Finalizing extraction'
            demyx_execute docker exec -t --user=root "$DEMYX_APP_ID" sh -c "rm /demyx/wp-config.php; chown -R demyx:demyx /demyx"

            demyx_echo 'Stopping temporary container'
            demyx_execute docker stop "$DEMYX_APP_ID"
        fi

        demyx compose "$DEMYX_APP_DOMAIN" up -d

        if [[ -n "$DEMYX_RUN_CLONE" ]]; then
            if [[ "$DEMYX_RUN_CLONE_STACK" = nginx-php || "$DEMYX_RUN_CLONE_STACK" = ols ]]; then
                demyx_echo 'Generating new wp-config.php'
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" config create \
                    --dbhost="$WORDPRESS_DB_HOST" \
                    --dbname="$WORDPRESS_DB_NAME" \
                    --dbuser="$WORDPRESS_DB_USER" \
                    --dbpass="$WORDPRESS_DB_PASSWORD" \
                    --force

                demyx_echo 'Installing WordPress'
                demyx_execute demyx wp "$DEMYX_APP_DOMAIN" core install \
                    --url="$DEMYX_RUN_PROTO" \
                    --title="$DEMYX_APP_DOMAIN" \
                    --admin_user="$WORDPRESS_USER" \
                    --admin_password="$WORDPRESS_USER_PASSWORD" \
                    --admin_email="$WORDPRESS_USER_EMAIL" \
                    --skip-email

                demyx_echo 'Configuring reverse proxy'
                demyx_execute docker run -t --rm \
                    --volumes-from="$DEMYX_APP_WP_CONTAINER" \
                    demyx/utilities demyx-proxy
            else
                demyx_echo 'Installing Bedrock'
                demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" sh -c "rm -f /demyx/.env; demyx-install"
            fi

            demyx_echo 'Importing clone database'
            demyx_execute demyx wp "$DEMYX_APP_DOMAIN" db import /demyx/clone.sql

            demyx_echo 'Creating admin account'
            demyx_execute demyx wp "$DEMYX_APP_DOMAIN" user create "$WORDPRESS_USER" info@"$DEMYX_APP_DOMAIN" \
                --role=administrator \
                --user_pass="$WORDPRESS_USER_PASSWORD"

            demyx_echo 'Replacing old URLs'
            demyx_execute demyx wp "$DEMYX_APP_DOMAIN" search-replace "$DEMYX_RUN_CLONE" "$DEMYX_APP_DOMAIN"

            demyx_echo 'Configuring permalinks'
            demyx_execute demyx wp "$DEMYX_APP_DOMAIN" rewrite structure '/%category%/%postname%/'

            demyx_echo 'Removing clone database'
            demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" rm -f /demyx/clone.sql

            demyx_echo 'Cleaning up'
            demyx_execute rm -rf "$DEMYX_APP_PATH"/demyx
        elif [[ -n "$DEMYX_RUN_ARCHIVE" ]]; then
            demyx_echo 'Creating new wp-config.php'
            demyx_execute demyx wp "$DEMYX_APP_DOMAIN" config create \
                --dbhost="$WORDPRESS_DB_HOST" \
                --dbname="$WORDPRESS_DB_NAME" \
                --dbuser="$WORDPRESS_DB_USER" \
                --dbpass="$WORDPRESS_DB_PASSWORD"

            demyx_echo 'Configuring wp-config.php for reverse proxy'
            demyx_execute docker run -t --rm \
                --volumes-from="$DEMYX_APP_WP_CONTAINER" \
                demyx/utilities demyx-proxy

            demyx_echo 'Installing WordPress'
            demyx_execute demyx wp "$DEMYX_APP_DOMAIN" core install \
                --url="$DEMYX_RUN_PROTO" \
                --title="$DEMYX_APP_DOMAIN" \
                --admin_user="$WORDPRESS_USER" \
                --admin_password="$WORDPRESS_USER_PASSWORD" \
                --admin_email="$WORDPRESS_USER_EMAIL" \
                --skip-email

            demyx_echo 'Importing archive database'
            demyx_execute demyx wp "$DEMYX_APP_DOMAIN" db import "${DEMYX_RUN_ARCHIVE//./_}".sql

            demyx_echo 'Creating admin account'
            demyx_execute demyx wp "$DEMYX_APP_DOMAIN" user create "$WORDPRESS_USER" info@"$DEMYX_APP_DOMAIN" \
                --role=administrator \
                --user_pass="$WORDPRESS_USER_PASSWORD"

            demyx_echo 'Replacing old URLs'
            demyx_execute demyx wp "$DEMYX_APP_DOMAIN" search-replace "$DEMYX_RUN_ARCHIVE" "$DEMYX_APP_DOMAIN"

            demyx_echo 'Configuring permalinks'
            demyx_execute demyx wp "$DEMYX_APP_DOMAIN" rewrite structure '/%category%/%postname%/'

            demyx_echo 'Configuring salts'
            demyx_execute demyx wp "$DEMYX_APP_DOMAIN" config shuffle-salts

            demyx_echo 'Removing archive database'
            demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" rm "${DEMYX_RUN_ARCHIVE//./_}".sql

            demyx_echo 'Cleaning up'
            demyx_execute rm -rf "$DEMYX_BACKUP_WP"/"$DEMYX_APP_DOMAIN"/"$DEMYX_RUN_ARCHIVE"
        else
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
        fi

        if [[ -n "$DEMYX_RUN_CLONE" ]]; then
            DEMYX_RUN_CLONE_ENV_AUTH_CHECK="$(demyx info "$DEMYX_RUN_CLONE" --filter=DEMYX_APP_AUTH)"
            DEMYX_RUN_CLONE_ENV_CACHE_CHECK="$(demyx info "$DEMYX_RUN_CLONE" --filter=DEMYX_APP_CACHE)"
            DEMYX_RUN_CLONE_ENV_WHITELIST_CHECK="$(demyx info "$DEMYX_RUN_CLONE" --filter=DEMYX_APP_IP_WHITELIST)"

            [[ "$DEMYX_RUN_CLONE_ENV_CACHE_CHECK" = true ]] && demyx config "$DEMYX_APP_DOMAIN" --cache && DEMYX_RUN_CACHE=true
            [[ "$DEMYX_RUN_CLONE_ENV_AUTH_CHECK" = true ]] && demyx config "$DEMYX_APP_DOMAIN" --auth && DEMYX_RUN_AUTH=true
            [[ "$DEMYX_RUN_CLONE_ENV_WHITELIST_CHECK" != false ]] && demyx config "$DEMYX_APP_DOMAIN" --whitelist="$DEMYX_RUN_WHITELIST" && DEMYX_RUN_WHITELIST="$DEMYX_RUN_CLONE_ENV_WHITELIST_CHECK"
        else
            [[ "$DEMYX_RUN_CACHE" = true ]] && demyx config "$DEMYX_APP_DOMAIN" --cache
            [[ "$DEMYX_RUN_AUTH" = true ]] && demyx config "$DEMYX_APP_DOMAIN" --auth
            [[ "$DEMYX_RUN_WHITELIST" = true ]] && demyx config "$DEMYX_APP_DOMAIN" --whitelist="$DEMYX_RUN_WHITELIST"
        fi

        demyx refresh "$DEMYX_APP_DOMAIN" --skip-backup
        demyx config "$DEMYX_APP_DOMAIN" --healthcheck

        if [[ "$DEMYX_RUN_TYPE" = html ]]; then
            DEMYX_RUN_TABLE_TITLE=HTML
        elif [[ "$DEMYX_RUN_TYPE" = php ]]; then
            DEMYX_RUN_TABLE_TITLE=PHP
        else
            DEMYX_RUN_TABLE_TITLE=WORDPRESS
        fi

        PRINT_TABLE="DEMYX^ ${DEMYX_RUN_TABLE_TITLE}\n"

        if [[ "$DEMYX_RUN_STACK" = ols || "$DEMYX_RUN_STACK" = ols-bedrock ]]; then
            PRINT_TABLE+="OPENLITESPEED URL^ ${DEMYX_RUN_PROTO}/demyx/ols/\n"
            PRINT_TABLE+="OPENLITESPEED USERNAME^ $DEMYX_APP_OLS_ADMIN_USERNAME\n"
            PRINT_TABLE+="OPENLITESPEED PASSWORD^ $DEMYX_APP_OLS_ADMIN_PASSWORD\n"
            PRINT_TABLE+="^\n"
        fi

        PRINT_TABLE+="WORDPRESS URL^ ${DEMYX_RUN_PROTO}/\n"
        PRINT_TABLE+="WORDPRESS USERNAME^ $WORDPRESS_USER\n"
        PRINT_TABLE+="WORDPRESS PASSWORD^ $WORDPRESS_USER_PASSWORD\n"
        PRINT_TABLE+="WORDPRESS EMAIL^ $WORDPRESS_USER_EMAIL\n"
        PRINT_TABLE+="^\n"

        if [[ "$DEMYX_RUN_STACK" = nginx-php || "$DEMYX_RUN_STACK" = bedrock ]]; then
            PRINT_TABLE+="NX CONTAINER^ $DEMYX_APP_NX_CONTAINER\n"
        fi

        PRINT_TABLE+="WP CONTAINER^ $DEMYX_APP_WP_CONTAINER\n"
        PRINT_TABLE+="DB CONTAINER^ $DEMYX_APP_DB_CONTAINER\n"
        demyx_execute -v demyx_table "$PRINT_TABLE"
    fi
}
