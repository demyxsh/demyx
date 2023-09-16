# Demyx
# https://demyx.sh
#
#   demyx restore <app> <args>
#
demyx_restore() {
    DEMYX_ARG_2="${1:-$DEMYX_ARG_2}"
    local DEMYX_RESTORE_CHECK=
    local DEMYX_RESTORE_FLAG=
    local DEMYX_RESTORE_FLAG_CONFIG=
    local DEMYX_RESTORE_FLAG_DATE=
    local DEMYX_RESTORE_FLAG_DB=
    local DEMYX_RESTORE_FLAG_FORCE=

    demyx_source "
        backup
        config
        compose
        info
        rm
        wp
    "

    while :; do
        DEMYX_RESTORE_FLAG="${2:-}"
        case "$DEMYX_RESTORE_FLAG" in
            -c)
                DEMYX_RESTORE_FLAG_CONFIG=true
            ;;
            --date=?*)
                DEMYX_RESTORE_FLAG_DATE="${DEMYX_RESTORE_FLAG#*=}"
            ;;
            -d)
                DEMYX_RESTORE_FLAG_DB=true
            ;;
            -f)
                DEMYX_RESTORE_FLAG_FORCE=true
            ;;
            --)
                shift
                break
                ;;
            -?*)
                demyx_error flag "$DEMYX_RESTORE_FLAG"
            ;;
            *)
                break
        esac
        shift
    done

    DEMYX_RESTORE_CHECK="$(find "$DEMYX_BACKUP" -type f -name "*${DEMYX_ARG_2}*.tgz" )"

    if [[ -n "$DEMYX_ARG_2" ]]; then
        if [[ "$DEMYX_RESTORE_FLAG_DB" = true ]]; then
            demyx_restore_db
        elif [[ -n "$DEMYX_RESTORE_CHECK" ]]; then
            if [[ "$DEMYX_RESTORE_FLAG_CONFIG" = true ]]; then
                demyx_restore_config
            else
                demyx_restore_app
            fi
        else
            demyx_error custom "No backups found for $DEMYX_ARG_2"
        fi
    else
        demyx_help restore
    fi
}
#
#   Main restore function.
#
demyx_restore_app() {
    local DEMYX_RESTORE_APP_CHECK=
    DEMYX_RESTORE_APP_CHECK="$(demyx_app_path "$DEMYX_ARG_2")"
    local DEMYX_RESTORE_APP_DATE=
    DEMYX_RESTORE_APP_DATE="$(date +%Y-%m-%d)"
    local DEMYX_RESTORE_APP_FIND_DATE=
    local DEMYX_RESTORE_APP_FIND_FILE=
    local DEMYX_RESTORE_APP_FIND_PATH=

    if [[ -n "$DEMYX_RESTORE_FLAG_DATE" ]]; then
        DEMYX_RESTORE_APP_FIND_FILE="${DEMYX_RESTORE_FLAG_DATE}-${DEMYX_ARG_2}.tgz"
    else
        DEMYX_RESTORE_APP_FIND_FILE="${DEMYX_RESTORE_APP_DATE}-${DEMYX_ARG_2}.tgz"
    fi

    DEMYX_RESTORE_APP_FIND_DATE="$(find "$DEMYX_BACKUP" -type f -name "$DEMYX_RESTORE_APP_FIND_FILE")"

    if [[ -f "$DEMYX_RESTORE_APP_FIND_DATE" ]]; then
        if [[ "$DEMYX_RESTORE_FLAG_FORCE" = true && -n "$DEMYX_RESTORE_APP_CHECK" ]]; then
            demyx_rm "$DEMYX_ARG_2" -f
        elif [[ -n "$DEMYX_RESTORE_APP_CHECK" ]]; then
            demyx_rm "$DEMYX_ARG_2"
        fi

        demyx_execute "Extracting $DEMYX_RESTORE_APP_FIND_DATE" \
            "tar -xzf $DEMYX_RESTORE_APP_FIND_DATE -C ${DEMYX_TMP}; \
            demyx_proper"

        DEMYX_RESTORE_APP_FIND_PATH="$(grep DEMYX_APP_PATH "$DEMYX_TMP"/"$DEMYX_ARG_2"/.env | awk -F '=' '{print $2}')"

        demyx_execute false \
            "mv ${DEMYX_TMP}/${DEMYX_ARG_2} $DEMYX_RESTORE_APP_FIND_PATH"
    else
        demyx_backup "$DEMYX_ARG_2" -l
        demyx_error file "$DEMYX_RESTORE_APP_FIND_FILE"
    fi

    demyx_app_env wp "
        DEMYX_APP_CONTAINER
        DEMYX_APP_DOMAIN
        DEMYX_APP_ID
        DEMYX_APP_PATH
        DEMYX_APP_TYPE
        DEMYX_APP_DB_CONTAINER
        DEMYX_APP_WP_CONTAINER
        WORDPRESS_DB_PASSWORD
        WORDPRESS_DB_USER
    "

    demyx_config "$DEMYX_APP_DOMAIN" --healthcheck=false

    demyx_execute "Creating volumes" \
        "docker volume create ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}; \
        docker volume create ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_code; \
        docker volume create ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_db; \
        docker volume create ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_log; \
        docker volume create ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_sftp"

    if [[ -d "$DEMYX_APP_PATH"/demyx-code ]]; then
        demyx_execute "Restoring ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_code" \
            "docker run -t \
                --rm \
                --entrypoint=bash \
                --user=root \
                -v demyx:$DEMYX \
                -v ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_code:/${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_code \
                demyx/demyx -c 'cp -rp ${DEMYX_APP_PATH}/demyx-code/. /${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_code'"
    fi

    if [[ -d "$DEMYX_APP_PATH"/demyx-sftp ]]; then
        demyx_execute "Restoring ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_sftp" \
            "docker run -t \
                --rm \
                --entrypoint=bash \
                --user=root \
                -v demyx:$DEMYX \
                -v ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_sftp:/${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_sftp \
                demyx/demyx -c 'cp -rp ${DEMYX_APP_PATH}/demyx-sftp/. /${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_sftp'"
    fi

    demyx_compose "$DEMYX_APP_DOMAIN" -d up -d

    demyx_execute "Initializing MariaDB" \
        "demyx_mariadb_ready"

    demyx_execute "Restoring app" \
        "docker run -dit --rm \
            --name=$DEMYX_APP_WP_CONTAINER \
            --network=demyx \
            --entrypoint=bash \
            -v wp_${DEMYX_APP_ID}:/demyx \
            -v wp_${DEMYX_APP_ID}_log:/var/log/demyx \
            demyx/wordpress; \
        docker cp ${DEMYX_APP_PATH}/demyx-wp/. ${DEMYX_APP_WP_CONTAINER}:/demyx; \
        docker cp ${DEMYX_APP_PATH}/demyx-log/. ${DEMYX_APP_WP_CONTAINER}:/var/log/demyx; \
        demyx_wp $DEMYX_APP_DOMAIN db import ${DEMYX_APP_CONTAINER}.sql
        docker exec -t $DEMYX_APP_CONTAINER rm -f /demyx/${DEMYX_APP_CONTAINER}.sql; \
        docker stop $DEMYX_APP_WP_CONTAINER"

    demyx_compose "$DEMYX_APP_DOMAIN" up -d
    demyx_config "$DEMYX_APP_DOMAIN" --healthcheck

    demyx_execute "Cleaning up" \
        "rm -rf ${DEMYX_APP_PATH}/demyx-wp; \
        rm -rf ${DEMYX_APP_PATH}/demyx-log; \
        rm -rf ${DEMYX_APP_PATH}/demyx-code; \
        rm -rf ${DEMYX_APP_PATH}/demyx-sftp; \
        rm -rf ${DEMYX_TMP}/${DEMYX_APP_DOMAIN}; \
        docker exec -t $DEMYX_APP_WP_CONTAINER rm -f /demyx/${DEMYX_APP_CONTAINER}.sql"

    demyx_info "$DEMYX_APP_DOMAIN" -l
}

            demyx_echo 'Restoring files'
            demyx_execute docker cp demyx-wp/. "$DEMYX_APP_WP_CONTAINER":/demyx; \
                docker cp demyx-log/. "$DEMYX_APP_WP_CONTAINER":/var/log/demyx

            demyx_echo 'Restoring database'
            demyx_execute demyx wp "$DEMYX_APP_DOMAIN" db import "$DEMYX_APP_CONTAINER".sql
            
            demyx_echo 'Removing backup database'
            demyx_execute docker exec -t "$DEMYX_APP_WP_CONTAINER" rm -f /demyx/"$DEMYX_APP_CONTAINER".sql

            demyx_echo 'Stopping temporary container'
            demyx_execute docker stop "$DEMYX_APP_WP_CONTAINER"

            demyx compose "$DEMYX_APP_DOMAIN" up -d --remove-orphans
            demyx config "$DEMYX_APP_DOMAIN" --healthcheck

            demyx_echo 'Cleaning up'
            demyx_execute rm -rf "$DEMYX_APP_PATH"/demyx-wp; \
                rm -rf "$DEMYX_APP_PATH"/demyx-log

            demyx info "$DEMYX_APP_DOMAIN"
        fi
    else
        demyx_die --restore-not-found
    fi
}
