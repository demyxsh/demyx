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
        docker pull demyx/demyx
        docker pull demyx/browsersync
        docker pull demyx/docker-compose
        docker pull demyx/logrotate
        docker pull demyx/mariadb
        docker pull demyx/nginx-rephp-wordpress
        docker pull demyx/ssh
        docker pull demyx/utilities
    fi
}
