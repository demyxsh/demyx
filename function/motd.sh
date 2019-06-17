# Demyx
# https://demyx.sh

function demyx_motd() {
    if [[ "$1" = init ]]; then
        [[ -z "$DEMYX_MODE" ]] && DEMYX_MODE=production
        DEMYX_MOTD_MODE=$(echo "$DEMYX_MODE" | tr [a-z] [A-Z] | sed -e 's/\r//g')
        DEMYX_HOST_UPPERCASE=$(hostname | tr [a-z] [A-Z])
        [[ -z "$DEMYX_SSH" ]] && DEMYX_SSH=2222
        [[ -z "$DEMYX_ET" ]] && DEMYX_ET=2022
        [[ -z "$DEMYX_STATUS" ]] && DEMYX_STATUS=0

        cat > /demyx/.env <<-EOF
            # AUTO GENERATED
            DEMYX_MOTD_MODE=$DEMYX_MOTD_MODE
            DEMYX_MOTD_HOST=$DEMYX_HOST_UPPERCASE
            DEMYX_MOTD_USER=DEMYX
            DEMYX_MOTD_SSH=$DEMYX_SSH
            DEMYX_MOTD_ET=$DEMYX_ET
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
        " | sed 's/            //g'

        cd "$DEMYX_ETC" || exit

        PRINT_TABLE="DEMYX^ HOST^ USER^ SSH/ETSERVER^ STATUS\n"
        PRINT_TABLE+="$DEMYX_MOTD_MODE^ $DEMYX_MOTD_HOST^ DEMYX^ $DEMYX_MOTD_SSH/$DEMYX_MOTD_ET^ $DEMYX_MOTD_STATUS"
        demyx_execute -v demyx_table "$PRINT_TABLE"
        demyx_execute -v echo -e "\nLatest Updates\n--------------"
        demyx_execute -v git --no-pager log -5 --format=format:'%C(white dim)(%ar)%C(reset) %C(white)%s%C(reset)%C(reset)'
        demyx_execute -v echo -e "\n"
    fi
}
