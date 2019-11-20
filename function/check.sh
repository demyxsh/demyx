# Demyx
# https://demyx.sh

DEMYX_CHECK_SUDO="$(id -u)"

if [ "$DEMYX_CHECK_SUDO" != 0 ]; then
    echo -e "\e[31m[CRITICAL]\e[39m Demyx must be ran as sudo"
    exit 1
fi

if [[ ! -d "$DEMYX"/custom/cron ]]; then
    demyx_execute -v cp -r "$DEMYX_ETC"/example/example-cron "$DEMYX"/custom
fi
