#!/bin/bash
# Demyx
# https://demyx.sh
# 
# demyx <args>
#
trap 'exit' ERR
DEMYX_COMMAND="$1"
DEMYX_TARGET="$2"
source "$DEMYX_FUNCTION"/global.sh
source "$DEMYX_FUNCTION"/help.sh

if [[ "$DEMYX_COMMAND" = backup ]]; then
    source "$DEMYX_FUNCTION"/backup.sh
    demyx_backup "$@"
elif [[ "$DEMYX_COMMAND" = compose ]]; then
    source "$DEMYX_FUNCTION"/compose.sh
    shift
    demyx_compose "$@"
elif [[ "$DEMYX_COMMAND" = config ]]; then
    source "$DEMYX_FUNCTION"/config.sh
    demyx_config "$@"
elif [[ "$DEMYX_COMMAND" = cp ]]; then
    source "$DEMYX_FUNCTION"/cp.sh
    shift
    demyx_cp "$@"
elif [[ "$DEMYX_COMMAND" = cron ]]; then
    source "$DEMYX_FUNCTION"/cron.sh
    shift
    demyx_cron "$@"
elif [[ "$DEMYX_COMMAND" = edit ]]; then
    source "$DEMYX_FUNCTION"/edit.sh
    demyx_edit "$@"
elif [[ "$DEMYX_COMMAND" = exec ]]; then
    source "$DEMYX_FUNCTION"/exec.sh
    shift 2
    demyx_exec "$@"
elif [[ "$DEMYX_COMMAND" = healthcheck ]]; then
    source "$DEMYX_FUNCTION"/healthcheck.sh
    demyx_healthcheck
elif [[ "$DEMYX_COMMAND" = help ]]; then
    demyx_help "$@"
elif [[ "$DEMYX_COMMAND" = info ]]; then
    source "$DEMYX_FUNCTION"/info.sh
    demyx_info "$@"
elif [[ "$DEMYX_COMMAND" = list ]]; then
    source "$DEMYX_FUNCTION"/list.sh
    demyx_list "$@"
elif [[ "$DEMYX_COMMAND" = log ]]; then
    source "$DEMYX_FUNCTION"/log.sh
    demyx_log "$@"
elif [[ "$DEMYX_COMMAND" = maldet ]]; then
    source "$DEMYX_FUNCTION"/maldet.sh
    demyx_maldet "$@"
elif [[ "$DEMYX_COMMAND" = monitor ]]; then
    source "$DEMYX_FUNCTION"/monitor.sh
    demyx_monitor "$@"
elif [[ "$DEMYX_COMMAND" = motd ]]; then
    source "$DEMYX_FUNCTION"/motd.sh
    shift
    demyx_motd "$@"
elif [[ "$DEMYX_COMMAND" = pull ]]; then
    source "$DEMYX_FUNCTION"/pull.sh
    shift
    demyx_pull "$@"
elif [[ "$DEMYX_COMMAND" = refresh ]]; then
    source "$DEMYX_FUNCTION"/refresh.sh
    demyx_refresh "$@"
elif [[ "$DEMYX_COMMAND" = restore ]]; then
    source "$DEMYX_FUNCTION"/restore.sh
    demyx_restore "$@"
elif [[ "$DEMYX_COMMAND" = rm ]]; then
    source "$DEMYX_FUNCTION"/rm.sh
    demyx_rm "$@"
elif [[ "$DEMYX_COMMAND" = run ]]; then
    source "$DEMYX_FUNCTION"/run.sh
    demyx_run "$@"
elif [[ "$DEMYX_COMMAND" = update ]]; then
    source "$DEMYX_FUNCTION"/update.sh
    demyx_update "$@"
elif [[ "$DEMYX_COMMAND" = util ]]; then
    source "$DEMYX_FUNCTION"/utility.sh
    demyx_utility "$@"
elif [[ "$DEMYX_COMMAND" = version ]]; then
    demyx_execute -v echo "$DEMYX_VERSION"
elif [[ "$DEMYX_COMMAND" = wp ]]; then
    source "$DEMYX_FUNCTION"/wp.sh
    shift 2
    demyx_wp "$@"
else
    demyx help
fi

demyx_permission
