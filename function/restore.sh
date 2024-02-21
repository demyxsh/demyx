# Demyx
# https://demyx.sh
# shellcheck shell=bash

#
#   demyx restore <app> <args>
#
demyx_restore() {
    demyx_event
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
    demyx_event
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
        docker volume create ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_custom; \
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
            -v wp_${DEMYX_APP_ID}_custom:/etc/demyx/custom \
            -v wp_${DEMYX_APP_ID}_log:/var/log/demyx \
            demyx/wordpress; \
        docker cp ${DEMYX_APP_PATH}/demyx-wp/. ${DEMYX_APP_WP_CONTAINER}:/demyx; \
        docker cp ${DEMYX_APP_PATH}/demyx-custom/. ${DEMYX_APP_WP_CONTAINER}:/etc/demyx/custom; \
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
        rm -rf ${DEMYX_APP_PATH}/demyx-custom; \
        rm -rf ${DEMYX_APP_PATH}/demyx-sftp; \
        rm -rf ${DEMYX_TMP}/${DEMYX_APP_DOMAIN}; \
        docker exec -t $DEMYX_APP_WP_CONTAINER rm -f /demyx/${DEMYX_APP_CONTAINER}.sql"

    demyx_info "$DEMYX_APP_DOMAIN" -l
}
#
#   Restore app's directory only.
#
demyx_restore_config() {
    demyx_event
    local DEMYX_RESTORE_CONFIG_FILE=
    DEMYX_RESTORE_CONFIG_FILE="$(find "$DEMYX_BACKUP"/config -type f -name "${DEMYX_ARG_2}.tgz")"

    if [[ -n "$DEMYX_RESTORE_CONFIG_FILE" ]]; then
        demyx_execute "Restoring configs" \
            "tar -xzf $DEMYX_RESTORE_CONFIG_FILE -C $DEMYX_WP"
    else
        demyx_error file "$DEMYX_RESTORE_CONFIG_FILE"
    fi

    demyx_compose "$DEMYX_ARG_2" up -d --remove-orphans
}
#
#   Restore app's database only.
#
demyx_restore_db() {
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_CONTAINER
        DEMYX_APP_DOMAIN
        DEMYX_APP_DB_CONTAINER
        DEMYX_APP_ID
        DEMYX_APP_NX_CONTAINER
        DEMYX_APP_STACK
        DEMYX_APP_WP_CONTAINER
    "

    local DEMYX_RESTORE_DB_CHECK=
    local DEMYX_RESTORE_DB_CHECK_BACKUP=
    local DEMYX_RESTORE_DB_CHECK_WP=

    if [[ -z "$DEMYX_RESTORE_FLAG_FORCE" ]]; then
        DEMYX_RESTORE_DB_CHECK_WP="$(docker exec "$DEMYX_APP_WP_CONTAINER" wp core is-installed 2>&1 || true)"
        if [[ "$DEMYX_RESTORE_DB_CHECK_WP" == *"Error"* ||
                "$DEMYX_RESTORE_DB_CHECK_WP" == *"error"* ]]; then
            demyx_logger "Backing up database of $DEMYX_APP_DOMAIN" "demyx_backup $DEMYX_APP_DOMAIN $DEMYX_RESTORE_FLAG" "$DEMYX_RESTORE_DB_CHECK_WP" error
            demyx_error custom "$DEMYX_ARG_2 has one or more errors. Please check error log."
        fi
    fi

    DEMYX_RESTORE_DB_CHECK="$(docker exec "$DEMYX_APP_WP_CONTAINER" ls | grep "${DEMYX_APP_CONTAINER}.sql" || true)"

    if [[ -z "$DEMYX_RESTORE_DB_CHECK" ]]; then
        DEMYX_RESTORE_DB_CHECK_BACKUP="$(find "$DEMYX_BACKUP_WP"/"$DEMYX_APP_DOMAIN" -type f -name "*${DEMYX_APP_DOMAIN}.tgz" | sort -r | head -n1)"

        demyx_echo "No database found, using latest backup ..."

        if [[ -f "$DEMYX_RESTORE_DB_CHECK_BACKUP" ]]; then
            demyx_execute "File found, extracting" \
                "tar -xzf $DEMYX_RESTORE_DB_CHECK_BACKUP -C $DEMYX_TMP; \
                    demyx_proper ${DEMYX_TMP}/${DEMYX_APP_DOMAIN}"

            demyx_execute "Copying database" \
                "docker cp ${DEMYX_TMP}/${DEMYX_APP_DOMAIN}/demyx-wp/${DEMYX_APP_CONTAINER}.sql ${DEMYX_APP_WP_CONTAINER}:/demyx; \
                    rm -rf ${DEMYX_TMP}/${DEMYX_APP_DOMAIN}"
        fi
    fi

    if [[ "$DEMYX_APP_STACK" = nginx-php || "$DEMYX_APP_STACK" = openlitespeed ]]; then
        demyx_execute "Putting WordPress into maintenance mode" \
            "docker exec -t $DEMYX_APP_WP_CONTAINER sh -c \"echo '<?php \\\$upgrading = time(); ?>' > .maintenance\""
    elif [[ "$DEMYX_APP_STACK" = bedrock || "$DEMYX_APP_STACK" = ols-bedrock ]]; then
        demyx_execute "Putting WordPress into maintenance mode" \
            "docker exec -t $DEMYX_APP_WP_CONTAINER sh -c \"echo '<?php \\\$upgrading = time(); ?>' > web/wp/.maintenance\""
    fi

    demyx_config "$DEMYX_APP_DOMAIN" --healthcheck=false

    demyx_execute "Deleting old database" \
        "docker stop ${DEMYX_APP_DB_CONTAINER}; \
            docker rm ${DEMYX_APP_DB_CONTAINER}; \
            docker volume rm wp_${DEMYX_APP_ID}_db"

    demyx_compose "$DEMYX_APP_DOMAIN" -d up -d

    demyx_execute "Installing MariaDB" \
        "demyx_mariadb_ready"

    demyx_execute "Importing database" \
        "demyx_wp $DEMYX_APP_DOMAIN db import ${DEMYX_APP_CONTAINER}.sql"

    #demyx_execute "Importing database" \
    #    "docker exec -t $DEMYX_APP_WP_CONTAINER wp db import ${DEMYX_APP_CONTAINER}.sql"

    demyx_config "$DEMYX_APP_DOMAIN" --healthcheck

    demyx_execute "Cleaning up" \
        "docker exec $DEMYX_APP_WP_CONTAINER rm -f ${DEMYX_APP_CONTAINER}.sql .maintenance"
}
