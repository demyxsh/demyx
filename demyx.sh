#!/bin/bash
# Demyx
# https://github.com/demyxco/demyx
trap 'exit' ERR
source /srv/demyx/etc/.env
source "$ETC"/functions/misc.sh

if [ "$1" = "stack" ]; then
    while :; do
        case $2 in
            -h|-\?|--help)
                echo
                echo "  --action        Actions: up, down, restart, logs, and other available docker-compose commands"
                echo "                  Example: demyx stack --up, demyx stack --service=traefik --action=restart"
                echo
                echo "  --down          Shorthand for docker-compose down"
                echo "                  Example: demyx stack --service=traefik --down, demyx stack --down"
                echo
                echo "  --refresh       Refreshes the stack's .env and .yml"
                echo "                  Example: demyx stack --refresh"
                echo
                echo "  --restart       Shorthand for docker-compose restart"
                echo "                  Example: demyx stack --service=traefik --restart, demyx stack --restart"
                echo
                echo "  --up            Shorthand for docker-compose up -d"
                echo "                  Example: demyx stack --service=traefik --up, demyx stack --up"
                echo
                echo "  --service       Services: traefik, ouroboros, logrotate"
                echo
                exit 1
                ;;
            --action=?*)
                ACTION=${2#*=} 
                ;;
            --action=)       
                die '"--action" cannot be empty.'
                ;;
            -d|--down)
                DOWN=1
                ACTION=down
                ;;
            --refresh)
                REFRESH=1
                ;;
            -r|--restart)
                RESTART=1
                ACTION=restart
                ;;
            --service=?*)
                SERVICE=${2#*=}
                ;;
            --service=)         
                die '"--service" cannot be empty.'
                ;;
            -u|--up)
                UP=1
                ACTION=up
                ;;
            --)      
                shift
                break
                ;;
            -?*)
                printf '\e[31m[CRITICAL]\e[39m Unknown option: %s\n' "$2" >&2
                exit 1
                ;;
            *) 
                break
        esac
        shift
    done

    cd "$ETC" || exit
    
    if [ "$ACTION" = up ] && [ -n "$SERVICE" ]; then
        docker-compose up -d --remove-orphans "$SERVICE"
    elif [ "$ACTION" = up ] && [ -z "$SERVICE" ]; then
        docker-compose up -d --remove-orphans
    elif [ "$ACTION" = down ] && [ -n "$SERVICE" ]; then
        docker-compose stop "$SERVICE" && docker-compose rm -f "$SERVICE"
    elif [ "$ACTION" = down ] && [ -z "$SERVICE" ]; then
        docker-compose stop && docker-compose rm -f
    elif [ -n "$ACTION" ] && [ -z "$SERVICE" ]; then
        docker-compose $ACTION
    elif [ -n "$ACTION" ] && [ -n "$SERVICE" ]; then
        docker-compose $ACTION "$SERVICE"
    elif [ -n "$REFRESH" ]; then
        echo -e "\e[34m[INFO]\e[39m Refreshing the stack's .env and .yml files"
        
        demyx_echo "Creating the stack's .env" 
        demyx_exec bash "$ETC"/functions/etc-env.sh
        
        demyx_echo "Creating the stack's .yml" 
        demyx_exec bash "$ETC"/functions/etc-yml.sh
        
        demyx stack -u
    fi

