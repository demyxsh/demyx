# Demyx
# https://demyx.sh
# 
# demyx pull <image>
#
demyx_pull() {
    DEMYX_PULL_IMAGE="$1"

    if [[ -n "$DEMYX_PULL_IMAGE" ]]; then
        docker pull demyx/"$DEMYX_PULL_IMAGE"
        [[ "$?" = 1 ]] && demyx help pull
    else
        # Only auto pull images that aren't always up
        docker pull demyx/docker-compose
        docker pull demyx/logrotate
        docker pull demyx/ssh
        docker pull demyx/utilities
    fi
}
