# Demyx
# https://demyx.sh
# 
# demyx ctop
#
demyx_ctop() {
    DEMYX_CTOP_CHECK=$(docker ps | grep quay.io/vektorlab/ctop || true)
    if [[ -n "$DEMYX_CTOP_CHECK" ]]; then
        docker exec -it demyx_ctop /ctop
    else
        docker run -it --rm --name demyx_ctop -v /var/run/docker.sock:/var/run/docker.sock:ro quay.io/vektorlab/ctop
    fi
}