elif [ "$1" = "wp" ]; then
    while :; do
        case $2 in
            -h|-\?|--help)
                echo
                echo "  --action        Actions: up, down, restart, logs, and other available docker-compose commands"
                echo "                  Example: demyx wp --dom=domain.tld --service=wp --action=up"
                echo
                echo "  --all           Selects all sites with some flags"
                echo "                  Example: demyx wp --backup --all"
                echo
                echo "  --admin_user    Override the auto generated admin username in --run"
                echo "                  Example: demyx wp --dom=domain.tld --run --admin_user=demo"
                echo
                echo "  --admin_pass    Override the auto generated admin password in --run"
                echo "                  Example: demyx wp --dom=domain.tld --run --admin_pass=demo"
                echo
                echo "  --admin_email   Override the auto generated admin email in --run"
                echo "                  Example: demyx wp --dom=domain.tld --run --admin_email=info@domain.tld"
                echo
                echo "  --backup        Backs up a site to /srv/demyx/backup"
                echo "                  Example: demyx wp --backup=domain.tld, demyx wp --dom=domain.tld --backup"
                echo
                echo "  --cache         Enables FastCGI cache with WordPress plugin helper"
                echo "                  Example: demyx wp --dom=domain.tld --run --cache"
                echo
                echo "  --cdn           Auto install CDN by Staticaly.com"
                echo "                  Example: demyx wp --dom=domain.tld --run --cdn"
                echo
                echo "  --cli           Run commands to containers: wp, db"
                echo "                  Example: demyx wp --dom=domain.tld --cli'ls -al'"
                echo
                echo "  --clone         Clones a site"
                echo "                  Example: demyx wp --dom=new-domain.tld --clone=old-domain.tld --ssl"
                echo
                echo "  --dom           Primary flag to target your sites"
                echo "  --domain        Example: demyx wp --dom=domain.tld --flag"
                echo
                echo "  --dev           Creates a development environment"
                echo "                  BrowserSync & UI, phpMyAdmin, SSH, autover WP plugin, and cache off"
                echo "                  Example: demyx wp --dom=domain.tld --dev, demyx wp --dom=domain.tld --dev=off"
                echo
                echo "  --down          Shorthand for docker-compose down"
                echo "                  Example: demyx wp --down=domain.tld, demyx wp --dom=domain.tld --down"
                echo 
                echo "  --env           Shows all environment variables for a given site"
                echo "                  Example: demyx wp --env=domain.tld, demyx wp --dom=domain.tld --env"
                echo
                echo "  --files         Used with --dev to configure BrowserSync files to watch."
                echo "                  Available options: themes, plugins, or absolute paths"
                echo "                  Example: demyx wp --dom=domain.tld --dev --files=/var/www/html, demyx wp --dom=domain.tld --dev --files=themes"
                echo
                echo "  --force         Force an override, only applies to --refresh for now"
                echo "                  Example: demyx wp --refresh --all --force, demyx wp --dom=domain.tld --refresh --force"
                echo
                echo "  --info          Get detailed info about a site"
                echo "                  Example: demyx wp --dom=domain.tld --info"
                echo
                echo "  --import        Import a non demyx stack WordPress site, must be in a specific format"
                echo "                  - Directory must be named domain.tld"
                echo "                  - Archive must be in /srv/demyx/backup named domain.tld.tgz"
                echo "                  - Database that will be imported must be named import.sql"
                echo "                  Example: demyx wp --dom=domain.tld --import"
                echo
                echo "  --list          List all WordPress sites"
                echo "                  Example: demyx wp --list"
                echo
                echo "  --monitor       Cron flag for auto scaling containers"
                echo
                echo "  --no-restart    Prevents a container from restarting when used with some flags"
                echo "                  Example: demyx wp --dom=domain.tld --run --dev --no-restart"
                echo 
                echo "  --rate-limit    Enable/disable rate limit requests for NGINX"
                echo "                  Example: demyx wp --dom=domain.tld --rate-limit, demyx wp --dom=domain.tld --rate-limit=off"
                echo
                echo "  --refresh       Regenerate all config files for a site; use with caution"
                echo "                  Example: demyx wp --refresh=domain.tld --ssl, demyx wp --dom=domain.tld --refresh --ssl"
                echo
                echo "  --remove        Removes a site"
                echo "                  Example: demyx wp --rm=domain.tld, demyx wp --dom=domain.tld --rm, demyx wp --rm --all"
                echo
                echo "  --restart       Shorthand for --service that loops through all the sites"
                echo "                  Example: demyx wp --restart=wp, demyx wp --restart=nginx-php"
                echo
                echo "  --restore       Restore a site's backup"
                echo "                  Example: demyx wp --restore=domain.tld, demyx wp --dom=domain.tld --restore"
                echo
                echo "  --run           Create a new site"
                echo "                  Example: demyx wp --run=domain.tld --ssl, demyx wp --dom=domain.tld --run --ssl"
                echo
                echo "  --scale         Scale a site's container"
                echo "                  Example: demyx wp --dom=domain.tld --scale=3, demyx wp --dom=domain.tld --service=wp --scale=3"
                echo
                echo "  --service       Selects a service when used with --action"
                echo "                  Available services: wp, db, nginx, php, nginx-php"
                echo "                  Example: demyx wp --dom=domain.tld --action=restart --service=nginx-php"
                echo
                echo "  --shell         Opens a site's shell for the following containers: wp, db, ssh, bs (BrowserSync)"
                echo "                  Example: demyx wp --dom=domain.tld --shell, demyx wp --dom=domain.tld --shell=db"
                echo
                echo "  --ssl           Enables SSL for your domain, provided by Lets Encrypt"
                echo "                  Example: demyx wp --dom=domain.tld --ssl, demyx wp --dom=domain.tld --ssl=off"
                echo
                echo "  --up            Shorthand for docker-compose up -d"
                echo "                  Example: demyx wp --up=domain.tld, demyx wp --dom=domain.tld --up"
                echo 
                echo "  --update        This flag only updates old file structure"
                echo "                  Example: demyx wp --dom=domain.tld --update=structure, demyx wp --update=structure --all"
                echo 
                echo "  --wpcli         Send wp-cli commands to a site"
                echo "                  Example: demyx wp --dom=domain.tld --wpcli='user list' --all"
                echo 
                exit 1
                ;;
            --action=?*)
                ACTION=${2#*=}
                ;;
            --action=)       
                die '"--action" cannot be empty.'
                ;;
            --admin_user=?*)
                ADMIN_USER=${2#*=}
                ;;
            --admin_user=)       
                die '"--admin_user" cannot be empty.'
                ;;
            --admin_pass=?*)
                ADMIN_PASS=${2#*=}
                ;;
            --admin_pass=)       
                die '"--admin_pass" cannot be empty.'
                ;;
            --admin_email=?*)
                ADMIN_EMAIL=${2#*=}
                ;;
            --admin_email=)       
                die '"--admin_email" cannot be empty.'
                ;;
            --all)
                ALL=1
                ;;
            --backup)
                BACKUP=1
                ;;
            --backup=?*)
                DOMAIN=${2#*=}
                BACKUP=1
                ;;
            --backup=)         
                die '"--backup" cannot be empty.'
                ;;
            --cache|--cache=on)
                CACHE=on
                ;;
            --cache=check)
                CACHE=check
                ;;
            --cache=off)
                CACHE=off
                ;;
            --cache=)         
                die '"--cache" cannot be empty.'
                ;;
            --cdn|--cdn=on)
                CDN=on
                ;;
            --cdn=off)
                CDN=off
                ;;
            --cdn=)         
                die '"--cdn" cannot be empty.'
                ;;
            --cli=?*)
                CLI=${2#*=}
                ;;
            --cli=)
                die '"--cli" cannot be empty.'
                ;;
            --clone=?*)
                CLONE=${2#*=}
                ;;
            --clone=)
                die '"--clone" cannot be empty.'
                ;;
            --dev|--dev=on)
                DEV=on
                ;;
            --dev=off)
                DEV=off
                ;;
            --dev=check)
                DEV=check
                ;;
            --dev=)         
                die '"--dev" cannot be empty.'
                ;;
            --dom=?*|--domain=?*)
                DOMAIN=${2#*=}
                ;;
            --dom=|--domain=)         
                die '"--domain" cannot be empty.'
                ;;
            --down)
                ACTION=down
                ;;
            --down=?*)
                DOMAIN=${2#*=}
                ACTION=down
                ;;
            --du)
                DU=1
                ;;
            --du=?*)
                DU=${2#*=}
                ;;
            --du=)         
                die '"--du" cannot be empty.'
                ;;
            --env)
                ENV=1
                ;;
            --env=?*)
                DOMAIN=${2#*=}
                ENV=1
                ;;
            --files=?*)
                FILES=${2#*=}
                ;;
            --files=)         
                die '"--files" cannot be empty.'
                ;;
            -f|--force)
                FORCE=1
                ;;
            --info)
                INFO=1
                ;;
            --import)
                IMPORT=1
                ;;
            --list)
                LIST=1
                ;;
            --monitor)
                MONITOR=1
                ;;
            --no-restart)
                NO_RESTART=1
                ;;
            --port=?*)
                PORT=${2#*=}
                ;;
            --port=)         
                die '"--port" cannot be empty.'
                ;;
            --rate-limit|--rate-limit=on)
                RATE_LIMIT=on
                ;;
            --rate-limit=off)
                RATE_LIMIT=off
                ;;
            --rate-limit=)         
                die '"--rate-limit" cannot be empty.'
                ;;
            --refresh)
                REFRESH=1
                ;;
            --refresh=?*)
                DOMAIN=${2#*=}
                REFRESH=${2#*=}
                ;;
            --refresh=)         
                die '"--refresh" cannot be empty.'
                ;;
            --rm|--remove)
                REMOVE=1
                ;;
            --rm=?*|--remove=?*)
                REMOVE=1
                DOMAIN=${2#*=}
                ;;
            --rm=|--remove=)         
                die '"--rm" cannot be empty.'
                ;;
            --restart)
                RESTART=1
                ;;
            --restart=?*)
                DOMAIN=${2#*=}
                RESTART=${2#*=}
                ;;
            --restart=)         
                die '"--restart" cannot be empty.'
                ;;
            --restore)
                RESTORE=1
                ;;
            --restore=?*)
                DOMAIN=${2#*=}
                RESTORE=1
                ;;
            --run)
                RUN=1
                ;;
            --run=?*)
                RUN=1
                DOMAIN=${2#*=}
                ;;
            --run=)         
                die '"--run" cannot be empty.'
                ;;
            --scale=?*)
                SCALE=${2#*=}
                ;;
            --scale=)         
                die '"--scale" cannot be empty.'
                ;;
            --service=?*)
                SERVICE=${2#*=}
                ;;
            --service=)         
                die '"--service" cannot be empty.'
                ;;
            --shell=?*)
                DEMYX_SHELL=${2#*=}
                ;;
            --shell|--shell=)
                if [ -z "$DEMYX_SHELL" ]; then
                    DEMYX_SHELL="wp"
                fi
                ;;
            --ssl|--ssl=on)
                SSL=on
                ;;
            --ssl=off)
                SSL=off
                ;;
            --ssl=)       
                die '"--ssl" cannot be empty.'
                ;;
            --up)
                ACTION=up
                ;;
            --up=?*)
                DOMAIN=${2#*=}
                ACTION=up
                ;;
            --update=structure)
                UPDATE=structure
                ;;
            --update=)       
                die '"--update" cannot be empty.'
                ;;
            --wpcli=?*)
                WPCLI=${2#*=}
                ;;
            --wpcli=)       
                die '"--wpcli" cannot be empty.'
                ;;
            --)      
                shift
                break
                ;;
            -?*)
                printf '\e[31m[CRITICAL]\e[39m Unknown option: %s\n' "$2" >&2
                exit 1
                ;;
            *) 
                break
        esac
        shift
    done
    
    CONTAINER_PATH=$APPS/$DOMAIN
    CONTAINER_NAME=${DOMAIN//./_}

    if [ -n "$ACTION" ]; then
        [[ ! -d "$CONTAINER_PATH" ]] && die "Domain doesn't exist"

        if [ -z "$ALL" ] && [ -n "$DOMAIN" ]; then
            cd "$CONTAINER_PATH" && source .env
        fi

        if [ "$ACTION" = up ] && [ -n "$SERVICE" ] && [ -n "$DOMAIN" ]; then
            if [ "$SERVICE" = wp ]; then
                docker-compose up -d --remove-orphans wp_"${WP_ID}"
            else
                docker-compose up -d --remove-orphans db_"${WP_ID}"
            fi
        elif [ "$ACTION" = up ] && [ -z "$ALL" ] && [ -n "$DOMAIN" ]; then
            docker-compose up -d --remove-orphans
        elif [ "$ACTION" = up ] && [ -n "$ALL" ]; then
            cd "$APPS" || exit
            for i in *
            do
                WP_CHECK=$(grep -s "WP_ID" "$APPS"/"$i"/.env || true)
                [[ -n "$WP_CHECK" ]] && cd "$APPS"/"$i" && docker-compose up -d --remove-orphans
            done
        elif [ "$ACTION" = down ] && [ -n "$SERVICE" ] && [ -n "$DOMAIN" ]; then
            if [ "$SERVICE" = wp ]; then
                docker-compose stop wp_"${WP_ID}"
                docker-compose rm -f wp_"${WP_ID}"
            else
                docker-compose stop db_"${WP_ID}"
                docker-compose rm -f db_"${WP_ID}"
            fi
        elif [ "$ACTION" = down ] && [ -z "$ALL" ] && [ -n "$DOMAIN" ]; then
            docker-compose stop
            docker-compose rm -f
        elif [ "$ACTION" = down ] && [ -n "$ALL" ]; then
            cd "$APPS" || exit
            for i in *
            do
                WP_CHECK=$(grep -s "WP_ID" "$APPS"/"$i"/.env || true)
                [[ -n "$WP_CHECK" ]] && cd "$APPS"/"$i" && docker-compose stop && docker-compose rm -f
            done
        elif [ -n "$ACTION" ] && [ -z "$SERVICE" ] && [ -n "$DOMAIN" ]; then
            docker-compose "$ACTION"    
        elif [ -n "$ACTION" ] && [ -n "$SERVICE" ] && [ -n "$DOMAIN" ]; then
            if [ "$ACTION" = restart ] && [ "$SERVICE" = nginx ]; then
                demyx_echo "Restarting NGINX"
                demyx_exec docker exec -it "$WP" sh -c 'nginx -s reload;'
            elif [ "$ACTION" = restart ] && [ "$SERVICE" = php ]; then
                demyx_echo "Restarting PHP"
                demyx_exec docker exec -it "$WP" sh -c 'pkill php-fpm; php-fpm -D'
            elif [ "$ACTION" = restart ] && [ "$SERVICE" = nginx-php ]; then
                demyx_echo "Restarting NGINX and PHP"
                demyx_exec docker exec -it "$WP" sh -c 'nginx -s reload; pkill php-fpm; php-fpm -D'
            elif [ "$SERVICE" = wp ]; then
                docker-compose "$ACTION" wp_"${WP_ID}"
            else
                docker-compose "$ACTION" db_"${WP_ID}"
            fi
        else
            echo
            echo -e "\e[31m[CRITICAL]\e[39m No --domain or --action"
            echo
            echo -e "\e[34m[INFO]\e[39m Try passing --all or demyx wp -h for a list of commands"
            echo
        fi
    elif [ -n "$BACKUP" ]; then
        cd "$APPS" || exit
        if [ -n "$ALL" ]; then
            for i in *
            do
                WP_CHECK=$(grep -s "WP_ID" "$APPS"/"$i"/.env || true)
                if [ -n "$WP_CHECK" ]; then
                    echo -e "\e[34m[INFO]\e[39m Backing up $i"
                    source "$i"/.env

                    demyx_echo 'Exporting database' 
                    demyx_exec docker run -it --rm \
                        --volumes-from "$WP" \
                        --network container:"$WP" \
                        wordpress:cli db export "$CONTAINER_NAME".sql
                    
                    demyx_echo 'Exporting files' 
                    demyx_exec docker cp "$WP":/var/www/html "$CONTAINER_PATH"/backup
                    
                    demyx_echo 'Deleting exported database' 
                    demyx_exec docker exec -it "$WP" rm /var/www/html/"$CONTAINER_NAME".sql
                    
                    demyx_echo 'Archiving directory' 
                    demyx_exec tar -czf "$DOMAIN".tgz -C "$APPS" "$DOMAIN"
                    
                    demyx_echo 'Moving archive' 
                    demyx_exec mv "$APPS"/"$DOMAIN".tgz "$APPS_BACKUP"
                    
                    demyx_echo 'Deleting backup directory' 
                    demyx_exec rm -rf "$CONTAINER_PATH"/backup
                fi
            done
        else
            WP_CHECK=$(grep -s "WP_ID" "$CONTAINER_PATH"/.env || true)
            [[ -z "$WP_CHECK" ]] && die 'Not a WordPress app.'
            echo -e "\e[34m[INFO]\e[39m Backing up $DOMAIN"
            source "$CONTAINER_PATH"/.env
            
            demyx_echo 'Exporting database' 
            demyx_exec docker run -it --rm \
                --volumes-from "$WP" \
                --network container:"$WP" \
                wordpress:cli db export "$CONTAINER_NAME".sql
            
            demyx_echo 'Exporting files' 
            demyx_exec docker cp "$WP":/var/www/html "$CONTAINER_PATH"/backup
            
            demyx_echo 'Deleting exported database' 
            demyx_exec docker exec -it "$WP" rm /var/www/html/"$CONTAINER_NAME".sql
            
            demyx_echo 'Archiving directory' 
            demyx_exec tar -czf "$DOMAIN".tgz -C "$APPS" "$DOMAIN"
            
            demyx_echo 'Moving archive' 
            demyx_exec mv "$APPS"/"$DOMAIN".tgz "$APPS_BACKUP"
            
            demyx_echo 'Deleting backup directory' 
            demyx_exec rm -rf "$CONTAINER_PATH"/backup
        fi
    elif [ -n "$CACHE" ] && [ -z "$RUN" ]; then
        WP_CHECK=$(grep -s "WP_ID" "$CONTAINER_PATH"/.env || true)
        [[ -z "$WP_CHECK" ]] && [[ "$CACHE" != check ]] && die 'Not a WordPress site.'
        [[ -f "$CONTAINER_PATH"/.env ]] && [[ -z "$RUN" ]] && source "$CONTAINER_PATH"/.env
        if [ "$CACHE" = on ]; then
            [[ "$FASTCGI_CACHE" = on ]] && die "Cache is already on for $DOMAIN"
            echo -e "\e[34m[INFO]\e[39m Turning on FastCGI Cache for $DOMAIN"
            NGINX_HELPER_CHECK=$(docker exec -it "$WP" sh -c 'ls wp-content/plugins' | grep nginx-helper || true)
            
            [[ -n "$NGINX_HELPER_CHECK" ]] && demyx_echo 'Activating nginx-helper' && demyx_exec \
                docker run -it --rm \
                --volumes-from "$WP" \
                --network container:"$WP" wordpress:cli plugin activate nginx-helper
            
            [[ -z "$NGINX_HELPER_CHECK" ]] && demyx_echo 'Installing nginx-helper' && demyx_exec \
                docker run -it --rm \
                --volumes-from "$WP" \
                --network container:"$WP" wordpress:cli plugin install nginx-helper --activate
            
            demyx_echo 'Configuring nginx-helper' 
            demyx_exec docker run -it --rm \
                --volumes-from "$WP" \
                --network container:"$WP" \
                wordpress:cli option update rt_wp_nginx_helper_options '{"enable_purge":"1","cache_method":"enable_fastcgi","purge_method":"get_request","enable_map":null,"enable_log":null,"log_level":"INFO","log_filesize":"5","enable_stamp":null,"purge_homepage_on_edit":"1","purge_homepage_on_del":"1","purge_archive_on_edit":"1","purge_archive_on_del":"1","purge_archive_on_new_comment":"1","purge_archive_on_deleted_comment":"1","purge_page_on_mod":"1","purge_page_on_new_comment":"1","purge_page_on_deleted_comment":"1","redis_hostname":"127.0.0.1","redis_port":"6379","redis_prefix":"nginx-cache:","purge_url":"","redis_enabled_by_constant":0}' --format=json
            
            demyx_echo 'Configuring NGINX' 
            demyx_exec docker exec -it "$WP" sh -c "printf ',s/#include \/etc\/nginx\/cache\/http.conf;/include \/etc\/nginx\/cache\/http.conf;/g\nw\n' | ed /etc/nginx/nginx.conf > /dev/null; printf ',s/#include \/etc\/nginx\/cache\/server.conf;/include \/etc\/nginx\/cache\/server.conf;/g\nw\n' | ed /etc/nginx/nginx.conf > /dev/null; printf ',s/#include \/etc\/nginx\/cache\/location.conf;/include \/etc\/nginx\/cache\/location.conf;/g\nw\n' | ed /etc/nginx/nginx.conf > /dev/null"
            
            demyx_echo 'Updating .env' 
            demyx_exec bash "$ETC"/functions/env.sh "$DOMAIN" "$ADMIN_USER" "$ADMIN_PASS" "on" "$FORCE"
        elif [ "$CACHE" = off ]; then
            [[ "$FASTCGI_CACHE" = off ]] && die "Cache is already off for $DOMAIN"
            echo -e "\e[34m[INFO]\e[39m Turning off FastCGI Cache for $DOMAIN"
            
            demyx_echo 'Deactivating nginx-helper' 
            demyx_exec docker run -it --rm \
                --volumes-from "$WP" \
                --network container:"$WP" wordpress:cli plugin deactivate nginx-helper
            
            demyx_echo 'Configuring NGINX' 
            demyx_exec docker exec -it "$WP" sh -c "printf ',s/include \/etc\/nginx\/cache\/http.conf;/#include \/etc\/nginx\/cache\/http.conf;/g\nw\n' | ed /etc/nginx/nginx.conf > /dev/null; printf ',s/include \/etc\/nginx\/cache\/server.conf;/#include \/etc\/nginx\/cache\/server.conf;/g\nw\n' | ed /etc/nginx/nginx.conf > /dev/null; printf ',s/include \/etc\/nginx\/cache\/location.conf;/#include \/etc\/nginx\/cache\/location.conf;/g\nw\n' | ed /etc/nginx/nginx.conf > /dev/null"
            
            demyx_echo 'Updating .env' 
            demyx_exec bash "$ETC"/functions/env.sh "$DOMAIN" "$ADMIN_USER" "$ADMIN_PASS" "off" "$FORCE"
        elif [ "$CACHE" = check ]; then
            cd "$APPS" || exit
            for i in *
            do
                [[ -z "$WP_CHECK" ]] && continue
                CHECK=$(grep "FASTCGI_CACHE=on" "$i"/.env || true)
                [[ -n "$CHECK" ]] && echo "$i"
            done
        fi

        [[ "$CACHE" != check ]] && demyx_echo 'Reloading NGINX' && demyx_exec docker exec -it "$WP" nginx -s reload
    elif [ -n "$CDN" ] && [ -z "$RUN" ]; then
        WP_CHECK=$(grep -s "WP_ID" "$CONTAINER_PATH"/.env || true)
        [[ -z "$WP_CHECK" ]] && die 'Not a WordPress site.'
        [[ -f "$CONTAINER_PATH"/.env ]] && [[ -z "$RUN" ]] && source "$CONTAINER_PATH"/.env
        if [ "$CDN" = on ]; then
            echo -e "\e[34m[INFO]\e[39m Turning on CDN for $DOMAIN"
            CDN_ENABLER_CHECK=$(docker exec -it "$WP" sh -c 'ls wp-content/plugins' | grep cdn-enabler || true)
            CDN_OPTION_CHECK=$(demyx wp --dom="$DOMAIN" --wpcli='option get cdn_enabler' | grep "Could not get" || true)
            
            [[ -n "$CDN_ENABLER_CHECK" ]] && demyx_echo 'Activating cdn-enabler' && demyx_exec \
                docker run -it --rm \
                --volumes-from "$WP" \
                --network container:"$WP" \
                wordpress:cli plugin activate cdn-enabler
            
            [[ -z "$CDN_ENABLER_CHECK" ]] && demyx_echo 'Installing cdn-enabler' && demyx_exec \
                docker run -it --rm \
                --volumes-from "$WP" \
                --network container:"$WP" \
                wordpress:cli plugin install cdn-enabler --activate
            
            demyx_echo 'Configuring cdn-enabler' 
            demyx_exec docker run -it --rm \
                --volumes-from "$WP" \
                --network container:"$WP" \
                wordpress:cli option update cdn_enabler "{\"url\":\"https:\/\/cdn.staticaly.com\/img\/$DOMAIN\",\"dirs\":\"wp-content,wp-includes\",\"excludes\":\".3g2, .3gp, .aac, .aiff, .alac, .apk, .avi, .css, .doc, .docx, .flac, .flv, .h264, .js, .json, .m4v, .mkv, .mov, .mp3, .mp4, .mpeg, .mpg, .ogg, .pdf, .php, .rar, .rtf, .svg, .tex, .ttf, .txt, .wav, .wks, .wma, .wmv, .woff, .woff2, .wpd, .wps, .xml, .zip, wp-content\/plugins, wp-content\/themes\",\"relative\":1,\"https\":1,\"keycdn_api_key\":\"\",\"keycdn_zone_id\":0}" --format=json
            
        elif [ "$CDN" = off ]; then
            echo -e "\e[34m[INFO]\e[39m Turning off CDN for $DOMAIN"
            
            demyx_echo 'Deactivating cdn-enabler' 
            demyx_exec docker run -it --rm \
                --volumes-from "$WP" \
                --network container:"$WP" \
                wordpress:cli plugin deactivate cdn-enabler
        fi
    elif [ -n "$CLI" ]; then
        cd "$CONTAINER_PATH" || exit
        source .env
        if [ "$SERVICE" = db ]; then
            docker-compose exec db_"${WP_ID}" $CLI
        else
            docker-compose exec wp_"${WP_ID}" $CLI
        fi
    elif [ -n "$CLONE" ]; then
        CLONE_WP=$(cat "$APPS"/"$CLONE"/.env | awk -F= '/^WP/ { print $2 }' | sed '1d')
        WP_CHECK=$(grep -s "WP_ID" "$APPS"/"$CLONE"/.env || true)
        DEV_MODE_CHECK=$(grep "sendfile off" /srv/demyx/apps/$CLONE/conf/nginx.conf || true)
        [[ -z "$SSL" ]] && SSL=on
        [[ -z "$WP_CHECK" ]] && die "$CLONE isn't a WordPress app"
        [[ -n "$DEV_MODE_CHECK" ]] && die "$CLONE is currently in dev mode. Please disable it before cloning"
        [[ -d "$CONTAINER_PATH" ]] && demyx wp --dom="$DOMAIN" --remove
        echo -e "\e[34m[INFO]\e[39m Cloning $CLONE to $DOMAIN"

        demyx_echo 'Creating directory'
        demyx_exec mkdir -p "$CONTAINER_PATH"/conf
        
        demyx_echo 'Creating .env' 
        demyx_exec bash "$ETC"/functions/env.sh "$DOMAIN" "$ADMIN_USER" "$ADMIN_PASS" "$CACHE" "$FORCE"
        
        demyx_echo 'Creating .yml' 
        demyx_exec bash "$ETC"/functions/yml.sh "$CONTAINER_PATH" "$FORCE" "$SSL"
        
        demyx_echo 'Creating nginx.conf' 
        demyx_exec bash "$ETC"/functions/nginx.sh "$CONTAINER_PATH" "$DOMAIN" "$FORCE" ""
         
        demyx_echo 'Creating php.ini' 
        demyx_exec bash "$ETC"/functions/php.sh "$CONTAINER_PATH" "$FORCE"
        
        demyx_echo 'Creating php-fpm.conf' 
        demyx_exec bash "$ETC"/functions/fpm.sh "$CONTAINER_PATH" "$DOMAIN" "$FORCE"
        
        demyx_echo 'Creating access/error logs' 
        demyx_exec bash "$ETC"/functions/logs.sh "$DOMAIN" "$FORCE"

        source "$CONTAINER_PATH"/.env

        demyx_echo 'Cloning database' 
        demyx_exec demyx wp --dom="$CLONE" --wpcli="db export clone.sql --exclude_tables=wp_users,wp_usermeta"
        
        demyx_echo 'Cloning files' 
        demyx_exec docker cp "$CLONE_WP":/var/www/html "$CONTAINER_PATH"/clone
        
        demyx_echo 'Removing exported clone database' 
        demyx_exec demyx wp --dom="$CLONE" --cli='rm /var/www/html/clone.sql'
        
        demyx_echo 'Creating data volume' 
        demyx_exec docker volume create wp_"$WP_ID"
        
        demyx_echo 'Creating db volume' 
        demyx_exec docker volume create db_"$WP_ID"
        
        demyx wp --dom="$DOMAIN" --service=db --action=up
        
        demyx_echo 'Initializing MariaDB'
        demyx_exec sleep 10
        
        demyx_echo 'Creating temporary container' 
        demyx_exec docker run -d --rm \
            --name clone_tmp \
            --network traefik \
            -v wp_"$WP_ID":/var/www/html demyx/nginx-php-wordpress tail -f /dev/null
        
        demyx_echo 'Copying files to temporary container' 
        demyx_exec docker cp "$CONTAINER_PATH"/clone/. clone_tmp:/var/www/html
        
        demyx_echo 'Removing old wp-config.php' 
        demyx_exec docker exec -it clone_tmp sh -c 'rm /var/www/html/wp-config.php'
        
        demyx_echo 'Creating new wp-config.php' 
        demyx_exec docker run -it --rm \
            --volumes-from clone_tmp \
            --network container:clone_tmp \
            wordpress:cli config create \
            --dbhost="$WORDPRESS_DB_HOST" \
            --dbname="$WORDPRESS_DB_NAME" \
            --dbuser="$WORDPRESS_DB_USER" \
            --dbpass="$WORDPRESS_DB_PASSWORD"
        
        demyx_echo 'Configuring wp-config.php for reverse proxy' 
        echo "#!/bin/bash" > "$CONTAINER_PATH"/proto.sh
        echo "sed -i \"s/$table_prefix = 'wp_';/$table_prefix = 'wp_';\n\n\/\/ If we're behind a proxy server and using HTTPS, we need to alert Wordpress of that fact\n\/\/ see also http:\/\/codex.wordpress.org\/Administration_Over_SSL#Using_a_Reverse_Proxy\nif (isset($\_SERVER['HTTP_X_FORWARDED_PROTO']) \&\& $\_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {\n\t$\_SERVER['HTTPS'] = 'on';\n}\n/g\" /var/www/html/wp-config.php" >> "$CONTAINER_PATH"/proto.sh
        docker cp "$CONTAINER_PATH"/proto.sh clone_tmp:/
        rm "$CONTAINER_PATH"/proto.sh
        demyx_exec docker exec -it clone_tmp sh -c 'bash /proto.sh && rm /proto.sh'
        
        if [ -n "$ADMIN_EMAIL" ]; then
            WORDPRESS_EMAIL="$ADMIN_EMAIL"
        else
            WORDPRESS_EMAIL=info@"$DOMAIN"
        fi

        demyx_echo 'Installing WordPress' 
        demyx_exec docker run -it --rm \
            --volumes-from clone_tmp \
            --network container:clone_tmp \
            wordpress:cli core install \
            --url="$DOMAIN" \
            --title="$DOMAIN" \
            --admin_user="$WORDPRESS_USER" \
            --admin_password="$WORDPRESS_USER_PASSWORD" \
            --admin_email="$WORDPRESS_EMAIL" \
            --skip-email
        
        demyx_echo 'Importing clone database' 
        demyx_exec docker run -it --rm \
            --volumes-from clone_tmp \
            --network container:clone_tmp \
            wordpress:cli db import clone.sql
        
        demyx_echo 'Replacing old URLs' 
        demyx_exec docker run -it --rm \
            --volumes-from clone_tmp \
            --network container:clone_tmp \
            wordpress:cli search-replace "$CLONE" "$DOMAIN"
        
        demyx_echo 'Creating wp-config.php salts' 
        demyx_exec docker run -it --rm \
            --volumes-from clone_tmp \
            --network container:clone_tmp \
            wordpress:cli config shuffle-salts
        
        demyx_echo 'Removing clone directory' 
        demyx_exec cd .. && rm -rf "$CONTAINER_PATH"/clone

        demyx_echo 'Removing clone database' 
        demyx_exec docker exec -it clone_tmp sh -c 'rm /var/www/html/clone.sql'
        
        demyx_echo 'Stopping temporary container' 
        demyx_exec docker stop clone_tmp

        demyx wp --dom="$DOMAIN" --service=wp --up

        [[ "$DEV" = on ]] && demyx wp --dom="$DOMAIN" --dev
        PRINT_TABLE="DOMAIN, $DOMAIN/wp-admin\n"
        PRINT_TABLE+="WORDPRESS USER, $WORDPRESS_USER\n"
        PRINT_TABLE+="WORDPRESS PASSWORD, $WORDPRESS_USER_PASSWORD"
        printTable ',' "$(echo -e $PRINT_TABLE)"
    elif [ -n "$DEV" ] && [ -z "$RUN" ] && [ -z "$CLONE" ]; then
        if [ "$DEV" != check ]; then
            [[ -z "$DOMAIN" ]] && die '--domain missing'
            SSH_VOLUME_CHECK=$(docker volume ls | grep ssh || true)
            CACHE_CHECK=$(grep -s "FASTCGI_CACHE=on" "$CONTAINER_PATH"/.env || true)
            SUBDOMAIN_CHECK=$(/usr/bin/dig +short "$DOMAIN" | sed -e '1d')
            SUBDOMAIN_GET=$(echo $DOMAIN | awk -F '[.]' '{print $1}')
            SUBDOMAIN_STRIP=$(echo $DOMAIN | awk -F '[.]' '{print $2"."$3}')
            WP_CHECK=$(grep -s "WP_ID" "$CONTAINER_PATH"/.env || true)
            SSH_PORT=2222
            PARSE_BASIC_AUTH=$(grep -s BASIC_AUTH_PASSWORD "$ETC"/.env | awk -F '[=]' '{print $2}' || true)
            BROWSERSYNC_SUB=dev
            BROWSERSYNC_SUB_UI=ui
            PHPMYADMIN_SUB=pma

            if [ -z "$SSH_VOLUME_CHECK" ]; then
                echo -e "\e[34m[INFO]\e[39m SSH volume not found, creating now..."
                
                demyx_echo 'Creating SSH volume' 
                demyx_exec docker volume create ssh
                
                demyx_echo 'Creating temporary SSH container' 
                demyx_exec docker run -d --rm \
                    --name ssh \
                    -v ssh:/home/www-data/.ssh \
                    demyx/ssh
                
                demyx_echo 'Copying authorized_keys to SSH volume' 
                demyx_exec docker cp /home/"$USER"/.ssh/authorized_keys ssh:/home/www-data/.ssh/authorized_keys
                
                demyx_echo 'Stopping temporary SSH container' 
                demyx_exec docker stop ssh
                
            fi
        fi

        if [ "$DEV" = on ]; then
            source "$CONTAINER_PATH"/.env
            if [ -z "$FORCE" ]; then 
                DEV_MODE_CHECK=$(grep "sendfile off" "$CONTAINER_PATH"/conf/nginx.conf || true)
                [[ -n "$DEV_MODE_CHECK" ]] && die "Development mode is already turned on for $DOMAIN"
            fi

            echo -e "\e[34m[INFO]\e[39m Turning on development mode for $DOMAIN"

            while true; do
                SSH_OPEN_PORT=$(netstat -tuplen 2>/dev/null | grep :"$SSH_PORT" || true)
                if [ -z "$SSH_OPEN_PORT" ]; then
                    break
                else
                    SSH_PORT=$((SSH_PORT+1))
                fi
            done

            demyx_echo 'Creating SSH container' 
            demyx_exec docker run -d --rm \
                --name ${DOMAIN//./}_ssh_"$WP_ID" \
                -v ssh:/home/www-data/.ssh \
                --volumes-from "$WP" \
                -p "$SSH_PORT":22 \
                demyx/ssh
            
            if [ -n "$SUBDOMAIN_CHECK" ]; then
                [[ "$SUBDOMAIN_GET" = "$BROWSERSYNC_SUB" ]] && BROWSERSYNC_SUB=bs
                BROWSERSYNC_FRONTEND_RULE="$BROWSERSYNC_SUB"."$SUBDOMAIN_STRIP"
                BROWSERSYNC_UI_FRONTEND_RULE="$BROWSERSYNC_SUB_UI"."$SUBDOMAIN_STRIP"
                PHPMYADMIN_FRONTEND_RULE="$PHPMYADMIN_SUB.$SUBDOMAIN_STRIP"
            else
                BROWSERSYNC_FRONTEND_RULE="$BROWSERSYNC_SUB"."$DOMAIN"
                BROWSERSYNC_UI_FRONTEND_RULE="$BROWSERSYNC_SUB_UI"."$DOMAIN"
                PHPMYADMIN_FRONTEND_RULE="$PHPMYADMIN_SUB.$DOMAIN"
            fi

            if [ "$FILES" = themes ]; then
                BS_FILES="/var/www/html/wp-content/themes/**/*"
            elif [ "$FILES" = plugins ]; then
                BS_FILES="/var/www/html/wp-content/plugins/**/*"
            elif [ -z "$FILES" ]; then
                BS_FILES="/var/www/html/wp-content/**/*"
            else
                BS_FILES="$FILES/**/*"
            fi

            echo "module.exports={rewriteRules:[{match:/$DOMAIN/g,fn:function(e,r,t){return'$BROWSERSYNC_FRONTEND_RULE'}}],socket:{domain:'$BROWSERSYNC_FRONTEND_RULE'}};" > "$CONTAINER_PATH"/conf/bs.js
            demyx_echo 'Creating BrowserSync container' 
            demyx_exec docker run -d --rm \
                --name ${DOMAIN//./}_bs_"$WP_ID" \
                --net traefik \
                --volumes-from "$WP" \
                -v "$CONTAINER_PATH"/conf/bs.js:/bs.js \
                -l "traefik.enable=true" \
                -l "traefik.bs.frontend.rule=Host:$BROWSERSYNC_FRONTEND_RULE" \
                -l "traefik.bs.port=3000" \
                -l "traefik.bs.frontend.redirect.entryPoint=https" \
                -l "traefik.bs.frontend.headers.forceSTSHeader=${FORCE_STS_HEADER}" \
                -l "traefik.bs.frontend.headers.STSSeconds=${STS_SECONDS}" \
                -l "traefik.bs.frontend.headers.STSIncludeSubdomains=${STS_INCLUDE_SUBDOMAINS}" \
                -l "traefik.bs.frontend.headers.STSPreload=${STS_PRELOAD}" \
                -l "traefik.ui.frontend.rule=Host:$BROWSERSYNC_UI_FRONTEND_RULE" \
                -l "traefik.ui.port=3001" \
                -l "traefik.ui.frontend.redirect.entryPoint=https" \
                -l "traefik.ui.frontend.headers.forceSTSHeader=${FORCE_STS_HEADER}" \
                -l "traefik.ui.frontend.headers.STSSeconds=${STS_SECONDS}" \
                -l "traefik.ui.frontend.headers.STSIncludeSubdomains=${STS_INCLUDE_SUBDOMAINS}" \
                -l "traefik.ui.frontend.headers.STSPreload=${STS_PRELOAD}" \
                -l "traefik.ui.frontend.auth.basic.users=${BASIC_AUTH_USER}:${PARSE_BASIC_AUTH}" \
                demyx/browsersync start \
                --config "/bs.js" \
                --proxy "$WP" \
                --files "$BS_FILES" \
                --port 3000 \
                --ui-port 3001

            demyx_echo 'Creating phpMyAdmin container' 
            demyx_exec docker run -d --rm \
                --name ${DOMAIN//./}_pma_"$WP_ID" \
                --network traefik \
                -e PMA_HOST="${DB}" \
                -e MYSQL_ROOT_PASSWORD="${MARIADB_ROOT_PASSWORD}" \
                -l "traefik.enable=true" \
                -l "traefik.frontend.rule=Host:$PHPMYADMIN_FRONTEND_RULE" \
                -l "traefik.port=80" \
                -l "traefik.frontend.redirect.entryPoint=https" \
                -l "traefik.frontend.headers.forceSTSHeader=${FORCE_STS_HEADER}" \
                -l "traefik.frontend.headers.STSSeconds=${STS_SECONDS}" \
                -l "traefik.frontend.headers.STSIncludeSubdomains=${STS_INCLUDE_SUBDOMAINS}" \
                -l "traefik.frontend.headers.STSPreload=${STS_PRELOAD}" \
                -l "traefik.frontend.auth.basic.users=${BASIC_AUTH_USER}:${PARSE_BASIC_AUTH}" \
                phpmyadmin/phpmyadmin

            PLUGIN_CHECK=$(demyx wp --dom="$DOMAIN" --wpcli='plugin list --format=csv')
            AUTOVER_CHECK=$(echo "$PLUGIN_CHECK" | grep -s autover || true)
            DEMYX_PLUGIN_CHECK=$(echo "$PLUGIN_CHECK" | grep -s demyx_browsersync || true)

            if [ -n "$AUTOVER_CHECK" ]; then
                demyx_echo 'Activating autover plugin'
                demyx_exec docker run -it --rm \
                    --volumes-from "$WP" \
                    --network container:"$WP" \
                    wordpress:cli plugin activate autover
            else
                demyx_echo 'Installing autover plugin'
                demyx_exec docker run -it --rm \
                    --volumes-from "$WP" \
                    --network container:"$WP" \
                    wordpress:cli plugin install autover --activate
            fi

            if [ -n "$DEMYX_PLUGIN_CHECK" ]; then
                demyx_echo 'Activating demyx_browsersync plugin'
                demyx_exec docker run -it --rm \
                    --volumes-from "$WP" \
                    --network container:"$WP" \
                    wordpress:cli plugin activate demyx_browsersync
            else
                demyx_echo 'Activating demyx_browsersync plugin'
                demyx_exec bash "$ETC"/functions/plugin.sh "$DOMAIN"; \
                docker cp "$CONTAINER_PATH"/conf/demyx_browsersync.php "$WP":/var/www/html/wp-content/plugins
                docker run -it --rm \
                    --volumes-from "$WP" \
                    --network container:"$WP" \
                    wordpress:cli plugin activate demyx_browsersync
            fi

            [[ -n "$CACHE_CHECK" ]] && demyx_echo 'Disabling NGINX cache' && demyx_exec demyx_exec docker exec -it "$WP" sh -c "printf ',s/include \/etc\/nginx\/cache\/http.conf;/#include \/etc\/nginx\/cache\/http.conf;/g\nw\n' | ed /etc/nginx/nginx.conf > /dev/null; printf ',s/include \/etc\/nginx\/cache\/server.conf;/#include \/etc\/nginx\/cache\/server.conf;/g\nw\n' | ed /etc/nginx/nginx.conf > /dev/null; printf ',s/include \/etc\/nginx\/cache\/location.conf;/#include \/etc\/nginx\/cache\/location.conf;/g\nw\n' | ed /etc/nginx/nginx.conf > /dev/null"
            
            demyx_echo 'Restarting NGINX' 
            demyx_exec docker exec -it "$WP" sh -c "printf ',s/sendfile on/sendfile off/g\nw\n' | ed /etc/nginx/nginx.conf; nginx -s reload"
            
            demyx_echo 'Restarting php-fpm' 
            demyx_exec docker exec -it "$WP" sh -c "mv /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini /; pkill php-fpm; php-fpm -D"
            
            PRINT_TABLE="$(echo "$DOMAIN" | tr a-z A-Z), DEVELOPMENT MODE\n"
            PRINT_TABLE+="SFTP, $DOMAIN\n"
            PRINT_TABLE+="SFTP USER, www-data\n"
            PRINT_TABLE+="SFTP PORT, $SSH_PORT\n"
            PRINT_TABLE+="PHPMYADMIN, https://$PHPMYADMIN_FRONTEND_RULE\n"
            PRINT_TABLE+="PHPMYADMIN USERNAME, $WORDPRESS_DB_USER\n"
            PRINT_TABLE+="PHPMYADMIN PASSWORD, $WORDPRESS_DB_PASSWORD\n"
            PRINT_TABLE+="BROWSERSYNC, https://$BROWSERSYNC_FRONTEND_RULE\n"
            PRINT_TABLE+="BROWSERSYNC UI, https://$BROWSERSYNC_UI_FRONTEND_RULE\n"
            PRINT_TABLE+="BROWSERSYNC FILES, $BS_FILES"
            printTable ',' "$(echo -e $PRINT_TABLE)"
        elif [ "$DEV" = off ]; then
            source "$CONTAINER_PATH"/.env
            if [ -z "$FORCE" ]; then
                DEV_MODE_CHECK=$(grep "sendfile on" "$CONTAINER_PATH"/conf/nginx.conf || true)
                [[ -n "$DEV_MODE_CHECK" ]] && die "Development mode is already turned off for $DOMAIN"
            fi
            echo -e "\e[34m[INFO]\e[39m Turning off development mode for $DOMAIN"
            AUTOVER_CHECK=$(docker exec -it "$WP" sh -c 'ls wp-content/plugins' | grep autover || true)
            
            demyx_echo 'Stopping SSH container' 
            demyx_exec docker stop ${DOMAIN//./}_ssh_"$WP_ID"
            
            demyx_echo 'Stopping phpMyAdmin container'
            demyx_exec docker stop ${DOMAIN//./}_pma_"$WP_ID"

            demyx_echo 'Stopping BrowserSync container'
            demyx_exec docker stop ${DOMAIN//./}_bs_"$WP_ID"
            rm "$CONTAINER_PATH"/conf/bs.js
            
            demyx_echo 'Deactivating autover' 
            demyx_exec docker run -it --rm --volumes-from "$WP" --network container:"$WP" wordpress:cli plugin deactivate autover

            demyx_echo 'Deactivating demyx_browsersync' 
            demyx_exec docker run -it --rm --volumes-from "$WP" --network container:"$WP" wordpress:cli plugin deactivate demyx_browsersync
            
            [[ -f "$CONTAINER_PATH"/conf/demyx_browsersync.php ]] && demyx_echo 'Deleting demyx_browsersync plugin from host' && demyx_exec rm "$CONTAINER_PATH"/conf/demyx_browsersync.php
            [[ -n "$CACHE_CHECK" ]] && demyx_echo 'Enabling NGINX cache' && demyx_exec demyx_exec docker exec -it "$WP" sh -c "printf ',s/#include \/etc\/nginx\/cache\/http.conf;/include \/etc\/nginx\/cache\/http.conf;/g\nw\n' | ed /etc/nginx/nginx.conf > /dev/null; printf ',s/#include \/etc\/nginx\/cache\/server.conf;/include \/etc\/nginx\/cache\/server.conf;/g\nw\n' | ed /etc/nginx/nginx.conf > /dev/null; printf ',s/#include \/etc\/nginx\/cache\/location.conf;/include \/etc\/nginx\/cache\/location.conf;/g\nw\n' | ed /etc/nginx/nginx.conf > /dev/null"

            demyx_echo 'Restarting NGINX' 
            demyx_exec docker exec -it "$WP" sh -c "printf ',s/sendfile off/sendfile on/g\nw\n' | ed /etc/nginx/nginx.conf; nginx -s reload"
            
            demyx_echo 'Restarting php-fpm' 
            demyx_exec docker exec -it "$WP" sh -c "mv /docker-php-ext-opcache.ini /usr/local/etc/php/conf.d; pkill php-fpm; php-fpm -D"
            
        elif [ "$DEV" = check ]; then
            cd "$APPS" || exit
            for i in *
            do
                WP_CHECK=$(grep -s "WP_ID" "$APPS"/"$i"/.env || true)
                [[ -n "$WP_CHECK" ]] && bash "$ETC"/functions/warnings.sh "$i" || true
            done
        elif [ "$DEV" = check ] && [ -n "$DOMAIN" ]; then
            [[ -n "$WP_CHECK" ]] && bash "$ETC"/functions/warnings.sh "$DOMAIN"
        else
            die "--dev=$DEV not found"
        fi
    elif [ -n "$ENV" ]; then
        echo
        cat "$CONTAINER_PATH"/.env
        echo
    elif [ -n "$LIST" ]; then
        cd "$APPS" || exit
        PRINT_TABLE="SITES\n"
        for i in *
        do
            WP_CHECK=$(grep -s "WP_ID" "$APPS"/"$i"/.env || true)
            [[ -z "$WP_CHECK" ]] && continue
            PRINT_TABLE+="$i\n"
        done
        printTable ',' "$(echo -e $PRINT_TABLE)"
    elif [ -n "$INFO" ]; then
        [[ -z "$DOMAIN" ]] && die 'Domain is required'
        source "$CONTAINER_PATH"/.env
        MONITOR_COUNT=0
        DEV_MODE_CHECK=$(grep -r "sendfile off" "$CONTAINER_PATH"/conf/nginx.conf || true)
        SSL_CHECK=$(grep -s "https" "$CONTAINER_PATH"/docker-compose.yml || true)
        SSL_INFO=off
        DATA_VOLUME=$(docker exec "$WP" sh -c "du -sh /var/www/html" | cut -f1)
        DB_VOLUME=$(docker exec "$DB" sh -c "du -sh /var/lib/mysql" | cut -f1)
        DEV_MODE_INFO=off
        [[ -n "$DEV_MODE_CHECK" ]] && DEV_MODE_INFO=on
        [[ -n "$SSL_CHECK" ]] && SSL_INFO=on
        [[ -f "$CONTAINER_PATH"/.monitor ]] && source "$CONTAINER_PATH"/.monitor
        PRINT_TABLE="DOMAIN, $DOMAIN\n"
        PRINT_TABLE+="PATH, $CONTAINER_PATH\n"
        PRINT_TABLE+="WP USER, $WORDPRESS_USER\n"
        PRINT_TABLE+="WP PASSWORD, $WORDPRESS_USER_PASSWORD\n"
        PRINT_TABLE+="WP CONTAINER, $WP\n"
        PRINT_TABLE+="DB CONTAINER, $DB\n"
        PRINT_TABLE+="DATA VOLUME, $DATA_VOLUME\n"
        PRINT_TABLE+="DB VOLUME, $DB_VOLUME\n"
        PRINT_TABLE+="DEVELOPMENT MODE, $DEV_MODE_INFO\n"
        PRINT_TABLE+="SSL, $SSL_INFO\n"
        PRINT_TABLE+="CACHE, $FASTCGI_CACHE\n"
        PRINT_TABLE+="MONITOR COUNT, $MONITOR_COUNT\n"
        PRINT_TABLE+="MONITOR THRESHOLD, $MONITOR_THRESHOLD\n"
        PRINT_TABLE+="MONITOR SCALE, $MONITOR_SCALE\n"
        PRINT_TABLE+="MONITOR CPU, $MONITOR_CPU%"
        printTable ',' "$(echo -e $PRINT_TABLE)"
    elif [ -n "$MONITOR" ]; then
        MONITOR_STATS=$(docker stats --no-stream)
        cd "$APPS" || exit
        for i in *
        do
            WP_CHECK=$(grep -s "WP_ID" "$APPS"/"$i"/.env || true)
            [[ -z "$WP_CHECK" ]] && continue
            source "$APPS"/"$i"/.env
            if [ ! -f "$APPS"/"$i"/.monitor ]; then
                echo "MONITOR_COUNT=0" > "$APPS"/"$i"/.monitor 
            else
                source "$APPS"/"$i"/.monitor
            fi

            MONITOR_CHECK=$(echo "$MONITOR_STATS" | grep "$WP" | awk '{print $3}' | awk -F '[.]' '{print $1}')

            if (( "$MONITOR_CHECK" >= "$MONITOR_CPU" )); then
                if [[ "$MONITOR_COUNT" != "$MONITOR_THRESHOLD" ]]; then
                    MONITOR_COUNT_UP=$((MONITOR_COUNT+1))
                    echo "MONITOR_COUNT=${MONITOR_COUNT_UP}" > "$APPS"/"$i"/.monitor
                else
                    if [[ "$MONITOR_COUNT" = 3 ]]; then
                        if [ ! -f "$APPS"/"$i"/.monitor_lock ]; then
                            touch "$APPS"/"$i"/.monitor_lock
                            cd "$APPS"/"$i" || exit
                            /usr/local/bin/docker-compose up -d --scale wp_"${WP_ID}"="${MONITOR_SCALE}" wp_"${WP_ID}"
                            /usr/local/bin/docker-compose up -d --scale db_"${WP_ID}"="${MONITOR_SCALE}" db_"${WP_ID}"
                            [[ -f "$DEMYX"/custom/callback.sh ]] && /bin/bash "$DEMYX"/custom/callback.sh "monitor-on" "$i" "$MONITOR_CHECK"
                        fi
                    fi
                fi
            elif (( "$MONITOR_CHECK" <= "$MONITOR_CPU" )); then
                if (( "$MONITOR_COUNT" > 0 )); then
                    MONITOR_COUNT_DOWN=$((MONITOR_COUNT-1))
                    echo "MONITOR_COUNT=${MONITOR_COUNT_DOWN}" > "$APPS"/"$i"/.monitor
                else
                    if [[ "$MONITOR_COUNT" = 0 ]]; then
                        if [ -f "$APPS"/"$i"/.monitor_lock ]; then
                            rm "$APPS"/"$i"/.monitor_lock
                            cd "$APPS"/"$i" || exit
                            /usr/local/bin/docker-compose up -d --scale wp_"${WP_ID}"=1 wp_"${WP_ID}"
                            /usr/local/bin/docker-compose up -d --scale db_"${WP_ID}"=1 db_"${WP_ID}"
                            [[ -f "$DEMYX"/custom/callback.sh ]] && /bin/bash "$DEMYX"/custom/callback.sh "monitor-off" "$i" "$MONITOR_CHECK"
                        fi
                    fi
                fi
            fi
        done
    elif [ -n "$RATE_LIMIT" ]; then
        WP_CHECK=$(grep -s "WP_ID" "$CONTAINER_PATH"/.env || true)
        [[ -z "$WP_CHECK" ]] && die 'Not a WordPress app.'
        source "$CONTAINER_PATH"/.env

        if [ "$RATE_LIMIT" = on ]; then
            echo -e "\e[34m[INFO]\e[39m Turning on rate limiting for $DOMAIN"
            
            demyx_echo 'Restarting NGINX' 
            demyx_exec docker exec -it "$WP" sh -c "printf ',s/#limit_req/limit_req/g\nw\n' | ed /etc/nginx/nginx.conf; nginx -s reload"
        elif [ "$RATE_LIMIT" = off ]; then
            echo -e "\e[34m[INFO]\e[39m Turning off rate limiting for $DOMAIN"
            
            demyx_echo 'Restarting NGINX' 
            demyx_exec docker exec -it "$WP" sh -c "printf ',s/limit_req/#limit_req/g\nw\n' | ed /etc/nginx/nginx.conf; nginx -s reload"
        fi
    elif [ -n "$REFRESH" ]; then
        if [ -n "$ALL" ]; then
            cd "$APPS" || exit
            for i in *
            do
                WP_CHECK=$(grep -s "WP_ID" "$APPS"/"$i"/.env || true)
                if [ -n "$WP_CHECK" ]; then 
                    echo -e "\e[34m[INFO]\e[39m Refreshing $i"
                    DOMAIN=$i
                    CONTAINER_PATH=$APPS/$DOMAIN
                    CONTAINER_NAME=${DOMAIN//./_}
                    CACHE_CHECK=$(grep -s "FASTCGI_CACHE=on" "$CONTAINER_PATH"/.env || true)
                    SSL_CHECK=$(grep -s "entryPoint=https" "$CONTAINER_PATH"/docker-compose.yml || true)
                    [[ -n "$CACHE_CHECK" ]] && CACHE=on
                    [[ -n "$SSL_CHECK" ]] && SSL=on
                    
                    demyx_echo 'Creating .env' 
                    demyx_exec bash "$ETC"/functions/env.sh "$DOMAIN" "$ADMIN_USER" "$ADMIN_PASS" "$CACHE" "$FORCE"
        
                    demyx_echo 'Creating .yml' 
                    demyx_exec bash "$ETC"/functions/yml.sh "$CONTAINER_PATH" "$FORCE" "$SSL"
        
                    demyx_echo 'Creating nginx.conf' 
                    demyx_exec bash "$ETC"/functions/nginx.sh "$CONTAINER_PATH" "$DOMAIN" "$FORCE" "$CACHE"
         
                    demyx_echo 'Creating php.ini' 
                    demyx_exec bash "$ETC"/functions/php.sh "$CONTAINER_PATH" "$FORCE"
        
                    demyx_echo 'Creating php-fpm.conf' 
                    demyx_exec bash "$ETC"/functions/fpm.sh "$CONTAINER_PATH" "$DOMAIN" "$FORCE"
        
                    demyx_echo 'Creating access/error logs' 
                    demyx_exec bash "$ETC"/functions/logs.sh "$DOMAIN" "$FORCE"

                    [[ -z "$NO_RESTART" ]] && demyx wp --dom="$i" --down && demyx wp --dom="$i" --up
                fi
            done
        else
            WP_CHECK=$(grep -s "WP_ID" "$CONTAINER_PATH"/.env || true)
            CACHE_CHECK=$(grep -s "FASTCGI_CACHE=on" "$CONTAINER_PATH"/.env || true)
            SSL_CHECK=$(grep -s "entryPoint=https" "$CONTAINER_PATH"/docker-compose.yml || true)
            [[ -z "$WP_CHECK" ]] && die 'Not a WordPress app'
            [[ -z "$DOMAIN" ]] && die 'Domain is missing or add --all'
            [[ -n "$CACHE_CHECK" ]] && CACHE=on
            [[ -n "$SSL_CHECK" ]] && SSL=on
            echo -e "\e[34m[INFO]\e[39m Refreshing $DOMAIN"

            demyx_echo 'Creating .env' 
            demyx_exec bash "$ETC"/functions/env.sh "$DOMAIN" "$ADMIN_USER" "$ADMIN_PASS" "$CACHE" "$FORCE"

            demyx_echo 'Creating .yml' 
            demyx_exec bash "$ETC"/functions/yml.sh "$CONTAINER_PATH" "$FORCE" "$SSL"

            demyx_echo 'Creating nginx.conf' 
            demyx_exec bash "$ETC"/functions/nginx.sh "$CONTAINER_PATH" "$DOMAIN" "$FORCE" "$CACHE"
 
            demyx_echo 'Creating php.ini' 
            demyx_exec bash "$ETC"/functions/php.sh "$CONTAINER_PATH" "$FORCE"

            demyx_echo 'Creating php-fpm.conf' 
            demyx_exec bash "$ETC"/functions/fpm.sh "$CONTAINER_PATH" "$DOMAIN" "$FORCE"

            demyx_echo 'Creating access/error logs' 
            demyx_exec bash "$ETC"/functions/logs.sh "$DOMAIN" "$FORCE"
            
            [[ -z "$NO_RESTART" ]] && demyx wp --dom="$DOMAIN" --down && demyx wp --dom="$DOMAIN" --up
        fi
    elif [ -n "$RESTART" ]; then
        cd "$APPS" || exit
        for i in *
        do
            WP_CHECK=$(grep -s "WP_ID" "$APPS"/"$i"/.env || true)
            [[ -z "$WP_CHECK" ]] && continue
            source "$APPS"/"$i"/.env
            if [ "$RESTART" = nginx-php ]; then
                demyx_echo "Restarting NGINX and PHP for $i"
                demyx_exec docker exec -it "$WP" sh -c 'nginx -s reload; pkill php-fpm; php-fpm -D'
            elif [ "$RESTART" = nginx ]; then
                demyx_echo "Restarting NGINX for $i"
                demyx_exec docker exec -it "$WP" sh -c 'nginx -s reload'
            elif [ "$RESTART" = php ]; then
                demyx_echo "Restarting PHP for $i"
                demyx_exec docker exec -it "$WP" sh -c 'pkill php-fpm; php-fpm -D'
            elif [ "$RESTART" = wp ]; then
                cd "$APPS"/"$i" && docker-compose restart wp_"$WP_ID"
            elif [ "$RESTART" = db ]; then
                cd "$APPS"/"$i" && docker-compose restart db_"$WP_ID"
            else
                cd "$APPS"/"$i" && docker-compose restart
            fi
        done
    elif [ -n "$RESTORE" ]; then
        [[ -d "$CONTAINER_PATH" ]] && demyx wp --dom="$DOMAIN" --remove
        [[ ! -f "$APPS_BACKUP"/"$DOMAIN".tgz ]] && die "No backups found for $DOMAIN"
        echo -e "\e[34m[INFO]\e[39m Restoring $DOMAIN"
        
        demyx_echo 'Extracting archive' 
        demyx_exec tar -xzf "$APPS_BACKUP"/"$DOMAIN".tgz -C "$APPS"
        
        source "$CONTAINER_PATH"/.env

        WP_CONTAINER_CHECK=$(docker ps -aq -f name="$WP")
        DB_CONTAINER_CHECK=$(docker ps -aq -f name="$DB")
        [[ -n "$WP_CONTAINER_CHECK" ]] && docker stop "$WP" && docker rm "$WP"
        [[ -n "$DB_CONTAINER_CHECK" ]] && docker stop "$DB" && docker rm "$DB"
        
        VOLUME_CHECK=$(docker volume ls)
        
        [[ -n "$(grep wp_${WP_ID} <<< $VOLUME_CHECK || true)" ]] && demyx_echo 'Removing data volume' && demyx_exec docker volume rm wp_"$WP_ID"
        [[ -n "$(grep db_${WP_ID} <<< $VOLUME_CHECK || true)" ]] && demyx_echo 'Removing database volume' && demyx_exec docker volume rm db_"$WP_ID"
        
        demyx_echo 'Creating data volume' 
        demyx_exec docker volume create wp_"$WP_ID"
        
        demyx_echo 'Creating db volume' 
        demyx_exec docker volume create db_"$WP_ID"
        
        demyx wp --dom="$DOMAIN" --service=db --action=up
        
        demyx_echo 'Initializing MariaDB' 
        demyx_exec sleep 10

        demyx_echo 'Creating temporary container' 
        demyx_exec docker run -d --rm \
            --name restore_tmp \
            --network traefik \
            -v wp_"$WP_ID":/var/www/html \
            demyx/nginx-php-wordpress tail -f /dev/null
        
        demyx_echo 'Copying files'
        demyx_exec docker cp "$CONTAINER_PATH"/backup/. restore_tmp:/var/www/html
        
        demyx_echo 'Importing database' 
        demyx_exec docker run -it --rm \
            --volumes-from restore_tmp \
            --network container:restore_tmp \
            wordpress:cli db import "$CONTAINER_NAME".sql
        
        demyx_echo 'Removing backup database' 
        demyx_exec docker exec -it restore_tmp sh -c "rm /var/www/html/$CONTAINER_NAME.sql"
          
        demyx_echo 'Stopping temporary container' 
        demyx_exec docker stop restore_tmp
        
        demyx_echo 'Removing backup directory' 
        demyx_exec rm -rf "$CONTAINER_PATH"/backup
        
        [[ ! -f "$LOGS"/"$DOMAIN".access.log ]] &&  demyx_echo 'Creating logs' && demyx_exec bash "$ETC"/functions/logs.sh "$DOMAIN" "$FORCE"
        
        demyx wp --dom="$DOMAIN" --service=wp --action=up
    elif [ -n "$REMOVE" ]; then
        if [ -z "$FORCE" ]; then
            echo -en "\e[33m"
            if [ -z "$DOMAIN" ]; then
                read -rep "[WARNING] Delete all sites? [yY]: " DELETE_SITE
            else
                read -rep "[WARNING] Delete $DOMAIN? [yY]: " DELETE_SITE
            fi
            echo -en "\e[39m"

            [[ "$DELETE_SITE" != [yY] ]] && die 'Cancel removal of site(s)'
        fi
        
        VOLUME_CHECK=$(docker volume ls)

        if [ -n "$ALL" ]; then
            cd "$APPS" || exit
            for i in *
            do
                WP_CHECK=$(grep -s "WP_ID" "$APPS"/"$i"/.env || true)
                echo -e "\e[31m[CRITICAL]\e[39m Removing $i"
                if [ -n "$WP_CHECK" ]; then
                    source "$APPS"/"$i"/.env
                    cd "$APPS"/"$i" && docker-compose kill && docker-compose rm -f
                    ORPHANS=$(docker ps -aq -f name="$WP_ID")
                    
                    [[ -n "$(grep wp_${WP_ID} <<< $VOLUME_CHECK || true)" ]] && demyx_echo 'Deleting data volume' && demyx_exec docker volume rm wp_"$WP_ID"
                    [[ -n "$(grep db_${WP_ID} <<< $VOLUME_CHECK || true)" ]] && demyx_echo 'Deleting db volume' && demyx_exec docker volume rm db_"$WP_ID"
                    [[ -n "$ORPHANS" ]] && demyx_echo 'Stopping orphan containers' && demyx_exec docker stop $(docker ps -aq -f name="$WP_ID")
                    [[ -f "$LOGS"/"$DOMAIN".access.log ]] && demyx_echo 'Deleting logs' && demyx_exec rm "$LOGS"/"$DOMAIN".access.log; rm "$LOGS"/"$DOMAIN".error.log
                    
                    demyx_echo 'Deleting directory'
                    demyx_exec rm -rf "$APPS"/"$i"
                fi
            done
        else
            [[ ! -f "$CONTAINER_PATH"/.env ]] && die "$DOMAIN is not a valid WordPress app or doesn't exist"
            WP_CHECK=$(grep -s "WP_ID" "$CONTAINER_PATH"/.env || true)
            if [ -n "$WP_CHECK" ]; then
                source "$CONTAINER_PATH"/.env
                echo -e "\e[31m[CRITICAL]\e[39m Removing $DOMAIN"
                cd "$CONTAINER_PATH" && docker-compose kill && docker-compose rm -f
                ORPHANS=$(docker ps -aq -f name="$WP_ID")
                
                [[ -n "$ORPHANS" ]] && demyx_echo 'Stopping orphan containers' && demyx_exec docker stop $(docker ps -aq -f name="$WP_ID")
                [[ -n "$(grep wp_${WP_ID} <<< $VOLUME_CHECK || true)" ]] && demyx_echo 'Deleting data volume' && demyx_exec docker volume rm wp_"$WP_ID"
                [[ -n "$(grep db_${WP_ID} <<< $VOLUME_CHECK || true)" ]] && demyx_echo 'Deleting db volume' && demyx_exec docker volume rm db_"$WP_ID"
                [[ -f "$LOGS"/"$DOMAIN".access.log ]] && demyx_echo 'Deleting logs' && demyx_exec rm "$LOGS"/"$DOMAIN".access.log; rm "$LOGS"/"$DOMAIN".error.log

                demyx_echo 'Deleting directory'
                demyx_exec rm -rf "$CONTAINER_PATH"
            else
                die "$DOMAIN a WordPress app"
            fi
        fi
    elif [ -n "$RUN" ]; then
        if [ -d "$CONTAINER_PATH" ]; then
            if [ -n "$FORCE" ]; then
                demyx wp --dom="$DOMAIN" --remove --force
            else
                demyx wp --dom="$DOMAIN" --remove
            fi
        fi
        # Future plans for subnets
        #bash $ETC/functions/subnet.sh $DOMAIN $CONTAINER_NAME create
        echo -e "\e[34m[INFO]\e[39m Creating $DOMAIN"

        [[ -z "$SSL" ]] && SSL=on

        demyx_echo 'Creating directory'
        demyx_exec mkdir -p "$CONTAINER_PATH"/conf

        demyx_echo 'Creating .env'
        demyx_exec bash "$ETC"/functions/env.sh "$DOMAIN" "$ADMIN_USER" "$ADMIN_PASS" "" "$FORCE"

        demyx_echo 'Creating .yml'
        demyx_exec bash "$ETC"/functions/yml.sh "$CONTAINER_PATH" "$FORCE" "$SSL"

        demyx_echo 'Creating nginx.conf'
        demyx_exec bash "$ETC"/functions/nginx.sh "$CONTAINER_PATH" "$DOMAIN" "$FORCE" 

        demyx_echo 'Creating php.ini'
        demyx_exec bash "$ETC"/functions/php.sh "$CONTAINER_PATH" "$FORCE"

        demyx_echo 'Creating php-fpm.conf'
        demyx_exec bash "$ETC"/functions/fpm.sh "$CONTAINER_PATH" "$DOMAIN" "$FORCE"

        demyx_echo 'Creating access/error logs'
        demyx_exec bash "$ETC"/functions/logs.sh "$DOMAIN" "$FORCE"

        source "$CONTAINER_PATH"/.env

        demyx_echo 'Creating data volume' 
        demyx_exec docker volume create wp_"$WP_ID"
        
        demyx_echo 'Creating db volume' 
        demyx_exec docker volume create db_"$WP_ID"
        
        cd "$CONTAINER_PATH" && docker-compose up -d --remove-orphans

        if [ -n "$ADMIN_EMAIL" ]; then
            WORDPRESS_EMAIL="$ADMIN_EMAIL"
        else
            WORDPRESS_EMAIL=info@"$DOMAIN"
        fi

        demyx_echo 'Initializing MariaDB'
        demyx_exec sleep 10

        demyx_echo 'Configuring wp-config.php' 
        demyx_exec docker run -it --rm \
            --volumes-from "$WP" \
            --network container:"$WP" \
            wordpress:cli core install \
            --url="$DOMAIN" \
            --title="$DOMAIN" \
            --admin_user="$WORDPRESS_USER" \
            --admin_password="$WORDPRESS_USER_PASSWORD" \
            --admin_email="$WORDPRESS_EMAIL" \
            --skip-email

        demyx_echo 'Replacing URLs to HTTPS' 
        demyx_exec docker run -it --rm \
            --volumes-from "$WP" \
            --network container:"$WP" \
            wordpress:cli search-replace "http://$DOMAIN" "https://$DOMAIN"
        
        demyx_echo 'Configuring permalinks' 
        demyx_exec docker run -it --rm \
            --volumes-from "$WP" \
            --network container:"$WP" \
            wordpress:cli rewrite structure '/%category%/%postname%/'
        

        [[ "$CDN" = on ]] && demyx wp --dom="$DOMAIN" --cdn
        [[ "$DEV" = on ]] && demyx wp --dom="$DOMAIN" --dev
        [[ "$CACHE" = on ]] && demyx wp --dom="$DOMAIN" --cache
        [[ "$SSL" = on ]] && RUN_PROTO='https://'

        PRINT_TABLE="DOMAIN, ${RUN_PROTO}${DOMAIN}/wp-admin\n"
        PRINT_TABLE+="WORDPRESS USER, $WORDPRESS_USER\n"
        PRINT_TABLE+="WORDPRESS PASSWORD, $WORDPRESS_USER_PASSWORD\n"
        printTable ',' "$(echo -e $PRINT_TABLE)"
    elif [ -n "$DEMYX_SHELL" ]; then
        source "$CONTAINER_PATH"/.env
        if [ "$DEMYX_SHELL" = "wp" ]; then
            docker exec -it "$WP" sh
        elif [ "$DEMYX_SHELL" = "bs" ]; then
            BROWSERSYNC_CONTAINER_CHECK=$(docker ps -aq -f name=${DOMAIN//./}_bs)
            [[ -z "$BROWSERSYNC_CONTAINER_CHECK" ]] && die "BrowserSync container isn't up"
            docker exec -it ${DOMAIN//./}_bs_"$WP_ID" sh
        elif [ "$DEMYX_SHELL" = "ssh" ]; then
            SSH_CONTAINER_CHECK=$(docker ps -aq -f name=${DOMAIN//./}_ssh)
            [[ -z "$SSH_CONTAINER_CHECK" ]] && die "SSH container isn't up"
            docker exec -it ${DOMAIN//./}_ssh_"$WP_ID" sh
        else
            docker exec -it "$DB" sh
        fi
    elif [ -n "$SCALE" ]; then
        cd "$CONTAINER_PATH" && source .env
        [[ -z "$SERVICE" ]] && echo -e "\e[33m[WARNING]\e[39m --service is missing, targeting all services..."
        if [ "$SERVICE" = wp ]; then
            docker-compose up -d --scale wp_"${WP_ID}"="$SCALE" wp_"${WP_ID}"
        elif [ "$SERVICE" = db ]; then
            docker-compose up -d --scale db_"${WP_ID}"="$SCALE" db_"${WP_ID}"
        else
            docker-compose up -d --scale wp_"${WP_ID}"="$SCALE" wp_"${WP_ID}"
            docker-compose up -d --scale db_"${WP_ID}"="$SCALE" db_"${WP_ID}"
        fi
    elif [ -n "$SSL" ] && [ -n "$DOMAIN" ]; then
        WP_CHECK=$(grep -s "WP_ID" "$CONTAINER_PATH"/.env || true)
        if [ -n "$WP_CHECK" ]; then
            source "$CONTAINER_PATH"/.env
            bash "$ETC"/functions/yml.sh "$CONTAINER_PATH" "$FORCE" "$SSL"
            if [ "$SSL" = on ]; then
                demyx_echo 'Replacing URLs to HTTPS' 
                demyx_exec docker run -it --rm \
                    --volumes-from "$WP" \
                    --network container:"$WP" \
                    wordpress:cli search-replace "http://$DOMAIN" "https://$DOMAIN"
            elif [ "$SSL" = off ]; then
                demyx_echo 'Replacing URLs to HTTP'
                demyx_exec docker run -it --rm \
                    --volumes-from "$WP" \
                    --network container:"$WP" \
                    wordpress:cli search-replace "https://$DOMAIN" "http://$DOMAIN"
            else
                die '--ssl only accepts: on, off'
            fi
            demyx wp --dom="$DOMAIN" --service=wp --action=up
        else
            die 'Not a WordPress app'
        fi    
    elif [ -n "$UPDATE" ]; then
        cd "$APPS" || exit
        if [ -n "$ALL" ]; then
            [[ "$UPDATE" != structure ]] && die '--update only takes structure as the value.'
            for i in *
            do
                [[ ! -d "$APPS"/"$i"/db ]] && echo -e "\e[34m[INFO]\e[39m $i is already updated, continuing..." && continue
                WP_CHECK=$(grep -s "WP_ID" "$APPS"/"$i"/.env || true)
                if [ -n "$WP_CHECK" ]; then
                    echo -e "\e[34m[INFO]\e[39m Updating up $i"
                    source "$i"/.env
                    docker volume create db_"$WP_ID" 
                    docker volume create wp_"$WP_ID"
                    sudo cp -R "$CONTAINER_PATH"/db/* /var/lib/docker/volumes/db_"$WP_ID"/_data
                    sudo cp -R "$CONTAINER_PATH"/data/* /var/lib/docker/volumes/wp_"$WP_ID"/_data
                    demyx wp --dom="$DOMAIN" --down
                    bash "$ETC"/functions/yml.sh "$CONTAINER_PATH" "$FORCE" "$SSL"
                    demyx wp --dom="$DOMAIN" --up
                    sudo rm -rf "$CONTAINER_PATH"/data "$CONTAINER_PATH"/db
                fi
            done
        else
            [[ ! -d "$APPS"/"$DOMAIN"/db ]] && die "$DOMAIN is already updated"
            [[ "$UPDATE" != structure ]] && die '--update only takes structure as the value.'
            WP_CHECK=$(grep -s "WP_ID" "$CONTAINER_PATH"/.env || true)
            [[ -z "$WP_CHECK" ]] && die 'Not a WordPress app.'
            echo -e "\e[34m[INFO]\e[39m Updating $DOMAIN"
            source "$CONTAINER_PATH"/.env
            docker volume create db_"$WP_ID" 
            docker volume create wp_"$WP_ID"
            sudo cp -R "$CONTAINER_PATH"/db/* /var/lib/docker/volumes/db_"$WP_ID"/_data
            sudo cp -R "$CONTAINER_PATH"/data/* /var/lib/docker/volumes/wp_"$WP_ID"/_data
            demyx wp --dom="$DOMAIN" --down
            bash "$ETC"/functions/yml.sh "$CONTAINER_PATH" "$FORCE" "$SSL"
            demyx wp --dom="$DOMAIN" --up
            sudo rm -rf "$CONTAINER_PATH"/data "$CONTAINER_PATH"/db
        fi
    elif [ -n "$WPCLI" ]; then
        cd "$APPS" || exit
        if [ -n "$ALL" ]; then
            for i in *
            do
                WP_CHECK=$(grep -s "WP_ID" "$APPS"/"$i"/.env || true)
                if [ -n "$WP_CHECK" ]; then
                    source "$APPS"/"$i"/.env
                    demyx_echo "Executing wp-cli for $i"
                    demyx_exec docker run -it --rm \
                        --volumes-from "$WP" \
                        --network container:"$WP" \
                        wordpress:cli $WPCLI
                fi
            done
        else
            WP_CHECK=$(grep -s "WP_ID" "$CONTAINER_PATH"/.env || true)
            [[ -z "$WP_CHECK" ]] && die 'Not a WordPress app.'
            source "$CONTAINER_PATH"/.env
            demyx_echo "Executing wp-cli for $DOMAIN"
            demyx_exec docker run -it --rm \
                --volumes-from "$WP" \
                --network container:"$WP" \
                wordpress:cli $WPCLI
        fi
    fi
elif [ "$1" = "logs" ]; then
    while :; do
        case $2 in
            -h|-\?|--help)
                echo
                echo "  -c, --clear     Clear the logs"
                echo "                  Example: demyx logs -c, demyx logs --clear"
                echo
                echo "  -f, --follow    Shorthand for tail -f"
                echo "                  Example: demyx logs -f, --follow"
                echo
                exit
                ;;
            -c|--clear)
                CLEAR=1
                ;;
            -f|--follow)
                FOLLOW=1
                ;;
            --)      
                shift
                break
                ;;
            -?*)
                printf '\e[31m[CRITICAL]\e[39m Unknown option: %s\n' "$2" >&2
                exit 1
                ;;
            *) 
                break
        esac
        shift
    done

    if [ -n "$FOLLOW" ]; then
        tail -f "$LOGS"/demyx.log
    elif [ -n "$CLEAR" ]; then
        echo > "$LOGS"/demyx.log
    else
        less +G "$LOGS"/demyx.log
    fi
else
    [[ -z "$1" ]] && echo && echo -e "\e[34m[INFO]\e[39m See commands for help: demyx -h, demyx stack -h, demyx wp -h, demyx logs -h" && echo
    while :; do
        case $1 in
            -h|-\?|--help)
                echo 
                echo "  If you modified any of the files (.conf/.ini/.yml/etc) then delete the first comment at the top of the file(s)"
                echo
                echo "  -df              Wrapper for docker system df"
                echo "                   Example: demyx -df"
                echo
                echo "  --dom            Flag needed to run other Docker images"
                echo "                   Example: demyx --dom=domain.tld --install=gitea"
                echo 
                echo "  --email          Flag needed for Rocket.Chat"
                echo "                   Example: demyx --dom=domain.tld --email=info@domain.tld --install=rocketchat"
                echo 
                echo "  -f, --force      Forces an update"
                echo "                   Example: demyx --force --update, demyx -f -u"
                echo
                echo "  --install        Install Rocket.Chat and Gitea"
                echo
                echo "  -p, --prune      Wrapper for docker system prune && docker volume prune"
                echo "                   Example: demyx -p, demyx --prune"
                echo
                echo "  -t, --top        Runs ctop (htop for containers)"
                echo "                   Example: demyx -t, demyx --top"
                echo
                exit 1
                ;;
            --dom=?*)
                DOMAIN=${1#*=}
                ;;
            --dom=)         
                die '"--domain" cannot be empty.'
                ;;
            --email=?*)
                EMAIL=${1#*=}
                ;;
            --email=)         
                die '"--email" cannot be empty.'
                ;;
            -f|--force)
                FORCE=1
                ;;
            --install=?*)
                INSTALL=${1#*=}
                ;;
            --install=)         
                die '"--install" cannot be empty.'
                ;;
            -p|--prune)
                docker system prune -f
                docker volume prune -f
                ;;
            -df)       
                docker system df
                ;;
            -t|--top)
                CTOP_CHECK=$(docker ps | grep ctop | awk '{print $1}' || true)
                [[ -n "$CTOP_CHECK" ]] && demyx_echo 'Stopping old ctop container' && demyx_exec docker stop "$CTOP_CHECK"
                docker run --rm -ti --name ctop -v /var/run/docker.sock:/var/run/docker.sock:ro quay.io/vektorlab/ctop
                ;;
            -u|--update)
                # Check for custom folder where users can place custom shell scripts
                if [ ! -f "$DEMYX"/custom/example-callback.sh ]; then
                    demyx_echo 'Creating custom directory' 
                    demyx_exec mkdir "$DEMYX"/custom; cp "$ETC"/functions/example-callback.sh "$DEMYX"/custom
                fi


                cd "$GIT" && git pull

                echo -e "\e[34m[INFO]\e[39m Updating Demyx..."
                    
                # Replace old cron with new
                CRON_OLD=$(crontab -l | grep -s "/usr/local/bin/demyx" || true)
                if [ -n "$CRON_OLD" ]; then
                    demyx_echo 'Updating crontab' 

                    crontab -l > "$ETC"/cron_tmp
                    sed -i '\/usr\/local\/bin\/demyx/d' "$ETC"/cron_tmp
                    sed -i '\/srv\/demyx\/etc\/cron/d' "$ETC"/cron_tmp 
                    echo "* * * * * /bin/bash $ETC/cron/every-minute.sh" >> "$ETC"/cron_tmp
                    echo "0 * * * * /bin/bash $ETC/cron/every-1-hour.sh" >> "$ETC"/cron_tmp
                    echo "0 */6 * * * /bin/bash $ETC/cron/every-6-hour.sh" >> "$ETC"/cron_tmp
                    echo "0 0 * * * /bin/bash $ETC/cron/every-day.sh" >> "$ETC"/cron_tmp
                    echo "0 0 1 * * /bin/bash $ETC/cron/every-month.sh" >> "$ETC"/cron_tmp

                    demyx_exec crontab "$ETC"/cron_tmp; rm "$ETC"/cron_tmp
                fi

                demyx_echo 'Creating stack .env'
                demyx_exec bash "$ETC"/functions/etc-env.sh
                
                demyx_echo 'Creating stack .yml'
                demyx_exec bash "$ETC"/functions/etc-yml.sh
                
                demyx_echo 'Updating files'
                demyx_exec rm -rf "$ETC"/functions; cp -R "$GIT"/etc/functions "$ETC"; rm -rf "$ETC"/cron; cp -R "$GIT"/etc/cron "$ETC"
                
                demyx stack -u
                demyx wp --dev=check
                ;;
            --)      
                shift
                break
                ;;
            -?*)
                printf '\e[31m[CRITICAL]\e[39m Unknown option: %s\n' "$2" >&2
                exit 1
                ;;
            *) 
                break
        esac
        shift
    done

    if [ -n "$DOMAIN" ] && [ -n "$EMAIL" ] && [ "$INSTALL" = rocketchat ]; then
        demyx_echo 'Making Rocket.Chat directory'
        demyx_exec mkdir -p "$APPS"/"$DOMAIN"
    
        demyx_echo 'Creating Rocket.Chat .env'
        demyx_exec bash "$ETC"/functions/rocketchat.sh "$DOMAIN" "$EMAIL" "$APPS"/"$DOMAIN"

        demyx_echo 'Creating Rocket.Chat .yml'
        cp "$GIT"/examples/rocketchat/docker-compose.yml "$APPS"/"$DOMAIN"
        
        cd "$APPS"/"$DOMAIN" && docker-compose up -d

        echo -e "\e[34m[INFO]\e[39m For first time install, please allow several minutes for Mongo to setup Rocket.Chat"
    elif [ -n "$DOMAIN" ] && [ "$INSTALL" = gitea ]; then
        demyx_echo 'Making Gitea directory'
        demyx_exec mkdir -p "$APPS"/"$DOMAIN"
        
        demyx_echo 'Creating SSH passthrough directory'
        demyx_exec sudo mkdir -p /app/gitea
        
        demyx_echo 'Changing SSH passthrough directory ownership'
        demyx_exec sudo chown -R "$USER":"$USER" /app/gitea
        
        demyx_echo 'Creating SSH passthrough executable'
        demyx_exec printf '#!/bin/sh\nssh -p 2222 -o StrictHostKeyChecking=no git@127.0.0.1 "SSH_ORIGINAL_COMMAND=\\"$SSH_ORIGINAL_COMMAND\\" $0 $@"' > /app/gitea/gitea
        
        demyx_echo 'Making executable executable'
        demyx_exec chmod +x /app/gitea/gitea
        
        demyx_echo 'Changing executable to root'
        demyx_exec sudo chown -R root:root /app/gitea
        
        demyx_echo 'Creating git user'
        demyx_exec sudo adduser git --gecos GECOS
        
        demyx_echo 'Creating SSH keys for git user'
        sudo -u git ssh-keygen -t rsa -b 4096 -C "Gitea Host Key"
        
        demyx_echo 'Setting ownershp to git home directory'
        demyx_exec sudo chown -R "$USER":"$USER" /home/git
        
        demyx_echo 'Modifying authorized_keys for git user'
        demyx_exec echo "no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty $(cat /home/git/.ssh/id_rsa.pub)" >> /home/git/.ssh/authorized_keys
        
        demyx_echo 'Changing ownership back to git'
        demyx_exec sudo chown -R git:git /home/git
        
        demyx_echo 'Creating Gitea .env'
        demyx_exec bash "$ETC"/functions/gitea.sh "$DOMAIN" "$APPS"/"$DOMAIN"

        demyx_echo 'Creating Gitea .yml'
        cp "$GIT"/examples/gitea/docker-compose.yml "$APPS"/"$DOMAIN"
        
        cd "$APPS"/"$DOMAIN" && docker-compose up -d

        cat "$APPS"/"$DOMAIN"/.env
    fi
fi