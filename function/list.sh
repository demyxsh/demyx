# Demyx
# https://demyx.sh
# 
# demyx list <args>
#
function demyx_list() {
    while :; do
        case "$2" in
            --raw)
                DEMYX_LIST_RAW=1
                ;;
            --)
                shift
                break
                ;;
            -?*)
                printf '\e[31m[CRITICAL]\e[39m Unknown option: %s\n' "$2" >&2
                exit 1
                ;;
            *)
                break
        esac
        shift
    done

    cd "$DEMYX_WP" || exit

    if [[ -n "$DEMYX_LIST_RAW" ]]; then
        for i in *
        do
            echo $i
        done
    else
        DEMYX_LIST_WP_COUNT=$(find * -maxdepth 0 -type d | wc -l)
        PRINT_TABLE="DEMYX, WORDPRESS ($DEMYX_LIST_WP_COUNT)\n"
        for i in *
        do
            PRINT_TABLE+="^ $i\n"
        done
        demyx_execute -v demyx_table "$PRINT_TABLE"
    fi
}
