# Demyx
# https://demyx.sh

DEMYX_MOTD_CHECK_WP="$(ls -A "$DEMYX_WP")"

demyx_motd_yml_check() {
    if [[ ! -f "$DEMYX"/docker-compose.yml ]]; then
        demyx_execute -v echo -e "\e[31m[CRITICAL]\e[39m The demyx stack needs to be updated on the host, please run these commands on the host:\n\n- demyx update\n- demyx update --system (needs to be ran again with this flag)\n- demyx rm\n- demyx\n"
    fi
}
demyx_motd_dev_warning() {
    if [[ -n "$DEMYX_MOTD_CHECK_WP" ]]; then
        cd "$DEMYX_WP"
        for i in *
        do
            DEMYX_COMMON_DEV_CHECK="$(grep DEMYX_APP_DEV "$DEMYX_WP"/"$i"/.env | awk -F '[=]' '{print $2}')"
            if [[ "$DEMYX_COMMON_DEV_CHECK" = true ]]; then
                demyx_execute -v echo -e "\e[33m[WARNING]\e[39m $i is in development mode"
            fi
        done
    fi
}
demyx_motd_getting_started() {
    if [[ ! -f "$DEMYX_STACK"/.env ]]; then
        demyx_execute -v echo -e "\e[34m[INFO]\e[39m Looks like the stack isn't installed, run this command to install:\n\n- demyx stack install --domain=your-domain --email=info@your-domain --user=your-user --pass=your-pass\n"
        demyx_execute -v echo -e "\e[34m[INFO]\e[39m To create a WordPress app: demyx run ${DEMYX_MOTD_GETTING_STARTED_DOMAIN:-domain.tld}"
        demyx_execute -v echo -e "\e[34m[INFO]\e[39m Supported stacks: bedrock, nginx-php, ols, ols-bedrock"
        demyx_execute -v echo -e "\e[34m[INFO]\e[39m To see more run options: demyx help run"
    else
        if [[ -z "$DEMYX_MOTD_CHECK_WP" ]]; then
            DEMYX_MOTD_GETTING_STARTED_DOMAIN="$(demyx info stack --filter=DEMYX_STACK_DOMAIN)"
            demyx_execute -v echo -e "\e[34m[INFO]\e[39m To create a WordPress app: demyx run ${DEMYX_MOTD_GETTING_STARTED_DOMAIN:-domain.tld}"
            demyx_execute -v echo -e "\e[34m[INFO]\e[39m Supported stacks: bedrock, nginx-php, ols, ols-bedrock"
            demyx_execute -v echo -e "\e[34m[INFO]\e[39m To see more run options: demyx help run"
        fi
    fi
}
demyx_motd_stack_check() {
    if [[ -f "$DEMYX_STACK"/.env ]]; then
        demyx_source stack
        if [[ "$DEMYX_STACK_AUTO_UPDATE" = false ]]; then
            demyx_execute -v echo -e "\e[33m[WARNING]\e[39m Auto updates are disabled, demyx stack --auto-update to enable"
        fi
        if [[ "$DEMYX_STACK_BACKUP" = false ]]; then
            demyx_execute -v echo -e "\e[33m[WARNING]\e[39m Auto backups are disabled, demyx stack --backup to enable"
        fi
        if [[ "$DEMYX_STACK_MONITOR" = false ]]; then
            demyx_execute -v echo -e "\e[33m[WARNING]\e[39m Global monitors are disabled, demyx stack --monitor to enable"
        fi
        if [[ "$DEMYX_STACK_HEALTHCHECK" = false ]]; then
            demyx_execute -v echo -e "\e[33m[WARNING]\e[39m Global healthchecks are disabled, demyx stack --healthcheck to enable"
        fi
    fi
}
demyx_motd_update_check() {
    demyx_update_count
    
    DEMYX_MOTD_UPDATE_COUNT="$(cat "$DEMYX"/.update_count)"
    if [[ "$DEMYX_MOTD_UPDATE_COUNT" = 1 ]]; then
        DEMYX_MOTD_UPDATE_PLURAL=update
        #echo -e "\e[33m[UPDATE]\e[39m $DEMYX_MOTD_UPDATE_COUNT update available! View update: demyx list update"
    elif [[ "$DEMYX_MOTD_UPDATE_COUNT" > 1 ]]; then
        DEMYX_MOTD_UPDATE_PLURAL=updates
        #echo -e "\e[32m[UPDATE]\e[39m $DEMYX_MOTD_UPDATE_COUNT updates available! View updates: demyx list update"
    fi

    echo 
    echo -e "\e[32m[UPDATE]\e[39m $DEMYX_MOTD_UPDATE_COUNT $DEMYX_MOTD_UPDATE_PLURAL available!"
    echo -e "\e[32m[UPDATE]\e[39m - To view ${DEMYX_MOTD_UPDATE_PLURAL}: demyx list update"
    echo -e "\e[32m[UPDATE]\e[39m - Run command on the host: demyx upgrade"
}
#demyx_motd_git_latest() {
#    cd "$DEMYX_ETC" || exit
#    DEMYX_MOTD_GIT_LOG="$(git --no-pager log -5 --format=format:'- %s %C(white dim)(%ar)%C(reset)')"
#    demyx_execute -v echo -e "Latest Updates\n----------------\n$DEMYX_MOTD_GIT_LOG\n"
#}

demyx_motd() {
    echo "
        Demyx
        https://demyx.sh

        Welcome to Demyx! Please report any bugs you see.

        - Help: demyx help
        - Bugs: github.com/demyxco/demyx/issues
        - Chat: https://webchat.freenode.net/?channel=#demyx
        - Contact: info@demyx.sh
        " | sed 's/        //g'
    
    if [[ -n "$(demyx_upgrade_apps)" ]]; then
        demyx_execute -v echo -e '\e[31m==========[BREAKING CHANGES]==========\e[39m\n\nFor best security practice and performance, all demyx containers will now\nrun as the demyx user, including the WordPress containers. Each WordPress\nsites will now have a total of 3 containers: MariaDB, NGINX, and WordPress.\nCertain demyx commands will not work until you upgrade the sites.\n\nPlease run the following commands:\n'
        demyx_upgrade_apps
    else
        demyx info system
        echo
    fi
    demyx_motd_yml_check
    demyx_motd_getting_started
    demyx_motd_stack_check
    demyx_motd_dev_warning
    demyx_motd_update_check
}
