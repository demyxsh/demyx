# Demyx
# https://demyx.sh
# 
# demyx util <args>
#
demyx_utility() {
    while :; do
        case "$2" in
            --cred)
                DEMYX_UTILITY_CREDENTIALS=1
                ;;
            --htpasswd=?*)
                DEMYX_UTILITY_HTPASSWD=${2#*=}
                ;;
            --htpasswd=)
                demyx_die '"--htpasswd" cannot be empty.'
                ;;
            --kill)
                DEMYX_UTILITY_KILL=1
                ;;
            --pass)
                DEMYX_UTILITY_PASS=1
                ;;
            --raw)
                DEMYX_UTILITY_RAW=1
                ;;
            --user)
                DEMYX_UTILITY_USER=1
                ;;
            --user=?*)
                DEMYX_UTILITY_USER=${2#*=}
                ;;
            --user=)
                demyx_die '"--user" cannot be empty.'
                ;;
            --)
                shift
                break
                ;;
            -?*)
                printf '\e[31m[CRITICAL]\e[39m Unknown option: %s\n' "$2" >&2
                exit 1
                ;;
            *)
                break
        esac
        shift
    done

    if [[ -n "$DEMYX_UTILITY_CREDENTIALS" ]]; then
        DEMYX_UTILITY_USER=$(demyx util gpw 1 10 | sed -e 's/\r//g')
        DEMYX_UTILITY_PASS=$(demyx util pwgen -cns 50 1 | sed -e 's/\r//g')
        DEMYX_UTILITY_HTPASSWD_OUTPUT=$(demyx util htpasswd -nb $DEMYX_UTILITY_USER $DEMYX_UTILITY_PASS | sed -e 's/\r//g')
        PRINT_TABLE="DEMYX^ UTILITY\n"
        PRINT_TABLE+="USERNAME^ $DEMYX_UTILITY_USER\n"
        PRINT_TABLE+="PASSWORD^ $DEMYX_UTILITY_PASS\n"
        PRINT_TABLE+="HTPASSWD^ $DEMYX_UTILITY_HTPASSWD_OUTPUT"

        if [[ -n "$DEMYX_UTILITY_RAW" ]]; then
            demyx_execute -v echo $DEMYX_UTILITY_USER
            demyx_execute -v -q echo $DEMYX_UTILITY_PASS
            demyx_execute -v -q echo $DEMYX_UTILITY_HTPASSWD_OUTPUT
        else
            demyx_execute -v demyx_table "$PRINT_TABLE"
        fi
    elif [[ -n "$DEMYX_UTILITY_HTPASSWD" ]]; then
        [[ -z "$DEMYX_UTILITY_USER" ]] && demyx_die 'Missing --user'
        DEMYX_UTILITY_HTPASSWD_OUTPUT=$(demyx util htpasswd -nb $DEMYX_UTILITY_USER $DEMYX_UTILITY_HTPASSWD | sed -e 's/\r//g')
        PRINT_TABLE="DEMYX^ UTILITY\n"
        PRINT_TABLE+="HTPASSWD^ $DEMYX_UTILITY_HTPASSWD_OUTPUT"
        
        if [[ -n "$DEMYX_UTILITY_RAW" ]]; then
            demyx_execute -v -q echo $DEMYX_UTILITY_HTPASSWD_OUTPUT
        else
            demyx_execute -v demyx_table "$PRINT_TABLE"
        fi
    elif [[ -n "$DEMYX_UTILITY_PASS" ]]; then
        DEMYX_UTILITY_PASS=$(demyx util pwgen -cns 50 1 | sed -e 's/\r//g')
        PRINT_TABLE="DEMYX^ UTILITY\n"
        PRINT_TABLE+="PASSWORD^ $DEMYX_UTILITY_PASS"
    
        if [[ -n "$DEMYX_UTILITY_RAW" ]]; then
            demyx_execute -v -q echo $DEMYX_UTILITY_PASS
        else
            demyx_execute -v demyx_table "$PRINT_TABLE"
        fi
    elif [[ -n "$DEMYX_UTILITY_USER" ]]; then
        DEMYX_UTILITY_USER=$(demyx util gpw 1 10 | sed -e 's/\r//g')
        PRINT_TABLE="DEMYX^ UTILITY\n"
        PRINT_TABLE+="USERNAME^ $DEMYX_UTILITY_USER"
        
        if [[ -n "$DEMYX_UTILITY_RAW" ]]; then
            demyx_execute -v echo $DEMYX_UTILITY_USER
        else
            demyx_execute -v demyx_table "$PRINT_TABLE"
        fi
    elif [[ -n "$DEMYX_UTILITY_KILL" ]]; then
        DEMYX_UTILITIES_CHECK=$(docker ps | grep -s demyx/utilities | awk '{print $1}' | awk 'BEGIN { ORS = " " } { print }')
        for i in $DEMYX_UTILITIES_CHECK
        do
            demyx_echo "Killing demyx/utility $i"
            demyx_execute docker kill "$i"
        done
    else
        shift
        DEMYX_UTILITY_EXEC="$@"
        [[ -z "$DEMYX_UTILITY_EXEC" ]] && demyx_die 'demyx util needs a command'
        docker run -it --rm demyx/utilities "$DEMYX_UTILITY_EXEC"
    fi
}
