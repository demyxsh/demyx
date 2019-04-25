#!/bin/bash
# Demyx
# https://github.com/demyxco/demyx

die() {
	printf '\n\e[31m[CRITICAL]\e[39m %s\n\n' "$1" >&2
	exit 1
}

source /srv/demyx/etc/.env

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
				echo "  --restart       Shorthand for docker-compose restart"
				echo "                  Example: demyx stack --service=traefik --restart, demyx stack --restart"
				echo
				echo "  --up            Shorthand for docker-compose up -d"
				echo "                  Example: demyx stack --service=traefik --up, demyx stack --up"
				echo
				echo "  --service       Services: traefik, watchtower, logrotate"
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
				printf '\e[31m[WARNING]\e[39m Unknown option: %s\n' "$2" >&2
				exit 1
				;;
			*) 
				break
		esac
		shift
	done

	cd "$ETC" || exit
	
	if [ "$ACTION" = up ] && [ -n "$SERVICE" ]; then
		docker-compose up -d "$SERVICE"
	elif [ "$ACTION" = up ] && [ -z "$SERVICE" ]; then
		docker-compose up -d
	elif [ "$ACTION" = down ] && [ -n "$SERVICE" ]; then
		docker-compose stop "$SERVICE" && docker-compose rm -f "$SERVICE"
	elif [ "$ACTION" = down ] && [ -z "$SERVICE" ]; then
		docker-compose stop && docker-compose rm -f
	elif [ -n "$ACTION" ] && [ -z "$SERVICE" ]; then
		docker-compose $ACTION
	elif [ -n "$ACTION" ] && [ -n "$SERVICE" ]; then
		docker-compose $ACTION "$SERVICE"
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
				echo "  --du            Get a site's directory total size"
				echo "                  Example: demyx wp --down=domain.tld --du, demyx wp --down=domain.tld --du=wp, demyx wp --down=domain.tld --du=db"
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
				printf '\e[31m[WARNING]\e[39m Unknown option: %s\n' "$2" >&2
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
				WP_CHECK=$(grep -s "WP_ID" "$APPS"/"$i"/.env)
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
				WP_CHECK=$(grep -s "WP_ID" "$APPS"/"$i"/.env)
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
				WP_CHECK=$(grep -s "WP_ID" "$APPS"/"$i"/.env)
				if [ -n "$WP_CHECK" ]; then
					echo -e "\e[34m[INFO]\e[39m Backing up $i"
					source "$i"/.env
					demyx wp --dom="$DOMAIN" --wpcli="db export ${CONTAINER_NAME}.sql"
					docker cp "$WP":/var/www/html "$CONTAINER_PATH"/backup
					demyx wp --dom="$DOMAIN" --cli="rm /var/www/html/${CONTAINER_NAME}.sql"
					tar -czf "$i".tgz "$i"
					mv "$i".tgz "$APPS_BACKUP"
					rm -rf "$CONTAINER_PATH"/backup
				fi
			done
		else
			WP_CHECK=$(grep -s "WP_ID" "$CONTAINER_PATH"/.env)
			[[ -z "$WP_CHECK" ]] && die 'Not a WordPress app.'
			echo -e "\e[34m[INFO]\e[39m Backing up $DOMAIN"
			source "$CONTAINER_PATH"/.env
			demyx wp --dom="$DOMAIN" --wpcli="db export ${CONTAINER_NAME}.sql"
			docker cp "$WP":/var/www/html "$CONTAINER_PATH"/backup
			demyx wp --dom="$DOMAIN" --cli="rm /var/www/html/${CONTAINER_NAME}.sql"
			tar -czvf "$DOMAIN".tgz "$DOMAIN"
			mv "$DOMAIN".tgz "$APPS_BACKUP"
			rm -rf "$CONTAINER_PATH"/backup
		fi
	elif [ -n "$CACHE" ] && [ -z "$RUN" ]; then
		WP_CHECK=$(grep -s "WP_ID" "$CONTAINER_PATH"/.env)
		[[ -z "$WP_CHECK" ]] && [[ "$CACHE" != check ]] && die 'Not a WordPress site.'
		[[ -f "$CONTAINER_PATH"/.env ]] && [[ -z "$RUN" ]] && source "$CONTAINER_PATH"/.env
		if [ "$CACHE" = on ]; then
			echo -e "\e[34m[INFO]\e[39m Turning on FastCGI Cache for $DOMAIN"
			NGINX_HELPER_CHECK=$(docker exec -it "$WP" sh -c '[[ -d wp-content/plugins/nginx-helper ]] && echo 1')
			if [ -n "$NGINX_HELPER_CHECK" ]; then
				docker run -it --rm \
				--volumes-from "$WP" \
				--network container:"$WP" \
				wordpress:cli plugin activate nginx-helper
			else
				docker run -it --rm \
				--volumes-from "$WP" \
				--network container:"$WP" \
				wordpress:cli plugin install nginx-helper --activate
			fi

			docker run -it --rm \
			--volumes-from "$WP" \
			--network container:"$WP" \
			wordpress:cli option update rt_wp_nginx_helper_options '{"enable_purge":"1","cache_method":"enable_fastcgi","purge_method":"get_request","enable_map":null,"enable_log":null,"log_level":"INFO","log_filesize":"5","enable_stamp":null,"purge_homepage_on_edit":"1","purge_homepage_on_del":"1","purge_archive_on_edit":"1","purge_archive_on_del":"1","purge_archive_on_new_comment":"1","purge_archive_on_deleted_comment":"1","purge_page_on_mod":"1","purge_page_on_new_comment":"1","purge_page_on_deleted_comment":"1","redis_hostname":"127.0.0.1","redis_port":"6379","redis_prefix":"nginx-cache:","purge_url":"","redis_enabled_by_constant":0}' --format=json

			docker exec -it "$WP" sh -c "printf ',s/#include \/etc\/nginx\/cache\/http.conf;/include \/etc\/nginx\/cache\/http.conf;/g\nw\n' | ed /etc/nginx/nginx.conf; \
			printf ',s/#include \/etc\/nginx\/cache\/server.conf;/include \/etc\/nginx\/cache\/server.conf;/g\nw\n' | ed /etc/nginx/nginx.conf; \
			printf ',s/#include \/etc\/nginx\/cache\/location.conf;/include \/etc\/nginx\/cache\/location.conf;/g\nw\n' | ed /etc/nginx/nginx.conf"

			bash "$ETC"/functions/env.sh "$DOMAIN" "$ADMIN_USER" "$ADMIN_PASS" "on" "$FORCE"
		elif [ "$CACHE" = off ]; then
			echo -e "\e[34m[INFO]\e[39m Turning off FastCGI Cache for $DOMAIN"
			docker run -it --rm \
			--volumes-from "$WP" \
			--network container:"$WP" \
			wordpress:cli plugin deactivate nginx-helper

			docker exec -it "$WP" sh -c "printf ',s/include \/etc\/nginx\/cache\/http.conf;/#include \/etc\/nginx\/cache\/http.conf;/g\nw\n' | ed /etc/nginx/nginx.conf; \
			printf ',s/include \/etc\/nginx\/cache\/server.conf;/#include \/etc\/nginx\/cache\/server.conf;/g\nw\n' | ed /etc/nginx/nginx.conf; \
			printf ',s/include \/etc\/nginx\/cache\/location.conf;/#include \/etc\/nginx\/cache\/location.conf;/g\nw\n' | ed /etc/nginx/nginx.conf"

			bash "$ETC"/functions/env.sh "$DOMAIN" "$ADMIN_USER" "$ADMIN_PASS" "off" "$FORCE"
		elif [ "$CACHE" = check ]; then
			cd "$APPS" || exit
			for i in *
			do
				[[ -z "$WP_CHECK" ]] && continue
				CHECK=$(grep "FASTCGI_CACHE=on" "$i"/.env)
				[[ -n "$CHECK" ]] && echo "$i"
			done
		fi
		[[ "$CACHE" != check ]] && demyx wp --dom="$DOMAIN" --cli='nginx -s reload'
	elif [ -n "$CDN" ] && [ -z "$RUN" ]; then
		WP_CHECK=$(grep -s "WP_ID" "$CONTAINER_PATH"/.env)
		[[ -z "$WP_CHECK" ]] && die 'Not a WordPress site.'
		[[ -f "$CONTAINER_PATH"/.env ]] && [[ -z "$RUN" ]] && source "$CONTAINER_PATH"/.env
		if [ "$CDN" = on ]; then
			echo -e "\e[34m[INFO]\e[39m Turning on CDN for $DOMAIN"
			CDN_ENABLER_CHECK=$(docker exec -it "$WP" sh -c '[[ -d wp-content/plugins/cdn-enabler ]] && echo 1')
			CDN_OPTION_CHECK=$(demyx wp --dom="$DOMAIN" --wpcli='option get cdn_enabler' | grep "Could not get")
			if [ -n "$CDN_ENABLER_CHECK" ]; then
				docker run -it --rm \
				--volumes-from "$WP" \
				--network container:"$WP" \
				wordpress:cli plugin activate cdn-enabler
			else
				docker run -it --rm \
				--volumes-from "$WP" \
				--network container:"$WP" \
				wordpress:cli plugin install cdn-enabler --activate
			fi			
			docker run -it --rm \
			--volumes-from "$WP" \
			--network container:"$WP" \
			wordpress:cli option update cdn_enabler "{\"url\":\"https:\/\/cdn.staticaly.com\/img\/$DOMAIN\",\"dirs\":\"wp-content,wp-includes\",\"excludes\":\".3g2, .3gp, .aac, .aiff, .alac, .apk, .avi, .css, .doc, .docx, .flac, .flv, .h264, .js, .json, .m4v, .mkv, .mov, .mp3, .mp4, .mpeg, .mpg, .ogg, .pdf, .php, .rar, .rtf, .svg, .tex, .ttf, .txt, .wav, .wks, .wma, .wmv, .woff, .woff2, .wpd, .wps, .xml, .zip, wp-content\/plugins, wp-content\/themes\",\"relative\":1,\"https\":1,\"keycdn_api_key\":\"\",\"keycdn_zone_id\":0}" --format=json
		elif [ "$CDN" = off ]; then
			echo -e "\e[34m[INFO]\e[39m Turning off CDN for $DOMAIN"
			docker run -it --rm \
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
		WP_CHECK=$(grep -s "WP_ID" "$APPS"/"$CLONE"/.env)
		DEV_MODE_CHECK=$(grep "sendfile off" /srv/demyx/apps/$CLONE/conf/nginx.conf)
		[[ -z "$WP_CHECK" ]] && die "$CLONE isn't a WordPress app"
		[[ -n "$DEV_MODE_CHECK" ]] && die "$CLONE is currently in dev mode. Please disable it before cloning"
		[[ -d "$CONTAINER_PATH" ]] && demyx wp --dom="$DOMAIN" --remove

		echo -e "\e[34m[INFO]\e[39m Cloning $CLONE to $DOMAIN"

		mkdir -p "$CONTAINER_PATH"/conf
		bash "$ETC"/functions/env.sh "$DOMAIN" "$ADMIN_USER" "$ADMIN_PASS" "$CACHE" "$FORCE"
		bash "$ETC"/functions/yml.sh "$CONTAINER_PATH" "$FORCE" "$SSL"
		bash "$ETC"/functions/nginx.sh "$CONTAINER_PATH" "$DOMAIN" "" "$FORCE"
		bash "$ETC"/functions/php.sh "$CONTAINER_PATH" "$FORCE"
		bash "$ETC"/functions/fpm.sh "$CONTAINER_PATH" "$DOMAIN" "$FORCE"
		bash "$ETC"/functions/logs.sh "$DOMAIN" "$FORCE"

		source "$CONTAINER_PATH"/.env

		demyx wp --dom="$CLONE" --wpcli="db export clone.sql --exclude_tables=wp_users,wp_usermeta"
		docker cp "$CLONE_WP":/var/www/html "$CONTAINER_PATH"/clone
		demyx wp --dom="$CLONE" --cli='rm /var/www/html/clone.sql'
		docker volume create wp_"$WP_ID"
		docker volume create db_"$WP_ID"

		demyx wp --dom="$DOMAIN" --service=db --action=up
		docker run -d --rm --name clone_tmp --network traefik -v wp_"$WP_ID":/var/www/html demyx/nginx-php-wordpress tail -f /dev/null
		cd "$CONTAINER_PATH"/clone && docker cp . clone_tmp:/var/www/html
		docker exec -it clone_tmp sh -c 'rm /var/www/html/wp-config.php'

		docker run -it --rm \
		--volumes-from clone_tmp \
		--network container:clone_tmp \
		wordpress:cli config create \
		--dbhost="$WORDPRESS_DB_HOST" \
		--dbname="$WORDPRESS_DB_NAME" \
		--dbuser="$WORDPRESS_DB_USER" \
		--dbpass="$WORDPRESS_DB_PASSWORD"

		echo "#!/bin/bash" > "$CONTAINER_PATH"/proto.sh
		echo "sed -i \"s/$table_prefix = 'wp_';/$table_prefix = 'wp_';\n\n\/\/ If we're behind a proxy server and using HTTPS, we need to alert Wordpress of that fact\n\/\/ see also http:\/\/codex.wordpress.org\/Administration_Over_SSL#Using_a_Reverse_Proxy\nif (isset($\_SERVER['HTTP_X_FORWARDED_PROTO']) \&\& $\_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {\n\t$\_SERVER['HTTPS'] = 'on';\n}\n/g\" /var/www/html/wp-config.php" >> "$CONTAINER_PATH"/proto.sh
		docker cp "$CONTAINER_PATH"/proto.sh clone_tmp:/
		rm "$CONTAINER_PATH"/proto.sh
		docker exec -it clone_tmp sh -c 'bash /proto.sh && rm /proto.sh'

		if [ -n "$ADMIN_EMAIL" ]; then
			WORDPRESS_EMAIL="$ADMIN_EMAIL"
		else
			WORDPRESS_EMAIL=info@"$DOMAIN"
		fi

		docker run -it --rm \
		--volumes-from clone_tmp \
		--network container:clone_tmp \
		wordpress:cli core install \
		--url="$DOMAIN" --title="$DOMAIN" \
		--admin_user="$WORDPRESS_USER" \
		--admin_password="$WORDPRESS_USER_PASSWORD" \
		--admin_email="$WORDPRESS_EMAIL" \
		--skip-email

		docker run -it --rm \
		--volumes-from clone_tmp \
		--network container:clone_tmp \
		wordpress:cli db import clone.sql

		docker run -it --rm \
		--volumes-from clone_tmp \
		--network container:clone_tmp \
		wordpress:cli search-replace "$CLONE" "$DOMAIN"

		docker run -it --rm \
		--volumes-from clone_tmp \
		--network container:clone_tmp \
		wordpress:cli config shuffle-salts

		cd .. && rm -rf "$CONTAINER_PATH"/clone

		docker stop clone_tmp
		demyx wp --dom="$DOMAIN" --up

		[[ "$DEV" = on ]] && demyx wp --dom="$DOMAIN" --dev

		echo
		echo "$DOMAIN/wp-admin"
		echo "Username: $WORDPRESS_USER"
		echo "Password: $WORDPRESS_USER_PASSWORD"
		echo
	elif [ -n "$DEV" ] && [ -z "$RUN" ] && [ -z "$CLONE" ]; then
		SSH_CONTAINER_CHECK=$(docker ps -aq -f name=ssh)
		SSH_VOLUME_CHECK=$(docker volume ls | grep ssh)
		WP_CHECK=$(grep -s "WP_ID" "$CONTAINER_PATH"/.env)

		if [ -z "$SSH_VOLUME_CHECK" ] && [ "$DEV" != check ]; then
			echo -e "\e[34m[INFO]\e[39m SSH volume not found, creating now..."
			docker volume create ssh

			docker run -d --rm \
			--name ssh \
			-v ssh:/home/www-data/.ssh \
			demyx/ssh

			docker cp /home/"$USER"/.ssh/authorized_keys ssh:/home/www-data/.ssh/authorized_keys
			docker exec -it sh -c "ssh chown -R www-data:www-data /home/www-data"
			docker stop ssh
		fi

		if [ "$DEV" = on ]; then
			source "$CONTAINER_PATH"/.env
			if [ -z "$FORCE" ]; then 
				DEV_MODE_CHECK=$(grep "sendfile off" "$CONTAINER_PATH"/conf/nginx.conf)
				[[ -n "$DEV_MODE_CHECK" ]] && die "Development mode is already turned on for $DOMAIN"
			fi
			[[ -n "$SSH_CONTAINER_CHECK" ]] && docker stop ssh

			echo -e "\e[34m[INFO]\e[39m Turning on development mode for $DOMAIN"
			
			docker exec -it "$WP" sh -c "printf ',s/sendfile on/sendfile off/g\nw\n' | ed /etc/nginx/nginx.conf; \
			nginx -s reload; \
			mv /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini /; \
			pkill php-fpm; \
			php-fpm -D"
			
			[[ -z "$PORT" ]] && PORT=2222

			docker run -d --rm \
			--name ssh \
			-v ssh:/home/www-data/.ssh \
			-v wp_"$WP_ID":/var/www/html \
			-p "$PORT":22 \
			demyx/ssh

			echo
			echo "SFTP Address: $PRIMARY_DOMAIN"
			echo "SFTP User: www-data"
			echo "SFTP Port: $PORT"
			echo
		elif [ "$DEV" = off ]; then
			source "$CONTAINER_PATH"/.env
			if [ -z "$FORCE" ]; then
				DEV_MODE_CHECK=$(grep "sendfile on" "$CONTAINER_PATH"/conf/nginx.conf)
				[[ -n "$DEV_MODE_CHECK" ]] && die "Development mode is already turned off for $DOMAIN"
			fi
			echo -e "\e[34m[INFO]\e[39m Turning off development mode for $DOMAIN"
			
			docker exec -it "$WP" sh -c "printf ',s/sendfile off/sendfile on/g\nw\n' | ed /etc/nginx/nginx.conf; \
			nginx -s reload; \
			mv /docker-php-ext-opcache.ini /usr/local/etc/php/conf.d; \
			pkill php-fpm; \
			php-fpm -D"
			
			docker stop ssh
		elif [ "$DEV" = check ] && [ -n "$ALL" ]; then
			cd "$APPS" || exit
			for i in *
			do
				WP_CHECK=$(grep -s "WP_ID" "$APPS"/"$i"/.env)
				[[ -n "$WP_CHECK" ]] && bash "$ETC"/functions/warnings.sh "$i"
			done
		elif [ "$DEV" = check ] && [ -n "$DOMAIN" ]; then
			[[ -n "$WP_CHECK" ]] && bash "$ETC"/functions/warnings.sh "$DOMAIN"
		else
			die "--dev=$DEV not found"
		fi
	elif [ -n "$DU" ]; then
		if [ "$DU" = wp ]; then
			du -sh "$CONTAINER_PATH"/data
		elif [ "$DU" = db ]; then
			du -sh "$CONTAINER_PATH"/db
		else
			du -sh "$CONTAINER_PATH"
		fi
	elif [ -n "$ENV" ]; then
		echo
		cat "$CONTAINER_PATH"/.env
		echo
	elif [ -n "$LIST" ]; then
		cd "$APPS" || exit
		for i in *
		do
			WP_CHECK=$(grep -s "WP_ID" "$APPS"/"$i"/.env)
			[[ -z "$WP_CHECK" ]] && continue
			echo "$i"
		done
	elif [ -n "$INFO" ]; then
		[[ -z "$DOMAIN" ]] && die 'Domain is required'
		source "$ETC"/functions/table.sh
		source "$CONTAINER_PATH"/.env
		MONITOR_COUNT=0
		[[ -f "$CONTAINER_PATH"/.monitor ]] && source "$CONTAINER_PATH"/.monitor
		SSL_CHECK=$(grep "https" "$CONTAINER_PATH"/docker-compose.yml)
		SSL_INFO=off

		[[ -n "$SSL_CHECK" ]] && SSL_INFO=on

		INFO_OUTPUT="DOMAIN, $DOMAIN\n"
		INFO_OUTPUT+="PATH, $CONTAINER_PATH\n"
		INFO_OUTPUT+="WP CONTAINER, $WP\n"
		INFO_OUTPUT+="DB CONTAINER, $DB\n"
		INFO_OUTPUT+="WORDPRESS USER, $WORDPRESS_USER\n"
		INFO_OUTPUT+="WORDPRESS PASSWORD, $WORDPRESS_USER_PASSWORD\n"
		INFO_OUTPUT+="SSL, $SSL_INFO\n"
		INFO_OUTPUT+="CACHE, $FASTCGI_CACHE\n"
		INFO_OUTPUT+="MONITOR COUNT, $MONITOR_COUNT\n"
		INFO_OUTPUT+="MONITOR THRESHOLD, $MONITOR_THRESHOLD\n"
		INFO_OUTPUT+="MONITOR SCALE, $MONITOR_SCALE\n"
		INFO_OUTPUT+="MONITOR CPU, $MONITOR_CPU%"

		printTable ',' "$(echo -e $INFO_OUTPUT)"
	elif [ -n "$IMPORT" ]; then
		die 'Import is disabled for now.'
		[[ ! -f $APPS_BACKUP/$DOMAIN.tgz ]] && die "$APPS_BACKUP/$DOMAIN.tgz doesn't exist"
		cd "$APPS_BACKUP" || exit
		tar -xzf "$DOMAIN".tgz
		[[ ! -d $APPS_BACKUP/$DOMAIN ]] && die "$APPS_BACKUP/$DOMAIN doesn't exist"
		[[ ! -f $APPS_BACKUP/$DOMAIN/import.sql ]] && die "$APPS_BACKUP/$DOMAIN/import.sql doesn't exist"
		[[ -d $CONTAINER_PATH ]] && demyx wp --rm="$DOMAIN"

		echo -e "\e[34m[INFO]\e[39m Importing $DOMAIN"

		mkdir -p "$CONTAINER_PATH"/conf

		bash "$ETC"/functions/env.sh "$DOMAIN" "$ADMIN_USER" "$ADMIN_PASS" "$CACHE" "$FORCE"
		bash "$ETC"/functions/yml.sh "$CONTAINER_PATH" "$FORCE" "$SSL"
		bash "$ETC"/functions/nginx.sh "$CONTAINER_PATH" "$DOMAIN" "" "$FORCE"
		bash "$ETC"/functions/php.sh "$CONTAINER_PATH" "$FORCE"
		bash "$ETC"/functions/fpm.sh "$CONTAINER_PATH" "$DOMAIN" "$FORCE"
		bash "$ETC"/functions/logs.sh "$DOMAIN" "$FORCE"

		source "$CONTAINER_PATH"/.env

		mv "$DOMAIN" "$CONTAINER_PATH"/data
		rm "$CONTAINER_PATH"/data/wp-config.php
		sudo chown -R "$USER":"$USER" "$CONTAINER_PATH"

		demyx wp --up="$DOMAIN"
		
		sleep 10

		docker run -it --rm \
		--volumes-from "$WP" \
		--network container:"$WP" \
		wordpress:cli config create \
		--dbhost="$WORDPRESS_DB_HOST" \
		--dbname="$WORDPRESS_DB_NAME" \
		--dbuser="$WORDPRESS_DB_USER" \
		--dbpass="$WORDPRESS_DB_PASSWORD"

		sudo sed -i "s/$table_prefix = 'wp_';/$table_prefix = 'wp_';\n\n\/\/ If we're behind a proxy server and using HTTPS, we need to alert Wordpress of that fact\n\/\/ see also http:\/\/codex.wordpress.org\/Administration_Over_SSL#Using_a_Reverse_Proxy\nif (isset($\_SERVER['HTTP_X_FORWARDED_PROTO']) \&\& $\_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {\n\t$\_SERVER['HTTPS'] = 'on';\n}\n/g" "$CONTAINER_PATH"/data/wp-config.php

		if [ -n "$ADMIN_EMAIL" ]; then
			WORDPRESS_EMAIL="$ADMIN_EMAIL"
		else
			WORDPRESS_EMAIL=info@"$DOMAIN"
		fi

		docker run -it --rm \
		--volumes-from "$WP" \
		--network container:"$WP" \
		wordpress:cli core install \
		--url="$DOMAIN" --title="$DOMAIN" \
		--admin_user="$WORDPRESS_USER" \
		--admin_password="$WORDPRESS_USER_PASSWORD" \
		--admin_email="$WORDPRESS_EMAIL" \
		--skip-email

		docker run -it --rm \
		--volumes-from "$WP" \
		--network container:"$WP" \
		wordpress:cli db reset --yes

		docker run -it --rm \
		--volumes-from "$WP" \
		--network container:"$WP" \
		wordpress:cli db import import.sql

		docker run -it --rm \
		--volumes-from "$WP" \
		--network container:"$WP" \
		wordpress:cli config shuffle-salts

		sudo rm "$CONTAINER_PATH"/data/import.sql

		echo
		echo "$DOMAIN/wp-admin"
		echo
	elif [ -n "$MONITOR" ]; then
		MONITOR_STATS=$(docker stats --no-stream)
		cd "$APPS" || exit
		for i in *
		do
			WP_CHECK=$(grep -s "WP_ID" "$APPS"/"$i"/.env)
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

			docker run -d \
			--name phpmyadmin \
			--network traefik \
			--restart unless-stopped \
			-e PMA_HOST="${DB}" \
			-e MYSQL_ROOT_PASSWORD="${MARIADB_ROOT_PASSWORD}" \
			-l "traefik.enable=1" \
			-l "traefik.frontend.rule=Host:pma.${PRIMARY_DOMAIN}" \
			-l "traefik.port=80" \
			-l "traefik.frontend.redirect.entryPoint=https" \
			-l "traefik.frontend.headers.forceSTSHeader=${FORCE_STS_HEADER}" \
			-l "traefik.frontend.headers.STSSeconds=${STS_SECONDS}" \
			-l "traefik.frontend.headers.STSIncludeSubdomains=${STS_INCLUDE_SUBDOMAINS}" \
			-l "traefik.frontend.headers.STSPreload=${STS_PRELOAD}" \
			phpmyadmin/phpmyadmin

			echo
			echo "phpMyAdmin: pma.$PRIMARY_DOMAIN"
			echo "Username: $WORDPRESS_DB_USER"
			echo "Password: $WORDPRESS_DB_PASSWORD"
			echo 
		else
			docker stop phpmyadmin && docker rm phpmyadmin
		fi
	elif [ -n "$RATE_LIMIT" ]; then
		WP_CHECK=$(grep -s "WP_ID" "$CONTAINER_PATH"/.env)
		[[ -z "$WP_CHECK" ]] && die 'Not a WordPress app.'

		source "$CONTAINER_PATH"/.env

		if [ "$RATE_LIMIT" = on ]; then
			echo -e "\e[34m[INFO]\e[39m Turning on rate limiting for $DOMAIN"
			docker exec -it "$WP" sh -c "printf ',s/#limit_req/limit_req/g\nw\n' | ed /etc/nginx/nginx.conf"
		elif [ "$RATE_LIMIT" = off ]; then
			echo -e "\e[34m[INFO]\e[39m Turning off rate limiting for $DOMAIN"
			docker exec -it "$WP" sh -c "printf ',s/limit_req/#limit_req/g\nw\n' | ed /etc/nginx/nginx.conf"
		fi

		docker exec -it "$WP" sh -c "nginx -s reload"
	elif [ -n "$REFRESH" ]; then
		if [ -n "$ALL" ]; then
			cd "$APPS" || exit
			for i in *
			do
				WP_CHECK=$(grep -s "WP_ID" "$APPS"/"$i"/.env)
				if [ -n "$WP_CHECK" ]; then 
					echo -e "\e[34m[INFO]\e[39m Refreshing $i"
					DOMAIN=$i
					CONTAINER_PATH=$APPS/$DOMAIN
					CONTAINER_NAME=${DOMAIN//./_}
					CACHE_CHECK=$(grep -s "FASTCGI_CACHE=on" "$CONTAINER_PATH"/.env)
					[[ -n "$CACHE_CHECK" ]] && CACHE=on
					[[ -z "$NO_RESTART" ]] && demyx wp --dom="$i" --down
					bash "$ETC"/functions/env.sh "$DOMAIN" "$ADMIN_USER" "$ADMIN_PASS" "$CACHE" "$FORCE"
					bash "$ETC"/functions/yml.sh "$CONTAINER_PATH" "$FORCE" "$SSL"
					bash "$ETC"/functions/nginx.sh "$CONTAINER_PATH" "$DOMAIN" "$FORCE" "$CACHE"
					bash "$ETC"/functions/php.sh "$CONTAINER_PATH" "$FORCE"
					bash "$ETC"/functions/fpm.sh "$CONTAINER_PATH" "$DOMAIN" "$FORCE"
					bash "$ETC"/functions/logs.sh "$DOMAIN" "$FORCE"
					[[ -z "$NO_RESTART" ]] && demyx wp --dom="$i" --up
				fi
			done
		else
			WP_CHECK=$(grep -s "WP_ID" "$CONTAINER_PATH"/.env)
			CACHE_CHECK=$(grep -s "FASTCGI_CACHE=on" "$CONTAINER_PATH"/.env)
			[[ -n "$CACHE_CHECK" ]] && CACHE=on
			[[ -z "$WP_CHECK" ]] && die 'Not a WordPress app.'
			[[ -z "$DOMAIN" ]] && die 'Domain is missing or add --all'
			echo -e "\e[34m[INFO]\e[39m Refreshing $DOMAIN"
			[[ -z "$NO_RESTART" ]] && demyx wp --dom="$DOMAIN" --down
			bash "$ETC"/functions/env.sh "$DOMAIN" "$ADMIN_USER" "$ADMIN_PASS" "$CACHE" "$FORCE"
			bash "$ETC"/functions/yml.sh "$CONTAINER_PATH" "$FORCE" "$SSL"
			bash "$ETC"/functions/nginx.sh "$CONTAINER_PATH" "$DOMAIN" "$FORCE" "$CACHE"
			bash "$ETC"/functions/php.sh "$CONTAINER_PATH" "$FORCE"
			bash "$ETC"/functions/fpm.sh "$CONTAINER_PATH" "$DOMAIN" "$FORCE"
			bash "$ETC"/functions/logs.sh "$DOMAIN" "$FORCE"
			[[ -z "$NO_RESTART" ]] && demyx wp --dom="$DOMAIN" --up
		fi
	elif [ -n "$RESTART" ]; then
		cd "$APPS" || exit
		if [ -n "$ALL" ]; then
			for i in *
			do
				WP_CHECK=$(grep -s "WP_ID" "$APPS"/"$i"/.env)
				[[ -z "$WP_CHECK" ]] && continue
				cd "$APPS"/"$i"
				docker-compose restart
			done
		else
			WP_CHECK=$(grep -s "WP_ID" "$CONTAINER_PATH"/.env)
			[[ -z "$WP_CHECK" ]] && die 'Not a WordPress app.'
			[[ -z "$DOMAIN" ]] && die 'Domain is missing, use --dom or --restart=domain.tld'
			cd "$CONTAINER_PATH"
			docker-compose restart
		fi
	elif [ -n "$RESTORE" ]; then
		[[ -d "$CONTAINER_PATH" ]] && demyx wp --dom="$DOMAIN" --remove
		[[ ! -f "$APPS_BACKUP"/"$DOMAIN".tgz ]] && die "No backups found for $DOMAIN"
		echo -e "\e[34m[INFO]\e[39m Restoring $DOMAIN"
		cd "$APPS_BACKUP" || exit
		tar -xzf "$DOMAIN".tgz
		mv "$APPS_BACKUP"/"$DOMAIN" "$APPS"
		source "$CONTAINER_PATH"/.env
		demyx wp --dom="$DOMAIN" --down
		docker volume rm wp_"$WP_ID" db_"$WP_ID"
		docker volume create wp_"$WP_ID"
		docker volume create db_"$WP_ID"
		demyx wp --dom="$DOMAIN" --service=db --action=up
		sleep 10
		docker run -d --rm --name restore_tmp --network traefik -v wp_"$WP_ID":/var/www/html demyx/nginx-php-wordpress tail -f /dev/null
		cd "$CONTAINER_PATH"/backup && docker cp . restore_tmp:/var/www/html
		docker run -it --rm \
		--volumes-from restore_tmp \
		--network container:restore_tmp \
		wordpress:cli db import "$CONTAINER_NAME".sql
		docker exec -it restore_tmp sh -c "rm /var/www/html/$CONTAINER_NAME.sql"
		docker stop restore_tmp
		cd .. && rm -rf "$CONTAINER_PATH"/backup
		
		[[ ! -f "$LOGS"/"$DOMAIN".access.log ]] && bash "$ETC"/functions/logs.sh "$DOMAIN" "$FORCE"
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
		
		if [ -n "$ALL" ]; then
			cd "$APPS" || exit
			for i in *
			do
				WP_CHECK=$(grep -s "WP_ID" "$APPS"/"$i"/.env)
				echo -e "\e[31m[CRITICAL]\e[39m Removing $i"
				if [ -n "$WP_CHECK" ]; then
					source "$APPS"/"$i"/.env
					cd "$APPS"/"$i"
					docker-compose kill
					docker-compose rm -f
					[[ -f "$LOGS"/"$i".access.log ]] && rm "$LOGS"/"$i".access.log && rm "$LOGS"/"$i".error.log
					docker volume rm wp_"$WP_ID" db_"$WP_ID"
					cd .. && rm -rf "$i"
				fi
			done
		else
			[[ ! -f "$CONTAINER_PATH"/.env ]] && die "$DOMAIN is not a valid WordPress app or doesn't exist"
			WP_CHECK=$(grep -s "WP_ID" "$CONTAINER_PATH"/.env)
			if [ -n "$WP_CHECK" ]; then
				source "$CONTAINER_PATH"/.env
				echo -e "\e[31m[CRITICAL]\e[39m Removing $DOMAIN"
				cd "$CONTAINER_PATH"
				docker-compose kill
				docker-compose rm -f
				docker volume rm wp_"$WP_ID" db_"$WP_ID"
				cd .. && rm -rf "$DOMAIN"
				[[ -f "$LOGS"/"$DOMAIN".access.log ]] && rm "$LOGS"/"$DOMAIN".access.log && rm "$LOGS"/"$DOMAIN".error.log
			else
				die "$DOMAIN a WordPress app"
			fi
		fi
	elif [ -n "$RUN" ]; then
		[[ -d $CONTAINER_PATH ]] && demyx wp --rm="$DOMAIN"

		echo -e "\e[34m[INFO]\e[39m Creating $DOMAIN"

		mkdir -p "$CONTAINER_PATH"/conf

		# Future plans for subnets
		#bash $ETC/functions/subnet.sh $DOMAIN $CONTAINER_NAME create
		bash "$ETC"/functions/env.sh "$DOMAIN" "$ADMIN_USER" "$ADMIN_PASS" "$CACHE" "$FORCE"
		bash "$ETC"/functions/yml.sh "$CONTAINER_PATH" "$FORCE" "$SSL"
		bash "$ETC"/functions/nginx.sh "$CONTAINER_PATH" "$DOMAIN" "" "$FORCE"
		bash "$ETC"/functions/php.sh "$CONTAINER_PATH" "$FORCE"
		bash "$ETC"/functions/fpm.sh "$CONTAINER_PATH" "$DOMAIN" "$FORCE"
		bash "$ETC"/functions/logs.sh "$DOMAIN" "$FORCE"

		source "$CONTAINER_PATH"/.env

		docker volume create db_"$WP_ID" 
		docker volume create wp_"$WP_ID"

		cd "$CONTAINER_PATH" || exit
		docker-compose up -d --remove-orphans

		if [ -n "$ADMIN_EMAIL" ]; then
			WORDPRESS_EMAIL="$ADMIN_EMAIL"
		else
			WORDPRESS_EMAIL=info@"$DOMAIN"
		fi

		sleep 10

		docker run -it --rm \
		--volumes-from "$WP" \
		--network container:"$WP" \
		wordpress:cli core install \
		--url="$DOMAIN" --title="$DOMAIN" \
		--admin_user="$WORDPRESS_USER" \
		--admin_password="$WORDPRESS_USER_PASSWORD" \
		--admin_email="$WORDPRESS_EMAIL" \
		--skip-email

		docker run -it --rm \
		--volumes-from "$WP" \
		--network container:"$WP" \
		wordpress:cli rewrite structure '/%category%/%postname%/'

		[[ "$CDN" = on ]] && demyx wp --dom="$DOMAIN" --cdn
		[[ "$DEV" = on ]] && demyx wp --dom="$DOMAIN" --dev
		[[ "$CACHE" = on ]] && demyx wp --dom="$DOMAIN" --cache

		demyx wp --dom="$DOMAIN" --info
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
				WP_CHECK=$(grep -s "WP_ID" "$APPS"/"$i"/.env)
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
			WP_CHECK=$(grep -s "WP_ID" "$CONTAINER_PATH"/.env)
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
				WP_CHECK=$(grep -s "WP_ID" "$APPS"/"$i"/.env)
				if [ -n "$WP_CHECK" ]; then
					source "$APPS"/"$i"/.env
					docker run -it --rm \
					--volumes-from "$WP" \
					--network container:"$WP" \
					wordpress:cli $WPCLI
				fi
			done
		else
			WP_CHECK=$(grep -s "WP_ID" "$CONTAINER_PATH"/.env)
			[[ -z "$WP_CHECK" ]] && die 'Not a WordPress app.'
			source "$CONTAINER_PATH"/.env
			docker run -it --rm \
			--volumes-from "$WP" \
			--network container:"$WP" \
			wordpress:cli $WPCLI
		fi
	fi
else
	[[ -z "$1" ]] && echo && echo -e "\e[34m[INFO]\e[39m See commands for help: demyx -h, demyx stack -h, demyx wp -h" && echo
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
				CTOP_CHECK=$(docker ps | grep ctop | awk '{print $1}')
				[[ -n "$CTOP_CHECK" ]] && docker stop "$CTOP_CHECK"
				docker run --rm -ti -v /var/run/docker.sock:/var/run/docker.sock:ro quay.io/vektorlab/ctop
				;;
			-u|--update)
				# Cron check
				CRON_WP_CHECK=$(crontab -l | grep "cron event run --due-now")
				CRON_MONITOR_CHECK=$(crontab -l | grep "demyx wp --monitor")

				if [ -z "$CRON_WP_CHECK" ]; then
					# WP Cron every 2 hours
					echo -e "\e[34m[INFO]\e[39m Demyx cron not found, installing now to crontabs"
					crontab -l > "$ETC"/CRON_WP_CHECK
					echo "0 */2 * * * /usr/local/bin/demyx wp --all --wpcli='cron event run --due-now'" >> "$ETC"/CRON_WP_CHECK
					crontab "$ETC"/CRON_WP_CHECK
					rm "$ETC"/CRON_WP_CHECK
				fi

				if [ -z "$CRON_MONITOR_CHECK" ]; then
					# WP Cron every minute
					echo -e "\e[34m[INFO]\e[39m Auto scaling cron not found, installing now to crontabs"
					crontab -l > "$ETC"/CRON_MONITOR_CHECK
					echo "* * * * * /usr/local/bin/demyx wp --monitor" >> "$ETC"/CRON_MONITOR_CHECK
					crontab "$ETC"/CRON_MONITOR_CHECK
					rm "$ETC"/CRON_MONITOR_CHECK
					demyx wp --refresh --all
				fi

				# Check for custom folder where users can place custom shell scripts
				if [ ! -d "$DEMYX"/custom ]; then
					mkdir "$DEMYX"/custom
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

				CHECK_FOR_UPDATES=$(git pull | grep "Already up to date." )

				if [ -n "$FORCE" ] || [ "$CHECK_FOR_UPDATES" != "Already up to date" ]; then
					[[ -z "$FORCE" ]] && echo -e "\e[34m[INFO]\e[39m Updating Demyx..."
					bash "$ETC"/functions/etc-env.sh
					bash "$ETC"/functions/etc-yml.sh
					rm -rf "$ETC"/functions
					cp -R "$GIT"/etc/functions "$ETC"
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
				printf '\e[31m[WARNING]\e[39m Unknown option: %s\n' "$2" >&2
				exit 1
				;;
			*) 
				break
		esac
		shift
	done

	if [ -n "$DOMAIN" ] && [ -n "$EMAIL" ] && [ "$INSTALL" = rocketchat ]; then
		mkdir -p "$APPS"/"$DOMAIN"
		bash "$ETC"/functions/rocketchat.sh "$DOMAIN" "$EMAIL" "$APPS"/"$DOMAIN"
		cd "$APPS"/"$DOMAIN" && docker-compose up -d
	elif [ -n "$DOMAIN" ] && [ "$INSTALL" = gitea ]; then
		mkdir -p "$APPS"/"$DOMAIN"
		sudo mkdir -p /app/gitea
		sudo chown -R "$USER":"$USER" /app/gitea
		printf '#!/bin/sh\nssh -p 2222 -o StrictHostKeyChecking=no git@127.0.0.1 "SSH_ORIGINAL_COMMAND=\\"$SSH_ORIGINAL_COMMAND\\" $0 $@"' > /app/gitea/gitea
		chmod +x /app/gitea/gitea
		sudo chown -R root:root /app/gitea
		sudo adduser git --gecos GECOS
		sudo -u git ssh-keygen -t rsa -b 4096 -C "Gitea Host Key"
		sudo chown -R "$USER":"$USER" /home/git
		echo "no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty $(cat /home/git/.ssh/id_rsa.pub)" >> /home/git/.ssh/authorized_keys
		sudo chown -R git:git /home/git
		bash "$ETC"/functions/gitea.sh "$DOMAIN" "$APPS"/"$DOMAIN"
		cd "$APPS"/"$DOMAIN" && docker-compose up -d
	fi

fi