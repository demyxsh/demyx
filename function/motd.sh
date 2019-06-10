# Demyx
# https://demyx.sh

function demyx_motd() {
    if [[ "$1" = init ]]; then
        DEMYX_MOTD_MODE="$DEMYX_MODE"
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
        sed -i 's/            //' /demyx/.env
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

            Welcome to Demyx! To see all demyx commands, run: demyx help
        " | sed 's/            //'

        PRINT_TABLE="DEMYX, $(echo $DEMYX_MOTD_MODE | tr [a-z] [A-Z])\n"
        PRINT_TABLE+="HOST, $DEMYX_MOTD_HOST\n"
        PRINT_TABLE+="USER, DEMYX\n"
        PRINT_TABLE+="SSH/SFTP, $DEMYX_MOTD_SSH\n"
        PRINT_TABLE+="ETSERVER, $DEMYX_MOTD_ET\n"
        PRINT_TABLE+="STATUS, $DEMYX_MOTD_STATUS"
        demyx_execute -v demyx_table "$PRINT_TABLE"
        echo
    fi
}
