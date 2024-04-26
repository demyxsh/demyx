# Demyx
# https://demyx.sh
# shellcheck shell=bash

#
#   demyx utility <type> <args>
#
demyx_utility() {
    demyx_event
    DEMYX_ARG_2="${1:-$DEMYX_ARG_2}"
    local DEMYX_UTILITY="DEMYX - UTILITY"
    local DEMYX_UTILITY_FLAG=
    local DEMYX_UTILITY_FLAG_RAW=
    local DEMYX_UTILITY_SHELL=
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
            demyx_utility_credentials
        ;;
        htpasswd) shift
            demyx_utility_htpasswd "$@"
        ;;
        id) shift
            demyx_utility_id "$@"
        ;;
        pass|password) shift
            demyx_utility_password "$@"
        ;;
        sh|shell) shift
            if [[ -z "$*" ]]; then
                DEMYX_UTILITY_SHELL=bash
            else
                DEMYX_UTILITY_SHELL="$*"
            fi

            docker run -it --rm demyx/utilities "$DEMYX_UTILITY_SHELL"
        ;;
        user|username)
            demyx_utility_username
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
    demyx_event
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

    demyx_divider_title "$DEMYX_UTILITY" "Credentials"
    cat < "$DEMYX_UTILITY_TRANSIENT"
}
#
#   Generates htpasswd.
#
demyx_utility_htpasswd() {
    demyx_event
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

        demyx_divider_title "$DEMYX_UTILITY" "Htpasswd"
        cat < "$DEMYX_UTILITY_TRANSIENT"
    fi
}
#
#   Generates ID.
#
demyx_utility_id() {
    demyx_event
    local DEMYX_UTILITY_ID="${1:-"5"}"
    local DEMYX_UTILITY_ID_PRINT=
    local DEMYX_UTILITY_IDGEN=

    DEMYX_UTILITY_IDGEN=()
    for i in {a..z} {A..Z} {0..9}; do
        DEMYX_UTILITY_IDGEN[RANDOM]=$i
    done
    DEMYX_UTILITY_ID_PRINT="$(printf %s "${DEMYX_UTILITY_IDGEN[@]::${DEMYX_UTILITY_ID}}" $'\n')"

    if [[ "$DEMYX_UTILITY_FLAG_RAW" = true ]]; then
        echo "$DEMYX_UTILITY_ID_PRINT"
    else
        {
            echo "$DEMYX_UTILITY_ID_PRINT"
        } > "$DEMYX_UTILITY_TRANSIENT"

        demyx_divider_title "$DEMYX_UTILITY" "ID"
            cat < "$DEMYX_UTILITY_TRANSIENT"
    fi
}
#
#   Generates password.
#
demyx_utility_password() {
    demyx_event
    local DEMYX_UTILITY_PASSWORD="${1:-"20"}"
    local DEMYX_UTILITY_PASSWORD_PRINT=
    local DEMYX_UTILITY_PWGEN=

    DEMYX_UTILITY_PWGEN=()
    for i in {a..z} {A..Z} {0..9}; do
        DEMYX_UTILITY_PWGEN[RANDOM]=$i
    done
    DEMYX_UTILITY_PASSWORD_PRINT="$(printf %s "${DEMYX_UTILITY_PWGEN[@]::${DEMYX_UTILITY_PASSWORD}}" $'\n')"

    if [[ "$DEMYX_UTILITY_FLAG_RAW" = true ]]; then
        echo "$DEMYX_UTILITY_PASSWORD_PRINT"
    else
        {
            echo "$DEMYX_UTILITY_PASSWORD_PRINT"
        } > "$DEMYX_UTILITY_TRANSIENT"

        demyx_divider_title "$DEMYX_UTILITY" "Password"
            cat < "$DEMYX_UTILITY_TRANSIENT"
    fi
}
#
#   Generates username.
#
demyx_utility_username() {
    demyx_event
    local DEMYX_UTILITY_USERNAME
    DEMYX_UTILITY_USERNAME="$(demyx_name)"

    if [[ "$DEMYX_UTILITY_FLAG_RAW" = true ]]; then
        echo "$DEMYX_UTILITY_USERNAME"
    else
        {
            echo "$DEMYX_UTILITY_USERNAME"
        } > "$DEMYX_UTILITY_TRANSIENT"

        demyx_divider_title "$DEMYX_UTILITY" "Username"
            cat < "$DEMYX_UTILITY_TRANSIENT"
    fi
}
