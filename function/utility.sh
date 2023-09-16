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
#
#   Generates htpasswd.
#
demyx_utility_htpasswd() {
    local DEMYX_UTILITY_HTPASSWD_USERNAME="${1:-}"
    local DEMYX_UTILITY_HTPASSWD_PASSWORD="${2:-}"
    local DEMYX_UTILITY_HTPASSWD=
    local DEMYX_UTILITY_HTPASSWD_CHECK=
    DEMYX_UTILITY_HTPASSWD_CHECK="$(which htpasswd 2>&1 || true)"

    if [[ "$DEMYX_UTILITY_HTPASSWD_CHECK" == *"not found"* || -z "$DEMYX_UTILITY_HTPASSWD_CHECK" ]]; then
        DEMYX_UTILITY_HTPASSWD="$(docker run -it --rm demyx/utilities bash -c "htpasswd -nb '$DEMYX_UTILITY_HTPASSWD_USERNAME' '$DEMYX_UTILITY_HTPASSWD_PASSWORD'" | sed 's|\r||g')"
    else
        DEMYX_UTILITY_HTPASSWD="$(htpasswd -nb "$DEMYX_UTILITY_HTPASSWD_USERNAME" "$DEMYX_UTILITY_HTPASSWD_PASSWORD")"
    fi

    if [[ -z "$DEMYX_UTILITY_HTPASSWD_USERNAME" || -z "$DEMYX_UTILITY_HTPASSWD_PASSWORD" ]]; then
        demyx_error custom "Missing username and/or password"
    fi

    if [[ "$DEMYX_UTILITY_FLAG_RAW" = true ]]; then
        echo "$DEMYX_UTILITY_HTPASSWD"
    else
        {
            echo "$DEMYX_UTILITY_HTPASSWD"
        } > "$DEMYX_UTILITY_TRANSIENT"

        demyx_execute false \
            "demyx_divider_title \"${DEMYX_UTILITY}\" \"Htpasswd\"; \
                cat < $DEMYX_UTILITY_TRANSIENT"
    fi
}
    else
        shift
        DEMYX_UTILITY_EXEC="$@"
        [[ -z "$DEMYX_UTILITY_EXEC" ]] && demyx_die 'demyx util needs a command'
        docker run -it --rm demyx/utilities sh -c "$DEMYX_UTILITY_EXEC"
    fi
}
