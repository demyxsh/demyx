# Demyx
# https://demyx.sh
# 
# demyx help <args>
#
function demyx_help() {
    if [[ "$2" = backup ]]; then
        echo
        echo "demyx backup <app> <args>     Backup an app by domain"
        echo "             all              Backup all apps"
        echo
    elif [[ "$2" = compose ]]; then
        echo
        echo "demyx compose <app> <args>    Accepts all docker-compose arguments"
        echo "                    db        docker-compose for the MariaDB container"
        echo "                    down      Shorthand for docker-compose stop/rm -f"
        echo "                    du        Shorthand for docker-compose stop/rm -f/up -d"
        echo "                    wp        docker-compose for the WordPress container"
        echo
    elif [[ "$2" = config ]]; then
        echo
        echo "demyx config <app> <args>           Config"
        echo "             all                    Targets all apps (only works with --refresh and --restart)"
        echo "                   --auth           Turns on/off basic auth"
        echo "                   --cache          Turns on/off fastcgi cache"
        echo "                   --cdn            Turns on/off CDN, powered by Staticaly"
        echo "                   --dev            Turns on/off development mode"
        echo "                   --files          BrowserSync arg: themes, plugins, or custom path"
        echo "                   --force          Force config"
        echo "                   --rate-limit     Turns on/off NGINX rate limting"
        echo "                   --refresh        Regenerate config files and uploaded to container"
        echo "                   --restart        Restart NGINX/PHP services"
        echo "                   --sftp           Turns on/off SFTP container"
        echo "                   --ssl            Turns on/off SSL"
        echo "                   --update         Pushes updated config files to container"
        echo
    elif [[ "$2" = exec ]]; then
        echo
        echo "demyx exec <app> <args>    Accepts all docker exec arguments"
        echo "                 --db      Targets MariaDB container"
        echo
    elif [[ "$2" = info ]]; then
        echo
        echo "demyx info <app> <args>       Show environment info for an app"
        echo "                 --all        Show all environment info"
        echo "                 --filter     Filter environment variables"
        echo
    elif [[ "$2" = install ]]; then
        echo
        echo "demyx install <args>      Install the demyx stack"
        echo "              --domain    Primary domain required"
        echo "              --email     Email for Lets Encrypt notifications"
        echo "              --force     Force reinstall the stack"
        echo "              --user      Username for basic auth"
        echo "              --pass      Password for basic auth"
        echo
    elif [[ "$2" = log ]]; then
        echo
        echo "demyx log <app> <args>          Show demyx/container logs"
        echo "                -f|--follow     Follow log"
        echo "                --rotate        Rotate logs for demyx, stack, and WP sites"
        echo
    elif [[ "$2" = maldet ]]; then
        echo
        echo "demyx maldet <app> <args>     Default scan is the WordPress container"
        echo "                   db         Scan the database container"
        echo
    elif [[ "$2" = monitor ]]; then
        echo
        echo "demyx monitor     Auto scale containers"
        echo
    elif [[ "$2" = restore ]]; then
        echo
        echo "demyx restore <app> <args>        Restore an app from a backup"
        echo "                    -f|--force    Force restore"
        echo
    elif [[ "$2" = rm ]]; then
        echo
        echo "demyx rm <app> <args>         Deletes an app"
        echo "         all                  Targets all apps"
        echo "               -f|--force     Force remove"
        echo "               --wp           Targets all WordPress apps"
        echo
    elif [[ "$2" = run ]]; then
        echo
        echo "demyx run <app> <arg>           Creates a new app"
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
    elif [[ "$2" = stack ]]; then
        echo
        echo "demyx stack <arg>     Target stack containers"
        echo "            down      Shorthand for docker-compose stop/rm -f"
        echo "            --du      Shorthand for docker-compose stop/rm -f/up -d"
        echo
    elif [[ "$2" = update ]]; then
        echo
        echo "demyx update      Update demyx code base"
        echo
    elif [[ "$2" = util ]]; then
        echo
        echo "demyx util <arg>          Generate credentials"
        echo "           --cred         Generate all credentials"
        echo "           --htpasswd     Generate htpasswd"
        echo "           --kill         Kill all demyx/utilities orphans"
        echo "           --pass         Generate password"
        echo "           --raw          Output without table"
        echo "           --user         Generate username"
        echo
    elif [[ "$2" = wp ]]; then
        echo
        echo "demyx wp <app> <arg>      Execute wp-cli commands"
        echo
    else
        echo
        echo "demyx <arg>       Main demyx command"
        echo "      backup      Back up an app"
        echo "      compose     Accepts all docker-compose arguments"
        echo "      config      Modifies an app's configuration"
        echo "      ctop        Htop but for containers"
        echo "      exec        Accepts all docker exec arguments"
        echo "      info        Shows an app's .env and filter output"
        echo "      log         Show or follow demyx.log"
        echo "      maldet      Linux Malware Detect"
        echo "      monitor     For auto scaling purposes"
        echo "      motd        Message of the day"
        echo "      restore     Restore an app"
        echo "      rm          Removes an app and its volumes"
        echo "      run         Creates a new app"
        echo "      stack       Control the stack via docker-compose arguments"
        echo "      update      Update demyx code base"
        echo "      util        Generates credentials or access util container"
        echo "      wp          Execute wp-cli commands"
        echo
    fi
}
