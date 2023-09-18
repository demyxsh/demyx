# Demyx
# https://demyx.sh
# shellcheck shell=bash

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
            -l)
                DEMYX_INFO_FLAG_LOGIN=true
            ;;
            -nv)
                DEMYX_INFO_FLAG_NO_VOLUME=true
            ;;
            -r)
                DEMYX_INFO_FLAG_RAW=true
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
#
#   # TODO - List apps that are currently installed.
#
demyx_info_apps() {
    local DEMYX_INFO_APPS_COUNT=
    DEMYX_INFO_APPS_COUNT="$(find "$DEMYX_WP" -mindepth 1 -maxdepth 1 -type d | wc -l)"

    if (( "$DEMYX_INFO_APPS_COUNT" > 0 )); then
        cd "$DEMYX_WP" || exit

        {
            for DEMYX_INFO_APPS_I in *; do
                echo "$DEMYX_INFO_APPS_I"
            done
        } > "$DEMYX_INFO_TRANSIENT"

        if [[ "$DEMYX_INFO_FLAG_RAW" = true ]]; then
            cat < "$DEMYX_INFO_TRANSIENT"
        else
            demyx_execute false \
                "demyx_divider_title \"$DEMYX_INFO\" \"Apps ($DEMYX_INFO_APPS_COUNT)\"; \
                    cat < $DEMYX_INFO_TRANSIENT"
        fi
    fi
}
#
#   Display basic information of demyx system.
#
demyx_info_system() {
    local DEMYX_INFO_SYSTEM_CONTAINER_DEAD=
    DEMYX_INFO_SYSTEM_CONTAINER_DEAD="$(docker ps -q --filter "status=exited" | wc -l)"
    local DEMYX_INFO_SYSTEM_CONTAINER_RUNNING=
    DEMYX_INFO_SYSTEM_CONTAINER_RUNNING="$(docker ps -q | wc -l)"
    local DEMYX_INFO_SYSTEM_DF=
    DEMYX_INFO_SYSTEM_DF="$(df -h /demyx | sed '1d')"
    local DEMYX_INFO_SYSTEM_DISK_PERCENTAGE=
    DEMYX_INFO_SYSTEM_DISK_PERCENTAGE="$(echo "$DEMYX_INFO_SYSTEM_DF" | awk '{print $5}')"
    local DEMYX_INFO_SYSTEM_DISK_TOTAL=
    DEMYX_INFO_SYSTEM_DISK_TOTAL="$(echo "$DEMYX_INFO_SYSTEM_DF" | awk '{print $2}')"
    local DEMYX_INFO_SYSTEM_DISK_USED=
    DEMYX_INFO_SYSTEM_DISK_USED="$(echo "$DEMYX_INFO_SYSTEM_DF" | awk '{print $3}')"
    local DEMYX_INFO_SYSTEM_LOAD_AVERAGE=
    DEMYX_INFO_SYSTEM_LOAD_AVERAGE="$(cat < /proc/loadavg | awk '{print $1 " " $2 " " $3}')"
    local DEMYX_INFO_SYSTEM_MEMORY=
    DEMYX_INFO_SYSTEM_MEMORY="$(free -m)"
    local DEMYX_INFO_SYSTEM_MEMORY_TOTAL=
    DEMYX_INFO_SYSTEM_MEMORY_TOTAL="$(echo "$DEMYX_INFO_SYSTEM_MEMORY" | grep Mem | awk '{print $2}')"
    local DEMYX_INFO_SYSTEM_MEMORY_USED=
    DEMYX_INFO_SYSTEM_MEMORY_USED="$(echo "$DEMYX_INFO_SYSTEM_MEMORY" | grep Mem | awk '{print $3}')"
    local DEMYX_INFO_SYSTEM_UPTIME=
    DEMYX_INFO_SYSTEM_UPTIME="$(uptime | awk -F '[,]' '{print $1}' | awk -F '[up]' '{print $3}' | sed 's|^.||')"
    local DEMYX_INFO_SYSTEM_WP_BACKUPS=
    DEMYX_INFO_SYSTEM_WP_BACKUPS="$([[ -d "$DEMYX_BACKUP_WP" ]] && du -sh "$DEMYX_BACKUP_WP" | awk '{print $1}' || echo 0)"
    local DEMYX_INFO_SYSTEM_WP_COUNT=
    DEMYX_INFO_SYSTEM_WP_COUNT="$(find "$DEMYX_WP" -mindepth 1 -maxdepth 1 -type d | wc -l)"

    if [[ "$DEMYX_INFO_FLAG_JSON" = true ]]; then
        {
            echo "{"
            echo "\"build\":\"$DEMYX_BUILD\","
            echo "\"version\":\"$DEMYX_VERSION\","
            echo "\"hostname\":\"$DEMYX_HOSTNAME\","
            echo "\"ip\":\"$DEMYX_SERVER_IP\","
            echo "\"wp_count\":\"$DEMYX_INFO_SYSTEM_WP_COUNT\","
            echo "\"wp_backups\":\"$DEMYX_INFO_SYSTEM_WP_BACKUPS\","
            echo "\"disk_used\":\"$DEMYX_INFO_SYSTEM_DISK_USED\","
            echo "\"disk_total\":\"$DEMYX_INFO_SYSTEM_DISK_TOTAL\","
            echo "\"disk_total_percentage\":\"$DEMYX_INFO_SYSTEM_DISK_PERCENTAGE\","
            echo "\"memory_used\":\"$DEMYX_INFO_SYSTEM_MEMORY_USED\","
            echo "\"memory_total\":\"$DEMYX_INFO_SYSTEM_MEMORY_TOTAL\","
            echo "\"uptime\":\"$DEMYX_INFO_SYSTEM_UPTIME\","
            echo "\"load_average\":\"$DEMYX_INFO_SYSTEM_LOAD_AVERAGE\","
            echo "\"container_running\":\"$DEMYX_INFO_SYSTEM_CONTAINER_RUNNING\","
            echo "\"container_dead\":\"$DEMYX_INFO_SYSTEM_CONTAINER_DEAD\""
            echo "}"
        } > "$DEMYX_INFO_TRANSIENT"

        demyx_execute false \
            "sed -i ':a;N;\$!ba;s/\n/ /g' $DEMYX_INFO_TRANSIENT; \
                cat < $DEMYX_INFO_TRANSIENT"
    else
        {
            echo "Build                     $DEMYX_BUILD"
            echo "Version                   $DEMYX_VERSION"
            echo "Hostname                  $DEMYX_HOSTNAME"
            echo "IP                        $DEMYX_SERVER_IP"
            echo "Apps                      $DEMYX_INFO_SYSTEM_WP_COUNT"
            echo "Backups                   $DEMYX_INFO_SYSTEM_WP_BACKUPS"
            echo "Disk Used                 $DEMYX_INFO_SYSTEM_DISK_USED"
            echo "Disk Total                $DEMYX_INFO_SYSTEM_DISK_TOTAL"
            echo "Disk Total %              $DEMYX_INFO_SYSTEM_DISK_PERCENTAGE"
            echo "Memory Used               $DEMYX_INFO_SYSTEM_MEMORY_USED"
            echo "Memory Total              $DEMYX_INFO_SYSTEM_MEMORY_TOTAL"
            echo "Uptime                    $DEMYX_INFO_SYSTEM_UPTIME"
            echo "Load Average              $DEMYX_INFO_SYSTEM_LOAD_AVERAGE"
            echo "Running Containers        $DEMYX_INFO_SYSTEM_CONTAINER_RUNNING"
            echo "Dead Containers           $DEMYX_INFO_SYSTEM_CONTAINER_DEAD"
        } > "$DEMYX_INFO_TRANSIENT"

        demyx_execute false \
            "demyx_divider_title \"$DEMYX_INFO\" \"System Information\"; \
                cat < $DEMYX_INFO_TRANSIENT"
    fi
}
