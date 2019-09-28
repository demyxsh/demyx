# Demyx
# https://demyx.sh

demyx_motd_dev_warning() {
    DEMYX_COMMON_WP_NOT_EMPTY=$(ls "$DEMYX_WP")
    if [[ -n "$DEMYX_COMMON_WP_NOT_EMPTY" ]]; then
        cd "$DEMYX_WP"
        for i in *
        do
            DEMYX_COMMON_DEV_CHECK=$(grep DEMYX_APP_DEV "$DEMYX_WP"/"$i"/.env | awk -F '[=]' '{print $2}')
            if [[ "$DEMYX_COMMON_DEV_CHECK" = on ]]; then
                demyx_execute -v echo -e "\e[33m[WARNING]\e[39m $i is in development mode"
            fi
        done
    fi
}
demyx_motd_stack_upgrade_notice() {
    if [[ "$DEMYX_CHECK_TRAEFIK" = 1 ]]; then
        demyx_execute -v echo -e "\e[34m[INFO]\e[39m An upgrade is available for the stack, please run: demyx stack --upgrade"
    fi
}
demyx_motd() {
    if [[ "$1" = init ]]; then
        [[ -z "$DEMYX_MODE" ]] && DEMYX_MODE=production
        DEMYX_MOTD_MODE=$(echo "$DEMYX_MODE" | tr [a-z] [A-Z] | sed -e 's/\r//g')
        DEMYX_HOST_UPPERCASE=$(hostname | tr [a-z] [A-Z])
        [[ -z "$DEMYX_SSH" ]] && DEMYX_SSH=2222
        [[ -z "$DEMYX_STATUS" ]] && DEMYX_STATUS=0

        cat > /demyx/.env <<-EOF
            # AUTO GENERATED
            DEMYX_MOTD_MODE=$DEMYX_MOTD_MODE
            DEMYX_MOTD_HOST=$DEMYX_HOST_UPPERCASE
            DEMYX_MOTD_USER=DEMYX
            DEMYX_MOTD_SSH=$DEMYX_SSH
            DEMYX_MOTD_STATUS=$DEMYX_STATUS
EOF
        sed -i 's/            //g' /demyx/.env
    else
        source /demyx/.env
        
        if (( "$DEMYX_MOTD_STATUS" > 1 )); then
            DEMYX_MOTD_STATUS="$(echo -e "\e[32m$DEMYX_MOTD_STATUS UPDATES\e[39m")"
        elif [[ "$DEMYX_MOTD_STATUS" = 1 ]]; then
            DEMYX_MOTD_STATUS="$(echo -e "\e[32m1 UPDATE\e[39m")"
        else
            DEMYX_MOTD_STATUS=UPDATED
        fi

        echo "
            Demyx
            https://demyx.sh

            Welcome to Demyx! Please report any bugs you see.

            - Help: demyx help
            - Bugs: github.com/demyxco/demyx/issues
            - Contact: info@demyx.sh

            =========================
             DEMYX  | $DEMYX_MOTD_MODE
             HOST   | $DEMYX_MOTD_HOST
             SSH    | $DEMYX_MOTD_SSH
             STATUS | $DEMYX_MOTD_STATUS
            =========================" | sed 's/            //g'

        cd "$DEMYX_ETC" || exit

        DEMYX_MOTD_GIT_LOG="$(git --no-pager log -5 --format=format:'- %s %C(white dim)(%ar)%C(reset)')"
        demyx_execute -v echo -e "\nLatest Updates\n--------------\n$DEMYX_MOTD_GIT_LOG\n"
        demyx_motd_stack_upgrade_notice
        demyx_motd_dev_warning
    fi
}
