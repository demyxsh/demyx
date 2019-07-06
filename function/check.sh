# Demyx
# https://demyx.sh

DEMYX_SUDO_CHECK=$(id -u)

if [ "$DEMYX_SUDO_CHECK" != 0 ]; then
    echo -e "\e[31m[CRITICAL]\e[39m Demyx must be ran as sudo"
    exit 1
fi

if [[ ! -d "$DEMYX"/custom/example-cron ]]; then
    cp -r "$DEMYX_ETC"/example/example-cron "$DEMYX"/custom
fi
