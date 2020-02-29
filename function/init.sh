# Demyx
# https://demyx.sh
#
# Not sure what else to put here, will leave it for review.
#

if [[ ! -d "$DEMYX"/custom/cron ]]; then
    demyx_execute -v cp -r "$DEMYX_ETC"/example/example-cron "$DEMYX"/custom
fi

# Will remove this March 31, 2020
if [[ -n "$(echo "$DEMYX_DOCKER_PS" | grep demyx_ouroboros || true)" ]]; then
    docker stop demyx_ouroboros
    docker rm demyx_ouroboros
fi
