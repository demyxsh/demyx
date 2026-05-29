# Demyx
# https://demyx.sh
# shellcheck shell=bash

#
#   demyx cron <args>
#
demyx_cron() {
    demyx_event
    demyx_source "
        backup
        log
        healthcheck
        monitor
        update
        wp
    "

    case "$DEMYX_ARG_2" in
        daily)
            demyx_cron_daily
        ;;
        five-minute)
            demyx_cron_five_minute
        ;;
        hourly)
            demyx_cron_hourly
        ;;
        minute)
            demyx_cron_minute
        ;;
        six-hour)
            demyx_cron_six_hour
        ;;
        weekly)
            demyx_cron_weekly
        ;;
        *)
            demyx_help cron
        ;;
    esac
}
#
#   Daily cron.
#
demyx_cron_daily() {
    demyx_event
    local DEMYX_CRON_DAILY_I=
    local DEMYX_CRON_DAILY_WP_CHECK=

    if [[ "$DEMYX_TELEMETRY" = true ]]; then
        demyx_execute "[CROND DAILY] Pinging home (REST telemetry)" \
            "DEMYX_TELEMETRY_URL=https://demyx.sh/wp-json/demyx/v1/telemetry; \
            DEMYX_TELEMETRY_REGISTER_URL=https://demyx.sh/wp-json/demyx/v1/telemetry/register; \
            DEMYX_TELEMETRY_IDENTITY_DIR=/demyx/.telemetry; \
            DEMYX_TELEMETRY_COMPAT_FALLBACK=true; \
            DEMYX_TELEMETRY_LEGACY_BASE=\${DEMYX_TELEMETRY_URL%%/wp-json*}; \
            DEMYX_TELEMETRY_LEGACY_URL=\${DEMYX_TELEMETRY_LEGACY_URL:-\${DEMYX_TELEMETRY_LEGACY_BASE}/?action=active&version=${DEMYX_VERSION}&token=V1VpdGNPcWNDVlZSUDFQdFBaR0Zhdz09OjrnA1h6ZbDFJ2T6MHOwg3p4}; \
            DEMYX_TELEMETRY_IDENTITY_FILE=\${DEMYX_TELEMETRY_IDENTITY_DIR}/identity.json; \
            DEMYX_TELEMETRY_PRIVATE_KEY_FILE=\${DEMYX_TELEMETRY_IDENTITY_DIR}/private_key.pem; \
            DEMYX_TELEMETRY_PUBLIC_KEY_FILE=\${DEMYX_TELEMETRY_IDENTITY_DIR}/public_key.pem; \
            DEMYX_TELEMETRY_OPENSSL=false; \
            if command -v openssl >/dev/null 2>&1; then \
                DEMYX_TELEMETRY_OPENSSL=true; \
            fi; \
            mkdir -p \"\${DEMYX_TELEMETRY_IDENTITY_DIR}\"; \
            chmod 700 \"\${DEMYX_TELEMETRY_IDENTITY_DIR}\"; \
            if [[ \"\${DEMYX_TELEMETRY_OPENSSL}\" = true && (! -f \"\${DEMYX_TELEMETRY_PRIVATE_KEY_FILE}\" || ! -f \"\${DEMYX_TELEMETRY_PUBLIC_KEY_FILE}\") ]]; then \
                if ! openssl genpkey -algorithm ED25519 -out \"\${DEMYX_TELEMETRY_PRIVATE_KEY_FILE}\" >/dev/null 2>&1; then \
                    echo \"[CROND DAILY] OpenSSL ED25519 key generation failed; skipping TOFU telemetry.\"; \
                    DEMYX_TELEMETRY_OPENSSL=false; \
                elif ! openssl pkey -in \"\${DEMYX_TELEMETRY_PRIVATE_KEY_FILE}\" -pubout -out \"\${DEMYX_TELEMETRY_PUBLIC_KEY_FILE}\" >/dev/null 2>&1; then \
                    echo \"[CROND DAILY] OpenSSL public key export failed; skipping TOFU telemetry.\"; \
                    DEMYX_TELEMETRY_OPENSSL=false; \
                fi; \
            fi; \
            if [[ -f \"\${DEMYX_TELEMETRY_PRIVATE_KEY_FILE}\" ]]; then chmod 600 \"\${DEMYX_TELEMETRY_PRIVATE_KEY_FILE}\"; fi; \
            if [[ -f \"\${DEMYX_TELEMETRY_PUBLIC_KEY_FILE}\" ]]; then chmod 644 \"\${DEMYX_TELEMETRY_PUBLIC_KEY_FILE}\"; fi; \
            if [[ ! -f \"\${DEMYX_TELEMETRY_IDENTITY_FILE}\" ]]; then \
                printf '{\"install_id\":\"\",\"key_id\":\"\",\"registered_at\":0}\n' > \"\${DEMYX_TELEMETRY_IDENTITY_FILE}\"; \
            fi; \
            DEMYX_TELEMETRY_INSTALL_ID=\$(sed -n 's/.*\"install_id\":\"\\([^\"]*\\)\".*/\\1/p' \"\${DEMYX_TELEMETRY_IDENTITY_FILE}\" | head -n1); \
            DEMYX_TELEMETRY_KEY_ID=\$(sed -n 's/.*\"key_id\":\"\\([^\"]*\\)\".*/\\1/p' \"\${DEMYX_TELEMETRY_IDENTITY_FILE}\" | head -n1); \
            DEMYX_TELEMETRY_TIMESTAMP=\$(date +%s); \
            if [[ \"\${DEMYX_TELEMETRY_OPENSSL}\" = true ]]; then \
                DEMYX_TELEMETRY_REQUEST_ID=\$(openssl rand -hex 16 2>/dev/null || date +%s); \
                DEMYX_TELEMETRY_REGISTER_REQUEST_ID=\$(openssl rand -hex 16 2>/dev/null || date +%s); \
            else \
                DEMYX_TELEMETRY_REQUEST_ID=\$(date +%s); \
                DEMYX_TELEMETRY_REGISTER_REQUEST_ID=\$((DEMYX_TELEMETRY_TIMESTAMP + 1)); \
            fi; \
            DEMYX_TELEMETRY_STATUS=0; \
            if [[ \"\${DEMYX_TELEMETRY_OPENSSL}\" = true && (-z \"\${DEMYX_TELEMETRY_INSTALL_ID}\" || -z \"\${DEMYX_TELEMETRY_KEY_ID}\") ]]; then \
                DEMYX_TELEMETRY_PUBLIC_KEY=\$(base64 < \"\${DEMYX_TELEMETRY_PUBLIC_KEY_FILE}\" | tr -d '\n'); \
                DEMYX_TELEMETRY_REGISTER_PAYLOAD=\$(printf '{\"public_key\":\"%s\",\"key_type\":\"ed25519\",\"client_version\":\"%s\",\"request_id\":\"%s\",\"sent_at\":%s}' \"\${DEMYX_TELEMETRY_PUBLIC_KEY}\" \"${DEMYX_VERSION}\" \"\${DEMYX_TELEMETRY_REGISTER_REQUEST_ID}\" \"\${DEMYX_TELEMETRY_TIMESTAMP}\"); \
                DEMYX_TELEMETRY_REGISTER_RESPONSE=\$(curl -sS -X POST \"\${DEMYX_TELEMETRY_REGISTER_URL}\" \
                    -H \"Content-Type: application/json\" \
                    --data \"\${DEMYX_TELEMETRY_REGISTER_PAYLOAD}\" \
                    -w \"\n%{http_code}\"); \
                DEMYX_TELEMETRY_REGISTER_STATUS=\$(echo \"\${DEMYX_TELEMETRY_REGISTER_RESPONSE}\" | tail -n1); \
                DEMYX_TELEMETRY_REGISTER_BODY=\$(echo \"\${DEMYX_TELEMETRY_REGISTER_RESPONSE}\" | sed '\$d'); \
                if [[ \"\${DEMYX_TELEMETRY_REGISTER_STATUS}\" -ge 200 && \"\${DEMYX_TELEMETRY_REGISTER_STATUS}\" -lt 300 ]]; then \
                    DEMYX_TELEMETRY_INSTALL_ID=\$(echo \"\${DEMYX_TELEMETRY_REGISTER_BODY}\" | tr -d '\n' | sed -n 's/.*\"install_id\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p' | head -n1); \
                    DEMYX_TELEMETRY_KEY_ID=\$(echo \"\${DEMYX_TELEMETRY_REGISTER_BODY}\" | tr -d '\n' | sed -n 's/.*\"key_id\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p' | head -n1); \
                    if [[ -n \"\${DEMYX_TELEMETRY_INSTALL_ID}\" && -n \"\${DEMYX_TELEMETRY_KEY_ID}\" ]]; then \
                        printf '{\"install_id\":\"%s\",\"key_id\":\"%s\",\"registered_at\":%s}\n' \"\${DEMYX_TELEMETRY_INSTALL_ID}\" \"\${DEMYX_TELEMETRY_KEY_ID}\" \"\${DEMYX_TELEMETRY_TIMESTAMP}\" > \"\${DEMYX_TELEMETRY_IDENTITY_FILE}\"; \
                    else \
                        echo \"[CROND DAILY] Register response missing install_id/key_id.\"; \
                    fi; \
                else \
                    echo \"[CROND DAILY] Register request failed with HTTP \${DEMYX_TELEMETRY_REGISTER_STATUS}.\"; \
                fi; \
            fi; \
            if [[ \"\${DEMYX_TELEMETRY_OPENSSL}\" = true && -n \"\${DEMYX_TELEMETRY_INSTALL_ID}\" && -n \"\${DEMYX_TELEMETRY_KEY_ID}\" ]]; then \
                DEMYX_TELEMETRY_ATTEMPT=1; \
                while [[ \${DEMYX_TELEMETRY_ATTEMPT} -le 3 ]]; do \
                    DEMYX_TELEMETRY_TIMESTAMP=\$(date +%s); \
                    DEMYX_TELEMETRY_REQUEST_ID=\$(openssl rand -hex 16 2>/dev/null || printf \"%s%s\" \"\${DEMYX_TELEMETRY_TIMESTAMP}\" \"\${DEMYX_TELEMETRY_ATTEMPT}\"); \
                    DEMYX_TELEMETRY_PAYLOAD=\$(printf '{\"version\":\"%s\",\"request_id\":\"%s\",\"sent_at\":%s}' \"${DEMYX_VERSION}\" \"\${DEMYX_TELEMETRY_REQUEST_ID}\" \"\${DEMYX_TELEMETRY_TIMESTAMP}\"); \
                    DEMYX_TELEMETRY_BODY_HASH=\$(printf \"%s\" \"\${DEMYX_TELEMETRY_PAYLOAD}\" | openssl dgst -sha256 -r | awk '{print \$1}' || true); \
                    DEMYX_TELEMETRY_SIGNING_STRING=\"\${DEMYX_TELEMETRY_TIMESTAMP}.\${DEMYX_TELEMETRY_REQUEST_ID}.\${DEMYX_TELEMETRY_BODY_HASH}\"; \
                    DEMYX_TELEMETRY_SIGN_FILE=\"\${DEMYX_TELEMETRY_IDENTITY_DIR}/signing_input.txt\"; \
                    DEMYX_TELEMETRY_SIG_FILE=\"\${DEMYX_TELEMETRY_IDENTITY_DIR}/signature.bin\"; \
                    DEMYX_TELEMETRY_SIG_ERR=\"\${DEMYX_TELEMETRY_IDENTITY_DIR}/signature.err\"; \
                    printf \"%s\" \"\${DEMYX_TELEMETRY_SIGNING_STRING}\" > \"\${DEMYX_TELEMETRY_SIGN_FILE}\"; \
                    : > \"\${DEMYX_TELEMETRY_SIG_ERR}\"; \
                    if openssl pkeyutl -sign -inkey \"\${DEMYX_TELEMETRY_PRIVATE_KEY_FILE}\" -rawin -in \"\${DEMYX_TELEMETRY_SIGN_FILE}\" -out \"\${DEMYX_TELEMETRY_SIG_FILE}\" 2>\"\${DEMYX_TELEMETRY_SIG_ERR}\"; then \
                        DEMYX_TELEMETRY_SIGNATURE=\$(base64 < \"\${DEMYX_TELEMETRY_SIG_FILE}\" | tr -d '\r\n' || true); \
                    else \
                        DEMYX_TELEMETRY_SIGNATURE=; \
                    fi; \
                    rm -f \"\${DEMYX_TELEMETRY_SIGN_FILE}\" \"\${DEMYX_TELEMETRY_SIG_FILE}\"; \
                    if [[ -z \"\${DEMYX_TELEMETRY_SIGNATURE}\" ]]; then \
                        echo \"[CROND DAILY] Failed to sign telemetry payload; skipping signed REST telemetry.\"; \
                        rm -f \"\${DEMYX_TELEMETRY_SIG_ERR}\"; \
                        break; \
                    fi; \
                    rm -f \"\${DEMYX_TELEMETRY_SIG_ERR}\"; \
                    DEMYX_TELEMETRY_STATUS=\$(curl -sS -X POST \"\${DEMYX_TELEMETRY_URL}\" \
                        -H \"Content-Type: application/json\" \
                        -H \"X-Demyx-Install-Id: \${DEMYX_TELEMETRY_INSTALL_ID}\" \
                        -H \"X-Demyx-Key-Id: \${DEMYX_TELEMETRY_KEY_ID}\" \
                        -H \"X-Demyx-Timestamp: \${DEMYX_TELEMETRY_TIMESTAMP}\" \
                        -H \"X-Demyx-Request-Id: \${DEMYX_TELEMETRY_REQUEST_ID}\" \
                        -H \"X-Demyx-Signature: \${DEMYX_TELEMETRY_SIGNATURE}\" \
                        -H \"X-Demyx-Signature-Alg: ed25519\" \
                        --data \"\${DEMYX_TELEMETRY_PAYLOAD}\" \
                        -o /dev/null -w \"%{http_code}\"); \
                    if [[ \"\${DEMYX_TELEMETRY_STATUS}\" -ge 200 && \"\${DEMYX_TELEMETRY_STATUS}\" -lt 300 ]]; then \
                        break; \
                    fi; \
                    echo \"[CROND DAILY] Telemetry attempt \${DEMYX_TELEMETRY_ATTEMPT} failed with HTTP \${DEMYX_TELEMETRY_STATUS}\"; \
                    sleep \$((DEMYX_TELEMETRY_ATTEMPT * 2)); \
                    DEMYX_TELEMETRY_ATTEMPT=\$((DEMYX_TELEMETRY_ATTEMPT + 1)); \
                done; \
            else \
                if [[ \"\${DEMYX_TELEMETRY_OPENSSL}\" != true ]]; then \
                    echo \"[CROND DAILY] OpenSSL unavailable; skipping TOFU telemetry and using compatibility fallback if enabled.\"; \
                else \
                    echo \"[CROND DAILY] Missing telemetry install identity; skipping signed REST telemetry.\"; \
                fi; \
            fi; \
            if [[ ! \"\${DEMYX_TELEMETRY_STATUS}\" -ge 200 || ! \"\${DEMYX_TELEMETRY_STATUS}\" -lt 300 ]]; then \
                if [[ \"\${DEMYX_TELEMETRY_COMPAT_FALLBACK}\" = true ]]; then \
                    echo \"[CROND DAILY] Falling back to legacy telemetry endpoint.\"; \
                    curl -s \"\${DEMYX_TELEMETRY_LEGACY_URL}\" -o /dev/null -w \"%{http_code}\"; \
                else \
                    echo \"[CROND DAILY] REST telemetry failed and legacy fallback is disabled.\"; \
                fi; \
            fi"
    fi

    # Backup demyx system and configs
    demyx_execute "[CROND DAILY] Backing up system" \
        "mkdir -p ${DEMYX_TMP}/system; \
        cp -pr $DEMYX_APP ${DEMYX_TMP}/system; \
        docker cp demyx_traefik:/demyx ${DEMYX_TMP}/system/traefik; \
        demyx_proper ${DEMYX_TMP}/system; \
        tar -czf ${DEMYX_BACKUP}/system-${DEMYX_HOSTNAME}.tgz -C ${DEMYX_TMP} system; \
        rm -rf ${DEMYX_TMP}/system"

    if [[ "$DEMYX_BACKUP_ENABLE" = true ]]; then
        # Backup WordPress sites at midnight
        demyx_backup all

        # Delete backups older than X amounts of days
        find "$DEMYX_BACKUP_WP" -name "*.tgz" -type f -mtime +"${DEMYX_BACKUP_LIMIT}" -delete
    fi

    # WP auto update
    cd "$DEMYX_WP" || exit

    for DEMYX_CRON_DAILY_I in *; do
        DEMYX_ARG_2="$DEMYX_CRON_DAILY_I"

        demyx_app_env wp "
            DEMYX_APP_STACK
            DEMYX_APP_TYPE
            DEMYX_APP_WP_CONTAINER
            DEMYX_APP_WP_UPDATE
        "

        if [[ "$DEMYX_APP_WP_UPDATE" = true ]]; then
            if [[ "$DEMYX_APP_STACK" = bedrock || "$DEMYX_APP_STACK" = ols-bedrock ]]; then
                demyx_execute "[CROND DAILY - ${DEMYX_CRON_DAILY_I}] Executing composer update" \
                    "docker exec -t $DEMYX_APP_WP_CONTAINER composer update --no-interaction"
            else
                demyx_execute "[CROND DAILY - ${DEMYX_CRON_DAILY_I}] Updating WordPress core, themes, and plugins" \
                    "demyx_wp $DEMYX_CRON_DAILY_I core update; \
                    demyx_wp $DEMYX_CRON_DAILY_I plugin update --all"

                # A roundabout way to handle wp-cli nonexistent error
                DEMYX_CRON_DAILY_WP_CHECK="$(docker exec "$DEMYX_APP_WP_CONTAINER" wp theme update --all 2>&1 || true)"
                if [[ "$DEMYX_CRON_DAILY_WP_CHECK" == *"Success"* || "$DEMYX_CRON_DAILY_WP_CHECK" == *"No themes updated"* ]]; then
                    docker exec "$DEMYX_APP_WP_CONTAINER" wp theme update --all
                else
                    docker exec "$DEMYX_APP_WP_CONTAINER" wp theme update --all
                fi
            fi
        fi
    done

    # Rotate demyx logs
    demyx_execute "[CROND DAILY] Rotating logs" \
        "logrotate --log=${DEMYX_LOG}/logrotate.log ${DEMYX_CONFIG}/logrotate.conf"

    # Execute custom cron
    if [[ -f "$DEMYX"/custom/cron/daily.sh ]]; then
        demyx_execute "[CROND DAILY] Executing ${DEMYX}/custom/cron/daily.sh" \
            "bash ${DEMYX}/custom/cron/daily.sh"
    fi
}
#
#   Every five minute cron.
#
demyx_cron_five_minute() {
    demyx_event
    # Healthchecks
    demyx_execute "[CROND FIVE-MINUTE] Healthcheck - App" \
        "demyx_healthcheck app"
    demyx_execute "[CROND FIVE-MINUTE] Healthcheck - Load" \
        "demyx_healthcheck load"

    # Execute custom cron
    if [[ -f "$DEMYX"/custom/cron/five-minute.sh ]]; then
        demyx_execute "[CROND FIVE-MINUTE] Executing ${DEMYX}/custom/cron/five-minute.sh" \
            "bash ${DEMYX}/custom/cron/five-minute.sh"
    fi
}
#
#   Hourly cron.
#
demyx_cron_hourly() {
    demyx_event

    # Disk healthcheck
    demyx_execute "[CROND DAILY] Healthcheck - Disk" \
        "demyx_healthcheck disk"

    # Execute custom cron
    if [[ -f "$DEMYX"/custom/cron/hourly.sh ]]; then
        demyx_execute "[CROND HOURLY] Executing ${DEMYX}/custom/cron/hourly.sh" \
            "bash ${DEMYX}/custom/cron/hourly.sh"
    fi
}
#
#   Every minute cron.
#
demyx_cron_minute() {
    demyx_event
    # Execute custom cron
    if [[ -f "$DEMYX"/custom/cron/minute.sh ]]; then
        demyx_execute "[CROND MINUTE] Executing ${DEMYX}/custom/cron/minute.sh" \
            "bash ${DEMYX}/custom/cron/minute.sh"
    fi
}
#
#   Every six hour cron.
#
demyx_cron_six_hour() {
    demyx_event
    # Execute custom cron
    if [[ -f "$DEMYX"/custom/cron/six-hour.sh ]]; then
        demyx_execute "[CROND SIX-HOUR] Executing ${DEMYX}/custom/cron/six-hour.sh" \
            "bash ${DEMYX}/custom/cron/six-hour.sh"
    fi
}
#
#   Every week cron.
#
demyx_cron_weekly() {
    demyx_event

    # Check for updates
    demyx_execute "[CROND WEEKLY] Updating cache" \
        "demyx_update"

    # Execute custom cron
    if [[ -f "$DEMYX"/custom/cron/weekly.sh ]]; then
        demyx_execute "[CROND WEEKLY] Executing ${DEMYX}/custom/cron/weekly.sh" \
            "bash ${DEMYX}/custom/cron/weekly.sh"
    fi
}
