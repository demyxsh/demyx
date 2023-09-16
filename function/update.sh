# Demyx
# https://demyx.sh
#
#   demyx update <args>
#
demyx_update() {
    local DEMYX_UPDATE_FLAG=
    local DEMYX_UPDATE_FLAG_IMAGE=
    local DEMYX_UPDATE_FLAG_LIST=
    local DEMYX_UPDATE_FILE_LOCAL="$DEMYX"/.update_local
    local DEMYX_UPDATE_FILE_IMAGE="$DEMYX"/.update_image
    local DEMYX_UPDATE_FILE_REMOTE="$DEMYX"/.update_remote
    local DEMYX_UPDATE_IMAGES=
    DEMYX_UPDATE_IMAGES="$(demyx_images cat)"
    local DEMYX_UPDATE_TRANSIENT="$DEMYX_TMP"/demyx_transient

    while :; do
        DEMYX_UPDATE_FLAG="${1:-}"
        case "$DEMYX_UPDATE_FLAG" in
            -i)
                DEMYX_UPDATE_FLAG_IMAGE=true
            ;;
            -l)
                DEMYX_UPDATE_FLAG_LIST=true
            ;;
            --)
                shift
                break
                ;;
            -?*)
                demyx_error flag "$DEMYX_UPDATE_FLAG"
                ;;
            *)
                break
        esac
        shift
    done

    if [[ "$DEMYX_UPDATE_FLAG_LIST" = true ]]; then
        demyx_update_list
    else
        rm -f "$DEMYX"/.update*

        demyx_execute "Updating demyx image cache" \
            "demyx_images update"

        demyx_execute "Updating local cache" \
            "demyx_update_local"

        demyx_execute "Updating remote cache" \
            "demyx_update_remote"

        demyx_execute "Updating image cache" \
            "demyx_update_image"

        if [[ -z "$DEMYX_UPDATE_FLAG_IMAGE" ]]; then
            demyx_execute "Updating demyx helper on the host" \
                "docker run -t --rm \
                    -v /usr/local/bin:/tmp \
                    --user=root \
                    --entrypoint=bash \
                    demyx/demyx -c \"cp -f /etc/demyx/host.sh /tmp/demyx; chmod +x /tmp/demyx\""
        fi

        demyx_update_list
    fi
}
    fi
}
