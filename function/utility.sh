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
#
#   Generates credentials.
#
demyx_utility_credentials() {
    local DEMYX_UTILITY_CREDENTIALS_USERNAME
    DEMYX_UTILITY_CREDENTIALS_USERNAME="$(demyx_utility username -r)"
    local DEMYX_UTILITY_CREDENTIALS_PASSWORD
    DEMYX_UTILITY_CREDENTIALS_PASSWORD="$(demyx_utility password -r)"
    local DEMYX_UTILITY_CREDENTIALS
    DEMYX_UTILITY_CREDENTIALS="$(demyx_utility htpasswd -r "$DEMYX_UTILITY_CREDENTIALS_USERNAME" "$DEMYX_UTILITY_CREDENTIALS_PASSWORD")"

    {
        echo "Username      $DEMYX_UTILITY_CREDENTIALS_USERNAME"
        echo "Password      $DEMYX_UTILITY_CREDENTIALS_PASSWORD"
        echo "Htpasswd      $DEMYX_UTILITY_CREDENTIALS"
    } > "$DEMYX_UTILITY_TRANSIENT"

    demyx_execute false \
        "demyx_divider_title \"${DEMYX_UTILITY}\" \"Credentials\"; \
            cat < $DEMYX_UTILITY_TRANSIENT"
}
    else
        shift
        DEMYX_UTILITY_EXEC="$@"
        [[ -z "$DEMYX_UTILITY_EXEC" ]] && demyx_die 'demyx util needs a command'
        docker run -it --rm demyx/utilities sh -c "$DEMYX_UTILITY_EXEC"
    fi
}
