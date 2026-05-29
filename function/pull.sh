# Demyx
# https://demyx.sh
# shellcheck shell=bash

#
#   demyx pull <args>
#
demyx_pull() {
    demyx_event
    DEMYX_ARG_2="${1:-$DEMYX_ARG_2}"

    case "$DEMYX_ARG_2" in
        all)
            demyx_pull_all
        ;;
        *)
            if [[ -n "$DEMYX_ARG_2" ]]; then
                demyx_pull_image
            else
                demyx_help pull
            fi
        ;;
    esac
}
#
#   Smart pull all demyx images.
#
demyx_pull_all() {
    demyx_event
    local DEMYX_PULL_ALL="
        demyx/browsersync:${DEMYX_VERSION}
        demyx/code-server:${DEMYX_VERSION}-bedrock
        demyx/code-server:${DEMYX_VERSION}-browse
        demyx/code-server:${DEMYX_VERSION}-openlitespeed
        demyx/code-server:${DEMYX_VERSION}-openlitespeed-bedrock
        demyx/code-server:${DEMYX_VERSION}-wp
        demyx/demyx:${DEMYX_VERSION}
        demyx/docker-socket-proxy:${DEMYX_VERSION}
        demyx/mariadb:${DEMYX_VERSION}
        demyx/nginx:${DEMYX_VERSION}
        demyx/openlitespeed:${DEMYX_VERSION}
        demyx/openlitespeed:${DEMYX_VERSION}-bedrock
        demyx/ssh:${DEMYX_VERSION}
        demyx/traefik:${DEMYX_VERSION}
        demyx/utilities:${DEMYX_VERSION}
        demyx/wordpress:${DEMYX_VERSION}
        demyx/wordpress:${DEMYX_VERSION}-bedrock
        docker:cli
        phpmyadmin/phpmyadmin
        quay.io/vektorlab/ctop
        redis:alpine3.22
    "
    local DEMYX_PULL_ALL_CHECK=
    local DEMYX_PULL_ALL_I=
    local DEMYX_PULL_ALL_PATH=
    DEMYX_PULL_ALL_PATH="$(demyx_images path)"

    for DEMYX_PULL_ALL_I in $DEMYX_PULL_ALL; do
        DEMYX_PULL_ALL_CHECK="$(grep "$DEMYX_PULL_ALL_I" "$DEMYX_PULL_ALL_PATH" || true)"

        if [[ -n "${DEMYX_PULL_ALL_CHECK}" ]]; then
            docker pull "${DEMYX_PULL_ALL_I}"
        fi
    done
}
#
#   Pull specific demyx images.
#
demyx_pull_image() {
    demyx_event
    local DEMYX_PULL_IMAGE=demyx/"$DEMYX_ARG_2"
    local DEMYX_PULL_IMAGE_VARIANT=

    if [[ "$DEMYX_ARG_2" = ctop ]]; then
        DEMYX_PULL_IMAGE="quay.io/vektorlab/ctop"
    elif [[ "$DEMYX_ARG_2" == code-server:* ]]; then
        DEMYX_PULL_IMAGE_VARIANT="${DEMYX_ARG_2#code-server:}"
        DEMYX_PULL_IMAGE=demyx/code-server:"${DEMYX_VERSION}-${DEMYX_PULL_IMAGE_VARIANT}"
    elif [[ "$DEMYX_ARG_2" == openlitespeed:* ]]; then
        DEMYX_PULL_IMAGE_VARIANT="${DEMYX_ARG_2#openlitespeed:}"
        DEMYX_PULL_IMAGE=demyx/openlitespeed:"${DEMYX_VERSION}-${DEMYX_PULL_IMAGE_VARIANT}"
    elif [[ "$DEMYX_ARG_2" == wordpress:* ]]; then
        DEMYX_PULL_IMAGE_VARIANT="${DEMYX_ARG_2#wordpress:}"
        DEMYX_PULL_IMAGE=demyx/wordpress:"${DEMYX_VERSION}-${DEMYX_PULL_IMAGE_VARIANT}"
    elif [[ "$DEMYX_ARG_2" = browsersync ||
            "$DEMYX_ARG_2" = demyx ||
            "$DEMYX_ARG_2" = docker-socket-proxy ||
            "$DEMYX_ARG_2" = mariadb ||
            "$DEMYX_ARG_2" = nginx ||
            "$DEMYX_ARG_2" = openlitespeed ||
            "$DEMYX_ARG_2" = ssh ||
            "$DEMYX_ARG_2" = traefik ||
            "$DEMYX_ARG_2" = utilities ||
            "$DEMYX_ARG_2" = wordpress ]]; then
        DEMYX_PULL_IMAGE=demyx/"$DEMYX_ARG_2":"${DEMYX_VERSION}"
    elif [[   "$DEMYX_ARG_2" = pma ||
            "$DEMYX_ARG_2" = phpmyadmin ]]; then
        DEMYX_PULL_IMAGE=phpmyadmin/phpmyadmin
    elif [[   "$DEMYX_ARG_2" = redis ]]; then
        DEMYX_PULL_IMAGE=redis:alpine3.22
    fi

    docker pull "${DEMYX_PULL_IMAGE}"
}
