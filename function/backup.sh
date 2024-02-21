# Demyx
# https://demyx.sh
# shellcheck shell=bash

#
#   demyx backup <app> <args>
#
demyx_backup() {
    demyx_event
    DEMYX_ARG_2="${1:-$DEMYX_ARG_2}"
    shift && local DEMYX_BACKUP_ARGS="$*"
    local DEMYX_BACKUP_FLAG=
    local DEMYX_BACKUP_FLAG_CONFIG=
    local DEMYX_BACKUP_FLAG_DB=
    local DEMYX_BACKUP_FLAG_LIST=
    local DEMYX_BACKUP_FLAG_PATH=

    demyx_source wp

    while :; do
        DEMYX_BACKUP_FLAG="${1:-}"
        case "$DEMYX_BACKUP_FLAG" in
            -c)
                DEMYX_BACKUP_FLAG_CONFIG=true
            ;;
            -d)
                DEMYX_BACKUP_FLAG_DB=true
            ;;
            -l)
                DEMYX_BACKUP_FLAG_LIST=true
            ;;
            --path=?*)
                DEMYX_BACKUP_FLAG_PATH="${DEMYX_BACKUP_FLAG#*=}"
            ;;
            --path=)
                demyx_error flag-empty "$DEMYX_BACKUP_FLAG"
            ;;
            --)
                shift
                break
            ;;
            -?*)
                demyx_error flag "$DEMYX_BACKUP_FLAG"
            ;;
            *)
                break
        esac
        shift
    done

    case "$DEMYX_ARG_2" in
        all)
            demyx_backup_all
        ;;
        *)
            demyx_arg_valid

            if [[ "$DEMYX_BACKUP_FLAG_CONFIG" = true ]]; then
                demyx_backup_config
            elif [[ "$DEMYX_BACKUP_FLAG_DB" = true ]]; then
                demyx_backup_db
            elif [[ "$DEMYX_BACKUP_FLAG_LIST" = true ]]; then
                demyx_backup_list
            else
                if [[ -n "$DEMYX_ARG_2" ]]; then
                    demyx_backup_app
                else
                    demyx_help backup
                fi
            fi
        ;;
    esac
}
#
#   Loop for demyx_backup_app.
#
demyx_backup_all() {
    local DEMYX_BACKUP_ALL=
    local DEMYX_BACKUP_ALL_CHECK=
    local DEMYX_BACKUP_ALL_CHECK_WP=

    cd "$DEMYX_WP" || exit

    for DEMYX_BACKUP_ALL in *; do
        demyx_event
        DEMYX_ARG_2="$DEMYX_BACKUP_ALL"
        DEMYX_BACKUP_ALL_CHECK=0

        demyx_app_env wp DEMYX_APP_WP_CONTAINER
        demyx_echo "Backing up $DEMYX_BACKUP_ALL"

        DEMYX_BACKUP_ALL_CHECK_WP="$(docker exec "$DEMYX_APP_WP_CONTAINER" "wp core is-installed" 2>&1 || true)"
        if [[ "$DEMYX_BACKUP_ALL_CHECK_WP" == *"Error"* ||
                "$DEMYX_BACKUP_ALL_CHECK_WP" == *"error"* ]]; then
            DEMYX_BACKUP_ALL_CHECK=1
        fi

        if [[ "$DEMYX_BACKUP_ALL_CHECK" = 1 ]]; then
            demyx_warning "$DEMYX_ARG_2 has one or more errors. Please check error log, skipping ..."
            continue
        else
            eval demyx_backup "$DEMYX_BACKUP_ALL" "$DEMYX_BACKUP_ARGS"
        fi
    done
}
#
#   Main backup function.
#
demyx_backup_app() {
    demyx_event
    local DEMYX_BACKUP_TODAYS_DATE=
    DEMYX_BACKUP_TODAYS_DATE="$(date +%Y-%m-%d)"

    demyx_app_env wp "
        DEMYX_APP_BACKUP
        DEMYX_APP_CONTAINER
        DEMYX_APP_DOMAIN
        DEMYX_APP_ID
        DEMYX_APP_PATH
        DEMYX_APP_TYPE
        DEMYX_APP_WP_CONTAINER
    "

    if [[ "$DEMYX_APP_BACKUP" = true ]]; then
        demyx_backup_config

        # shellcheck disable=SC2153
        if [[ ! -d "$DEMYX_BACKUP_WP"/"$DEMYX_APP_DOMAIN" ]]; then
            mkdir -p "$DEMYX_BACKUP_WP"/"$DEMYX_APP_DOMAIN"
        fi

        if [[ ! -d "$DEMYX_TMP"/"$DEMYX_APP_DOMAIN" ]]; then
            cp -rp "$DEMYX_WP"/"$DEMYX_APP_DOMAIN" "$DEMYX_TMP"
        fi

        if [[ "$DEMYX_APP_TYPE" = wp ]]; then
            demyx_execute "Exporting ${DEMYX_APP_CONTAINER}.sql" \
                "demyx_wp ${DEMYX_APP_DOMAIN} db export ${DEMYX_APP_CONTAINER}.sql"

            demyx_execute "Exporting ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}" \
                "docker cp ${DEMYX_APP_WP_CONTAINER}:/demyx ${DEMYX_TMP}/${DEMYX_APP_DOMAIN}/demyx-wp"
        fi

        demyx_execute "Exporting ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_log" \
            "docker cp ${DEMYX_APP_WP_CONTAINER}:/var/log/demyx ${DEMYX_TMP}/${DEMYX_APP_DOMAIN}/demyx-log"

        demyx_execute "Exporting ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_code" \
            "docker run -t \
                --rm \
                --entrypoint=bash \
                -v demyx:$DEMYX \
                -v ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_code:/${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_code \
                demyx/utilities -c 'cp -rp /${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_code ${DEMYX_TMP}/${DEMYX_APP_DOMAIN}/demyx-code'"

        demyx_execute "Exporting ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_custom" \
            "docker cp ${DEMYX_APP_WP_CONTAINER}:/etc/demyx/custom ${DEMYX_TMP}/${DEMYX_APP_DOMAIN}/demyx-custom"

        demyx_execute "Exporting ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_sftp" \
            "docker run -t \
                --rm \
                --entrypoint=bash \
                -v demyx:$DEMYX \
                -v ${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_sftp:/${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_sftp \
                demyx/utilities -c 'cp -rp /${DEMYX_APP_TYPE}_${DEMYX_APP_ID}_sftp ${DEMYX_TMP}/${DEMYX_APP_DOMAIN}/demyx-sftp'"

        demyx_execute "Archiving directory" \
            "demyx_proper ${DEMYX_TMP}/${DEMYX_APP_DOMAIN}; \
            tar -czf ${DEMYX_TMP}/${DEMYX_BACKUP_TODAYS_DATE}-${DEMYX_APP_DOMAIN}.tgz -C $DEMYX_TMP ${DEMYX_APP_DOMAIN}; \
            mv ${DEMYX_TMP}/${DEMYX_BACKUP_TODAYS_DATE}-${DEMYX_APP_DOMAIN}.tgz ${DEMYX_BACKUP_WP}/${DEMYX_APP_DOMAIN}"

        if [[ -n "$DEMYX_BACKUP_FLAG_PATH" ]]; then
            demyx_execute "Moving backup to $DEMYX_BACKUP_FLAG_PATH" \
                "mkdir -p ${DEMYX_BACKUP_FLAG_PATH}; \
                mv ${DEMYX_BACKUP_WP}/${DEMYX_APP_DOMAIN}/${DEMYX_BACKUP_TODAYS_DATE}-${DEMYX_APP_DOMAIN}.tgz $DEMYX_BACKUP_FLAG_PATH"
        fi

        if [[ "$DEMYX_APP_TYPE" = wp ]]; then
            demyx_execute "Cleaning up" \
                "docker exec -t $DEMYX_APP_WP_CONTAINER rm -f ${DEMYX_APP_CONTAINER}.sql; \
                rm -rf ${DEMYX_TMP}/${DEMYX_APP_DOMAIN}"
        fi
    else
        demyx_warning "$DEMYX_APP_DOMAIN has backups disabled, skipping ..."
    fi
}
#
#   Backup config only.
#
demyx_backup_config() {
    demyx_event
    demyx_app_env wp DEMYX_APP_DOMAIN

    if [[ ! -d "$DEMYX_BACKUP"/config ]]; then
        mkdir -p "$DEMYX_BACKUP"/config
    fi

    demyx_execute "Backing up configs" \
        "tar -czf ${DEMYX_BACKUP}/config/${DEMYX_APP_DOMAIN}.tgz -C $DEMYX_WP $DEMYX_APP_DOMAIN"
}
#
#   Backup database only.
#
demyx_backup_db() {
    demyx_event
    demyx_app_env wp "
        DEMYX_APP_CONTAINER
        DEMYX_APP_DOMAIN
        DEMYX_APP_TYPE
    "

    local DEMYX_BACKUP_DB="Backing up database"

    if [[ -n "${DEMYX_BACKUP_ALL:-}" ]]; then
        DEMYX_BACKUP_DB=false
    fi

    if [[ "$DEMYX_APP_TYPE" = wp ]]; then
        demyx_execute "$DEMYX_BACKUP_DB" \
            "demyx_wp ${DEMYX_APP_DOMAIN} db export ${DEMYX_APP_CONTAINER}.sql"
    fi
}
#
#   List app's backups.
#
demyx_backup_list() {
    demyx_event
    local DEMYX_BACKUP_LIST="$DEMYX_TMP"/demyx_transient
    local DEMYX_BACKUP_LIST_COUNT=
    local DEMYX_BACKUP_LIST_TOTAL_SIZE=
    local DEMYX_BACKUP_LIST_I=

    DEMYX_BACKUP_LIST_COUNT="$(find "$DEMYX_BACKUP_WP"/"$DEMYX_ARG_2" -name "*${DEMYX_ARG_2}.tgz" -type f | wc -l)"
    DEMYX_BACKUP_LIST_TOTAL_SIZE="$(du -sh "$DEMYX_BACKUP_WP"/"$DEMYX_ARG_2" | cut -f1)"

    [[ -f "$DEMYX_BACKUP_LIST" ]] && rm -f "$DEMYX_BACKUP_LIST"

    if [[ "$DEMYX_BACKUP_LIST_COUNT" != 0 ]]; then
        cd "$DEMYX_BACKUP_WP"/"$DEMYX_ARG_2" || exit

        for DEMYX_BACKUP_LIST_I in *;do
            if [[ "$DEMYX_BACKUP_LIST_I" == *".tgz" ]]; then
                {
                    echo "$DEMYX_BACKUP_LIST_I - $(du -sh "$DEMYX_BACKUP_WP"/"$DEMYX_ARG_2"/"$DEMYX_BACKUP_LIST_I" | cut -f1)"
                } >> "$DEMYX_BACKUP_LIST"
            fi
        done
    fi

    demyx_divider_title "DEMYX - BACKUP" "$DEMYX_ARG_2 - Count: $DEMYX_BACKUP_LIST_COUNT - Total Size: $DEMYX_BACKUP_LIST_TOTAL_SIZE"
    cat < "$DEMYX_BACKUP_LIST"
}
