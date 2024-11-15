#!/bin/bash
# Demyx
# https://demyx.sh
set -euo pipefail
#
#   Entrypoint.
#
demyx_entrypoint() {
    # Execute skeletons.
    demyx_entrypoint_skeleton

    # Refresh Traefik.
    demyx refresh traefik

    # Refresh code-server.
    demyx refresh code

    # Execute reset.
    demyx_entrypoint_reset

    # TODO - TEMPORARY
    demyx_entrypoint_www

    # Execute init.
    demyx_entrypoint_init
}
#
#   Init.
#
demyx_entrypoint_init() {
    # TODO - Start api.
    #if [[ "$DEMYX_API" != false ]]; then
    #    demyx_entrypoint_init
        # shellcheck disable=2016
    #    shell2http -log="$DEMYX_LOG"/api.log -form -show-errors -export-all-vars -shell bash /motd 'demyx info system --json --no-volume'
    #else

    # SMTP config
    if [[ "$DEMYX_SMTP" = true ]]; then
        echo "
            AuthPass=$DEMYX_SMTP_PASSWORD
            AuthUser=$DEMYX_SMTP_USERNAME
            FromLineOverride=YES
            UseSTARTTLS=YES
            hostname=$DEMYX_DOMAIN
            mailhub=${DEMYX_SMTP_HOST}:${DEMYX_SMTP_PORT}
            rewriteDomain=$DEMYX_DOMAIN
            root=$DEMYX_EMAIL
        " | sed 's/[[:blank:]]//g' > /etc/ssmtp/ssmtp.conf
    fi

    sudo -E crond -L "$DEMYX_LOG"/cron.log
    sudo -E tail -f "$DEMYX_LOG"/cron.log "$DEMYX_LOG"/demyx.log "$DEMYX_LOG"/error.log
}
#
#   Perform various chmod and chown.
#
demyx_entrypoint_reset() {
    # Reset permissions if /demyx is not empty
    if (( "$(find "$DEMYX" | wc -l)" > 0 )); then
        find "$DEMYX" -type d -exec chmod 0755 {} \;
        find "$DEMYX" -type f -exec chmod 0644 {} \;
    fi

    # Reset permissions if /var/log/demyx is not empty
    if (( "$(find "$DEMYX_LOG" | wc -l)" > 0 )); then
        find "$DEMYX_LOG" -type d -exec chmod 0755 {} \;
        find "$DEMYX_LOG" -type f -exec chmod 0644 {} \;
    fi

    # Reset ownership
    chown -R demyx:demyx "$DEMYX"
    chown -R demyx:demyx "$DEMYX_LOG"
    chown -R root:root /usr/local/bin
}
#
#   Installs or copies missing files/directories.
#
demyx_entrypoint_skeleton() {
    local DEMYX_ENTRYPOINT_SKELETON_I=

    if [[ ! -d "$DEMYX" ]]; then
        install -d -m 0755 -o demyx -g demyx "$DEMYX"
    fi

    if [[ ! -d "$DEMYX_BACKUP" ]]; then
        install -d -m 0755 -o demyx -g demyx "$DEMYX_BACKUP"
    fi

    if [[ ! -d "$DEMYX_BACKUP_WP" ]]; then
        install -d -m 0755 -o demyx -g demyx "$DEMYX_BACKUP_WP"
    fi

    if [[ ! -d "$DEMYX_CODE" ]]; then
        install -d -m 0755 -o demyx -g demyx "$DEMYX_CODE"
    fi

    if [[ ! -d "$DEMYX_CONFIG" ]]; then
        install -d -m 0755 -o demyx -g demyx "$DEMYX_CONFIG"
    fi

    if [[ ! -d "$DEMYX_HTML" ]]; then
        install -d -m 0755 -o demyx -g demyx "$DEMYX_HTML"
    fi

    if [[ ! -d "$DEMYX_LOG" ]]; then
        install -d -m 0755 -o demyx -g demyx "$DEMYX_LOG"
    fi

    if [[ ! -d "$DEMYX_PHP" ]]; then
        install -d -m 0755 -o demyx -g demyx "$DEMYX_PHP"
    fi

    if [[ ! -d "$DEMYX_TMP" ]]; then
        install -d -m 0755 -o demyx -g demyx "$DEMYX_TMP"
    fi

    if [[ ! -d "$DEMYX_TRAEFIK" ]]; then
        install -d -m 0755 -o demyx -g demyx "$DEMYX_TRAEFIK"
    fi

    if [[ ! -d "$DEMYX_WP" ]]; then
        install -d -m 0755 -o demyx -g demyx "$DEMYX_WP"
    fi

    if [[ ! -d "$DEMYX"/custom ]]; then
        cp -r "$DEMYX_CONFIG"/custom "$DEMYX"
    fi

    if [[ -d "$DEMYX"/custom/cron ]]; then
        cd "$DEMYX_CONFIG"/custom/example-cron || exit

        for DEMYX_ENTRYPOINT_SKELETON_I in *; do
            if [[ ! -f "$DEMYX"/custom/cron/"$DEMYX_ENTRYPOINT_SKELETON_I" ]]; then
                cp "$DEMYX_CONFIG"/custom/example-cron/"$DEMYX_ENTRYPOINT_SKELETON_I" "$DEMYX"/custom/cron
            fi
        done
    fi

    if [[ ! -f "$DEMYX_LOG"/api.log ]]; then
        touch "$DEMYX_LOG"/api.log
    fi

    if [[ ! -f "$DEMYX_LOG"/cron.log ]]; then
        touch "$DEMYX_LOG"/cron.log
    fi

    if [[ ! -f "$DEMYX_LOG"/demyx.log ]]; then
        touch "$DEMYX_LOG"/demyx.log
    fi

    if [[ ! -f "$DEMYX_LOG"/error.log ]]; then
        touch "$DEMYX_LOG"/error.log
    fi
}
#
#   # TODO - Check for domains with www and remove it.
#
demyx_entrypoint_www() {
    local DEMYX_ENTRYPOINT_WWW_DB=
    local DEMYX_ENTRYPOINT_WWW_NX=
    local DEMYX_ENTRYPOINT_WWW_STACK=
    local DEMYX_ENTRYPOINT_WWW_WP=
    local DEMYX_ENTRYPOINT_WWW=
    local DEMYX_ENTRYPOINT_WWW_I=

    if [[ -d "$DEMYX_WP" ]]; then
        cd "$DEMYX_WP" || exit

        for DEMYX_ENTRYPOINT_WWW_I in *; do
            if [[ "$DEMYX_ENTRYPOINT_WWW_I" == "www."* ]]; then
                DEMYX_ENTRYPOINT_WWW="${DEMYX_ENTRYPOINT_WWW_I//www./}"
                DEMYX_ENTRYPOINT_WWW_DB="$(grep DEMYX_APP_DB_CONTAINER "$DEMYX_ENTRYPOINT_WWW_I"/.env)"
                DEMYX_ENTRYPOINT_WWW_DB="${DEMYX_ENTRYPOINT_WWW_DB/*=/}"
                DEMYX_ENTRYPOINT_WWW_NX="$(grep DEMYX_APP_NX_CONTAINER "$DEMYX_ENTRYPOINT_WWW_I"/.env)"
                DEMYX_ENTRYPOINT_WWW_NX="${DEMYX_ENTRYPOINT_WWW_NX/*=/}"
                DEMYX_ENTRYPOINT_WWW_STACK="$(grep DEMYX_APP_STACK "$DEMYX_ENTRYPOINT_WWW_I"/.env)"
                DEMYX_ENTRYPOINT_WWW_STACK="${DEMYX_ENTRYPOINT_WWW_STACK/*=/}"
                DEMYX_ENTRYPOINT_WWW_WP="$(grep DEMYX_APP_WP_CONTAINER "$DEMYX_ENTRYPOINT_WWW_I"/.env)"
                DEMYX_ENTRYPOINT_WWW_WP="${DEMYX_ENTRYPOINT_WWW_WP/*=/}"

                cp "$DEMYX_ENTRYPOINT_WWW_I"/.env "$DEMYX_ENTRYPOINT_WWW_I"/.env.bak
                mv "$DEMYX_ENTRYPOINT_WWW_I" "$DEMYX_ENTRYPOINT_WWW"

                if [[ -d "$DEMYX_BACKUP_WP"/"$DEMYX_ENTRYPOINT_WWW_I" ]]; then
                    mv "$DEMYX_BACKUP_WP"/"$DEMYX_ENTRYPOINT_WWW_I" "$DEMYX_BACKUP_WP"/"$DEMYX_ENTRYPOINT_WWW"
                fi

                sed -i "
                    s|DEMYX_APP_DOMAIN=.*|DEMYX_APP_DOMAIN=${DEMYX_ENTRYPOINT_WWW}|g
                    s|DEMYX_APP_CONTAINER=.*|DEMYX_APP_CONTAINER=${DEMYX_ENTRYPOINT_WWW//[^a-z 0-9 A-Z]/_}|g
                    s|DEMYX_APP_PATH=.*|DEMYX_APP_PATH=|g
                    s|DEMYX_APP_COMPOSE_PROJECT=.*|DEMYX_APP_COMPOSE_PROJECT=${DEMYX_ENTRYPOINT_WWW//[^a-z 0-9 A-Z -]/}|g
                    s|DEMYX_APP_DB_CONTAINER=.*|DEMYX_APP_DB_CONTAINER=|g
                    s|DEMYX_APP_NX_CONTAINER=.*|DEMYX_APP_NX_CONTAINER=|g
                    s|DEMYX_APP_WP_CONTAINER=.*|DEMYX_APP_WP_CONTAINER=|g
                    s|WORDPRESS_USER_EMAIL=.*|WORDPRESS_USER_EMAIL=|g
                " "$DEMYX_ENTRYPOINT_WWW"/.env
                echo "DEMYX_APP_DOMAIN_WWW=true" >> "$DEMYX_ENTRYPOINT_WWW"/.env

                if [[ "$DEMYX_ENTRYPOINT_WWW_STACK" = nginx-php || "$DEMYX_ENTRYPOINT_WWW_STACK" = bedrock ]]; then
                    docker stop "$DEMYX_ENTRYPOINT_WWW_NX"
                    docker rm "$DEMYX_ENTRYPOINT_WWW_NX"
                fi

                docker stop "$DEMYX_ENTRYPOINT_WWW_DB" "$DEMYX_ENTRYPOINT_WWW_WP"
                docker rm "$DEMYX_ENTRYPOINT_WWW_DB" "$DEMYX_ENTRYPOINT_WWW_WP"
                demyx refresh "$DEMYX_ENTRYPOINT_WWW"
            fi
        done

        cd - || exit
    fi
}
#
#   Execute.
#
demyx_entrypoint
