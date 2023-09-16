# Demyx
# https://demyx.sh
#
#   demyx util <type> <args>
#
demyx_utility() {
    DEMYX_ARG_2="${1:-$DEMYX_ARG_2}"
    local DEMYX_UTILITY="DEMYX - UTILITY"
    local DEMYX_UTILITY_FLAG=
    local DEMYX_UTILITY_FLAG_RAW=
    local DEMYX_UTILITY_TRANSIENT="$DEMYX_TMP"/demyx_transient

    demyx_source name

    while :; do
        DEMYX_UTILITY_FLAG="${2:-}"
        [[ -z "$DEMYX_ARG_2" ]] && break
        case "$DEMYX_UTILITY_FLAG" in
            -r)
                DEMYX_UTILITY_FLAG_RAW=true
            ;;
            --)
                shift
                break
            ;;
            -?*)
                demyx_error flag "$DEMYX_UTILITY_FLAG"
            ;;
            *)
                break
        esac
        shift
    done

    case "$DEMYX_ARG_2" in
        cred|credentials)
            demyx_execute false \
                "demyx_utility_credentials"
        ;;
        htpasswd) shift
            demyx_execute false \
                "demyx_utility_htpasswd $*"
        ;;
        id) shift
            demyx_execute false \
                "demyx_utility_id $*"
        ;;
        pass|password) shift
            demyx_execute false \
                "demyx_utility_password $*"
        ;;
        sh|shell) shift
            demyx_execute false \
                "docker run -it --rm demyx/utilities $*"
        ;;
        user|username)
            demyx_execute false \
                "demyx_utility_username"
        ;;
        *)
            demyx_help utility
        ;;
    esac
}

        if [[ -n "$DEMYX_UTILITY_RAW" ]]; then
            demyx_execute -v echo "$DEMYX_UTILITY_USER"
            demyx_execute -v -q echo "$DEMYX_UTILITY_PASS"
            demyx_execute -v -q echo "$DEMYX_UTILITY_HTPASSWD_OUTPUT"
        else
            demyx_execute -v demyx_table "$PRINT_TABLE"
        fi
    elif [[ -n "$DEMYX_UTILITY_HTPASSWD" ]]; then
        [[ -z "$DEMYX_UTILITY_USER" ]] && demyx_die 'Missing --user'
        DEMYX_UTILITY_HTPASSWD_OUTPUT="$(demyx util htpasswd -nb "$DEMYX_UTILITY_USER $DEMYX_UTILITY_HTPASSWD" | sed -e 's/\r//g')"
        PRINT_TABLE="DEMYX^ UTILITY\n"
        PRINT_TABLE+="HTPASSWD^ $DEMYX_UTILITY_HTPASSWD_OUTPUT"
        
        if [[ -n "$DEMYX_UTILITY_RAW" ]]; then
            demyx_execute -v -q echo "$DEMYX_UTILITY_HTPASSWD_OUTPUT"
        else
            demyx_execute -v demyx_table "$PRINT_TABLE"
        fi
    elif [[ -n "$DEMYX_UTILITY_ID" ]]; then
        DEMYX_UTILITY_ID="$(uuidgen | head -c 8 | sed -e 's/\r//g')"
        PRINT_TABLE="DEMYX^ UTILITY\n"
        PRINT_TABLE+="ID^ $DEMYX_UTILITY_ID"
        
        if [[ -n "$DEMYX_UTILITY_RAW" ]]; then
            demyx_execute -v -q echo "$DEMYX_UTILITY_ID"
        else
            demyx_execute -v demyx_table "$PRINT_TABLE"
        fi
    elif [[ -n "$DEMYX_UTILITY_PASS" ]]; then
        DEMYX_UTILITY_PASS="$(demyx_generate_password)"
        PRINT_TABLE="DEMYX^ UTILITY\n"
        PRINT_TABLE+="PASSWORD^ $DEMYX_UTILITY_PASS"
    
        if [[ -n "$DEMYX_UTILITY_RAW" ]]; then
            demyx_execute -v -q echo "$DEMYX_UTILITY_PASS"
        else
            demyx_execute -v demyx_table "$PRINT_TABLE"
        fi
    elif [[ -n "$DEMYX_UTILITY_USER" ]]; then
        demyx_source name
        DEMYX_UTILITY_USER="$(demyx_name)"
        PRINT_TABLE="DEMYX^ UTILITY\n"
        PRINT_TABLE+="USERNAME^ $DEMYX_UTILITY_USER"
        
        if [[ -n "$DEMYX_UTILITY_RAW" ]]; then
            demyx_execute -v echo "$DEMYX_UTILITY_USER"
        else
            demyx_execute -v demyx_table "$PRINT_TABLE"
        fi
    elif [[ -n "$DEMYX_UTILITY_KILL" ]]; then
        DEMYX_UTILITIES_CHECK="$(echo "$DEMYX_DOCKER_PS" | grep -s demyx/utilities | awk '{print $1}' | awk 'BEGIN { ORS = " " } { print }')"
        for i in "$DEMYX_UTILITIES_CHECK"
        do
            demyx_echo "Killing demyx/utility $i"
            demyx_execute docker kill "$i"
        done
    else
        shift
        DEMYX_UTILITY_EXEC="$@"
        [[ -z "$DEMYX_UTILITY_EXEC" ]] && demyx_die 'demyx util needs a command'
        docker run -it --rm demyx/utilities sh -c "$DEMYX_UTILITY_EXEC"
    fi
}
