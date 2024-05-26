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
            echo "                   -c                 Backup only the configs (docker-compose.yml and .env)."
            echo "                   -d                 Backup only the database."
            echo "                   -l                 List all backups with file size shown."
            echo "                   --path             For advance users where the main docker-compose.yml has been extended with a custom volume path. (Usage: --path=/custom/path)"
            echo
        ;;
        compose)
            echo
            echo "demyx compose <app> <args> <docker compose args>      Targets an app to execute docker compose commands."
            echo "                    all                               Execute docker compose commands to all apps."
            echo "                    -d                                Targets an app’s MariaDB container."
            echo "                    down                              Executes docker compose stop and rm -f."
            echo "                    fr                                Executes docker compose up -d –for-recreate –remove-orphans."
            echo "                    -n                                Target an app’s Nginx container."
            echo "                    -w                                Targets an app’s WordPress container."
            echo
        ;;
        config)
            echo
            echo "demyx config <app> <args>                             Configure a specific app."
            echo "             all                                      Configures all apps in a loop)."
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
            echo "                   --php                              Switch PHP/LSPHP version. (Usage: --php=<8.1|8.2>)"
            echo "                   --php-max-children                 Update php-fpm max child processes. (Usage: --php-max-children=5)"
            echo "                   --php-max-requests                 Update php-fpm max requests per child process. (Usage: --php-max-requests=500)"
            echo "                   --php-max-spare-servers            Update php-fpm max idle server processes. (Usage: --php-max-spare=4)"
            echo "                   --php-min-spare-servers            Update php-fpm minimum idle server processes. (Usage: --php-min-spare=1)"
            echo "                   --php-pm                           Update php-fpm process manager. (Usage: --php-pm=<static|ondemand|dynamic>)"
            echo "                   --php-pm-calc                      Automatically adjust php-fpm values based on container's memory."
            echo "                   --php-process-idle-timeout         Update php-fpm duration when killing an idle process. (Usage: --php-process-idle-timeout=3s)"
            echo "                   --php-start-servers                Update php-fpm initial child processes on startup. (Usage: --php-start-servers=1)"
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
            echo "                   --www                              Converts/reverts top level domain to use/remove www."
            echo "                   --xmlrpc                           Enable/disable /xmlrpc.php file by returning a 404. Disabled by default."
            echo
        ;;
        cp)
            echo
            # TODO
            #echo "demyx cp <app/path>:<path> <app/path>:<path>      Wrapper for docker cp"
            #echo "         db                                       Target docker cp for MariaDB container"
            echo "demyx cp <app>    Outputs a series of commands to copy and paste."
            echo
        ;;
        cron)
            echo
            echo "demyx cron <arg>              Execute demyx cron manually."
            echo "           daily              Daily cron that will execute a series of commands in order on midnight and depending on the value of DEMYX_TZ."
            echo "           five-minute        Every five minute cron that will execute a series of commands."
            echo "           hourly             Hourly cron that will execute a custom hourly callback script for now."
            echo "           minute             Every minute cron that will execute a custom minute callback script for now."
            echo "           six-hour           Every six hour cron that will execute a custom six hour callback script for now."
            echo "           weekly             Weekly cron that will execute a custom weekly callback script for now."
            echo
        ;;
        edit)
            echo
            echo "demyx edit <app>      <args>          Executes 'nano /demyx/app/wp/<app>/.env' inside the Demyx container."
            # TODO - echo "           traefik                    Edit Traefik's .env"
            echo "                      -r              Use this flag to refresh the app’s docker-compose.yml and .env files. App’s containers will be recreated."
            echo
        ;;
        exec)
            echo
            echo "demyx exec <app> <args>       Executes commands inside the WordPress container. If no arguments passed, then a bash shell will open."
            echo "                 -d           Executes commands inside the MariaDB container. If no arguments passed, then a bash shell will open."
            echo "                 -n           Executes commands inside the Nginx container. If no arguments passed, then a bash shell will open."
            echo "                 -r           Executes root commands inside the container. (Usage: demyx exec <app> -r)"
            echo "                 -t           Disables interactive mode."
            echo
        ;;
        healthcheck)
            echo
            echo "demyx healthcheck <args>      Mainly used by demyx cron but can be executed manually. If there’s no output, then everything is working smoothly. To enable notifications, fill in the values under DEMYX_MATRIX and DEMYX_SMTP when you run 'demyx host edit'."
            echo "demyx healthcheck app         Checks if any of the app’s containers are down. Executes a series of commands to display multiple and relevant logs if any are down."
            echo "demyx healthcheck disk        Checks how low disk space is based on the value of DEMYX_HEALTHCHECK_DISK_THRESHOLD."
            echo "demyx healthcheck load        Checks and compares the 5 minute load average value from /proc/loadavg with DEMYX_HEALTHCHECK_LOAD."
            echo
        ;;
        info)
            echo
            echo "demyx info <app>      <args>      Prints all environment variables for an app and formatted using column."
            echo "           apps                   Prints currently installed apps."
            echo "           system                 Prints useful system information. Mainly used with demyx motd."
            echo "                      --env       Executes grep to grab environment variable(s). (Usage: --env=DEMYX_APP_STACK)"
            echo "                      -j          Print in JSON format."
            echo "                      -l          Prints all login credentials with a WordPress login link provided by wp login package."
            echo "                      -nv         Suppress showing DB and WP's volume sizes."
            echo "                      -r          Prints raw list of installed apps without the header."
            echo
        ;;
        log)
            echo
            echo "demyx log <app>           <args>          Main command to print various logs."
            echo "          cron                            Prints Demyx cron log."
            echo "          main                            Prints Demyx main log."
            echo "          traefik                         Prints Traefik log."
            echo "                          -c|-cf|-fc      Prints cron log."
            echo "                          -d|-df|-fd      Prints MariaDB log."
            echo "                          -e|-ef|-fe      Prints error log."
            echo "                          -f              Print log and follow."
            echo "                          -s|-sf|-fs      Execute docker logs."
            echo
        ;;
        pull)
            echo
            echo "demyx pull <args>                                 Pull available specific Demyx or third party images to update them manually."
            echo "           all                                    Smart pulls all Demyx and third party images."
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
            echo "demyx refresh <app>       <args>      Regenerate docker-compose.yml and .env files."
            echo "              all                     Regenerate all app's .env/docker-compose.yml files."
            echo "              code                    Regenerate docker-compose.yml and .env for the code-server service."
            echo "              traefik                 Regenerate docker-compose.yml and .env for the traefik service."
            echo "                          -f          Delete and regenerate app's non-sensitive environment variables between two points. Does not work with code-server and traefik service."
            echo "                          -fr         Regenerate docker-compose.yml and .env files and execute docker compose up -d --force-recreate --remove-orphans."            
            echo "                          -nc         Regenerate docker-compose.yml and .env files only, no docker compose commands will be executed."
            echo "                          -s          Regenerate docker-compose.yml and .env files and skip app's config backup."
            echo
        ;;
        restore)
            echo
            echo "demyx restore <app> <args>        Restore app’s configs and volumes."
            echo "                    -c            Restores app’s docker-compose.yml and .env files only."
            echo "                    --date        Specify which archive date you want to restore. Must be in the format of yy-mm-d."
            echo "                    -d            Restore database only."
            echo "                    -f            Disable prompt when restoring an app."
            echo
        ;;
        rm)
            echo
            echo "demyx rm <app> <args>         Delete an app’s configs and volumes."
            echo "         all                  Delete all app configs and volumes."
            echo "               -f             Disable prompt when deleting an app."
            echo
        ;;
        run)
            echo
            echo "demyx run <app> <args>                    Creates an app."
            echo "                --auth                    Create an app with basic authentication enabled."
            echo "                --cache                   Create an app with cache enabled."
            echo "                --clone                   Create an app by cloning a running app. (Usage: --clone=<app>)"
            echo "                --email                   Set custom email when creating an app instead of info@DEMYX_DOMAIN."
            echo "                -f                        Disable delete prompt when creating an app that already exist."
            echo "                --pass|--password         Set custom password when creating a new app."
            echo "                --php                     Set specific PHP version when creating an app. PHP version is set to 8.1 by default. (Usage: --php=<8.1|8.2>)"
            echo "                --redis                   Create an app with Redis enabled."
            echo "                --ssl                     Enable SSL when creating an app. SSL is false by default."
            echo "                --ssl-wildcard            Enable wildcard SSL when creating an app."
            echo "                --stack                   Set stack type when creating an app. Nginx/PHP is set by default. (Usage: --stack=<bedrock|nginx-php|ols|ols-bedrock>)"
            echo "                --type                    Create an app other than WordPress. Default is WordPress. (WordPress is only available)"
            echo "                --user|--username         Set custom username instead of using the auto generated username."
            echo "                --whitelist               Enable IP whitelist when creating an app. Defaults to all. (Usage: --whitelist=<all|login>)"
            echo "                --www                     Include www. as the app's full URL"
            echo
        ;;
        smtp)
            echo
            echo "demyx smtp        Sends out a success email if SMTP is configured properly."
            echo
        ;;
        update)
            echo
            echo "demyx update <args>           Runs a series of commands to compare local versions of Demyx images to remote versions. It will also update the Demyx helper script on the host."
            echo "             -i               Update cache only and not the Demyx helper script."
            echo "             -l               Prints out all Demyx images with current versions. An indicator will show when an update is available."
            echo
        ;;
        utility)
            echo
            echo "demyx utility <type>              <args>          Generate various credentials or open a shell to the Demyx Utilities container."
            echo "              cred|credentials                    Generates username, password, and htpasswd."
            echo "              htpasswd                            Generates htpasswd. (Usage: demyx htpasswd <username> <password>)"
            echo "              id                                  Generates random ID. Default is 5 characters. (Usage: demyx id <length>)"
            echo "              pass|password                       Generates random password. Default is 20 characters. (Usage: demyx password <length>)"
            echo "              sh|shell                            Run commands to demyx/utilities container. Opens a bash shell if there's no args passed."
            echo "              user|username                       Generates random username."
            echo "              -r                                  Prints raw. Does not work with the credentials arg."
            echo
        ;;
        wp)
            echo
            echo "demyx wp <app> <args>     Execute wp-cli commands to an app."
            echo "demyx wp all <args>       Execute wp-cli commands to all apps in a loop."
            echo
        ;;
        *)
            echo
            echo "demyx <arg>                   Main demyx command, for more info: demyx help <arg>"
            echo "      backup                  Backup specific app."
            echo "      compose                 Targets an app to execute docker compose commands."
            echo "      config                  Configure a specific app."
            echo "      cp                      Outputs a series of commands to copy and paste."
            echo "      cron                    Execute demyx cron manually."
            echo "      edit                    Executes 'nano /demyx/app/wp/<app>/.env' inside the Demyx container."
            echo "      exec                    Executes commands inside the WordPress container. If no arguments passed, then a bash shell will open."
            echo "      healthcheck             Mainly used by demyx cron but can be executed manually."
            echo "      info                    Prints all environment variables for an app and formatted using column."
            echo "      log                     Main command to print various logs."
            echo "      motd                    Message of the day."
            echo "      pull                    Pull available specific Demyx or third party images to update them manually."
            echo "      refresh                 Regenerate docker-compose.yml and .env files."
            echo "      restore                 Restore app’s configs and volumes."
            echo "      rm                      Delete an app’s configs and volumes."
            echo "      run                     Creates an app."
            echo "      smtp                    Sends out a success email if SMTP is configured properly."
            echo "      update                  Runs a series of commands to compare local versions of Demyx images to remote versions. It will also update the Demyx helper script on the host."
            echo "      util|utility            Generate various credentials or open a shell to the Demyx Utilities container."
            echo "      -v|--version|version    Show demyx version."
            echo "      wp                      Execute wp-cli commands to an app."
            echo
        ;;
    esac
}
