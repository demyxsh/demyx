# Demyx
# https://demyx.sh

function demyx_nginx() {
    demyx_app_config

    if [[ "$DEMYX_APP_TYPE" = wp ]]; then
        cat > "$DEMYX_APP_CONFIG"/nginx.conf <<-EOF
            # AUTO GENERATED
            # This file is not used in the docker-compose file so you can edit it.
            # Please run the command below to push it inside the container:
            # demyx config domain.tld --update

            load_module modules/ngx_http_cache_purge_module.so;
            load_module modules/ngx_http_headers_more_filter_module.so;

            error_log stderr notice;
            error_log /var/log/demyx/$DEMYX_APP_DOMAIN.error.log;
            pid /var/run/nginx.pid;

            worker_processes  auto;
            worker_cpu_affinity auto;
            worker_rlimit_nofile 100000;
            pcre_jit on;

            events {
                worker_connections  1024;
                multi_accept on;
                accept_mutex on;
                use epoll;
            }

            http {

                log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                    '\$status \$body_bytes_sent "\$http_referer" '
                    '"\$http_user_agent" "\$http_x_forwarded_for"';

                sendfile on;
                sendfile_max_chunk 512k;

                include    /etc/nginx/mime.types;
                include    /etc/nginx/fastcgi.conf;

                default_type application/octet-stream;

                access_log stdout;
                access_log /var/log/demyx/$DEMYX_APP_DOMAIN.access.log main;

                tcp_nopush   on;
                tcp_nodelay  on;

                keepalive_timeout 8;
                keepalive_requests 500;
                keepalive_disable msie6;

                lingering_time 20s;
                lingering_timeout 5s;

                server_tokens off;
                reset_timedout_connection on;

                add_header X-Powered-By "Demyx";
                add_header X-Frame-Options "SAMEORIGIN";
                add_header X-XSS-Protection  "1; mode=block";
                add_header X-Content-Type-Options "nosniff";
                add_header Referrer-Policy "strict-origin-when-cross-origin";
                add_header X-Download-Options "noopen";
                add_header Feature-Policy "geolocation 'self'; midi 'self'; sync-xhr 'self'; microphone 'self'; camera 'self'; magnetometer 'self'; gyroscope 'self'; speaker 'self'; fullscreen 'self'; payment 'self'; usb 'self'";

                client_max_body_size 128M;
                client_body_temp_path /tmp 1 2;
                fastcgi_temp_path /tmp 1 2;
                fastcgi_read_timeout 120s;

                resolver 1.1.1.1 1.0.0.1 valid=300s;
                resolver_timeout 10;

                gzip off;

                # Limit Request
                limit_req_status 503;
                limit_req_zone \$request_uri zone=one:10m rate=1r/s;

                upstream php {
                    server 127.0.0.1:9000;
                }

                #include /etc/nginx/cache/http.conf;

                server {
                    listen       80;
                    root /var/www/html;
                    index  index.php index.html index.htm;
                    access_log stdout;
                    access_log /var/log/demyx/$DEMYX_APP_DOMAIN.access.log main;
                    error_log stderr notice;
                    error_log /var/log/demyx/$DEMYX_APP_DOMAIN.error.log;
                    disable_symlinks off;

                    #include /etc/nginx/cache/server.conf;

                    location / {
                        try_files \$uri \$uri/ /index.php?\$args;
                    }

                    location ~ [^/]\.php(/|\$) {
                        fastcgi_split_path_info ^(.+?\.php)(/.*)\$;
                        if (!-f \$document_root\$fastcgi_script_name) {
                            return 404;
                        }
                        fastcgi_pass php;
                        fastcgi_index index.php;
                        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
                        include fastcgi_params;
                        limit_req zone=one burst=5 nodelay;
                        #include /etc/nginx/cache/location.conf;
                    }

                    include /etc/nginx/common/*.conf;
                }
            }
EOF
        sed -i 's/            //' "$DEMYX_APP_CONFIG"/nginx.conf
    fi
}
