#!/bin/bash
# Demyx
# https://demyx.sh
# TEMPORARY CODE

# Begin migration
DEMYX_MIGRATE_CONFIG=/tmp/.demyx
[[ -f "$DEMYX_APP"/stack/.env ]] && DEMYX_MIGRATE_STACK_ENV="$DEMYX_APP"/stack/.env
[[ -f "$DEMYX_BACKUP"/stack/.env ]] && DEMYX_MIGRATE_STACK_ENV="$DEMYX_BACKUP"/stack/.env

if [[ -f "$DEMYX_APP"/stack/.env ]]; then
    # Replace necessary configs
    sed -i "s|DEMYX_HOST_CPU=.*|DEMYX_HOST_CPU=$(grep -w DEMYX_STACK_CPU "$DEMYX_MIGRATE_STACK_ENV" | awk -F '[=]' '{print $2}')|g" "$DEMYX_MIGRATE_CONFIG"
    sed -i "s|DEMYX_HOST_DOMAIN=.*|DEMYX_HOST_DOMAIN=$(grep -w DEMYX_STACK_DOMAIN "$DEMYX_MIGRATE_STACK_ENV" | awk -F '[=]' '{print $2}')|g" "$DEMYX_MIGRATE_CONFIG"
    sed -i "s|DEMYX_HOST_EMAIL=.*|DEMYX_HOST_EMAIL=$(grep -w DEMYX_STACK_ACME_EMAIL "$DEMYX_MIGRATE_STACK_ENV" | awk -F '[=]' '{print $2}')|g" "$DEMYX_MIGRATE_CONFIG"
    sed -i "s|DEMYX_HOST_BACKUP=.*|DEMYX_HOST_BACKUP=$(grep -w DEMYX_STACK_BACKUP "$DEMYX_MIGRATE_STACK_ENV" | awk -F '[=]' '{print $2}')|g" "$DEMYX_MIGRATE_CONFIG"
    sed -i "s|DEMYX_HOST_BACKUP_LIMIT=.*|DEMYX_HOST_BACKUP_LIMIT=$(grep -w DEMYX_STACK_BACKUP_LIMIT "$DEMYX_MIGRATE_STACK_ENV" | awk -F '[=]' '{print $2}')|g" "$DEMYX_MIGRATE_CONFIG"
    sed -i "s|DEMYX_HOST_HEALTHCHECK=.*|DEMYX_HOST_HEALTHCHECK=$(grep -w DEMYX_STACK_HEALTHCHECK "$DEMYX_MIGRATE_STACK_ENV" | awk -F '[=]' '{print $2}')|g" "$DEMYX_MIGRATE_CONFIG"
    sed -i "s|DEMYX_HOST_HEALTHCHECK_TIMEOUT=.*|DEMYX_HOST_HEALTHCHECK_TIMEOUT=$(grep -w DEMYX_STACK_HEALTHCHECK_TIMEOUT "$DEMYX_MIGRATE_STACK_ENV" | awk -F '[=]' '{print $2}')|g" "$DEMYX_MIGRATE_CONFIG"
    sed -i "s|DEMYX_HOST_MEM=.*|DEMYX_HOST_MEM=$(grep -w DEMYX_STACK_MEM "$DEMYX_MIGRATE_STACK_ENV" | awk -F '[=]' '{print $2}')|g" "$DEMYX_MIGRATE_CONFIG"
    sed -i "s|DEMYX_HOST_MONITOR=.*|DEMYX_HOST_MONITOR=$(grep -w DEMYX_STACK_MONITOR "$DEMYX_MIGRATE_STACK_ENV" | awk -F '[=]' '{print $2}')|g" "$DEMYX_MIGRATE_CONFIG"
    sed -i "s|DEMYX_HOST_TELEMETRY=.*|DEMYX_HOST_TELEMETRY=$(grep -w DEMYX_STACK_TELEMETRY "$DEMYX_MIGRATE_STACK_ENV" | awk -F '[=]' '{print $2}')|g" "$DEMYX_MIGRATE_CONFIG"
    
    # Move old stack directory to backup
    mv "$DEMYX_APP"/stack "$DEMYX_BACKUP"
fi
