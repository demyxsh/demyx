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

            Welcome to Demyx! To see all demyx commands, run: demyx help
        " | sed 's/            //g'

        cd "$DEMYX_ETC" || exit

        DEMYX_MOTD_NEWS_FETCH=$(git --no-pager log -5 --pretty=oneline --pretty=format:"%s")
        DEMYX_MOTD_NEWS_LATEST_COMMIT="LATEST COMMIT $(git --no-pager log --pretty=oneline -1 --pretty=format:"%h %ar" | tr [a-z] [A-Z] | sed -e 's/\r//g')"
        readarray -t DEMYX_MOTD_NEWS <<< "$DEMYX_MOTD_NEWS_FETCH"

        PRINT_TABLE="DEMYX, $DEMYX_MOTD_MODE, $DEMYX_MOTD_NEWS_LATEST_COMMIT\n"
        PRINT_TABLE+="HOST, $DEMYX_MOTD_HOST, ${DEMYX_MOTD_NEWS[0]}\n"
        PRINT_TABLE+="USER, DEMYX, ${DEMYX_MOTD_NEWS[1]}\n"
        PRINT_TABLE+="SSH/SFTP, $DEMYX_MOTD_SSH, ${DEMYX_MOTD_NEWS[2]}\n"
        PRINT_TABLE+="ETSERVER, $DEMYX_MOTD_ET, ${DEMYX_MOTD_NEWS[3]}\n"
        PRINT_TABLE+="STATUS, $DEMYX_MOTD_STATUS, ${DEMYX_MOTD_NEWS[4]}"
        demyx_execute -v demyx_table "$PRINT_TABLE"
        echo
    fi
}
