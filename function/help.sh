# Demyx
# https://demyx.sh
# 
# demyx help <args>
#
demyx_help() {
    DEMYX_HELP="$2"

    if [[ "$DEMYX_HELP" = backup ]]; then
        echo
        echo "demyx backup <app> <args>     Backup an app by domain"
        echo "             all              Backup all apps"
        echo "                   --path     Save backups to a specific path"
        echo "                   --config   Backup only the configs"
        echo
    elif [[ "$DEMYX_HELP" = compose ]]; then
        echo
        echo "demyx compose <app> <args>    Accepts all docker-compose arguments"
        echo "                    db        docker-compose for the MariaDB container"
        echo "                    down      Shorthand for docker-compose stop/rm -f"
        echo "                    fr        Shorthand for docker-compose up -d --force-recreate --remove-orphans"
        echo "                    nx        docker-compose for the NGINX container"
        echo "                    wp        docker-compose for the WordPress container"
        echo
    elif [[ "$DEMYX_HELP" = config ]]; then
        echo
        echo "demyx config <app> <args>                         Configure demyx apps"
        echo "             all                                  Targets all apps (only works with --restart)"
        echo "                   --auth                         Turns on/off basic auth"
        echo "                   --auth-wp                      Turns on/off basic auth for wp-login.php"
        echo "                   --bedrock                      Sets production/development mode for Bedrock"
        echo "                   --cache                        Turns on/off fastcgi cache"
        echo "                   --cf                           Switch between HTTP or Cloudflare resolvers, accepts only true or false"
        echo "                   --clean                        Creates new MariaDB credentials and reinstalls WordPress core files"
        echo "                   --db-cpu                       Set the app's DB container CPU usage, --db-cpu=null to remove cap"
        echo "                   --db-mem                       Set the app's DB container MEM usage, --db-mem=null to remove cap"
        echo "                   --dev                          Turns on/off development mode"
        echo "                   --dev-base-path                Change code-server base path"
        echo "                   --expose                       Export ports to access web endpoint, works only with --dev and --pma"
        echo "                   --files                        BrowserSync arg: themes, plugins, or custom path"
        echo "                   --fix-innodb                   Back up ib_logfile files and deletes them"
        echo "                   --force                        Force config"
        echo "                   --healthcheck                  Turns on/off healthcheck for WordPress container"
        echo "                   --mem                          Change the app's container memory usage, --mem=null to remove cap"
        echo "                   --opcache                      Turns on/off PHP opcache"
        echo "                   --php-max-children             Update PHP's pm.max_children"
        echo "                   --php-max-requests             Update PHP's pm.max_requests"
        echo "                   --php-max-spare-servers        Update PHP's pm.max_spare_servers"
        echo "                   --php-min-spare-servers        Update PHP's pm.min_spare_servers"
        echo "                   --php-pm                       Update PHP's pm"
        echo "                   --php-process-idle-timeout     Update PHP's pm.process_idle_timeout"
        echo "                   --php-start-servers            Update PHP's pm.start_servers"
        echo "                   --pma                          Turns on/off phpMyAdmin"
        echo "                   --rate-limit                   Turns on/off NGINX rate limting"
        echo "                   --restart                      Restart NGINX/PHP/OLS services: nginx, nginx-php, ols, php"
        echo "                   --sftp                         Turns on/off SFTP container"
        echo "                   --skip-checks                  Skip checking other configs (cache, rate limit, etc.)"
        echo "                   --sleep                        Set sleep when all loop is used"
        echo "                   --ssl                          Turns on/off SSL"
        echo "                   --stack                        Switch the WordPress stack: bedrock, nginx-php, ols, ols-bedrock"
        echo "                   --upgrade                      Upgrade the app"
        echo "                   --whitelist                    Available values: all (site-wide), login"
        echo "                   --wp-cpu                       Set the app's container CPU usage, --wp-cpu=null to remove cap"
        echo "                   --wp-mem                       Set the app's container MEM usage, --wp-mem=null to remove cap"
        echo "                   --wp-update                    Auto update WordPress core, themes, and plugins"
        echo "                   --xmlrpc                       Turns on/off xmlrpc.php"
        echo
    elif [[ "$DEMYX_HELP" = cp ]]; then
        echo
        echo "demyx cp <app/path>:<path> <app/path>:<path>      Wrapper for docker cp"
        echo "         db                                       Target docker cp for MariaDB container"
        echo
    elif [[ "$DEMYX_HELP" = cron ]]; then
        echo
        echo "demyx cron <arg>      Execute demyx cron"
        echo "           daily      Execute every day cron"
        echo "           hourly     Execute every day cron"
        echo "           minute     Execute every minute cron"
        echo "           six-hour   Execute every six hour cron"
        echo "           weekly     Execute every week cron"
        echo
    elif [[ "$DEMYX_HELP" = edit ]]; then
        echo
        echo "demyx edit <app> <args>       Opens nano to edit .env files"
        echo "                 stack        Edit the stack's .env"
        echo "                 --up         Executes demyx compose <app> up -d after exiting nano"
        echo
    elif [[ "$DEMYX_HELP" = exec ]]; then
        echo
        echo "demyx exec <app> <args>       Accepts all docker exec arguments (default flags: -it)"
        echo "                 db           Targets MariaDB container"
        echo "                 nx           Targets NGINX container"
        echo "                 -r           Execute as root"
        echo "                 -t           Allocate a non-interactive TTY"
        echo
    elif [[ "$DEMYX_HELP" = healthcheck ]]; then
        echo
        echo "demyx healthcheck     Checks if WordPress apps are up"
        echo
    elif [[ "$DEMYX_HELP" = info ]]; then
        echo
        echo "demyx info <app>  <args>          Show environment info for an app"
        echo "           all                    Loop through all apps"
        echo "           env                    Use --filter for all WordPress sites"
        echo "           motd                   Show miscellaneous server data for motd"
        echo "                  --all           Show all environment info"
        echo "                  --backup        Show all backups"
        echo "                  --filter        Filter environment variables"
        echo "                  --json          Output data in JSON"
        echo "                  --no-password   Omit passwords"
        echo "                  --no-volume     Omit volume sizes"
        echo "                  --quiet         Prevent output of error if filter not found"
        echo
    elif [[ "$DEMYX_HELP" = list ]]; then
        echo
        echo "demyx list <args>         List all apps"
        echo "           update         List updates if any"
        echo "           --json         List all sites in json"
        echo "           --raw          Raw list with no tables"
        echo
    elif [[ "$DEMYX_HELP" = log ]]; then
        echo
        echo "demyx log <app> <args>            Show demyx/container logs, defaults to demyx log"
        echo "          api                     Show api log"
        echo "          cron                    Show cron log"
        echo "          main                    Show demyx container log, pass -e for error log"
        echo "          traefik                 Show Traefik logs"
        echo "          domain.tld              Show WP container logs"
        echo "                -c|--container    Show container log"
        echo "                -d|--database     Show log for MariaDB"
        echo "                -e|--error        Show error log"
        echo "                -f|--follow       Follow log"
        echo "                --rotate          Rotate logs"
        echo
    elif [[ "$DEMYX_HELP" = maldet ]]; then
        echo
        echo "demyx maldet <app> <args>     Default scan is the WordPress container"
        echo "                   db         Scan the database container"
        echo
    elif [[ "$DEMYX_HELP" = monitor ]]; then
        echo
        echo "demyx monitor     Auto scale containers"
        echo
    elif [[ "$DEMYX_HELP" = pull ]]; then
        echo
        echo "demyx pull <args>                                 Enter specific image or demyx pull all"
        echo "demyx pull all                                    Pull core and relevant images"
        echo "demyx pull browsersync"
        echo "demyx pull code-server:openlitespeed"
        echo "demyx pull code-server:openlitespeed-sage"
        echo "demyx pull code-server:sage"
        echo "demyx pull code-server:wp"
        echo "demyx pull demyx"
        echo "demyx pull docker-compose"
        echo "demyx pull docker-socket-proxy"
        echo "demyx pull logrotate"
        echo "demyx pull mariadb"
        echo "demyx pull nginx"
        echo "demyx pull openlitespeed:bedrock"
        echo "demyx pull pma"
        echo "demyx pull ssh"
        echo "demyx pull traefik"
        echo "demyx pull utilities"
        echo "demyx pull wordpress"
        echo "demyx pull wordpress:bedrock"
        echo "demyx pull wordpress:cli"
        echo
    elif [[ "$DEMYX_HELP" = refresh ]]; then
        echo
        echo "demyx refresh <app> <args>            Regenerate .env/.yml files of an app"
        echo "              all                     Regenerate all app's .env/.yml files"
        echo "              code                    Regenerate code-server .env/.yml files"
        echo "              traefik                 Regenerate reverse proxy .yml"
        echo "                    --skip-backup     Skip backing up config files"
        echo "                    --skip-checks     Skip regenerating other configs like auth, cache, etc."
        echo
    elif [[ "$DEMYX_HELP" = restore ]]; then
        echo
        echo "demyx restore <app> <args>        Restore an app from a backup"
        echo "                    --config      Restore only the configs"
        echo "                    --date        Restore from a specific date in format: YY/mm/dd"
        echo "                    -f|--force    Force restore"
        echo
    elif [[ "$DEMYX_HELP" = rm ]]; then
        echo
        echo "demyx rm <app> <args>         Deletes an app"
        echo "         all                  Targets all apps"
        echo "               -f|--force     Force remove"
        echo "               --wp           Targets all WordPress apps"
        echo
    elif [[ "$DEMYX_HELP" = run ]]; then
        echo
        echo "demyx run <app> <arg>                 Creates a new app"
        echo "                --archive             Run a WordPress app from an archive"
        echo "                --auth                Run with basic auth on/off"
        echo "                --cache               Run with cache on/off"
        echo "                --cf                  Use Cloudflare as the DNS challenge for SSL/TLS"
        echo "                --clone               Clone an already running app"
        echo "                --email               Override email generation"
        echo "                --force               Force delete if exists"
        echo "                --pass                Override password generation"
        echo "                --rate-limit          Run with rate limit on/off"
        echo "                --skip-init           Skip the initializing checks, useful if the run command hangs"
        echo "                --ssl                 Run with ssl on/off"
        echo "                --stack               Create a WordPress app using preferred stack: bedrock, nginx-php, ols (default), ols-bedrock"
        echo "                --type                Run app type as wp/php/html"
        echo "                --user                Override user generation"
        echo "                --whitelist           Available values: all (site-wide), login"
        echo
    elif [[ "$DEMYX_HELP" = update ]]; then
        echo
        echo "demyx update          Update demyx cache"
        echo "demyx update show     Show demyx images that has an udpate"
        echo
    elif [[ "$DEMYX_HELP" = util ]]; then
        echo
        echo "demyx util <arg>          Generate credentials"
        echo "           --cred         Generate all credentials"
        echo "           --htpasswd     Generate htpasswd"
        echo "           --kill         Kill all demyx/utilities orphans"
        echo "           --pass         Generate password"
        echo "           --raw          Output without table"
        echo "           --user         Generate username"
        echo
    elif [[ "$DEMYX_HELP" = wp ]]; then
        echo
        echo "demyx wp <app> <arg>      Execute wp-cli commands"
        echo
    else
        echo
        echo "demyx <arg>           Main demyx command"
        echo "      backup          Back up an app"
        echo "      compose         Accepts all docker-compose arguments"
        echo "      config          Modifies an app's configuration"
        echo "      cp              Wrapper for docker cp"
        echo "      cron            Execute demyx cron"
        echo "      edit            Opens nano to edit .env files"
        echo "      exec            Accepts all docker exec arguments"
        echo "      host            Command only available on the host OS, for more info: demyx host help"
        echo "      healthcheck     Checks if WordPress apps are up"
        echo "      info            Shows an app's .env and filter output"
        echo "      list            List all apps"
        echo "      log             Show or follow demyx.log"
        echo "      maldet          Linux Malware Detect"
        echo "      monitor         For auto scaling purposes"
        echo "      motd            Message of the day"
        echo "      pull            Pull one or all demyx images from Docker hub"
        echo "      refresh         Refresh env and yml files of an app"
        echo "      restore         Restore an app"
        echo "      rm              Removes an app and its volumes"
        echo "      run             Creates a new app"
        echo "      shell           Host command to execute shell commands into the demyx container"
        echo "      update          Update demyx ccache"
        echo "      util            Generates credentials or access util container"
        echo "      version         Show demyx version"
        echo "      wp              Execute wp-cli commands"
        echo
    fi
}
