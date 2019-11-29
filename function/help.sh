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
        echo "demyx config <app> <args>                     Configure demyx apps"
        echo "             all                              Targets all apps (only works with --refresh and --restart)"
        echo "                   --auth                     Turns on/off basic auth"
        echo "                   --auth-wp                  Turns on/off basic auth for wp-login.php"
        echo "                   --bedrock                  Sets production/development mode for Bedrock"
        echo "                   --cache                    Turns on/off fastcgi cache"
        echo "                   --cdn                      Turns on/off CDN, powered by Staticaly"
        echo "                   --clean                    Creates new MariaDB credentials and reinstalls WordPress core files"
        echo "                   --db-cpu                   Set the app's DB container CPU usage, --db-cpu=null to remove cap"
        echo "                   --db-mem                   Set the app's DB container MEM usage, --db-mem=null to remove cap"
        echo "                   --dev                      Turns on/off development mode"
        echo "                   --dev-base-path            Change code-server base path"
        echo "                   --dev-cpu                  Set the dev app's container CPU usage, --dev-cpu=null to remove cap"
        echo "                   --dev-mem                  Set the dev app's container MEM usage, --dev-mem=null to remove cap"
        echo "                   --expose                   Export ports to access web endpoint, works only with --dev and --pma"
        echo "                   --files                    BrowserSync arg: themes, plugins, or custom path"
        echo "                   --force                    Force config"
        echo "                   --healthcheck              Turns on/off healthcheck for WordPress container"
        echo "                   --mem                      Change the app's container memory usage, --mem=null to remove cap"
        echo "                   --no-backup                Disable auto back up"
        echo "                   --opcache                  Turns on/off PHP opcache"
        echo "                   --php-max-children         Update PHP's pm.max_children"
        echo "                   --php-max-requests         Update PHP's pm.max_requests"
        echo "                   --php-max-spare-servers    Update PHP's pm.max_spare_servers"
        echo "                   --php-min-spare-servers    Update PHP's pm.min_spare_servers"
        echo "                   --php-pm                   Update PHP's pm"
        echo "                   --php-process-idle-timeout Update PHP's pm.process_idle_timeout"
        echo "                   --php-start-servers        Update PHP's pm.start_servers"
        echo "                   --pma                      Turns on/off phpMyAdmin"
        echo "                   --rate-limit               Turns on/off NGINX rate limting"
        echo "                   --refresh                  Regenerate config files and uploaded to container"
        echo "                   --restart                  Restart NGINX/PHP services"
        echo "                   --sftp                     Turns on/off SFTP container"
        echo "                   --skip-checks              Skip checking other configs (cache, cdn, rate limit, etc.)"
        echo "                   --sleep                    Set sleep when all loop is used"
        echo "                   --ssl                      Turns on/off SSL"
        echo "                   --upgrade                  Upgrade the app"
        echo "                   --upgrade-db               Upgrade MariaDB"
        echo "                   --wp-cpu                   Set the app's container CPU usage, --wp-cpu=null to remove cap"
        echo "                   --wp-mem                   Set the app's container MEM usage, --wp-mem=null to remove cap"
        echo "                   --wp-update                Auto update WordPress core, themes, and plugins"
        echo "                   --xmlrpc                   Turns on/off xmlrpc.php"
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
        echo "           minute     Execute every minute cron"
        echo "           six-hour   Execute every six hour cron"
        echo "           weekly     Execute every week cron"
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
        echo "           stack                  Show stack versions and other info"
        echo "           system                 Show miscellaneous server data"
        echo "                  --all           Show all environment info"
        echo "                  --backup        Show all backups"
        echo "                  --filter        Filter environment variables"
        echo "                  --json          Output data in JSON"
        echo "                  --no-password   Omit passwords"
        echo "                  --no-volume     Omit volume sizes"
        echo "                  --quiet         Prevent output of error if filter not found"
        echo
    elif [[ "$DEMYX_HELP" = install ]]; then
        echo
        echo "demyx install <args>      Install the demyx stack"
        echo "              --domain    Primary domain required"
        echo "              --email     Email for Lets Encrypt notifications"
        echo "              --force     Force reinstall the stack"
        echo "              --user      Username for basic auth"
        echo "              --pass      Password for basic auth"
        echo
    elif [[ "$DEMYX_HELP" = list ]]; then
        echo
        echo "demyx list <args>         List all apps"
        echo "           --raw          Raw list with no tables"
        echo
    elif [[ "$DEMYX_HELP" = log ]]; then
        echo
        echo "demyx log <app> <args>            Show demyx/container logs, defaults to demyx log"
        echo "          api                     Show api log"
        echo "          cron                    Show cron log"
        echo "          main                    Show demyx container log, pass -e for error log"
        echo "          ouroboros               Show Ouroboros log"
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
        echo "demyx pull <args>     Enter specific image or blank to pull all"
        echo "           demyx"
        echo "           code-server:wp"
        echo "           docker-compose"
        echo "           logrotate"
        echo "           mariadb"
        echo "           nginx-rephp-wordpress"
        echo "           ssh"
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
        echo "demyx run <app> <arg>           Creates a new app"
        echo "                --archive       Run a WordPress app from an archive"
        echo "                --auth          Run with basic auth on/off"
        echo "                --cache         Run with cache on/off"
        echo "                --cdn           Run with cdn on/off"
        echo "                --clone         Clone an already running app"
        echo "                --email         Override email generation"
        echo "                --force         Force delete if exists"
        echo "                --pass          Override password generation"
        echo "                --rate-limit    Run with rate limit on/off"
        echo "                --ssl           Run with ssl on/off"
        echo "                --type          Run app type as wp/php/html"
        echo "                --user          Override user generation"
        echo
    elif [[ "$DEMYX_HELP" = stack ]]; then
        echo
        echo "demyx stack <app> <arg>       Target stack containers"
        echo "            api               Configure api"
        echo "            ouroboros         Configure Ouroboros"
        echo "            refresh           Refresh env and yml stack files"
        echo "            upgrade           Upgrade acme.json and configs for Traefik v2"
        echo "            --auto-update     Auto update Demyx core files"
        echo "            --backup          Turns on/off WordPress backups"
        echo "            --backup-limit    Set how many daily backup files to keep per site, defaults to 30"
        echo "            --cloudflare      Turns on/off Cloudflare as the CA resolver"
        echo "            --cf-api-email    Required Cloudflare email for --cloudflare"
        echo "            --cf-api-key      Required Cloudflare api key for --cloudflare"
        echo "            --cpu             Set the stack's container CPU usage, --cpu=null to remove cap"
        echo "            --healthcheck     Turns on/off healthcheck globally"
        echo "            --ignore          Used by Ouroboros to ignore updating images, enter container name or off to disable"
        echo "            --mem             Set the stack's container MEM usage, --mem=null to remove cap"
        echo "            --monitor         Turns on/off auto scaling globally"
        echo "            --false           Passes off flag"
        echo "            --telemetry       Pings to demyx.sh server to count active Demyx install"
        echo "            --true            Passes on flag"
        echo
    elif [[ "$DEMYX_HELP" = update ]]; then
        echo
        echo "demyx update      Update demyx code base"
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
        echo "      exec            Accepts all docker exec arguments"
        echo "      healthcheck     Checks if WordPress apps are up"
        echo "      info            Shows an app's .env and filter output"
        echo "      list            List all apps"
        echo "      log             Show or follow demyx.log"
        echo "      maldet          Linux Malware Detect"
        echo "      monitor         For auto scaling purposes"
        echo "      motd            Message of the day"
        echo "      pull            Pull one or all demyx images from Docker hub"
        echo "      restore         Restore an app"
        echo "      rm              Removes an app and its volumes"
        echo "      run             Creates a new app"
        echo "      stack           Control the stack via docker-compose arguments"
        echo "      update          Update demyx code base"
        echo "      util            Generates credentials or access util container"
        echo "      wp              Execute wp-cli commands"
        echo
    fi
}
