# Demyx
# https://demyx.sh
#
# Not sure what else to put here, will leave it for review.
#

if [[ ! -d "$DEMYX"/custom/cron ]]; then
    demyx_execute -v cp -r "$DEMYX_ETC"/example/example-cron "$DEMYX"/custom
fi
