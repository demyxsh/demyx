# Demyx
# https://demyx.sh
# shellcheck shell=bash

#
#   Checks if main app domain is www or not.
#
demyx_app_domain() {
    demyx_event
    local DEMYX_APP_DOMAIN_ARG="${1:-$DEMYX_ARG_2}"
    local DEMYX_APP_DOMAIN_ARG_FIND=
    DEMYX_APP_DOMAIN_ARG_FIND="$(demyx_app_path "$DEMYX_APP_DOMAIN_ARG")"
    local DEMYX_APP_DOMAIN_ARG_WWW=
    DEMYX_APP_DOMAIN_ARG_WWW="$(grep DEMYX_APP_DOMAIN_WWW "$DEMYX_APP_DOMAIN_ARG_FIND"/.env | awk -F '=' '{print $2}' || true)"

    if [[ "$DEMYX_APP_DOMAIN_ARG_WWW" = true ]]; then
        echo "www.${DEMYX_APP_DOMAIN_ARG}"
    else
        echo "$DEMYX_APP_DOMAIN_ARG"
    fi
}
#
#   Get variable from app's .env file.
#
demyx_app_env() {
    demyx_event
    local DEMYX_APP_ENV_1="${1:-}"
    local DEMYX_APP_ENV_2="${2:-}"
    local DEMYX_APP_FILE=

    case "$DEMYX_APP_ENV_1" in
        code)
            # TODO
        ;;
        html)
            # TODO
        ;;
        php)
            # TODO
        ;;
        wp)
            DEMYX_APP_FILE="$DEMYX_WP"/"$DEMYX_ARG_2"/.env
        ;;
    esac

    if [[ -f "$DEMYX_APP_FILE" ]]; then
        local DEMYX_APP_ENV_GREP="${DEMYX_APP_ENV_2:-}"
        local DEMYX_APP_ENV_I=
        local DEMYX_APP_ENV_I_VAL=
        local DEMYX_APP_ENV_REMOVE_ENV=
        local DEMYX_APP_ENV_REMOVE_COMPOSE=

        # TEMPORARY
        DEMYX_APP_ENV_REMOVE_ENV="$(grep DEMYX_APP_AUTH_HTPASSWD "$DEMYX_APP_FILE" || true)"
        if [[ -n "$DEMYX_APP_ENV_REMOVE_ENV" ]]; then
            sed -i "/DEMYX_APP_AUTH_HTPASSWD/d" "$DEMYX_WP"/"$DEMYX_ARG_2"/.env
        fi

        # TEMPORARY
        if [[ -f "${DEMYX_WP}/${DEMYX_ARG_2}/compose" ]]; then
            DEMYX_APP_ENV_REMOVE_COMPOSE="$(grep DEMYX_APP_AUTH_HTPASSWD "${DEMYX_WP}/${DEMYX_ARG_2}/compose" || true)"
            if [[ -n "$DEMYX_APP_ENV_REMOVE_COMPOSE" ]]; then
                sed -i "/DEMYX_APP_AUTH_HTPASSWD/d" "${DEMYX_WP}/${DEMYX_ARG_2}/compose"
            fi
        fi

        for DEMYX_APP_ENV_I in $DEMYX_APP_ENV_GREP; do
            DEMYX_APP_ENV_I_VAL="$(grep -w "$DEMYX_APP_ENV_I" "$DEMYX_APP_FILE" | awk -F '=' '{print $2}' || true)"

            # Refresh app's .env if variable doesn't exist.
            if [[ -z "$DEMYX_APP_ENV_I_VAL" ]]; then
                demyx_source env
                demyx_env

                # Grep again.
                DEMYX_APP_ENV_I_VAL="$(grep -w "$DEMYX_APP_ENV_I" "$DEMYX_APP_FILE" | awk -F '=' '{print $2}' || true)"
            fi

            # shellcheck disable=SC2316
            export local "$DEMYX_APP_ENV_I"="$DEMYX_APP_ENV_I_VAL"
        done
    else
        demyx_error custom "Invalid app or missing app's .env"
    fi
}
#
#   Update an app's specific environment variable.
#
demyx_app_env_update() {
    demyx_event
    local DEMYX_APP_ENV_UPDATE="${1:-}"
    local DEMYX_APP_ENV_UPDATE_I=
    local DEMYX_APP_ENV_UPDATE_I_VAL=
    local DEMYX_APP_ENV_UPDATE_I_VAR=

    demyx_app_env wp "
        DEMYX_APP_PATH
        DEMYX_APP_STACK
    "

    demyx_source "
        env
        yml
    "

    demyx_env
    demyx_yml "$DEMYX_APP_STACK"

    for DEMYX_APP_ENV_UPDATE_I in $DEMYX_APP_ENV_UPDATE; do
        DEMYX_APP_ENV_UPDATE_I_VAL="${DEMYX_APP_ENV_UPDATE_I//*=/}"
        DEMYX_APP_ENV_UPDATE_I_VAR="${DEMYX_APP_ENV_UPDATE_I//=*/}"

        sed -i "s|${DEMYX_APP_ENV_UPDATE_I_VAR}=.*|${DEMYX_APP_ENV_UPDATE_I_VAR}=${DEMYX_APP_ENV_UPDATE_I_VAL}|g" "$DEMYX_APP_PATH"/.env
    done
}
#
#   Check if a WordPress or MariaDB container is running.
#
demyx_app_is_up() {
    demyx_event
    local DEMYX_APP_IS_UP=
    DEMYX_APP_IS_UP="$(demyx_ps)"

    local DEMYX_APP_IS_UP_CHECK_DB=
    DEMYX_APP_IS_UP_CHECK_DB="$(echo "$DEMYX_APP_IS_UP" | grep "${DEMYX_APP_DB_CONTAINER:-}" || true)"
    local DEMYX_APP_IS_UP_CHECK_WP=
    DEMYX_APP_IS_UP_CHECK_WP="$(echo "$DEMYX_APP_IS_UP" | grep "${DEMYX_APP_WP_CONTAINER:-}" || true)"

    if [[ -z "$DEMYX_APP_IS_UP_CHECK_DB" || -z "$DEMYX_APP_IS_UP_CHECK_WP" ]]; then
        demyx_error "$DEMYX_APP_DOMAIN isn't running"
    fi
}
#
#   Output WordPress login URL.
#
#
demyx_app_login() {
    demyx_event
    local DEMYX_APP_LOGIN=
    local DEMYX_APP_LOGIN_COUNT=0

    demyx_app_env wp "
        DEMYX_APP_WP_CONTAINER
        WORDPRESS_USER
    "

    while true; do
        DEMYX_APP_LOGIN="$(docker exec "$DEMYX_APP_WP_CONTAINER" wp login as "$WORDPRESS_USER" --url-only 2>&1 | tr '\r' ' ' || true)"

        if [[ "$DEMYX_APP_LOGIN_COUNT" = 3 ]]; then
            demyx_error custom "$DEMYX_APP_LOGIN"
        elif [[ "$DEMYX_APP_LOGIN" == *"Error:"* ]]; then
            DEMYX_APP_LOGIN_COUNT="$((DEMYX_APP_LOGIN_COUNT+1))"
        else
            echo "$DEMYX_APP_LOGIN"
            break
        fi
    done
}
#   Get app's path using find.
#
demyx_app_path() {
    demyx_event
    local DEMYX_APP_PATH="${1:-$DEMYX_ARG_2}"
    local DEMYX_APP_PATH_FIND=
    DEMYX_APP_PATH_FIND="$(find "$DEMYX_APP" -name "$DEMYX_APP_PATH" -type d)"

    if [[ "$DEMYX_APP_PATH_FIND" == *"$DEMYX_WP"/"$DEMYX_APP_PATH"* ]]; then
        echo "$DEMYX_WP"/"$DEMYX_APP_PATH"
    else
        echo "$DEMYX_APP_PATH_FIND"
    fi
}
#
#   Echo out protocol based on DEMYX_APP_SSL or DEMYX_APP_SSL_WILDCARD.
#
demyx_app_proto() {
    demyx_event
    local DEMYX_APP_PROTO=
    local DEMYX_APP_PROTO_ENV=
    DEMYX_APP_PROTO_ENV="$(demyx_app_path "$DEMYX_ARG_2")"/.env
    local DEMYX_APP_PROTO_SSL=
    local DEMYX_APP_PROTO_SSL_WILDCARD=

    if [[ -f "$DEMYX_APP_PROTO_ENV" ]]; then
        DEMYX_APP_PROTO_SSL="$(grep DEMYX_APP_SSL=true "$DEMYX_APP_PROTO_ENV" || true)"
        DEMYX_APP_PROTO_SSL_WILDCARD="$(grep DEMYX_APP_SSL_WILDCARD=true "$DEMYX_APP_PROTO_ENV" || true)"
    fi

    if [[ -n "$DEMYX_APP_PROTO_SSL" || -n "$DEMYX_APP_PROTO_SSL_WILDCARD" ]]; then
        DEMYX_APP_PROTO=https
    else
        DEMYX_APP_PROTO=http
    fi

    echo "$DEMYX_APP_PROTO"
}
#
#   Validates $DEMYX_ARG_2.
#
demyx_arg_valid() {
    demyx_event
    if [[ "$DEMYX_ARG_2" == *"://"* ]]; then
        demyx_error custom "${DEMYX_ARG_2//:\/\/*/}:// is not allowed"
    fi

    if [[ "$DEMYX_ARG_2" == "www."* ]]; then
        DEMYX_ARG_2="${DEMYX_ARG_2/www./}"
    fi

    if [[ "$DEMYX_ARG_2" == "code."* || "$DEMYX_ARG_2" == "traefik."* ]]; then
        demyx_error custom "That domain is reserved"
    fi

    # Checks if DEMYX_ARG_2 has a period to indicate it's a domain
    if [[ ! "${DEMYX_ARG_2}" =~ \. ]]; then
        demyx_error custom "Not a valid domain"
    fi

    local DEMYX_ARG_PATH_CHECK=
    DEMYX_ARG_PATH_CHECK="$(find "$DEMYX_APP" -name "$DEMYX_ARG_2" || true)"

    # shellcheck disable=SC2153
    if [[ "$DEMYX_ARG_1" != run && "$DEMYX_ARG_1" != restore ]]; then
        if [[ ! -d "$DEMYX_ARG_PATH_CHECK" && ! -f "$DEMYX_ARG_PATH_CHECK"/.env && ! -f "$DEMYX_ARG_PATH_CHECK"/compose.yml ]]; then
            demyx_error app
        fi
    fi
}
#
#   Compare versions.
#
demyx_compare() {
    demyx_event
    echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }';
}
#
#   Count all WP sites.
#
demyx_count_wp() {
    demyx_event
    if [[ -d "$DEMYX_WP" ]]; then
        find "$DEMYX_WP" -mindepth 1 -maxdepth 1 -type d | wc -l
    else
        echo 0
    fi
}
#
#   Print a divider as long as the current terminal width. Defaults to 100.
#
demyx_divider() {
    demyx_event
    local DEMYX_DIVIDER="${1:-}"
    local DEMYX_DIVIDER_COUNT="${DEMYX_DIVIDER:-50}"

    if [[ -t 0 && -z "$DEMYX_DIVIDER" ]]; then
        DEMYX_DIVIDER_COUNT="$(stty size | awk -F ' ' '{print $2}')"
    fi

    printf %"${DEMYX_DIVIDER_COUNT}"s | tr " " "="
    echo
}
#
#   Print divider title.
#
demyx_divider_title() {
    demyx_event
    local DEMYX_DIVIDER_TITLE="${1:-}"
    local DEMYX_DIVIDER_TITLE_BODY="${2:-}"
    local DEMYX_DIVIDER_TITLE_COUNT="${3:-}"

    demyx_divider "$DEMYX_DIVIDER_TITLE_COUNT"
    echo "[$DEMYX_DIVIDER_TITLE] $DEMYX_DIVIDER_TITLE_BODY"
    demyx_divider "$DEMYX_DIVIDER_TITLE_COUNT"
}
#
#   Echos INFO messages
#
demyx_echo() {
    demyx_event
    local DEMYX_ECHO="\e[34m[INFO]\e[39m ${1:-}"
    echo -e "$DEMYX_ECHO"
}
#
#   Outputs error string with an exit code 1.
#
demyx_error() {
    demyx_event
    local DEMYX_ERROR="${1:-}"
    local DEMYX_ERROR_ARG="${2:-$DEMYX_ARG_2}"
    local DEMYX_ERROR_STRING=
    DEMYX_ERROR_STRING="[$(date +%F-%T)] \e[31m[ERROR]\e[39m"

    case "$DEMYX_ERROR" in
        app)
            echo -en "$DEMYX_ERROR_STRING Not a valid app: $DEMYX_ERROR_ARG\n"
        ;;
        args)
            echo -en "$DEMYX_ERROR_STRING Missing argument(s)\n"
        ;;
        config)
            echo -en "$DEMYX_ERROR_STRING This config is already set to $DEMYX_ERROR_ARG, use -f to force\n"
        ;;
        cancel)
            echo -en "$DEMYX_ERROR_STRING Cancelled\n"
        ;;
        custom)
            echo -en "$DEMYX_ERROR_STRING $DEMYX_ERROR_ARG\n"
        ;;
        file)
            echo -en "$DEMYX_ERROR_STRING File not found: $DEMYX_ERROR_ARG\n"
        ;;
        flag)
            echo -en "$DEMYX_ERROR_STRING Invalid flag: $DEMYX_ERROR_ARG\n"
        ;;
        flag-empty)
            echo -en "$DEMYX_ERROR_STRING Cannot be empty: ${DEMYX_ERROR_ARG//=/}\n"
        ;;
    esac

    exit 1
}
#
#   Echos useful messages to the user and executes second argument.
#
demyx_execute() {
    demyx_event
    local DEMYX_EXECUTE="${1:-}"
    shift

    echo -n "$DEMYX_EXECUTE ... "
    # shellcheck disable=SC2153
    eval "$*" > "$DEMYX_TMP"/demyx_execute
    echo -en "\e[32mdone\e[39m\n"
}
#
#   GitHub Action and existing volume warning fix.
#
demyx_external_volume() {
    local DEMYX_EXTERNAL_VOLUME=
    local DEMYX_EXTERNAL_VOLUME_ARG="${1:-}"

    if [[ ! -f "$DEMYX"/github_action ]]; then
        if [[ ! -f "$DEMYX_TMP"/demyx_volumes ]]; then
            DEMYX_EXTERNAL_VOLUME="$(docker volume ls | tee "$DEMYX_TMP"/demyx_volumes)"
        else
            DEMYX_EXTERNAL_VOLUME="$(cat < "$DEMYX_TMP"/demyx_volumes)"
        fi

        case "$DEMYX_EXTERNAL_VOLUME_ARG" in
            traefik)
                if [[ -n "$(echo "$DEMYX_EXTERNAL_VOLUME" | grep -w demyx_traefik || true)" ]]; then
                    echo "external: true"
                fi
            ;;
        esac
    fi
}
#
#   Output `docker images` to a file for performance and outputs contents to stdout.
#
demyx_images() {
    demyx_event
    local DEMYX_IMAGES="${1:-}"
    local DEMYX_IMAGES_FILE="$DEMYX"/.images

    if [[ ! -f "$DEMYX_IMAGES_FILE" ]]; then
        docker images --format="{{.Repository}}:{{.Tag}}" | sed '/:<none>/d' | sed 's|:latest||g' > "$DEMYX_IMAGES_FILE"
    fi

    case "$DEMYX_IMAGES" in
        cat)
            cat < "$DEMYX"/.images
        ;;
        path)
            echo "$DEMYX"/.images
        ;;
        update)
            docker images --format="{{.Repository}}:{{.Tag}}" | sed '/:<none>/d' | sed 's|:latest||g' > "$DEMYX_IMAGES_FILE"
        ;;
        *)
            cat <<< "$DEMYX_IMAGES_FILE"
        ;;
    esac
}
#
#   Loop checks a connection to MariaDB and exits when a connection is successful.
#
demyx_mariadb_ready() {
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_DB_CONTAINER
        WORDPRESS_DB_PASSWORD
        WORDPRESS_DB_USER
    "

    until docker exec -t "$DEMYX_APP_DB_CONTAINER" mysqladmin -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" status 2>/dev/null
    do
        sleep 1
    done
}
#
#   Send notification by email/matrix.
#
demyx_notification() {
    demyx_event
    local DEMYX_NOTIFICATION="${1:-}"
    local DEMYX_NOTIFICATION_ARG_2="${2:-}"
    local DEMYX_NOTIFICATION_BODY=

    case "$DEMYX_NOTIFICATION" in
        error)
            DEMYX_NOTIFICATION="[ERROR - $DEMYX_HOSTNAME] $DEMYX_NOTIFICATION_ARG_2"
            DEMYX_NOTIFICATION_BODY="$(cat < "$DEMYX_TMP"/demyx_trap | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" | sed 's|["'\'']||g' | sed ':a;N;$!ba;s/\n/<br>/g')"
            DEMYX_NOTIFICATION_BODY+="$(cat < "$DEMYX_TMP"/demyx_trace | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" | sed 's|["'\'']||g' | sed ':a;N;$!ba;s/\n/<br>/g')"
        ;;
        healthcheck)
            DEMYX_NOTIFICATION="[HEALTHCHECK - $DEMYX_HOSTNAME] $DEMYX_NOTIFICATION_ARG_2"
            DEMYX_NOTIFICATION_BODY="$(cat < "$DEMYX_TMP"/demyx_notify_healthcheck | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" | sed 's|["'\'']||g' | sed ':a;N;$!ba;s/\n/<br>/g')"
        ;;
    esac

    if [[ "$DEMYX_MATRIX" = true && -n "$DEMYX_MATRIX_KEY" && -n "$DEMYX_MATRIX_URL" ]]; then
        curl -s -X POST \
        -H 'Content-Type: application/json' \
        --data "
            {
                \"text\":\"${DEMYX_NOTIFICATION}<br>${DEMYX_NOTIFICATION_BODY}\",
                \"key\":\"$DEMYX_MATRIX_KEY\"
            }
        " \
        "$DEMYX_MATRIX_URL" >/dev/null 2>&1
    fi

    if [[ "$DEMYX_SMTP" = true ]]; then
        demyx_smtp "$DEMYX_NOTIFICATION" "$DEMYX_NOTIFICATION_BODY"
    fi
}
#
#   Checks if stack is ols and then exits.
#
demyx_ols_not_supported() {
    demyx_event
    demyx_app_env wp DEMYX_APP_STACK

    if [[ "$DEMYX_APP_STACK" = ols || "$DEMYX_APP_STACK" = ols-bedrock ]]; then
        demyx_error custom "OpenLiteSpeed doesn't support that feature"
    fi
}
#
#   Checks for open ports on the host.
#
demyx_open_port() {
    demyx_event
    local DEMYX_OPEN_PORT=

    DEMYX_OPEN_PORT="$(docker run --rm \
        --network=host \
        demyx/utilities demyx-port | sed 's/\r//g')"

    echo "$DEMYX_OPEN_PORT" > "$DEMYX_TMP"/"$DEMYX_ARG_2"_sftp
}
#
#   Calculates php-fpm's pm values based on app container's memory.
#   Reference: https://chrismoore.ca/2018/10/finding-the-correct-pm-max-children-settings-for-php-fpm/
#
demyx_pm_calc() {
    demyx_event
    demyx_source "
        exec
        utility
    "

    demyx_app_env wp DEMYX_APP_PHP_PM_AVERAGE

    local DEMYX_PM_CALC="${1:-}"
    local DEMYX_PM_CALC_MEMORY=
    DEMYX_PM_CALC_MEMORY="$(free | grep Mem | awk -F ' ' '{print $2}')"
    local DEMYX_PM_CALC_MEMORY_BUFFER=
    DEMYX_PM_CALC_MEMORY_BUFFER="$(( "${DEMYX_PM_CALC_MEMORY}" * 10 /100 ))"
    DEMYX_PM_CALC_MEMORY="$(( "${DEMYX_PM_CALC_MEMORY}" - "${DEMYX_PM_CALC_MEMORY_BUFFER}" - "${DEMYX_PM_CALC_MEMORY_BUFFER}" ))"
    local DEMYX_PM_CALC_MAX_CHILDREN="$(( "${DEMYX_PM_CALC_MEMORY}" / "${DEMYX_APP_PHP_PM_AVERAGE}" ))"

    case "$DEMYX_PM_CALC" in
        max-children)
            echo "${DEMYX_PM_CALC_MAX_CHILDREN}"
        ;;
        max-spare)
            echo "$(( "$DEMYX_PM_CALC_MAX_CHILDREN" * 75 / 100 ))"
        ;;
        min-spare)
            echo "$(( "$DEMYX_PM_CALC_MAX_CHILDREN" * 25 / 100 ))"
        ;;
        start-server)
            echo "$(( "$DEMYX_PM_CALC_MAX_CHILDREN" * 75 / 100 ))"
        ;;
    esac
}
#
#   Properizes files/directories.
#
demyx_proper() {
    demyx_event
    local DEMYX_PROPER="${1:-}"

    {
        # Reset properness
        if [[ -n "$DEMYX_PROPER" ]]; then
            chown -R demyx:demyx "$DEMYX_PROPER"
        else
            chown -R demyx:demyx "$DEMYX"
            chown -R demyx:demyx "$DEMYX_LOG"
        fi

        # Delete volume cache
        if [[ -f "$DEMYX_TMP"/demyx_volumes ]]; then
            rm -f "$DEMYX_TMP"/demyx_volumes
        fi
    } || true
}
#
#   Source .env/.sh depending on first argument.
#
demyx_source() {
    demyx_event
    local DEMYX_SOURCE=
    DEMYX_SOURCE="${1:-}"
    local DEMYX_SOURCE_I=

    for DEMYX_SOURCE_I in $DEMYX_SOURCE; do
        local DEMYX_SOURCE_APP=
        DEMYX_SOURCE_APP="$(find "$DEMYX_APP" -name "$DEMYX_SOURCE_I" -type d || true)"
        local DEMYX_SOURCE_FUNCTION=
        DEMYX_SOURCE_FUNCTION="$(find "$DEMYX_FUNCTION" -name "$DEMYX_SOURCE_I".sh -type f)"

        if [[ -f "$DEMYX_SOURCE_FUNCTION" ]]; then
            # Source only if function isn't found.
            if ! declare -F demyx_"$DEMYX_SOURCE_I" &>/dev/null; then
                . "$DEMYX_SOURCE_FUNCTION"
            fi
        elif [[ -f "$DEMYX_SOURCE_APP"/.env ]]; then
            . "$DEMYX_SOURCE_APP"/.env
        fi
    done
}
#
#   Return string if it's a subdomain.
#
demyx_subdomain() {
    demyx_event
    local DEMYX_SUBDOMAIN="${1:-}"
    echo "$DEMYX_SUBDOMAIN" | grep -E '\.[^.]+\.[[:alpha:]]' || true
}
#
#   Custom stack trace.
#
demyx_trap() {
    local DEMYX_TRAP_LINENO=('' ${BASH_LINENO[@]})
    local DEMYX_TRAP_EXIT="$4"
    local DEMYX_TRAP_COMMAND="$5"
    local DEMYX_TRAP_I=
    local DEMYX_TRAP_INDEX=()

    {
        echo
        echo "[$(date +%F-%T)] Fatal Error: '$DEMYX_TRAP_COMMAND' with exit code '$DEMYX_TRAP_EXIT' in ${BASH_SOURCE[1]}:${BASH_LINENO[0]}"
        echo
        echo "Stack Trace:"

        for DEMYX_TRAP_I in "${!BASH_SOURCE[@]}"; do
            DEMYX_TRAP_INDEX+=("$DEMYX_TRAP_I" )
        done

        for DEMYX_TRAP_I in "${!BASH_SOURCE[@]}"; do
            [[ "$DEMYX_TRAP_I" = 0 ]] && continue
            DEMYX_TRAP_INDEX[DEMYX_TRAP_I]="$((DEMYX_TRAP_INDEX[DEMYX_TRAP_I]-1))"
            echo "#${DEMYX_TRAP_INDEX[$DEMYX_TRAP_I]} ${BASH_SOURCE[$DEMYX_TRAP_I]}(${DEMYX_TRAP_LINENO[$DEMYX_TRAP_I]}): ${FUNCNAME[$DEMYX_TRAP_I]}"
        done

        DEMYX_TRAP_I="$(echo "${DEMYX_TRAP_INDEX[@]}" | wc -w)"
        echo "#$((DEMYX_TRAP_I-1)) $DEMYX_ARGS"
        echo
    } > "$DEMYX_TMP"/demyx_trace

    {
        cat < "$DEMYX_TMP"/demyx_trap
        cat < "$DEMYX_TMP"/demyx_trace
    } >> "$DEMYX_LOG"/error.log

    {
        cat < "$DEMYX_TMP"/demyx_trap
        cat < "$DEMYX_TMP"/demyx_trace
    } > "$DEMYX_TMP"/demyx_log_error

    demyx_notification error "$DEMYX_ARGS"
}
#
#   Event logs.
#
demyx_event() {
    local DEMYX_EVENT=

    {
        echo -en "[$(date +%F-%T)][${DEMYX_ARGS}]"
        for DEMYX_EVENT in "${FUNCNAME[@]}"; do
            [[ "$DEMYX_EVENT" = demyx || "$DEMYX_EVENT" = main ]] && continue
            echo -en "[${DEMYX_EVENT}]"
        done
        echo

        # TODO
        #echo -en "[$(date +%F-%T)]"
        #for DEMYX_EVENT in $DEMYX_ARGS; do
        #    echo -en "[$DEMYX_EVENT]"
        #done
    } >> "$DEMYX_LOG"/demyx.log
}
#
#   TODO
#   Validates IP addresses.
#
demyx_validate_ip() {
    demyx_event
    local DEMYX_VALIDATE_IP="${1:-}"
    echo "$DEMYX_VALIDATE_IP" |
    grep -E '(([0-9]{1,3})\.){3}([0-9]{1,3}){1}' |
    grep -vE '25[6-9]|2[6-9][0-9]|[3-9][0-9][0-9]' |
    grep -Eo '(([0-9]{1,2}|1[0-9]{1,2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]{1,2}|1[0-9]{1,2}|2[0-4][0-9]|25[0-5]){1}'
}
#
#   Echos WARNING messages.
#
demyx_warning() {
    demyx_event
    local DEMYX_WARNING="\e[33m[WARNING]\e[39m ${1:-}"
    local DEMYX_WARNING_EXIT="${2:-}"

    echo -e "$DEMYX_WARNING"

    if [[ "$DEMYX_WARNING_EXIT" = true ]]; then
        exit
    fi
}
#
#   Loop checks a connection to WordPress and exits when a connection is successful.
#
demyx_wordpress_ready() {
    demyx_event
    demyx_app_env wp DEMYX_APP_WP_CONTAINER

    local DEMYX_WORDPRESS_READY=0
    local DEMYX_WORDPRESS_READY_MESSAGE="Something is wrong with the WP container, docker logs has been attached"

    until docker exec "$DEMYX_APP_WP_CONTAINER" wp core is-installed 2>/dev/null; do
        DEMYX_WORDPRESS_READY="$((DEMYX_WORDPRESS_READY+1))"

        if [[ "$DEMYX_WORDPRESS_READY" = 10 ]]; then
            docker logs "$DEMYX_APP_WP_CONTAINER"
            demyx_error custom "$DEMYX_WORDPRESS_READY_MESSAGE"
        else
            sleep 1
        fi
    done
}
