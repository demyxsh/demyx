#!/bin/bash
# Demyx
# https://github.com/demyxco/demyx

CONTAINER_PATH=$1
DOMAIN=$2
FORCE=$3
CACHE=$4

if [ -f "$CONTAINER_PATH"/conf/nginx.conf ]; then 
  NO_UPDATE=$(grep -r "AUTO GENERATED" "$CONTAINER_PATH"/conf/nginx.conf)
  [[ -z "$NO_UPDATE" ]] && [[ -z "$FORCE" ]] && echo -e "\e[33m[WARNING]\e[39m Skipped nginx.conf" && exit 1
fi

cat > "$CONTAINER_PATH"/conf/nginx.conf <<-EOF
# AUTO GENERATED
# To override, see demyx -h

error_log stderr notice;
error_log /var/log/demyx/$DOMAIN.error.log;
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
  access_log /var/log/demyx/$DOMAIN.access.log main;
  
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
  add_header Feature-Policy "geolocation 'none'; midi 'none'; sync-xhr 'none'; microphone 'none'; camera 'none'; magnetometer 'none'; gyroscope 'none'; speaker 'none'; fullscreen 'self'; payment 'none'; usb 'none'";

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
    access_log /var/log/demyx/$DOMAIN.access.log main;
    error_log stderr notice;
    error_log /var/log/demyx/$DOMAIN.error.log;

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

[[ "$CACHE" = on ]] && sed -i "s|#include|include|g" "$CONTAINER_PATH"/conf/nginx.conf

echo -e "\e[32m[SUCCESS]\e[39m Generated nginx.conf"