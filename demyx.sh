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
		demyx_exec "Creating the stack's .env" "$(bash "$ETC"/functions/etc-env.sh)"
		demyx_exec "Creating the stack's .yml" "$(bash "$ETC"/functions/etc-yml.sh)"
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
				echo "  --dom, --domain Primary flag to target your sites"
				echo "                  Example: demyx wp --dom=domain.tld --flag"
				echo
				echo "  --dev           Editing files from host to container will reflect on page reload"
				echo "                  Example: demyx wp --dom=domain.tld --dev, demyx wp --dom=domain.tld --dev=off"
				echo
				echo "  --down          Shorthand for docker-compose down"
				echo "                  Example: demyx wp --down=domain.tld, demyx wp --dom=domain.tld --down"
				echo 
				echo "  --env           Shows all environment variables for a given site"
				echo "                  Example: demyx wp --env=domain.tld, demyx wp --dom=domain.tld --env"
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
				echo "  --pma           Enable phpmyadmin: pma.primary-domain.tld"
				echo "                  Example: demyx wp --dom=domain.tld --pma, demyx wp --dom=domain.tld --pma=off"
				echo
				echo "  --port          Sets SFTP port for --dev, defaults to 2222"
				echo "                  Example: demyx wp --dom=domain.tld --dev --port=2022"
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
				echo "  --restart       Shorthand for docker-compose restart"
				echo "                  Example: demyx wp --restart=domain.tld, demyx wp --dom=domain.tld --restart"
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
				echo "  --shell         Shell into a site's wp/db container"
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
			--pma|--pma=on)
				PMA=on
				;;
			--pma=off)
				PMA=off
				;;
			--pma=)         
				die '"--pma" cannot be empty.'
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
			if [ "$SERVICE" = wp ]; then
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
					demyx_exec 'Exporting database' "$(docker run -it --rm --volumes-from "$WP" --network container:"$WP" wordpress:cli db export "$CONTAINER_NAME".sql)"
					demyx_exec 'Exporting files' "$(docker cp "$WP":/var/www/html "$CONTAINER_PATH"/backup)"
					demyx_exec 'Deleting exported database' "$(docker exec -it "$WP" rm /var/www/html/"$CONTAINER_NAME".sql)"
					demyx_exec 'Archiving directory' "$(tar -czf "$DOMAIN".tgz -C "$APPS" "$DOMAIN")"
					demyx_exec 'Moving archive' "$(mv "$APPS"/"$DOMAIN".tgz "$APPS_BACKUP")"
					demyx_exec 'Deleting backup directory' "$(rm -rf "$CONTAINER_PATH"/backup)"
				fi
			done
		else
			WP_CHECK=$(grep -s "WP_ID" "$CONTAINER_PATH"/.env || true)
			[[ -z "$WP_CHECK" ]] && die 'Not a WordPress app.'
			echo -e "\e[34m[INFO]\e[39m Backing up $DOMAIN"
			source "$CONTAINER_PATH"/.env
			demyx_exec 'Exporting database' "$(docker run -it --rm --volumes-from "$WP" --network container:"$WP" wordpress:cli db export "$CONTAINER_NAME".sql)"
			demyx_exec 'Exporting files' "$(docker cp "$WP":/var/www/html "$CONTAINER_PATH"/backup)"
			demyx_exec 'Deleting exported database' "$(docker exec -it "$WP" rm /var/www/html/"$CONTAINER_NAME".sql)"
			demyx_exec 'Archiving directory' "$(tar -czf "$DOMAIN".tgz -C "$APPS" "$DOMAIN")"
			demyx_exec 'Moving archive' "$(mv "$APPS"/"$DOMAIN".tgz "$APPS_BACKUP")"
			demyx_exec 'Deleting backup directory' "$(rm -rf "$CONTAINER_PATH"/backup)"
		fi
	elif [ -n "$CACHE" ] && [ -z "$RUN" ]; then
		WP_CHECK=$(grep -s "WP_ID" "$CONTAINER_PATH"/.env || true)
		[[ -z "$WP_CHECK" ]] && [[ "$CACHE" != check ]] && die 'Not a WordPress site.'
		[[ -f "$CONTAINER_PATH"/.env ]] && [[ -z "$RUN" ]] && source "$CONTAINER_PATH"/.env
		if [ "$CACHE" = on ]; then
			[[ "$FASTCGI_CACHE" = on ]] && die "Cache is already on for $DOMAIN"
			echo -e "\e[34m[INFO]\e[39m Turning on FastCGI Cache for $DOMAIN"
			NGINX_HELPER_CHECK=$(docker exec -it "$WP" sh -c 'ls wp-content/plugins' | grep nginx-helper || true)
			[[ -n "$NGINX_HELPER_CHECK" ]] && demyx_exec 'Activating nginx-helper' "$(docker run -it --rm --volumes-from "$WP" --network container:"$WP" wordpress:cli plugin activate nginx-helper)"
			[[ -z "$NGINX_HELPER_CHECK" ]] && demyx_exec 'Installing nginx-helper' "$(docker run -it --rm --volumes-from "$WP" --network container:"$WP" wordpress:cli plugin install nginx-helper --activate)"
			demyx_exec 'Configuring nginx-helper' "$(docker run -it --rm --volumes-from "$WP" --network container:"$WP" wordpress:cli option update rt_wp_nginx_helper_options '{"enable_purge":"1","cache_method":"enable_fastcgi","purge_method":"get_request","enable_map":null,"enable_log":null,"log_level":"INFO","log_filesize":"5","enable_stamp":null,"purge_homepage_on_edit":"1","purge_homepage_on_del":"1","purge_archive_on_edit":"1","purge_archive_on_del":"1","purge_archive_on_new_comment":"1","purge_archive_on_deleted_comment":"1","purge_page_on_mod":"1","purge_page_on_new_comment":"1","purge_page_on_deleted_comment":"1","redis_hostname":"127.0.0.1","redis_port":"6379","redis_prefix":"nginx-cache:","purge_url":"","redis_enabled_by_constant":0}' --format=json)"
			demyx_exec 'Configuring NGINX' "$(docker exec -it "$WP" sh -c "printf ',s/#include \/etc\/nginx\/cache\/http.conf;/include \/etc\/nginx\/cache\/http.conf;/g\nw\n' | ed /etc/nginx/nginx.conf > /dev/null; printf ',s/#include \/etc\/nginx\/cache\/server.conf;/include \/etc\/nginx\/cache\/server.conf;/g\nw\n' | ed /etc/nginx/nginx.conf > /dev/null; printf ',s/#include \/etc\/nginx\/cache\/location.conf;/include \/etc\/nginx\/cache\/location.conf;/g\nw\n' | ed /etc/nginx/nginx.conf > /dev/null")"
			demyx_exec 'Updating .env' "$(bash "$ETC"/functions/env.sh "$DOMAIN" "$ADMIN_USER" "$ADMIN_PASS" "on" "$FORCE")"
		elif [ "$CACHE" = off ]; then
			[[ "$FASTCGI_CACHE" = off ]] && die "Cache is already off for $DOMAIN"
			echo -e "\e[34m[INFO]\e[39m Turning off FastCGI Cache for $DOMAIN"
			demyx_exec 'Deactivating nginx-helper' "$(docker run -it --rm --volumes-from "$WP" --network container:"$WP" wordpress:cli plugin deactivate nginx-helper)"
			demyx_exec 'Configuring NGINX' "$(docker exec -it "$WP" sh -c "printf ',s/include \/etc\/nginx\/cache\/http.conf;/#include \/etc\/nginx\/cache\/http.conf;/g\nw\n' | ed /etc/nginx/nginx.conf > /dev/null; printf ',s/include \/etc\/nginx\/cache\/server.conf;/#include \/etc\/nginx\/cache\/server.conf;/g\nw\n' | ed /etc/nginx/nginx.conf > /dev/null; printf ',s/include \/etc\/nginx\/cache\/location.conf;/#include \/etc\/nginx\/cache\/location.conf;/g\nw\n' | ed /etc/nginx/nginx.conf > /dev/null")"
			demyx_exec 'Updating .env' "$(bash "$ETC"/functions/env.sh "$DOMAIN" "$ADMIN_USER" "$ADMIN_PASS" "off" "$FORCE")"
		elif [ "$CACHE" = check ]; then
			cd "$APPS" || exit
			for i in *
			do
				[[ -z "$WP_CHECK" ]] && continue
				CHECK=$(grep "FASTCGI_CACHE=on" "$i"/.env || true)
				[[ -n "$CHECK" ]] && echo "$i"
			done
		fi
		[[ "$CACHE" != check ]] && demyx_exec 'Reloading NGINX' "$(docker exec -it "$WP" nginx -s reload)"
	elif [ -n "$CDN" ] && [ -z "$RUN" ]; then
		WP_CHECK=$(grep -s "WP_ID" "$CONTAINER_PATH"/.env || true)
		[[ -z "$WP_CHECK" ]] && die 'Not a WordPress site.'
		[[ -f "$CONTAINER_PATH"/.env ]] && [[ -z "$RUN" ]] && source "$CONTAINER_PATH"/.env
		if [ "$CDN" = on ]; then
			echo -e "\e[34m[INFO]\e[39m Turning on CDN for $DOMAIN"
			CDN_ENABLER_CHECK=$(docker exec -it "$WP" sh -c 'ls wp-content/plugins' | grep cdn-enabler || true)
			CDN_OPTION_CHECK=$(demyx wp --dom="$DOMAIN" --wpcli='option get cdn_enabler' | grep "Could not get" || true)
			[[ -n "$CDN_ENABLER_CHECK" ]] && demyx_exec 'Activating cdn-enabler' "$(docker run -it --rm --volumes-from "$WP" --network container:"$WP" wordpress:cli plugin activate cdn-enabler)"
			[[ -z "$CDN_ENABLER_CHECK" ]] && demyx_exec 'Installing cdn-enabler' "$(docker run -it --rm --volumes-from "$WP" --network container:"$WP" wordpress:cli plugin install cdn-enabler --activate)"
			demyx_exec 'Configuring cdn-enabler' "$(docker run -it --rm --volumes-from "$WP" --network container:"$WP" wordpress:cli option update cdn_enabler "{\"url\":\"https:\/\/cdn.staticaly.com\/img\/$DOMAIN\",\"dirs\":\"wp-content,wp-includes\",\"excludes\":\".3g2, .3gp, .aac, .aiff, .alac, .apk, .avi, .css, .doc, .docx, .flac, .flv, .h264, .js, .json, .m4v, .mkv, .mov, .mp3, .mp4, .mpeg, .mpg, .ogg, .pdf, .php, .rar, .rtf, .svg, .tex, .ttf, .txt, .wav, .wks, .wma, .wmv, .woff, .woff2, .wpd, .wps, .xml, .zip, wp-content\/plugins, wp-content\/themes\",\"relative\":1,\"https\":1,\"keycdn_api_key\":\"\",\"keycdn_zone_id\":0}" --format=json)"
		elif [ "$CDN" = off ]; then
			echo -e "\e[34m[INFO]\e[39m Turning off CDN for $DOMAIN"
			demyx_exec 'Deactivating cdn-enabler' "$(docker run -it --rm --volumes-from "$WP" --network container:"$WP" wordpress:cli plugin deactivate cdn-enabler)"
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
		[[ -z "$WP_CHECK" ]] && die "$CLONE isn't a WordPress app"
		[[ -n "$DEV_MODE_CHECK" ]] && die "$CLONE is currently in dev mode. Please disable it before cloning"
		[[ -d "$CONTAINER_PATH" ]] && demyx wp --dom="$DOMAIN" --remove

		echo -e "\e[34m[INFO]\e[39m Cloning $CLONE to $DOMAIN"

		demyx_exec "Creating directory" "$(mkdir -p "$CONTAINER_PATH"/conf)"
		demyx_exec 'Creating .env' "$(bash "$ETC"/functions/env.sh "$DOMAIN" "$ADMIN_USER" "$ADMIN_PASS" "$CACHE" "$FORCE")"
		demyx_exec 'Creating .yml' "$(bash "$ETC"/functions/yml.sh "$CONTAINER_PATH" "$FORCE" $SSL)"
		demyx_exec 'Creating nginx.conf' "$(bash "$ETC"/functions/nginx.sh "$CONTAINER_PATH" "$DOMAIN" "$FORCE" "")" 
		demyx_exec 'Creating php.ini' "$(bash "$ETC"/functions/php.sh "$CONTAINER_PATH" "$FORCE")"
		demyx_exec 'Creating php-fpm.conf' "$(bash "$ETC"/functions/fpm.sh "$CONTAINER_PATH" "$DOMAIN" "$FORCE")"
		demyx_exec 'Creating access/error logs' "$(bash "$ETC"/functions/logs.sh "$DOMAIN" "$FORCE")"

		source "$CONTAINER_PATH"/.env

		demyx_exec 'Cloning database' "$(demyx wp --dom="$CLONE" --wpcli="db export clone.sql --exclude_tables=wp_users,wp_usermeta")"
		demyx_exec 'Cloning files' "$(docker cp "$CLONE_WP":/var/www/html "$CONTAINER_PATH"/clone)"
		demyx_exec 'Removing exported clone database' "$(demyx wp --dom="$CLONE" --cli='rm /var/www/html/clone.sql')"
		demyx_exec 'Creating data volume' "$(docker volume create wp_"$WP_ID")"
		demyx_exec 'Creating db volume' "$(docker volume create db_"$WP_ID")"
		demyx wp --dom="$DOMAIN" --service=db --action=up
		demyx_exec 'Initializing MariaDB' && sleep 10
		demyx_exec 'Creating temporary container' "$(docker run -d --rm --name clone_tmp --network traefik -v wp_"$WP_ID":/var/www/html demyx/nginx-php-wordpress tail -f /dev/null)"
		demyx_exec 'Copying files to temporary container' "$(cd "$CONTAINER_PATH"/clone && docker cp . clone_tmp:/var/www/html)"
		demyx_exec 'Removing old wp-config.php' "$(docker exec -it clone_tmp sh -c 'rm /var/www/html/wp-config.php')"
		demyx_exec 'Creating new wp-config.php' "$(docker run -it --rm --volumes-from clone_tmp --network container:clone_tmp wordpress:cli config create --dbhost="$WORDPRESS_DB_HOST" --dbname="$WORDPRESS_DB_NAME" --dbuser="$WORDPRESS_DB_USER" --dbpass="$WORDPRESS_DB_PASSWORD")"
		demyx_exec 'Configuring wp-config.php for reverse proxy' "$(echo "#!/bin/bash" > "$CONTAINER_PATH"/proto.sh; echo "sed -i \"s/$table_prefix = 'wp_';/$table_prefix = 'wp_';\n\n\/\/ If we're behind a proxy server and using HTTPS, we need to alert Wordpress of that fact\n\/\/ see also http:\/\/codex.wordpress.org\/Administration_Over_SSL#Using_a_Reverse_Proxy\nif (isset($\_SERVER['HTTP_X_FORWARDED_PROTO']) \&\& $\_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {\n\t$\_SERVER['HTTPS'] = 'on';\n}\n/g\" /var/www/html/wp-config.php" >> "$CONTAINER_PATH"/proto.sh; docker cp "$CONTAINER_PATH"/proto.sh clone_tmp:/; rm "$CONTAINER_PATH"/proto.sh; docker exec -it clone_tmp sh -c 'bash /proto.sh && rm /proto.sh')"

		if [ -n "$ADMIN_EMAIL" ]; then
			WORDPRESS_EMAIL="$ADMIN_EMAIL"
		else
			WORDPRESS_EMAIL=info@"$DOMAIN"
		fi

		demyx_exec 'Installing WordPress' "$(docker run -it --rm --volumes-from clone_tmp --network container:clone_tmp wordpress:cli core install --url="$DOMAIN" --title="$DOMAIN" --admin_user="$WORDPRESS_USER" --admin_password="$WORDPRESS_USER_PASSWORD" --admin_email="$WORDPRESS_EMAIL" --skip-email)"
		demyx_exec 'Importing clone database' "$(docker run -it --rm --volumes-from clone_tmp --network container:clone_tmp wordpress:cli db import clone.sql)"
		demyx_exec 'Replacing old URLs' "$(docker run -it --rm --volumes-from clone_tmp --network container:clone_tmp wordpress:cli search-replace "$CLONE" "$DOMAIN")"
		demyx_exec 'Creating wp-config.php salts' "$(docker run -it --rm --volumes-from clone_tmp --network container:clone_tmp wordpress:cli config shuffle-salts)"
		demyx_exec 'Removing temporary directory' "$(cd .. && rm -rf "$CONTAINER_PATH"/clone)"
		demyx_exec 'Stopping temporary container' "$(docker stop clone_tmp)"

		demyx wp --dom="$DOMAIN" --service=wp --up

		[[ "$DEV" = on ]] && demyx wp --dom="$DOMAIN" --dev

		PRINT_TABLE="DOMAIN, $DOMAIN/wp-admin\n"
		PRINT_TABLE+="WORDPRESS USER, $WORDPRESS_USER\n"
		PRINT_TABLE+="WORDPRESS PASSWORD, $WORDPRESS_USER_PASSWORD"

		printTable ',' "$(echo -e $PRINT_TABLE)"
	elif [ -n "$DEV" ] && [ -z "$RUN" ] && [ -z "$CLONE" ]; then
		SSH_CONTAINER_CHECK=$(docker ps -aq -f name=ssh)
		SSH_VOLUME_CHECK=$(docker volume ls | grep ssh || true)
		WP_CHECK=$(grep -s "WP_ID" "$CONTAINER_PATH"/.env || true)

		if [ -z "$SSH_VOLUME_CHECK" ] && [ "$DEV" != check ]; then
			echo -e "\e[34m[INFO]\e[39m SSH volume not found, creating now..."
			demyx_exec 'Creating SSH volume' "$(docker volume create ssh)"
			demyx_exec 'Creating temporary SSH container' "$(docker run -d --rm --name ssh -v ssh:/home/www-data/.ssh demyx/ssh)"
			demyx_exec 'Copying authorized_keys to SSH volume' "$(docker cp /home/"$USER"/.ssh/authorized_keys ssh:/home/www-data/.ssh/authorized_keys)"
			demyx_exec 'Stopping temporary SSH container' "$(docker stop ssh)"
		fi

		if [ "$DEV" = on ]; then
			source "$CONTAINER_PATH"/.env
			if [ -z "$FORCE" ]; then 
				DEV_MODE_CHECK=$(grep "sendfile off" "$CONTAINER_PATH"/conf/nginx.conf || true)
				[[ -n "$DEV_MODE_CHECK" ]] && die "Development mode is already turned on for $DOMAIN"
			fi
			[[ -n "$SSH_CONTAINER_CHECK" ]] && demyx_exec 'SSH container detected, stopping now' "$(docker stop ssh)"

			echo -e "\e[34m[INFO]\e[39m Turning on development mode for $DOMAIN"

			demyx_exec 'Restarting NGINX' "$(docker exec -it "$WP" sh -c "printf ',s/sendfile on/sendfile off/g\nw\n' | ed /etc/nginx/nginx.conf; nginx -s reload")"
			demyx_exec 'Restarting php-fpm' "$(docker exec -it "$WP" sh -c "mv /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini /; pkill php-fpm; php-fpm -D")"
			
			[[ -z "$PORT" ]] && PORT=2222

			demyx_exec 'Creating SSH container' "$(docker run -d --rm --name ssh -v ssh:/home/www-data/.ssh -v wp_"$WP_ID":/var/www/html -p "$PORT":22 demyx/ssh)"

			PRINT_TABLE="SFTP ADDRESS, $PRIMARY_DOMAIN\n"
			PRINT_TABLE+="SFTP USER, www-data\n"
			PRINT_TABLE+="SFTP PORT, $PORT"

			printTable ',' "$(echo -e $PRINT_TABLE)"
		elif [ "$DEV" = off ]; then
			source "$CONTAINER_PATH"/.env
			if [ -z "$FORCE" ]; then
				DEV_MODE_CHECK=$(grep "sendfile on" "$CONTAINER_PATH"/conf/nginx.conf || true)
				[[ -n "$DEV_MODE_CHECK" ]] && die "Development mode is already turned off for $DOMAIN"
			fi
			echo -e "\e[34m[INFO]\e[39m Turning off development mode for $DOMAIN"
			
			demyx_exec 'Stopping SSH container' "$(docker stop ssh)"
			demyx_exec 'Restarting NGINX' "$(docker exec -it "$WP" sh -c "printf ',s/sendfile off/sendfile on/g\nw\n' | ed /etc/nginx/nginx.conf; nginx -s reload")"
			demyx_exec 'Restarting php-fpm' "$(docker exec -it "$WP" sh -c "mv /docker-php-ext-opcache.ini /usr/local/etc/php/conf.d; pkill php-fpm; php-fpm -D")"
		elif [ "$DEV" = check ] && [ -n "$ALL" ]; then
			cd "$APPS" || exit
			for i in *
			do
				WP_CHECK=$(grep -s "WP_ID" "$APPS"/"$i"/.env || true)
				[[ -n "$WP_CHECK" ]] && bash "$ETC"/functions/warnings.sh "$i"
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
						cd "$APPS"/"$i" || exit
						/usr/local/bin/docker-compose up -d --scale wp_"${WP_ID}"="${MONITOR_SCALE}" wp_"${WP_ID}"
						/usr/local/bin/docker-compose up -d --scale db_"${WP_ID}"="${MONITOR_SCALE}" db_"${WP_ID}"
						[[ -f "$DEMYX"/custom/callback.sh ]] && bash "$DEMYX"/custom/callback.sh "monitor" "$i" "$MONITOR_CHECK"
					fi
				fi
			elif (( "$MONITOR_CHECK" <= "$MONITOR_CPU" )); then
				if (( "$MONITOR_COUNT" > 0 )); then
					MONITOR_COUNT_DOWN=$((MONITOR_COUNT-1))
					echo "MONITOR_COUNT=${MONITOR_COUNT_DOWN}" > "$APPS"/"$i"/.monitor
				else
					if [[ "$MONITOR_COUNT" = 0 ]]; then
						cd "$APPS"/"$i" || exit
						/usr/local/bin/docker-compose up -d --scale wp_"${WP_ID}"=1 wp_"${WP_ID}"
						/usr/local/bin/docker-compose up -d --scale db_"${WP_ID}"=1 db_"${WP_ID}"
					fi
				fi
			fi
		done
	elif [ -n "$PMA" ]; then
		PMA_EXIST=$(docker ps -aq -f name=phpmyadmin)
		if [ "$PMA" = "on" ]; then
			[[ -n "$PMA_EXIST" ]] && docker stop phpmyadmin && docker rm phpmyadmin
			
			source "$CONTAINER_PATH"/.env

			demyx_exec 'Creating phpMyAdmin' "$(docker run -d --rm --name phpmyadmin --network traefik -e PMA_HOST="${DB}" -e MYSQL_ROOT_PASSWORD="${MARIADB_ROOT_PASSWORD}" -l "traefik.enable=1" -l "traefik.frontend.rule=Host:pma.${PRIMARY_DOMAIN}" -l "traefik.port=80" -l "traefik.frontend.redirect.entryPoint=https" -l "traefik.frontend.headers.forceSTSHeader=${FORCE_STS_HEADER}" -l "traefik.frontend.headers.STSSeconds=${STS_SECONDS}" -l "traefik.frontend.headers.STSIncludeSubdomains=${STS_INCLUDE_SUBDOMAINS}" -l "traefik.frontend.headers.STSPreload=${STS_PRELOAD}" phpmyadmin/phpmyadmin)"

			PRINT_TABLE="PHPMYADMIN, pma.$PRIMARY_DOMAIN\n"
			PRINT_TABLE+="USERNAME, $WORDPRESS_DB_USER\n"
			PRINT_TABLE+="PASSWORD, $WORDPRESS_DB_PASSWORD"

			printTable ',' "$(echo -e $PRINT_TABLE)"
		else
			demyx_exec 'Stopping phpMyAdmin' "$(docker stop phpmyadmin)"
		fi
	elif [ -n "$RATE_LIMIT" ]; then
		WP_CHECK=$(grep -s "WP_ID" "$CONTAINER_PATH"/.env || true)
		[[ -z "$WP_CHECK" ]] && die 'Not a WordPress app.'

		source "$CONTAINER_PATH"/.env

		if [ "$RATE_LIMIT" = on ]; then
			echo -e "\e[34m[INFO]\e[39m Turning on rate limiting for $DOMAIN"
			demyx_exec 'Restarting NGINX' "$(docker exec -it "$WP" sh -c "printf ',s/#limit_req/limit_req/g\nw\n' | ed /etc/nginx/nginx.conf; nginx -s reload")"
		elif [ "$RATE_LIMIT" = off ]; then
			echo -e "\e[34m[INFO]\e[39m Turning off rate limiting for $DOMAIN"
			demyx_exec 'Restarting NGINX' "$(docker exec -it "$WP" sh -c "printf ',s/limit_req/#limit_req/g\nw\n' | ed /etc/nginx/nginx.conf; nginx -s reload")"
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
					[[ -n "$CACHE_CHECK" ]] && CACHE=on
					[[ -z "$NO_RESTART" ]] && demyx wp --dom="$i" --down
					demyx_exec 'Creating .env' "$(bash "$ETC"/functions/env.sh "$DOMAIN" "$ADMIN_USER" "$ADMIN_PASS" "$CACHE" "$FORCE")"
					demyx_exec 'Creating .yml' "$(bash "$ETC"/functions/yml.sh "$CONTAINER_PATH" "$FORCE" $SSL)"
					demyx_exec 'Creating nginx.conf' "$(bash "$ETC"/functions/nginx.sh "$CONTAINER_PATH" "$DOMAIN" "$FORCE")" 
					demyx_exec 'Creating php.ini' "$(bash "$ETC"/functions/php.sh "$CONTAINER_PATH" "$FORCE")"
					demyx_exec 'Creating php-fpm.conf' "$(bash "$ETC"/functions/fpm.sh "$CONTAINER_PATH" "$DOMAIN" "$FORCE")"
					demyx_exec 'Creating access/error logs' "$(bash "$ETC"/functions/logs.sh "$DOMAIN" "$FORCE")"
					[[ -z "$NO_RESTART" ]] && demyx wp --dom="$i" --up
				fi
			done
		else
			WP_CHECK=$(grep -s "WP_ID" "$CONTAINER_PATH"/.env || true)
			CACHE_CHECK=$(grep -s "FASTCGI_CACHE=on" "$CONTAINER_PATH"/.env || true)
			[[ -n "$CACHE_CHECK" ]] && CACHE=on
			[[ -z "$WP_CHECK" ]] && die 'Not a WordPress app.'
			[[ -z "$DOMAIN" ]] && die 'Domain is missing or add --all'
			echo -e "\e[34m[INFO]\e[39m Refreshing $DOMAIN"
			[[ -z "$NO_RESTART" ]] && demyx wp --dom="$DOMAIN" --down
			demyx_exec 'Creating .env' "$(bash "$ETC"/functions/env.sh "$DOMAIN" "$ADMIN_USER" "$ADMIN_PASS" "$CACHE" "$FORCE")"
			demyx_exec 'Creating .yml' "$(bash "$ETC"/functions/yml.sh "$CONTAINER_PATH" "$FORCE" $SSL)"
			demyx_exec 'Creating nginx.conf' "$(bash "$ETC"/functions/nginx.sh "$CONTAINER_PATH" "$DOMAIN" "$FORCE")" 
			demyx_exec 'Creating php.ini' "$(bash "$ETC"/functions/php.sh "$CONTAINER_PATH" "$FORCE")"
			demyx_exec 'Creating php-fpm.conf' "$(bash "$ETC"/functions/fpm.sh "$CONTAINER_PATH" "$DOMAIN" "$FORCE")"
			demyx_exec 'Creating access/error logs' "$(bash "$ETC"/functions/logs.sh "$DOMAIN" "$FORCE")"
			[[ -z "$NO_RESTART" ]] && demyx wp --dom="$DOMAIN" --up
		fi
	elif [ -n "$RESTART" ]; then
		cd "$APPS" || exit
		if [ -n "$ALL" ]; then
			for i in *
			do
				WP_CHECK=$(grep -s "WP_ID" "$APPS"/"$i"/.env || true)
				[[ -z "$WP_CHECK" ]] && continue
				cd "$APPS"/"$i"
				docker-compose restart
			done
		else
			WP_CHECK=$(grep -s "WP_ID" "$CONTAINER_PATH"/.env || true)
			[[ -z "$WP_CHECK" ]] && die 'Not a WordPress app.'
			[[ -z "$DOMAIN" ]] && die 'Domain is missing, use --dom or --restart=domain.tld'
			cd "$CONTAINER_PATH"
			docker-compose restart
		fi
	elif [ -n "$RESTORE" ]; then
		[[ -d "$CONTAINER_PATH" ]] && demyx wp --dom="$DOMAIN" --remove
		[[ ! -f "$APPS_BACKUP"/"$DOMAIN".tgz ]] && die "No backups found for $DOMAIN"
		echo -e "\e[34m[INFO]\e[39m Restoring $DOMAIN"
		demyx_exec 'Extracting archive' "$(tar -xzf "$APPS_BACKUP"/"$DOMAIN".tgz -C "$APPS")"
		source "$CONTAINER_PATH"/.env
		demyx wp --dom="$DOMAIN" --down
		VOLUME_CHECK=$(docker volume ls)
		[[ -n "$(grep wp_${WP_ID} <<< $VOLUME_CHECK || true)" ]] && demyx_exec 'Removing data volume' "$(docker volume rm wp_"$WP_ID")"
		[[ -n "$(grep db_${WP_ID} <<< $VOLUME_CHECK || true)" ]] && demyx_exec 'Removing database volume' "$(docker volume rm db_"$WP_ID")"
		demyx_exec 'Creating data volume' "$(docker volume create wp_"$WP_ID")"
		demyx_exec 'Creating db volume' "$(docker volume create db_"$WP_ID")"
		demyx wp --dom="$DOMAIN" --service=db --action=up
		demyx_exec 'Initializing MariaDB' && sleep 10
		demyx_exec 'Creating temporary container' "$(docker run -d --rm --name restore_tmp --network traefik -v wp_"$WP_ID":/var/www/html demyx/nginx-php-wordpress tail -f /dev/null)"
		demyx_exec 'Copying files' "$(cd "$CONTAINER_PATH"/backup && docker cp . restore_tmp:/var/www/html)"
		demyx_exec 'Importing database' "$(docker run -it --rm --volumes-from restore_tmp --network container:restore_tmp wordpress:cli db import "$CONTAINER_NAME".sql)"
		demyx_exec 'Removing backup database' "$(docker exec -it restore_tmp sh -c "rm /var/www/html/$CONTAINER_NAME.sql")"  
		demyx_exec 'Stopping temporary container' "$(docker stop restore_tmp)"
		demyx_exec 'Removing backup directory' "$(rm -rf "$CONTAINER_PATH"/backup)"
		[[ ! -f "$LOGS"/"$DOMAIN".access.log ]] &&  demyx_exec 'Creating logs' "$(bash "$ETC"/functions/logs.sh "$DOMAIN" "$FORCE")"
		demyx wp --dom="$DOMAIN" --service=wp --action=up
	elif [ -n "$REMOVE" ]; then
		if [ -z "$FORCE" ]; then
			echo -e "\e[33m"
			if [ -z "$DOMAIN" ]; then
				read -rep "[WARNING] Delete all sites? [yY]: " DELETE_SITE
			else
				read -rep "[WARNING] Delete/overwrite $DOMAIN? [yY]: " DELETE_SITE
			fi
			echo -e "\e[39m"
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
					cd "$APPS"/"$i"
					docker-compose kill
					docker-compose rm -f
					[[ -n "$(grep wp_${WP_ID} <<< $VOLUME_CHECK || true)" ]] && demyx_exec 'Deleting data volume' "$(docker volume rm wp_"$WP_ID")" 
					[[ -n "$(grep db_${WP_ID} <<< $VOLUME_CHECK || true)" ]] && demyx_exec 'Deleting db volume' "$(docker volume rm db_"$WP_ID")" 
					[[ -f "$LOGS"/"$DOMAIN".access.log ]] && demyx_exec 'Deleting logs' "$(rm "$LOGS"/"$DOMAIN".access.log; rm "$LOGS"/"$DOMAIN".error.log)"
					demyx_exec 'Deleting directory' "$(rm -rf "$APPS"/"$i")"
				fi
			done
		else
			[[ ! -f "$CONTAINER_PATH"/.env ]] && die "$DOMAIN is not a valid WordPress app or doesn't exist"
			WP_CHECK=$(grep -s "WP_ID" "$CONTAINER_PATH"/.env || true)
			if [ -n "$WP_CHECK" ]; then
				source "$CONTAINER_PATH"/.env
				echo -e "\e[31m[CRITICAL]\e[39m Removing $DOMAIN"
				cd "$CONTAINER_PATH"
				docker-compose kill
				docker-compose rm -f
				[[ -n "$(grep wp_${WP_ID} <<< $VOLUME_CHECK || true)" ]] && demyx_exec 'Deleting data volume' "$(docker volume rm wp_"$WP_ID")" 
				[[ -n "$(grep db_${WP_ID} <<< $VOLUME_CHECK || true)" ]] && demyx_exec 'Deleting db volume' "$(docker volume rm db_"$WP_ID")" 
				[[ -f "$LOGS"/"$DOMAIN".access.log ]] && demyx_exec 'Deleting logs' "$(rm "$LOGS"/"$DOMAIN".access.log; rm "$LOGS"/"$DOMAIN".error.log)"
				demyx_exec 'Deleting directory' "$(rm -rf "$CONTAINER_PATH")"
			else
				die "$DOMAIN a WordPress app"
			fi
		fi
	elif [ -n "$RUN" ]; then
		if [ -d "$CONTAINER_PATH" ]; then
			if [ -n "$FORCE" ]; then
				demyx wp --remove="$DOMAIN" --force
			else
				demyx wp --remove="$DOMAIN"
			fi
		fi

		echo -e "\e[34m[INFO]\e[39m Creating $DOMAIN"

		demyx_exec "Creating directory" "$(mkdir -p "$CONTAINER_PATH"/conf)"

		# Future plans for subnets
		#bash $ETC/functions/subnet.sh $DOMAIN $CONTAINER_NAME create
		demyx_exec 'Creating .env' "$(bash "$ETC"/functions/env.sh "$DOMAIN" "$ADMIN_USER" "$ADMIN_PASS" "" "$FORCE")"
		demyx_exec 'Creating .yml' "$(bash "$ETC"/functions/yml.sh "$CONTAINER_PATH" "$FORCE" $SSL)"
		demyx_exec 'Creating nginx.conf' "$(bash "$ETC"/functions/nginx.sh "$CONTAINER_PATH" "$DOMAIN" "$FORCE")" 
		demyx_exec 'Creating php.ini' "$(bash "$ETC"/functions/php.sh "$CONTAINER_PATH" "$FORCE")"
		demyx_exec 'Creating php-fpm.conf' "$(bash "$ETC"/functions/fpm.sh "$CONTAINER_PATH" "$DOMAIN" "$FORCE")"
		demyx_exec 'Creating access/error logs' "$(bash "$ETC"/functions/logs.sh "$DOMAIN" "$FORCE")"

		source "$CONTAINER_PATH"/.env

		demyx_exec 'Creating data volume' "$(docker volume create wp_"$WP_ID")"
		demyx_exec 'Creating db volume' "$(docker volume create db_"$WP_ID")"

		cd "$CONTAINER_PATH" || exit
		docker-compose up -d --remove-orphans

		if [ -n "$ADMIN_EMAIL" ]; then
			WORDPRESS_EMAIL="$ADMIN_EMAIL"
		else
			WORDPRESS_EMAIL=info@"$DOMAIN"
		fi

		demyx_exec 'Initializing MariaDB' && sleep 10
		demyx_exec 'Configuring wp-config.php' "$(docker run -it --rm --volumes-from "$WP" --network container:"$WP" wordpress:cli core install --url="$DOMAIN" --title="$DOMAIN" --admin_user="$WORDPRESS_USER" --admin_password="$WORDPRESS_USER_PASSWORD" --admin_email="$WORDPRESS_EMAIL" --skip-email)"
		demyx_exec 'Configuring permalinks' "$(docker run -it --rm --volumes-from "$WP" --network container:"$WP" wordpress:cli rewrite structure '/%category%/%postname%/')"

		[[ "$CDN" = on ]] && demyx wp --dom="$DOMAIN" --cdn
		[[ "$DEV" = on ]] && demyx wp --dom="$DOMAIN" --dev
		[[ "$CACHE" = on ]] && demyx wp --dom="$DOMAIN" --cache

		PRINT_TABLE="DOMAIN, $DOMAIN/wp-admin\n"
		PRINT_TABLE+="WORDPRESS USER, $WORDPRESS_USER\n"
		PRINT_TABLE+="WORDPRESS PASSWORD, $WORDPRESS_USER_PASSWORD\n"

		printTable ',' "$(echo -e $PRINT_TABLE)"
	elif [ -n "$DEMYX_SHELL" ]; then
		source "$CONTAINER_PATH"/.env
		if [ "$DEMYX_SHELL" = "wp" ]; then
			docker exec -it "$WP" sh
		else
			docker exec -it "$DB" sh
		fi
	elif [ -n "$SCALE" ]; then
		cd "$CONTAINER_PATH" || exit
		source .env
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
		bash "$ETC"/functions/yml.sh "$CONTAINER_PATH" "$FORCE" "$SSL"
		demyx wp --dom="$DOMAIN" --service=wp --action=up
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
					docker run -it --rm \
					--volumes-from "$WP" \
					--network container:"$WP" \
					wordpress:cli $WPCLI
				fi
			done
		else
			WP_CHECK=$(grep -s "WP_ID" "$CONTAINER_PATH"/.env || true)
			[[ -z "$WP_CHECK" ]] && die 'Not a WordPress app.'
			source "$CONTAINER_PATH"/.env
			docker run -it --rm \
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
		demyx_exec 'demyx log -f' && clear && tail -f "$LOGS"/demyx.log
	elif [ -n "$CLEAR" ]; then
		demyx_exec 'Clearing logs' "$(echo > "$LOGS"/demyx.log)"
	else
		demyx_exec 'demyx log' && less +G "$LOGS"/demyx.log
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
				[[ -n "$CTOP_CHECK" ]] && demyx_exec 'Stopping old ctop container' "$(docker stop "$CTOP_CHECK")"
				demyx_exec 'Starting ctop' && docker run --rm -ti -v /var/run/docker.sock:/var/run/docker.sock:ro quay.io/vektorlab/ctop
				;;
			-u|--update)
				# Cron check
				CRON_WP_CHECK=$(crontab -l | grep "cron event run --due-now" || true)
				CRON_MONITOR_CHECK=$(crontab -l | grep "demyx wp --monitor" || true)

				if [ -z "$CRON_WP_CHECK" ]; then
					# WP Cron every 2 hours
					echo -e "\e[34m[INFO]\e[39m Demyx cron not found, installing now to crontabs"
					crontab -l > "$ETC"/CRON_WP_CHECK
					echo "0 */2 * * * /usr/local/bin/demyx wp --all --wpcli='cron event run --due-now'" >> "$ETC"/CRON_WP_CHECK
					demyx_exec 'Modifying crontab for WordPress cron' "$(crontab "$ETC"/CRON_WP_CHECK)"
					demyx_exec 'Removing temporary crontab' "$(rm "$ETC"/CRON_WP_CHECK)"
				fi

				if [ -z "$CRON_MONITOR_CHECK" ]; then
					# WP Cron every minute
					echo -e "\e[34m[INFO]\e[39m Auto scaling cron not found, installing now to crontabs"
					crontab -l > "$ETC"/CRON_MONITOR_CHECK
					echo "* * * * * /usr/local/bin/demyx wp --monitor" >> "$ETC"/CRON_MONITOR_CHECK
					demyx_exec 'Modifying crontab for monitor cron' "$(crontab "$ETC"/CRON_MONITOR_CHECK)"
					demyx_exec 'Removing temporary crontab' "$(rm "$ETC"/CRON_MONITOR_CHECK)"
					demyx wp --refresh --all
				fi

				# Check for custom folder where users can place custom shell scripts
				if [ ! -d "$DEMYX"/custom ]; then
					demyx_exec 'Creating custom directory' "$(mkdir "$DEMYX"/custom)"
					echo "#!/bin/bash
					# Demyx
					# https://github.com/demyxco/demyx
					# Feel free to edit/modify this file since it will not be updated.

					TYPE=\$1

					#if [ \"\$TYPE\" = monitor ]; then
					#DOMAIN=\$2
					#CPU=\$3
					#do code
					#fi" | tr -d '\011' > "$DEMYX"/custom/callback.sh
				fi

				if [ -f /etc/cron.daily/demyx-daily ]; then
					# Will remove this May 1st
					echo -e "\e[33m[WARNING]\e[39m Old cron for Demyx detected, deleting now..." 
					sudo rm /etc/cron.daily/demyx-daily
				fi

				cd "$GIT" || exit

				if [ -n "$FORCE" ]; then
					echo -e "\e[33m[WARNING]\e[39m Forcing an update for Demyx..."
				else
					echo -e "\e[34m[INFO]\e[39m Checking for updates"
				fi

				CHECK_FOR_UPDATES=$(git pull | grep "Already up to date." || true)

				if [ -n "$FORCE" ] || [ "$CHECK_FOR_UPDATES" != "Already up to date" ]; then
					[[ -z "$FORCE" ]] && echo -e "\e[34m[INFO]\e[39m Updating Demyx..."
					demyx_exec 'Creating stack .env' "$(bash "$ETC"/functions/etc-env.sh)"
					demyx_exec 'Creating stack .yml' "$(bash "$ETC"/functions/etc-yml.sh)"
					demyx_exec 'Updating files' "$(rm -rf "$ETC"/functions; cp -R "$GIT"/etc/functions "$ETC")"
					demyx stack -u
				else
					echo -e "\e[32m[SUCCESS]\e[39m Already up to date"
				fi
				
				demyx wp --dev=check --all
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
		demyx_exec 'Making Rocket.Chat directory' "$(mkdir -p "$APPS"/"$DOMAIN")"
		demyx_exec 'Creating .yml' "$(bash "$ETC"/functions/rocketchat.sh "$DOMAIN" "$EMAIL" "$APPS"/"$DOMAIN")"
		cd "$APPS"/"$DOMAIN" && docker-compose up -d
	elif [ -n "$DOMAIN" ] && [ "$INSTALL" = gitea ]; then
		demyx_exec 'Making Gitea directory' "$(mkdir -p "$APPS"/"$DOMAIN")"
		demyx_exec 'Creating SSH passthrough directory' "$(sudo mkdir -p /app/gitea)"
		demyx_exec 'Changing SSH passthrough directory ownership' "$(sudo chown -R "$USER":"$USER" /app/gitea)"
		demyx_exec 'Creating SSH passthrough executable' "$(printf '#!/bin/sh\nssh -p 2222 -o StrictHostKeyChecking=no git@127.0.0.1 "SSH_ORIGINAL_COMMAND=\\"$SSH_ORIGINAL_COMMAND\\" $0 $@"' > /app/gitea/gitea)"
		demyx_exec 'Making executable executable' "$(chmod +x /app/gitea/gitea)"
		demyx_exec 'Changing executable to root' "$(sudo chown -R root:root /app/gitea)"
		demyx_exec 'Creating git user' "$(sudo adduser git --gecos GECOS)"
		demyx_exec 'Creating SSH keys for git user' "$(sudo -u git ssh-keygen -t rsa -b 4096 -C "Gitea Host Key")"
		demyx_exec 'Setting ownershp to git home directory' "$(sudo chown -R "$USER":"$USER" /home/git)"
		demyx_exec 'Modifying authorized_keys for git user' "$(echo "no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty $(cat /home/git/.ssh/id_rsa.pub)" >> /home/git/.ssh/authorized_keys)"
		demyx_exec 'Changing ownership back to git' "$(sudo chown -R git:git /home/git)"
		demyx_exec 'Creating .yml' "$(bash "$ETC"/functions/gitea.sh "$DOMAIN" "$APPS"/"$DOMAIN")"
		cd "$APPS"/"$DOMAIN" && docker-compose up -d
	fi

fi