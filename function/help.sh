# Demyx
# https://demyx.sh
# shellcheck shell=bash

#
#   demyx help <args>
#
demyx_help() {
    demyx_event
    case "${1:-$DEMYX_ARG_2}" in
        backup)
            echo
            echo "demyx backup <app> <args>             Backup specific app."
            echo "             all                      Backup all apps in a loop."
            echo "             traefik                  Backup Traefik's acme.json and compose.yml files."
            echo "                   -c                 Backup only the configs (compose.yml and .env)."
            echo "                   -d                 Backup only the database."
            echo "                   -l                 List all backups with file size shown."
            echo "                   --path             Move backup to custom path after creation. (Usage: --path=/custom/path)"
            echo
        ;;
        compose)
            echo
            echo "demyx compose <app> <args> <docker compose args>      Targets an app to execute docker compose commands."
            echo "                    all                               Execute docker compose commands to all apps."
            echo "                    -d                                Targets an app's MariaDB container (db_<id>)."
            echo "                    down                              Executes docker compose stop and rm -f."
            echo "                    fr                                Executes docker compose up -d --force-recreate --remove-orphans."
            echo "                    -n                                Targets an app's Nginx container (nx_<id>)."
            echo "                    -w                                Targets an app's WordPress container (wp_<id>)."
            echo
        ;;
        config)
            echo
            echo "demyx config <app> <args>                             Configure a specific app."
            echo "             all                                      Configures all apps in a loop."
            echo "                   -f                                 Skip confirmation."
            echo "                   --auth                             Enable/disable basic authentication."
            echo "                   --auth-wp                          Enable/disable basic authentication for WordPress login."
            echo "                   --backup                           Enable/disable app backup. (Usage: --backup=<true|false>)"
            echo "                   --bedrock                          Configure a Bedrock app's mode to production/development. (Usage: --bedrock=<production|development>)"
            echo "                   --cache                            Installs and configures cache plugins depending on app's stack. Supports WP Rocket with rocket-nginx (only for the nginx-php stack). (Usage: --cache=<true|false|default|rocket>)"
            echo "                   --clean                            Export and imports database with new credentials, force downloads core WordPress files, and refresh salts."
            echo "                   --convert                          Convert container and volume names to the new format."
            echo "                   --db-cpu                           Configure DB container's CPU limit, --db-cpu=0 to remove limit. (Usage: --db-cpu=.50)"
            echo "                   --db-mem                           Configure DB container's memory limit, --db-mem=0 to remove limit. (Usage: --db-mem=256m)"
            echo "                   --dev                              Code-server service will be created and perform various commands to WordPress."
            echo "                   --healthcheck                      Enable/disable healthcheck."
            echo "                   --maintenance                      Enable/disable maintenance mode."
            echo "                   --no-compose                       Prevents executing docker compose up -d after running a config."
            # TODO - echo "                   --no-maldet                        Skip maldet commands, used with --clean"
            echo "                   --opcache                          Enable/disable PHP opcache."
            echo "                   --php                              Switch PHP/LSPHP version. (Usage: --php=<8.2|8.3>)"
            echo "                   --php-average                      Set php-fpm child process ram average in kb. (Usage: --php-average=100000)"
            echo "                   --php-max-requests                 Update php-fpm max requests per child process. (Usage: --php-max-requests=500)"
            echo "                   --pma                              Enable/disable phpMyAdmin service."
            echo "                   --rate-limit                       Enable/disable Nginx's rate limiting for /wp-login.php and /wp-cron.php."
            echo "                   --redis                            Enable/disable Redis service and configures the proper plugin depending on app's stack."
            # TODO - echo "                   --restart                          Restart NGINX/PHP/OLS services: nginx, nginx-php, ols, php (restarting nginx will delete cache)"
            echo "                   --sftp                             Enable/disable SFTP service. Automatically scans for open port starting with 2222."
            echo "                   --ssl                              Enable/disable http or https. Executes wp-cli to search and replace the database."
            echo "                   --ssl-wildcard                     Enable/disable wildcard for SSL. Executes wp-cli to search and replace the database."
            echo "                   --stack                            Switch stack between Nginx/PHP to OpenLiteSpeed and vice versa but cannot switch from Nginx/PHP to Bedrock. The same applies to OpenLiteSpeed to OpenLiteSpeed Bedrock. (Usage: --stack=<bedrock|nginx-php|ols|ols-bedrock>)"
            echo "                   --whitelist                        Enables/disables IP whitelisting site-wide or just WordPress login. DEMYX_IP must be set by running demyx host edit. (Usage: --whitelist=<all|login>)"
            echo "                   --wp-cpu                           Configure WP container's CPU limit, --wp-cpu=0 to remove limit. (Usage: --wp-cpu=.50)"
            echo "                   --wp-mem                           Configure WP container's memory limit, --wp-mem=0 to remove limit. (Usage: --wp-mem=256m)"
            echo "                   --wp-update                        Enable/disable WordPress auto update by wp-cli. Auto updates WordPress core files, plugins, and themes."
            echo "                   --www                              Enable/disable www subdomain for the app's domain."
            echo "                   --xmlrpc                           Enable/disable /xmlrpc.php file by returning a 404. Disabled by default."
            echo
        ;;
        cp)
            echo
            echo "demyx cp <app>    Generates docker cp commands for copying files to/from app containers."
            echo "                  Shows commands for MariaDB, Nginx (if applicable), and WordPress containers."
            echo
        ;;
        cron)
            echo
            echo "demyx cron <arg>              Execute demyx cron manually."
            echo "           daily              Daily cron: system backup, WordPress backups, auto-updates, log rotation."
            echo "           five-minute        Every five minute cron: app and load healthchecks."
            echo "           hourly             Hourly cron: disk healthcheck."
            echo "           minute             Every minute cron: executes custom minute script if exists."
            echo "           six-hour           Every six hour cron: executes custom six-hour script if exists."
            echo "           weekly             Weekly cron: system updates."
            echo
        ;;
        down)
            echo
            echo "demyx down <app>        Shortcut for docker compose down"
            echo
        ;;
        edit)
            echo
            echo "demyx edit <app>      <args>          Opens the app's .env file in nano editor inside the Demyx container."
            # TODO - echo "           traefik                    Edit Traefik's .env"
            echo "                      -r              Refresh the app's compose.yml and .env files after editing. App's containers will be recreated."
            echo
        ;;
        exec)
            echo
            echo "demyx exec <app> <args>       Executes commands inside the WordPress container. Opens bash shell if no command specified."
            echo "           code               Executes commands inside the code-server container. Opens zsh shell if no command specified."
            echo "           traefik            Executes commands inside the Traefik container. Opens bash shell if no command specified."
            echo "                 -d           Executes commands inside the MariaDB container. Opens bash shell if no command specified."
            echo "                 -n           Executes commands inside the Nginx container. Opens bash shell if no command specified."
            echo "                 -r           Execute commands as root user instead of demyx user."
            echo "                 -t           Disable interactive mode (TTY only)."
            echo
        ;;
        healthcheck)
            echo
            echo "demyx healthcheck <args>      Mainly used by demyx cron but can be executed manually. If there's no output, then everything is working smoothly. To enable notifications, fill in the values under DEMYX_MATRIX and DEMYX_SMTP when you run 'demyx host edit'."
            echo "demyx healthcheck app         Checks if any app containers are down. Shows docker logs and log files for failed containers."
            echo "demyx healthcheck disk        Checks disk usage and shows df output. Sends notification if usage exceeds DEMYX_HEALTHCHECK_DISK_THRESHOLD."
            echo "demyx healthcheck load        Checks system load average and shows top output with container stats. Sends notification if 5-minute load exceeds DEMYX_HEALTHCHECK_LOAD."
            echo
        ;;
        info)
            echo
            echo "demyx info <app>      <args>      Prints app's environment variables and volume sizes. Shows DB and WP volume sizes by default."
            echo "           apps                   Lists all installed apps with count."
            echo "           system                 Shows system information: build, version, hostname, IP, apps count, backups, disk, memory, uptime, load, containers."
            echo "                      --env       Search for specific environment variable(s). (Usage: --env=DEMYX_APP_STACK)"
            echo "                      -j          Print output in JSON format."
            echo "                      -l          Shows all login credentials: basic auth, code server, OLS admin (if applicable), MariaDB, WordPress."
            echo "                      -nv         Suppress showing DB and WP volume sizes."
            echo "                      -r          Print raw list of installed apps without header (only works with apps)."
            echo
        ;;
        log)
            echo
            echo "demyx log <app>           <args>          View various logs. Default shows app's access log (last 200 lines)."
            echo "          cron                            View Demyx cron log."
            echo "          main                            View Demyx main log or error log."
            echo "          traefik                         View Traefik access log or error log."
            echo "                          -c|-cf|-fc      View app's cron log (add f to follow)."
            echo "                          -d|-df|-fd      View app's MariaDB log (add f to follow)."
            echo "                          -e|-ef|-fe      View app's error log (add f to follow)."
            echo "                          -f              Follow log output (real-time)."
            echo "                          -s|-sf|-fs      View app's docker logs (add f to follow)."
            echo
        ;;
        pull)
            echo
            echo "demyx pull <args>                                 Pull Docker images. Use 'all' to pull all Demyx and third-party images."
            echo "           all                                    Smart pull: only pulls images that are already in the local registry."
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
            echo "           redis"
            echo "           ssh"
            echo "           traefik"
            echo "           utilities"
            echo "           wordpress"
            echo "           wordpress:bedrock"
            echo
        ;;
        refresh)
            echo
            echo "demyx refresh <app>       <args>      Regenerate compose.yml and .env files. Creates config backup by default."
            echo "              all                     Regenerate all app's .env/compose.yml files."
            echo "              code                    Regenerate compose.yml and .env for the code-server service."
            echo "              traefik                 Regenerate compose.yml for traefik service and backup acme.json."
            echo "                          -f          Delete and regenerate app's non-sensitive environment variables between refreshable markers."
            echo "                          -fr         Regenerate files and execute docker compose up -d --force-recreate --remove-orphans."
            echo "                          -nc         Regenerate compose.yml and .env files only, no docker compose commands will be executed."
            echo "                          -s          Skip app's config backup before regenerating files."
            echo
        ;;
        restore)
            echo
            echo "demyx restore <app>       <args>        Restore app from backup. Removes existing app if present."
            echo "demyx restore traefik                   Restore Traefik's acme.json and compose.yml files."
            echo "                          -c            Restore app's compose.yml and .env files only (config backup)."
            echo "                          --date        Specify backup date to restore. Format: YYYY-MM-DD (defaults to today)."
            echo "                          -d            Restore database only. Uses latest backup if no .sql file found."
            echo "                          -f            Skip confirmation prompt when restoring an app."
            echo
        ;;
        rm)
            echo
            echo "demyx rm <app> <args>         Delete an app completely: containers, volumes, and config files."
            echo "         all                  Delete all apps from all directories (html, php, wp)."
            echo "               -f             Skip confirmation prompt when deleting an app."
            echo
        ;;
        run)
            echo
            echo "demyx run <app> <args>                    Create a new WordPress app with specified configuration."
            echo "                --auth                    Enable basic authentication for the app."
            echo "                --cache                   Enable cache for the app."
            echo "                --clone                   Clone an existing app. (Usage: --clone=<app>)"
            echo "                --email                   Set custom admin email instead of info@DEMYX_DOMAIN."
            echo "                -f                        Skip confirmation prompt when app already exists."
            echo "                --pass|--password         Set custom admin password for the app."
            echo "                --php                     Set PHP version. Default: 8.3. (Usage: --php=<8.2|8.3>)"
            echo "                --redis                   Enable Redis for the app."
            echo "                --ssl                     Enable SSL for the app (requires DEMYX_DOMAIN and DEMYX_EMAIL)."
            echo "                --ssl-wildcard            Enable wildcard SSL (requires DEMYX_CF_KEY)."
            echo "                --stack                   Set stack type. Default: nginx-php. (Usage: --stack=<bedrock|nginx-php|ols|ols-bedrock>)"
            echo "                --type                    Set app type. Default: wp. (Usage: --type=<wp|php|html>)"
            echo "                --user|--username         Set custom admin username for the app."
            echo "                --whitelist               Enable IP whitelist. Default: all. (Usage: --whitelist=<all|login>)"
            echo "                --www                     Enable www subdomain for the app."
            echo
        ;;
        smtp)
            echo
            echo "demyx smtp        Sends out a success email if SMTP is configured properly."
            echo
        ;;
        up)
            echo
            echo "demyx up <app>        Shortcut for docker compose up -d"
            echo
        ;;
        update)
            echo
            echo "demyx update <args>           Check for updates and update Demyx images and helper script."
            echo "             -i               Update image cache only (skip helper script update)."
            echo "             -l               List all Demyx images with local/remote versions. Shows (NEW) indicator for available updates."
            echo
        ;;
        utility)
            echo
            echo "demyx utility <type>              <args>          Generate credentials or access the Demyx Utilities container."
            echo "              cred|credentials                    Generate username, password, and htpasswd in formatted table."
            echo "              htpasswd                            Generate htpasswd hash. (Usage: demyx utility htpasswd <username> <password>)"
            echo "              id                                  Generate random alphanumeric ID. Default: 5 characters. (Usage: demyx utility id <length>)"
            echo "              pass|password                       Generate random password. Default: 20 characters. (Usage: demyx utility password <length>)"
            echo "              sh|shell                            Open shell in demyx/utilities container. Default: bash. (Usage: demyx utility shell <command>)"
            echo "              user|username                       Generate random username using demyx name generator."
            echo "              -r                                  Output raw value (no formatting). Does not work with credentials."
            echo
        ;;
        wp)
            echo
            echo "demyx wp <app> <args>     Execute WP-CLI commands in the app's WordPress container."
            echo "demyx wp all <args>       Execute WP-CLI commands on all WordPress apps. Skips apps with errors."
            echo
        ;;
        *)
            echo
            echo "demyx <arg>                   Main demyx command, for more info: demyx help <arg>"
            echo "      backup                  Backup apps with config, database, or full backups."
            echo "      compose                 Execute docker compose commands on app containers."
            echo "      config                  Configure app settings and features."
            echo "      cp                      Generate docker cp commands for app containers."
            echo "      cron                    Execute scheduled maintenance tasks manually."
            echo "      down                    Shortcut for docker compose down."
            echo "      edit                    Edit app's .env file in nano editor."
            echo "      exec                    Execute commands in app containers with shell access."
            echo "      healthcheck             Check app and system health with notifications."
            echo "      info                    Display app environment variables and system information."
            echo "      log                     View various logs with follow options."
            echo "      motd                    Message of the day."
            echo "      pull                    Pull Docker images for Demyx and third-party services."
            echo "      refresh                 Regenerate app configuration files with backups."
            echo "      restore                 Restore apps from backups with container recreation."
            echo "      rm                      Delete apps completely: containers, volumes, and config files."
            echo "      run                     Create new WordPress apps with configuration options."
            echo "      smtp                    Test SMTP configuration with success email."
            echo "      up                      Shortcut for docker compose up -d."
            echo "      update                  Check for updates and update Demyx images and helper script."
            echo "      util|utility            Generate credentials or access the Demyx Utilities container."
            echo "      -v|--version|version    Show demyx version."
            echo "      wp                      Execute WP-CLI commands in WordPress containers."
            echo
        ;;
    esac
}
