# Demyx
# https://demyx.sh

function demyx_php_fpm() {
    demyx_app_config

    if [[ "$DEMYX_APP_TYPE" = wp ]]; then
        cat > "$DEMYX_APP_CONFIG"/php-fpm.conf <<-EOF
            ; AUTO GENERATED
            
            [www]
            user = www-data
            group = www-data
            listen = 127.0.0.1:9000

            pm = ondemand
            pm.max_children = 75
            pm.start_servers = 2
            pm.min_spare_servers = 1
            pm.max_spare_servers = 3
            pm.process_idle_timeout = 10s
            pm.max_requests = 500
            chdir = /var/www/html
            catch_workers_output = yes

            php_admin_value[error_log] = /var/log/demyx/$DEMYX_APP_DOMAIN.error.log
EOF
        sed -i 's/            //' "$DEMYX_APP_CONFIG"/php-fpm.conf
    fi
}
