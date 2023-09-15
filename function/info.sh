# Demyx
# https://demyx.sh
#
#   demyx info <app> <args>
#
demyx_info() {
    DEMYX_ARG_2="${1:-$DEMYX_ARG_2}"
    local DEMYX_INFO="DEMYX - INFO"
    local DEMYX_INFO_FLAG=
    local DEMYX_INFO_FLAG_ENV=
    local DEMYX_INFO_FLAG_ENV_GREP=
    local DEMYX_INFO_FLAG_JSON=
    local DEMYX_INFO_FLAG_RAW=
    local DEMYX_INFO_FLAG_LOGIN=
    local DEMYX_INFO_FLAG_NO_VOLUME=
    local DEMYX_INFO_TRANSIENT="$DEMYX_TMP"/demyx_transient

    while :; do
        DEMYX_INFO_FLAG="${2:-}"
        case "$DEMYX_INFO_FLAG" in
            --env=?*)
                DEMYX_INFO_FLAG_ENV=true
                DEMYX_INFO_FLAG_ENV_GREP="${DEMYX_INFO_FLAG#*=}"
            ;;
            -j)
                DEMYX_INFO_FLAG_JSON=true
            ;;
            -r)
                DEMYX_INFO_FLAG_RAW=true
            ;;
            -l)
                DEMYX_INFO_FLAG_LOGIN=true
            ;;
            -nv)
                DEMYX_INFO_FLAG_NO_VOLUME=true
            ;;
            --)
                shift
                break
                ;;
            -?*)
                demyx_error flag "$DEMYX_INFO_FLAG"
                ;;
            *)
                break
        esac
        shift
    done

    case "$DEMYX_ARG_2" in
        app|apps)
            demyx_info_apps
        ;;
        system)
            demyx_info_system
        ;;
        *)
            if [[ -n "$DEMYX_ARG_2" ]]; then
                demyx_arg_valid
                demyx_info_app
            else
                demyx_help info
            fi
        ;;
    esac

}
#
#   Displays app's entire environment variables.
#
demyx_info_app() {
    local DEMYX_INFO_APP_DB_VOLUME=
    local DEMYX_INFO_APP_ENV=
    local DEMYX_INFO_APP_ENV_VAR=
    local DEMYX_INFO_APP_ENV_VAL=
    local DEMYX_INFO_APP_JSON=
    local DEMYX_INFO_APP_VOLUME=
    local DEMYX_INFO_APP_WP_VOLUME=

    if [[ "$DEMYX_INFO_FLAG_ENV" = true ]]; then
        demyx_app_env wp DEMYX_APP_PATH
        DEMYX_INFO_APP_ENV="$(grep -i "$DEMYX_INFO_FLAG_ENV_GREP" "$DEMYX_APP_PATH"/.env || true)"
        if [[ -n "$DEMYX_INFO_APP_ENV" ]]; then
            echo "$DEMYX_INFO_APP_ENV"
        else
            demyx_error custom "$DEMYX_INFO_FLAG_ENV_GREP doesn't exist"
        fi
    elif [[ "$DEMYX_INFO_FLAG_LOGIN" = true ]]; then
        demyx_source wp
        demyx_app_env wp "
            DEMYX_APP_AUTH_PASSWORD
            DEMYX_APP_AUTH_USERNAME
            DEMYX_APP_DEV_PASSWORD
            DEMYX_APP_DOMAIN
            DEMYX_APP_OLS_ADMIN_PASSWORD
            DEMYX_APP_OLS_ADMIN_USERNAME
            DEMYX_APP_STACK
            MARIADB_ROOT_PASSWORD
            WORDPRESS_DB_HOST
            WORDPRESS_DB_NAME
            WORDPRESS_DB_PASSWORD
            WORDPRESS_DB_USER
            WORDPRESS_USER
            WORDPRESS_USER_PASSWORD
        "

        {
            echo "Basic Auth Username           $DEMYX_APP_AUTH_USERNAME"
            echo "Basic Auth Password           $DEMYX_APP_AUTH_PASSWORD"
            echo
            echo "Code Server Login             $(demyx_app_proto)://$(demyx_app_domain)/demyx/cs/"
            echo "Code Server Password          $DEMYX_APP_DEV_PASSWORD"

            if [[ "$DEMYX_APP_STACK" = ols || "$DEMYX_APP_STACK" = ols-bedrock ]]; then
                echo
                echo "OLS Admin Login           $(demyx_app_proto)://$(demyx_app_domain)/demyx/ols/"
                echo "OLS Admin Username        $DEMYX_APP_OLS_ADMIN_USERNAME"
                echo "OLS Admin Password        $DEMYX_APP_OLS_ADMIN_PASSWORD"
            fi

            echo
            echo "MariaDB DB Host               $WORDPRESS_DB_HOST"
            echo "MariaDB DB Name               $WORDPRESS_DB_NAME"
            echo "MariaDB DB Username           $WORDPRESS_DB_USER"
            echo "MariaDB DB Password           $WORDPRESS_DB_PASSWORD"
            echo "MariaDB Root Password         $MARIADB_ROOT_PASSWORD"
            echo
            echo "WordPress Login               $(demyx_app_login)"
            echo "WordPress Username            $WORDPRESS_USER"
            echo "WordPress Password            $WORDPRESS_USER_PASSWORD"
        } > "$DEMYX_INFO_TRANSIENT"

        demyx_execute false "demyx_divider_title \"$DEMYX_INFO\" \"Login Credentials\"; \
            cat < $DEMYX_INFO_TRANSIENT"
    else
        demyx_app_env wp "
            DEMYX_APP_DB_CONTAINER
            DEMYX_APP_PATH
            DEMYX_APP_WP_CONTAINER
            WORDPRESS_DB_NAME
        "

        if [[ -z "$DEMYX_INFO_FLAG_NO_VOLUME" ]]; then
            DEMYX_INFO_APP_DB_VOLUME="$(docker exec -t "$DEMYX_APP_DB_CONTAINER" du -sh /demyx/"$WORDPRESS_DB_NAME" | cut -f1)"
            DEMYX_INFO_APP_WP_VOLUME="$(docker exec -t "$DEMYX_APP_WP_CONTAINER" du -sh /demyx | cut -f1)"
            DEMYX_INFO_APP_VOLUME="^DB VOLUME^ $DEMYX_INFO_APP_DB_VOLUME\n"
            DEMYX_INFO_APP_VOLUME+="^WP VOLUME^ $DEMYX_INFO_APP_WP_VOLUME\n"
            DEMYX_INFO_APP_JSON="{\"db_volume\":\"${DEMYX_INFO_APP_DB_VOLUME}\",\"wp_volume\":\"${DEMYX_INFO_APP_WP_VOLUME}\","
        fi

        if [[ "$DEMYX_INFO_FLAG_JSON" = true ]]; then
            while IFS= read -r DEMYX_INFO_APP_ENV; do
                DEMYX_INFO_APP_ENV_VAR="$(echo "${DEMYX_INFO_APP_ENV/=*/}" | awk '{print tolower($0)}')"
                DEMYX_INFO_APP_ENV_VAL="${DEMYX_INFO_APP_ENV/*=/}"
                DEMYX_INFO_APP_JSON+="\"${DEMYX_INFO_APP_ENV_VAR}\":\"${DEMYX_INFO_APP_ENV_VAL}\","
            done < <(grep '=' < "$DEMYX_APP_PATH"/.env)

            echo "${DEMYX_INFO_APP_JSON%,*}}" > "$DEMYX_TMP"/demyx_info

            demyx_execute false \
                "cat < ${DEMYX_TMP}/demyx_info"
        else
            demyx_app_env wp DEMYX_APP_PATH

            {
                cat < "$DEMYX_APP_PATH"/.env | sed '/#/d'
            } > "$DEMYX_INFO_TRANSIENT"

            demyx_execute false "demyx_divider_title \"$DEMYX_INFO\" \"DB Volume ($DEMYX_INFO_APP_DB_VOLUME) - WP Volume ($DEMYX_INFO_APP_WP_VOLUME)\""
            column "$DEMYX_INFO_TRANSIENT"
        fi
    fi
}

            if [[ "$DEMYX_INFO_BACKUP_COUNT" != 0 ]]; then
                cd "$DEMYX_BACKUP_WP"/"$DEMYX_APP_DOMAIN"
                for i in *
                do
                    DEMYX_INFO_BACKUP_SIZE="$(du -sh "$DEMYX_BACKUP_WP"/"$DEMYX_APP_DOMAIN"/"$i" | cut -f1)"
                    PRINT_TABLE+="$DEMYX_INFO_BACKUP_SIZE^ $i\n"
                done
            fi
                        
            demyx_execute -v demyx_table "$PRINT_TABLE"
        elif [[ -n "$DEMYX_INFO_FILTER" ]]; then
            DEMYX_INFO_FILTER="$(cat "$DEMYX_APP_PATH"/.env | grep -w "$DEMYX_INFO_FILTER")"
            if [[ -n "$DEMYX_INFO_FILTER" ]]; then
                demyx_execute -v -q echo "$DEMYX_INFO_FILTER" | awk -F '[=]' '{print $2}'
            else
                demyx_die 'Filter not found'
            fi
        else
            if [[ -z "$DEMYX_INFO_NO_VOLUME" ]]; then
                DEMYX_INFO_DATA_VOLUME="$(docker exec -t "$DEMYX_APP_WP_CONTAINER" du -sh /demyx | cut -f1)"
                DEMYX_INFO_DB_VOLUME="$(docker exec -t "$DEMYX_APP_DB_CONTAINER" du -sh /demyx/"$WORDPRESS_DB_NAME" | cut -f1)"
            fi

            if [[ -n "$DEMYX_INFO_JSON" ]]; then
                echo '{
                    "path": "'$DEMYX_APP_PATH'",
                    "wp_user": "'$WORDPRESS_USER'",
                    "wp_password": "'$WORDPRESS_USER_PASSWORD'",
                    "nx_container": "'$DEMYX_APP_NX_CONTAINER'",
                    "wp_container": "'$DEMYX_APP_WP_CONTAINER'",
                    "db_container": "'$DEMYX_APP_DB_CONTAINER'",
                    "wp_volume": "'$DEMYX_INFO_DATA_VOLUME'",
                    "db_volume": "'$DEMYX_INFO_DB_VOLUME'",
                    "wp_cpu": "'$DEMYX_APP_WP_CPU'",
                    "wp_mem": "'$DEMYX_APP_WP_MEM'",
                    "db_cpu": "'$DEMYX_APP_DB_CPU'",
                    "db_mem": "'$DEMYX_APP_DB_MEM'",
                    "ssl": "'$DEMYX_APP_SSL'",
                    "cache": "'$DEMYX_APP_CACHE'",
                    "cdn": "'$DEMYX_APP_CDN'",
                    "auth": "'$DEMYX_APP_AUTH'",
                    "auth_wp": "'$DEMYX_APP_AUTH_WP'",
                    "dev": "'$DEMYX_APP_DEV'",
                    "healthcheck": "'$DEMYX_APP_HEALTHCHECK'"' | sed 's/                    /    /g'
                echo '}'
            else
                [[ -z "$DEMYX_APP_AUTH_WP" ]] && DEMYX_APP_AUTH_WP=false
                PRINT_TABLE="DEMYX^ INFO\n"
                PRINT_TABLE+="DOMAIN^ $DEMYX_APP_DOMAIN\n"
                PRINT_TABLE+="PATH^ $DEMYX_APP_PATH\n"
                PRINT_TABLE+="BASIC AUTH USERNAME^ $DEMYX_APP_AUTH_USERNAME\n"
                PRINT_TABLE+="BASIC AUTH PASSWORD^ $DEMYX_APP_AUTH_PASSWORD\n"
                PRINT_TABLE+="OPENLITESPEED ADMIN USERNAME^ $DEMYX_APP_OLS_ADMIN_USERNAME\n"
                PRINT_TABLE+="OPENLITESPEED ADMIN PASSWORD^ $DEMYX_APP_OLS_ADMIN_PASSWORD\n"
                PRINT_TABLE+="CODE-SERVER PASSWORD^ $DEMYX_APP_DEV_PASSWORD\n"
                PRINT_TABLE+="WP USER^ $WORDPRESS_USER\n"
                PRINT_TABLE+="WP PASSWORD^ $WORDPRESS_USER_PASSWORD\n"
                PRINT_TABLE+="DB ROOT PASSWORD^ $MARIADB_ROOT_PASSWORD\n"
                PRINT_TABLE+="NX CONTAINER^ $DEMYX_APP_NX_CONTAINER\n"
                PRINT_TABLE+="WP CONTAINER^ $DEMYX_APP_WP_CONTAINER\n"
                PRINT_TABLE+="DB CONTAINER^ $DEMYX_APP_DB_CONTAINER\n"
                PRINT_TABLE+="WP VOLUME^ $DEMYX_INFO_DATA_VOLUME\n"
                PRINT_TABLE+="DB VOLUME^ $DEMYX_INFO_DB_VOLUME\n"
                PRINT_TABLE+="WP CPU^ $DEMYX_APP_WP_CPU\n"
                PRINT_TABLE+="WP MEM^ $DEMYX_APP_WP_MEM\n"
                PRINT_TABLE+="DB CPU^ $DEMYX_APP_DB_CPU\n"
                PRINT_TABLE+="DB MEM^ $DEMYX_APP_DB_MEM\n"
                PRINT_TABLE+="UPLOAD LIMIT^ $DEMYX_APP_UPLOAD_LIMIT\n"
                PRINT_TABLE+="PHP MEMORY^ $DEMYX_APP_PHP_MEMORY\n"
                PRINT_TABLE+="PHP MAX EXECUTION TIME^ $DEMYX_APP_PHP_MAX_EXECUTION_TIME\n"
                PRINT_TABLE+="PHP OPCACHE^ $DEMYX_APP_PHP_OPCACHE\n"
                PRINT_TABLE+="SSL^ $DEMYX_APP_SSL\n"
                PRINT_TABLE+="CACHE^ $DEMYX_APP_CACHE\n"
                PRINT_TABLE+="AUTH^ $DEMYX_APP_AUTH\n"
                PRINT_TABLE+="WP AUTH^ $DEMYX_APP_AUTH_WP\n"
                PRINT_TABLE+="DEV^ $DEMYX_APP_DEV\n"
                PRINT_TABLE+="HEALTHCHECK^ $DEMYX_APP_HEALTHCHECK\n"
                PRINT_TABLE+="WP AUTO UPDATE^ $DEMYX_APP_WP_UPDATE\n"
                demyx_execute -v demyx_table "$PRINT_TABLE"
            fi
        fi
    else
        [[ -z "$DEMYX_INFO_QUIET" ]] && demyx_die --not-found
    fi
}
