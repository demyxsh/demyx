# Demyx
# https://demyx.sh
#
#   demyx run <app> <args>
#
demyx_run() {
    DEMYX_ARG_2="${1:-$DEMYX_ARG_2}"
    local DEMYX_RUN="DEMYX - RUN"
    local DEMYX_RUN_FLAG=
    local DEMYX_RUN_FLAG_AUTH=
    local DEMYX_RUN_FLAG_CACHE=
    local DEMYX_RUN_FLAG_CLONE=
    local DEMYX_RUN_FLAG_EMAIL=
    local DEMYX_RUN_FLAG_FORCE=
    local DEMYX_RUN_FLAG_PASSWORD=
    local DEMYX_RUN_FLAG_PHP=
    local DEMYX_RUN_FLAG_SKIP_INIT=
    local DEMYX_RUN_FLAG_SSL=
    local DEMYX_RUN_FLAG_STACK=
    local DEMYX_RUN_FLAG_TYPE=
    local DEMYX_RUN_FLAG_USERNAME=
    local DEMYX_RUN_FLAG_WHITELIST=
    local DEMYX_RUN_FLAG_WWW=
    local DEMYX_RUN_TRANSIENT="$DEMYX_TMP"/demyx_transient

    demyx_source "
        compose
        config
        env
        rm
        yml
    "

    while :; do
        DEMYX_RUN_FLAG="${2:-}"
        case "$DEMYX_RUN_FLAG" in
            --auth)
                DEMYX_RUN_FLAG_AUTH=true
            ;;
            --cache)
                DEMYX_RUN_FLAG_CACHE=true
            ;;
            --clone=?*)
                DEMYX_RUN_FLAG_CLONE="${DEMYX_RUN_FLAG#*=}"
            ;;
            --email=?*)
                DEMYX_RUN_FLAG_EMAIL="${DEMYX_RUN_FLAG#*=}"
            ;;
            -f)
                DEMYX_RUN_FLAG_FORCE=true
            ;;
            --pass=?*|--password=?*)
                DEMYX_RUN_FLAG_PASSWORD="${DEMYX_RUN_FLAG#*=}"
            ;;
            --php=8|--php=8.0|--php=8.1)
                DEMYX_RUN_FLAG_PHP="${DEMYX_RUN_FLAG#*=}"
            ;;
            --skip-init)
                DEMYX_RUN_FLAG_SKIP_INIT=true
            ;;
            --ssl|--ssl=true)
                DEMYX_RUN_FLAG_SSL=true
            ;;
            --ssl=false)
                DEMYX_RUN_FLAG_SSL=false
            ;;
            --stack=bedrock|--stack=nginx-php|--stack=ols|--stack=ols-bedrock)
                DEMYX_RUN_FLAG_STACK="${DEMYX_RUN_FLAG#*=}"
            ;;
            --type=wp|--type=php|--type=html)
                DEMYX_RUN_FLAG_TYPE="${DEMYX_RUN_FLAG#*=}"
            ;;
            --user=?*|--username=?*)
                DEMYX_RUN_FLAG_USERNAME="${DEMYX_RUN_FLAG#*=}"
            ;;
            --whitelist=all|--whitelist=login)
                DEMYX_RUN_FLAG_WHITELIST="${DEMYX_RUN_FLAG#*=}"
            ;;
            --www)
                DEMYX_RUN_FLAG_WWW=true
            ;;
            --) shift
                break
            ;;
            -?*)
                demyx_error flag "$DEMYX_RUN_FLAG"
            ;;
            *) break
        esac
        shift
    done

    if [[ -n "$DEMYX_ARG_2" ]]; then
        demyx_arg_valid
        demyx_run_soon
        demyx_run_init

        if [[ -n "$DEMYX_RUN_FLAG_CLONE" ]]; then
            demyx_run_clone
        else
            demyx_run_app
        fi

        demyx_run_extras
        demyx_run_table
    else
        demyx_help run
    fi
}
#
#   Main run function.
#
demyx_run_app() {
    demyx_execute "Creating app" \
        "demyx_run_directory; \
        demyx_env; \
        demyx_yml ${DEMYX_APP_STACK}; \
        demyx_run_volumes"

    demyx_app_env wp DEMYX_APP_DOMAIN

    demyx_config "$DEMYX_APP_DOMAIN" --healthcheck=false
    demyx_compose "$DEMYX_APP_DOMAIN" -d up -d

    if [[ -z "$DEMYX_RUN_FLAG_SKIP_INIT" ]]; then
        demyx_execute "Installing MariaDB" \
            "demyx_mariadb_ready"
    fi

    demyx_compose "$DEMYX_APP_DOMAIN" up -d
    demyx_config "$DEMYX_APP_DOMAIN" --healthcheck
}
#
#   Main run clone function.
#
demyx_run_clone() {
    local DEMYX_RUN_CLONE_APP=
    DEMYX_RUN_CLONE_APP="$(find "$DEMYX_APP" -name "$DEMYX_RUN_FLAG_CLONE")"
    local DEMYX_RUN_CLONE_WP_CONTAINER=

    if [[ -n "$DEMYX_RUN_CLONE_APP" ]]; then
        DEMYX_RUN_CLONE_WP_CONTAINER="$(grep DEMYX_APP_WP_CONTAINER "$DEMYX_RUN_CLONE_APP"/.env | awk -F '=' '{print $2}')"
    else
        demyx_error app "$DEMYX_RUN_FLAG_CLONE"
    fi

    demyx_execute "Creating app" \
        "demyx_run_directory; \
        demyx_env; \
        demyx_yml ${DEMYX_APP_STACK}; \
        demyx_run_volumes"

    demyx_app_env wp "
        DEMYX_APP_DOMAIN
        DEMYX_APP_DOMAIN_WWW
        DEMYX_APP_ID
        DEMYX_APP_DB_CONTAINER
        DEMYX_APP_NX_CONTAINER
        DEMYX_APP_WP_CONTAINER
        WORDPRESS_DB_HOST
        WORDPRESS_DB_NAME
        WORDPRESS_DB_PASSWORD
        WORDPRESS_DB_USER
        WORDPRESS_URL
        WORDPRESS_USER
        WORDPRESS_USER_EMAIL
        WORDPRESS_USER_PASSWORD
    "

    demyx_config "$DEMYX_APP_DOMAIN" --healthcheck=false
    demyx_compose "$DEMYX_APP_DOMAIN" -d up -d

    if [[ -z "$DEMYX_RUN_FLAG_SKIP_INIT" ]]; then
        demyx_execute "Installing MariaDB" \
            "demyx_mariadb_ready"
    fi

    demyx_execute "Cloning app" \
        "docker run -dt --rm \
            --entrypoint=bash \
            --name=$DEMYX_APP_WP_CONTAINER \
            --network=demyx \
            -v wp_${DEMYX_APP_ID}:/demyx \
            demyx/wordpress; \
        demyx_wp $DEMYX_RUN_FLAG_CLONE db export /demyx/${DEMYX_APP_ID}.sql; \
        mkdir -p ${DEMYX_TMP}/run-${DEMYX_APP_ID}; \
        docker cp ${DEMYX_RUN_CLONE_WP_CONTAINER}:/demyx ${DEMYX_TMP}/run-${DEMYX_APP_ID}; \
        docker cp ${DEMYX_TMP}/run-${DEMYX_APP_ID}/demyx ${DEMYX_APP_WP_CONTAINER}:/; \
        demyx_wp $DEMYX_APP_DOMAIN config create \
            --dbhost=$WORDPRESS_DB_HOST \
            --dbname=$WORDPRESS_DB_NAME \
            --dbuser=$WORDPRESS_DB_USER \
            --dbpass=$WORDPRESS_DB_PASSWORD \
            --force; \
        docker stop $DEMYX_APP_WP_CONTAINER"

    demyx_compose "$DEMYX_APP_DOMAIN" up -d

    demyx_execute "Installing WordPress" \
        "demyx_wp $DEMYX_APP_DOMAIN core install \
            --admin_email=$WORDPRESS_USER_EMAIL \
            --admin_password=$WORDPRESS_USER_PASSWORD \
            --admin_user=$WORDPRESS_USER \
            --skip-email \
            --title=$DEMYX_APP_DOMAIN \
            --url=$(demyx_app_proto)://$(demyx_app_domain); \
        docker run -t --rm \
            --volumes-from=$DEMYX_APP_WP_CONTAINER \
            demyx/utilities demyx-proxy; \
        demyx_wp $DEMYX_APP_DOMAIN db import /demyx/${DEMYX_APP_ID}.sql; \
        demyx_wp $DEMYX_APP_DOMAIN user create $WORDPRESS_USER $WORDPRESS_USER_EMAIL \
            --role=administrator \
            --user_pass=${WORDPRESS_USER_PASSWORD}; \
        demyx_wp $DEMYX_APP_DOMAIN search-replace --precise --all-tables $(demyx_app_domain "$DEMYX_RUN_FLAG_CLONE") $(demyx_app_domain "$DEMYX_APP_DOMAIN"); \
        demyx_wp $DEMYX_APP_DOMAIN rewrite structure '/%category%/%postname%/'"

    demyx_execute "Cleaning up" \
        "docker exec -t $DEMYX_RUN_CLONE_WP_CONTAINER rm -f /demyx/${DEMYX_APP_ID}.sql; \
        rm -rf ${DEMYX_TMP}/run-*"

    demyx_config "$DEMYX_APP_DOMAIN" --healthcheck
}
#
#   Create app directory based on --type.
#
demyx_run_directory() {
    case "$DEMYX_APP_TYPE" in
        html)
            mkdir -p "$DEMYX_HTML"/"$DEMYX_ARG_2"
        ;;
        php)
            mkdir -p "$DEMYX_PHP"/"$DEMYX_ARG_2"
        ;;
        *)
            mkdir -p "$DEMYX_WP"/"$DEMYX_ARG_2"
        ;;
    esac
}
#
#   Initialize commands before main run function.
#
demyx_run_init() {
    local DEMYX_APP_RUN_INIT_CHECK
    DEMYX_APP_RUN_INIT_CHECK="$(demyx_app_path "$DEMYX_ARG_2")"
    local DEMYX_RUN_APP_INIT_CONFIRM=

    # Define stack.
    case "$DEMYX_RUN_FLAG_STACK" in
        bedrock)
            DEMYX_APP_STACK=bedrock
            DEMYX_RUN_FLAG_STACK=bedrock
        ;;
        ols)
            DEMYX_APP_STACK=ols
            DEMYX_RUN_FLAG_STACK=ols
        ;;
        ols-bedrock)
            DEMYX_APP_STACK=ols-bedrock
            DEMYX_RUN_FLAG_STACK=ols-bedrock
        ;;
        *)
            DEMYX_APP_STACK=nginx-php
            DEMYX_RUN_FLAG_STACK=nginx-php
        ;;
    esac

    # Define SSL.
    DEMYX_APP_SSL="${DEMYX_RUN_FLAG_SSL:-false}"

    # Define type.
    DEMYX_APP_TYPE="${DEMYX_RUN_FLAG_TYPE:-wp}"

    # Define basic auth.
    DEMYX_APP_AUTH="${DEMYX_RUN_FLAG_AUTH:-false}"

    # Define cache.
    DEMYX_APP_CACHE="${DEMYX_RUN_FLAG_CACHE:-false}"

    # Define whitelist.
    DEMYX_APP_IP_WHITELIST="${DEMYX_RUN_FLAG_WHITELIST:-false}"

    # Define php version.
    DEMYX_APP_PHP="${DEMYX_RUN_FLAG_PHP:-8.0}"

    # Define WordPress admin credentials.
    WORDPRESS_USER="${WORDPRESS_USER:-$DEMYX_RUN_FLAG_USERNAME}"
    WORDPRESS_USER_EMAIL="${WORDPRESS_USER_EMAIL:-$DEMYX_RUN_FLAG_EMAIL}"
    WORDPRESS_USER_PASSWORD="${WORDPRESS_USER_PASSWORD:-$DEMYX_RUN_FLAG_PASSWORD}"

    if [[ "$DEMYX_RUN_FLAG_WWW" = true ]]; then
        # shellcheck disable=2034
        DEMYX_APP_DOMAIN_WWW=true
    fi

    # Can't clone itself
    if [[ "$DEMYX_ARG_2" = "$DEMYX_RUN_FLAG_CLONE" ]]; then
        demyx_error custom "You can't clone itself"
    fi

    # Prompt user to delete.
    if [[ -d "$DEMYX_APP_RUN_INIT_CHECK" ]]; then
        if [[ "$DEMYX_RUN_FLAG_FORCE" = true ]]; then
            demyx_rm "$DEMYX_ARG_2" -f
        else
            echo -en "\e[33m"
            read -rep "[WARNING] Delete $DEMYX_ARG_2? [yY]: " DEMYX_RUN_APP_INIT_CONFIRM
            echo -en "\e[39m"

            if [[ "$DEMYX_RUN_APP_INIT_CONFIRM" != [yY] ]]; then
                demyx_error cancel
            else
                demyx_rm "$DEMYX_ARG_2" -f
            fi
        fi
    fi
}
#
#   Execute extra commands.
#
demyx_run_extras() {
    local DEMYX_RUN_EXTRAS=

    if [[ "$DEMYX_RUN_FLAG_AUTH" = true ]]; then
        DEMYX_RUN_EXTRAS+="--auth "
    fi

    if [[ "$DEMYX_RUN_FLAG_CACHE" = true ]]; then
        DEMYX_RUN_EXTRAS+="--cache "
    fi

    if [[ -n "$DEMYX_RUN_FLAG_WHITELIST" ]]; then
        DEMYX_RUN_EXTRAS+="--whitelist=$DEMYX_RUN_FLAG_WHITELIST "
    fi

    eval demyx_config "$DEMYX_APP_DOMAIN" --no-compose "$DEMYX_RUN_EXTRAS"

    if [[ -n "$DEMYX_RUN_EXTRAS" ]]; then
        demyx_compose "$DEMYX_APP_DOMAIN" up -d
    fi
}
#
#   Feature coming soon.
#
demyx_run_soon() {
    if [[ "$DEMYX_RUN_FLAG_TYPE" = html || "$DEMYX_RUN_FLAG_TYPE" = php ]]; then
        demyx_error custom "Coming Soon™"
    fi
}

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
