# Demyx
# https://demyx.sh
# shellcheck shell=bash

#
#   demyx help <args>
#
demyx_help() {
    case "${1:-$DEMYX_ARG_2}" in
        backup)
            echo
            echo "demyx backup <app> <args>             Backs up app's WordPress, code-server, MariaDB, logs, and SFTP volumes"
            echo "             all                      Backup all apps"
            echo "                   -c                 Backup configs only"
            echo "                   -d                 Backup database only"
            echo "                   -l                 List an app's backups"
            echo "                   --path             Save backups to a specific path"
            echo
        ;;
        compose)
            echo
            echo "demyx compose <app> <args> <docker-compose args>      Execute docker-compose commands to apps"
            echo "                    -d                                docker-compose for the MariaDB container"
            echo "                    down                              Shorthand for docker-compose stop/rm -f"
            echo "                    fr                                Shorthand for docker-compose up -d --force-recreate --remove-orphans"
            echo "                    -n                                docker-compose for the NGINX container"
            echo "                    -w                                docker-compose for the WordPress container"
            echo
        ;;
        config)
            echo
            echo "demyx config <app> <args>                             Configure demyx apps"
            echo "             all                                      Targets all apps (only works with --restart)"
            echo "                   --auth                             Turns on/off basic auth"
            echo "                   --auth-wp                          Turns on/off basic auth for wp-login.php"
            echo "                   --bedrock                          Sets production/development mode for Bedrock"
            echo "                   --cache                            Turns on/off fastcgi cache"
            echo "                   --clean                            Creates new MariaDB credentials and reinstalls WordPress core files"
            echo "                   --db-cpu                           Set the app's DB container CPU usage, --db-cpu=0 to remove cap"
            echo "                   --db-mem                           Set the app's DB container MEM usage, --db-mem=0 to remove cap"
            echo "                   --dev                              Turns on/off development mode"
            echo "                   --healthcheck                      Turns on/off healthcheck for WordPress container"
            echo "                   --no-compose                       Skip docker-compose command"
            # TODO - echo "                   --no-maldet                        Skip maldet commands, used with --clean"
            echo "                   --opcache                          Turns on/off PHP opcache"
            echo "                   --php                              Update PHP version, accepts: 8, 8.0, 8.1"
            echo "                   --php-max-children                 Update PHP's pm.max_children"
            echo "                   --php-max-requests                 Update PHP's pm.max_requests"
            echo "                   --php-max-spare-servers            Update PHP's pm.max_spare_servers"
            echo "                   --php-min-spare-servers            Update PHP's pm.min_spare_servers"
            echo "                   --php-pm                           Update PHP's pm"
            echo "                   --php-process-idle-timeout         Update PHP's pm.process_idle_timeout"
            echo "                   --php-start-servers                Update PHP's pm.start_servers"
            echo "                   --pma                              Activate/deactivate phpMyAdmin container"
            echo "                   --rate-limit                       Turns on/off NGINX rate limting"
            echo "                   --redis                            Enable/disable redis"
            # TODO - echo "                   --restart                          Restart NGINX/PHP/OLS services: nginx, nginx-php, ols, php (restarting nginx will delete cache)"
            echo "                   --sftp                             Activate/deactivate SFTP container"
            echo "                   --ssl                              Turns on/off SSL"
            echo "                   --stack                            Switch the WordPress stack: bedrock, nginx-php, ols, ols-bedrock"
            echo "                   --whitelist                        Available values: all (site-wide), login"
            echo "                   --wp-cpu                           Set the app's container CPU usage, --wp-cpu=0 to remove cap"
            echo "                   --wp-mem                           Set the app's container MEM usage, --wp-mem=0 to remove cap"
            echo "                   --wp-update                        Auto update WordPress core, themes, and plugins"
            echo "                   --www                              Search/replace www. to an app's domain"
            echo "                   --xmlrpc                           Turns on/off xmlrpc.php"
            echo
        ;;
        cp)
            echo
            # TODO
            #echo "demyx cp <app/path>:<path> <app/path>:<path>      Wrapper for docker cp"
            #echo "         db                                       Target docker cp for MariaDB container"
            echo "demyx cp <app>    Outputs a table of commands for MariaDB, Nginx, and WordPress"
            echo
        ;;
        cron)
            echo
            echo "demyx cron <arg>              Execute demyx cron (daily|hourly|minute|six-hour|weekly)"
            echo "           daily              Execute daily cron"
            echo "           five-minute        Execute every five minute cron"
            echo "           hourly             Execute hourly cron"
            echo "           minute             Execute every minute cron"
            echo "           six-hour           Execute every six hour cron"
            echo "           weekly             Execute every week cron"
            echo
        ;;
        edit)
            echo
            echo "demyx edit <app>      <args>          Uses nano to edit .env files"
            # TODO - echo "           traefik                    Edit Traefik's .env"
            echo "                      -r              Refreshes the config to reflect changes, will restart container(s)"
            echo
        ;;
        exec)
            echo
            echo "demyx exec <app> <args>       Execute docker exec commands to apps"
            echo "                 -d           Targets MariaDB container"
            echo "                 -n           Targets NGINX container"
            echo "                 -r           Execute as root"
            echo "                 -t           Allocate a non-interactive TTY"
            echo
        ;;
        healthcheck)
            echo
            echo "demyx healthcheck     Checks if WordPress apps are up"
            echo
        ;;
        info)
            echo
            echo "demyx info <app>      <args>      Prints useful information about demyx images, installed apps, and system"
            echo "           apps                   Show table of installed apps"
            echo "           system                 Show miscellaneous system data"
            echo "                      --env       Grab value from a specific environment variable"
            echo "                      -j          Output data in JSON"
            echo "                      -l          Show variable login credentials for a specific app"
            echo "                      -nv         Omit volume sizes"
            echo "                      -r          Currently works with apps, show list of installed apps without a table"
            echo
        ;;
        log)
            echo
            echo "demyx log <app>           <args>          Show logs from various apps, can also logrotate"
            echo "          cron                            Show cron log"
            echo "          main                            Show demyx container log, pass -e for error log"
            echo "          traefik                         Show Traefik logs"
            echo "                          -c|-cf|-fc      Show log for WP cron"
            echo "                          -d|-df|-fd      Show log for MariaDB"
            echo "                          -e|-ef|-fe      Show error log"
            echo "                          -f              Follow log"
            echo "                          -s|-sf|-fs      Show stdout using docker logs"
            echo
        ;;
        pull)
            echo
            echo "demyx pull <args>                                 Enter specific image or demyx pull all"
            echo "           all                                    Pull core and relevant images"
            echo "           browsersync"
            echo "           code-server:bedrock"
            echo "           code-server:browse"
            echo "           code-server:openlitespeed"
            echo "           code-server:openlitespeed-bedrock"
            echo "           code-server:wp"
            echo "           ctop"
            echo "           demyx"
            echo "           docker-socket-proxy"
            echo "           mariadb"
            echo "           nginx"
            echo "           openlitespeed"
            echo "           openlitespeed:bedrock"
            echo "           pma"
            echo "           ssh"
            echo "           traefik"
            echo "           utilities"
            echo "           wordpress"
            echo "           wordpress:bedrock"
            echo
        ;;
        refresh)
            echo
            echo "demyx refresh <app>       <args>      Regenerate .env/docker-compose.yml files of an app"
            echo "              all                     Regenerate all app's .env/docker-compose.yml files"
            echo "              code                    Regenerate code-server docker-compose.yml"
            echo "              traefik                 Regenerate Traefik docker-compose.yml"
            echo "                          -f          Deletes non-core variables"
            echo "                          -nc         Refresh env/yml only, no compose commands"
            echo "                          -nfr        Pass 'up -d' instead of '--force-recreate --remove-orphans' to docker-compose"
            echo "                          -s          Skip regenerating other configs like auth, cache, etc."
            echo
        ;;
        restore)
            echo
            echo "demyx restore <app> <args>        Restore app's configs and volumes"
            echo "                    -c            Restore configs only"
            echo "                    -d            Restore database only"
            echo "                    --date        Restore from a specific date in format: YY/mm/dd"
            echo "                    -f            Force restore"
            echo
        ;;
        rm)
            echo
            echo "demyx rm <app> <args>         Deletes an app and its volumes"
            echo "         all                  Deletes all apps"
            echo "               -f             Force delete without confirmation"
            echo
        ;;
        run)
            echo
            echo "demyx run <app> <args>                Creates a new app"
            echo "                --auth                Run with basic auth on/off"
            echo "                --cache               Run with cache on/off"
            echo "                --clone               Clone an already running app"
            echo "                --email               Override email generation"
            echo "                -f                    Force delete if exists"
            echo "                --pass                Override password generation"
            echo "                --php                 Set PHP version, accepts: 8, 8.0, 8.1"
            echo "                --redis               Enable redis when creating an app"
            echo "                --ssl                 Run with ssl on/off"
            echo "                --stack               Create a WordPress app using preferred stack: bedrock, nginx-php (default), ols, ols-bedrock"
            echo "                --type                Run app type as html, php, wp (default)"
            echo "                --user                Override user generation"
            echo "                --whitelist           Available values: all (site-wide), login"
            echo "                --www                 Adds www. to app's domain"
            echo
        ;;
        smtp)
            echo
            echo "demyx smtp        Execute command to send a test email via ssmtp, with proper credentials"
            echo
        ;;
        update)
            echo
            echo "demyx update <args>           Update demyx cache"
            echo "             -i               Update images only"
            echo "             -l               Show local/remote versions of updates"
            echo
        ;;
        utility)
            echo
            echo "demyx utility <type>              <args>          Generate credentials or execute shell commands to demyx/utilities"
            echo "              cred|credentials                    Generates full random credentials"
            echo "              htpasswd                            Usage: demyx htpasswd <username> <password>"
            echo "              id                                  Usage: demyx id <length> (default 10)"
            echo "              pass|password                       Usage: demyx password <length> (default 20)"
            echo "              sh|shell                            Runs demyx/utility container"
            echo "              user|username                       Generates random username"
            echo "              -r                                  Output generated string without a table"
            echo
        ;;
        wp)
            echo
            echo "demyx wp <app> <arg>      Execute wp-cli commands"
            echo
        ;;
        *)
            echo
            echo "demyx <arg>                   Main demyx command, for more info: demyx help <arg>"
            echo "      backup                  Backs up app's WordPress, code-server, MariaDB, logs, and SFTP volumes"
            echo "      compose                 Execute docker-compose commands to apps"
            echo "      config                  Configure demyx apps"
            echo "      cp                      Outputs a table of container names for MariaDB, Nginx, and WordPress"
            echo "      cron                    Execute demyx cron (daily|hourly|minute|six-hour|weekly)"
            echo "      edit                    Uses nano to edit .env files"
            echo "      exec                    Execute docker exec commands to apps"
            echo "      healthcheck             Checks if WordPress apps are up"
            echo "      info                    Prints useful information about apps and system"
            echo "      log                     Show logs from various apps"
            echo "      motd                    Message of the day"
            echo "      pull                    Enter specific image or demyx pull all relevant demyx images"
            echo "      refresh                 Regenerate app's .env/docker-compose.yml"
            echo "      restore                 Restore app's configs and volumes"
            echo "      rm                      Deletes an app and its volumes"
            echo "      run                     Creates a new app"
            echo "      update                  Update demyx cache and helper script on host"
            echo "      util|utility            Generate credentials or execute shell commands to demyx/utilities"
            echo "      -v|--version|version    Show demyx version"
            echo "      wp                      Execute wp-cli commands"
            echo
        ;;
    esac
}
