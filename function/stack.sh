# Demyx
# https://demyx.sh
# 
# demyx stack <args>
#
demyx_stack() {
    while :; do
        case "$2" in
            api)
                DEMYX_STACK_SELECT=api
                ;;
            ouroboros)
                DEMYX_STACK_SELECT=ouroboros
                ;;
            refresh)
                DEMYX_STACK_SELECT=refresh
                ;;
            upgrade)
                DEMYX_STACK_SELECT=upgrade
                ;;
            --auto-update|--auto-update=true)
                DEMYX_STACK_AUTO_UPDATE=true
                ;;
            --auto-update=false)
                DEMYX_STACK_AUTO_UPDATE=false
                ;;
            --backup|--backup=true)
                DEMYX_STACK_BACKUP=true
                ;;
            --backup=false)
                DEMYX_STACK_BACKUP=false
                ;;
            --backup-limit=?*)
                DEMYX_STACK_BACKUP_LIMIT="${2#*=}"
                ;;
            --backup-limit=)
                demyx_die '"--backup-limit" cannot be empty'
                ;;
            --cloudflare|--cloudflare=true)
                DEMYX_STACK_CLOUDFLARE=true
                ;;
            --cloudflare=false)
                DEMYX_STACK_CLOUDFLARE=false
                ;;
            --cf-api-email=?*)
                DEMYX_STACK_CLOUDFLARE_API_EMAIL="${2#*=}"
                ;;
            --cf-api-email=)
                demyx_die '"--cf-api-email" cannot be empty'
                ;;
            --cf-api-key=?*)
                DEMYX_STACK_CLOUDFLARE_API_KEY="${2#*=}"
                ;;
            --cf-api-key=)
                demyx_die '"--cf-api-key" cannot be empty'
                ;;
            --cpu=null|--cpu=?*)
                DEMYX_STACK_CPU="${2#*=}"
                DEMYX_STACK_RESOURCE=1
                ;;
            --cpu=)
                demyx_die '"--cpu" cannot be empty'
                ;;
            --false)
                DEMYX_STACK_FALSE=1
                ;;
            --healthcheck|--healthcheck=true)
                DEMYX_STACK_HEALTHCHECK=true
                ;;
            --healthcheck=false)
                DEMYX_STACK_HEALTHCHECK=false
                ;;
            --healthcheck-timeout=?*)
                DEMYX_STACK_HEALTHCHECK_TIMEOUT="${2#*=}"
                ;;
            --healthcheck-timeout=)
                demyx_die '"--healthcheck-timeout" cannot be empty'
                ;;
            --ignore=?*)
                DEMYX_STACK_IGNORE="${2#*=}"
                ;;
            --ignore=)
                demyx_die '"--ignore" cannot be empty'
                ;;
            --mem=null|--mem=?*)
                DEMYX_STACK_MEM="${2#*=}"
                DEMYX_STACK_RESOURCE=1
                ;;
            --mem=)
                demyx_die '"--mem" cannot be empty'
                ;;
            --monitor|--monitor=true)
                DEMYX_STACK_MONITOR=true
                ;;
            --monitor=false)
                DEMYX_STACK_MONITOR=false
                ;;
            --revert)
                DEMYX_STACK_REVERT=1
                ;;
            --telemetry|--telemetry=true)
                DEMYX_STACK_TELEMETRY=true
                ;;
            --telemetry=false)
                DEMYX_STACK_TELEMETRY=false
                ;;
            --true)
                DEMYX_STACK_TRUE=1
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

    if [[ "$DEMYX_STACK_SELECT" = api ]]; then
        if [[ -n "$DEMYX_STACK_FALSE" ]]; then
            demyx_echo 'Disabling api'
            demyx_execute sed -i "s|DEMYX_STACK_API=.*|DEMYX_STACK_API=false|g" "$DEMYX_STACK"/.env
            demyx stack refresh
        elif [[ -n "$DEMYX_STACK_TRUE" ]]; then
            demyx_echo 'Enabling api'
            demyx_execute sed -i "s|DEMYX_STACK_API=.*|DEMYX_STACK_API=true|g" "$DEMYX_STACK"/.env
            demyx stack refresh
        fi
    elif [[ "$DEMYX_STACK_SELECT" = ouroboros ]]; then
        if [[ -n "$DEMYX_STACK_IGNORE" ]]; then
            DEMYX_STACK_OUROBOROS_IGNORE_CHECK="$(demyx info stack --filter=DEMYX_STACK_OUROBOROS_IGNORE)"
            
            if [[ "$DEMYX_STACK_IGNORE" = false ]]; then
                demyx_echo 'Updating Ouroboros'
                demyx_execute sed -i "s|DEMYX_STACK_OUROBOROS_IGNORE=.*|DEMYX_STACK_OUROBOROS_IGNORE=demyx_socket|g" "$DEMYX_STACK"/.env
            else
                demyx_echo 'Updating Ouroboros'
                demyx_execute sed -i "s|DEMYX_STACK_OUROBOROS_IGNORE=.*|DEMYX_STACK_OUROBOROS_IGNORE=\"demyx_socket $DEMYX_STACK_IGNORE\"|g" "$DEMYX_STACK"/.env
            fi

            demyx compose stack up -d
        elif [[ -n "$DEMYX_STACK_FALSE" ]]; then
            demyx_echo 'Disabling Ouroboros'
            demyx_execute sed -i "s|DEMYX_STACK_OUROBOROS=.*|DEMYX_STACK_OUROBOROS=false|g" "$DEMYX_STACK"/.env
            demyx stack refresh
        elif [[ -n "$DEMYX_STACK_TRUE" ]]; then
            demyx_echo 'Enabling Ouroboros'
            demyx_execute sed -i "s|DEMYX_STACK_OUROBOROS=.*|DEMYX_STACK_OUROBOROS=true|g" "$DEMYX_STACK"/.env
            demyx stack refresh
        fi
    elif [[ "$DEMYX_STACK_SELECT" = refresh ]]; then
        if [[ -d "$DEMYX_STACK" ]]; then
            demyx_echo 'Backing up stack directory as /demyx/backup/stack.tgz'
            demyx_execute tar -czf /demyx/backup/stack.tgz -C /demyx/app stack
        fi

        demyx_source env
        demyx_source yml

        demyx_echo 'Refreshing stack env and yml'
        demyx_execute demyx_stack_env; demyx_stack_yml

        # Will remove this in January 1st, 2020
        demyx_echo 'Setting proper permission for acme.json'
        demyx_execute docker run --user=root -it --rm -v demyx_traefik:/demyx demyx/utilities sh -c "chmod 600 /demyx/acme.json; chown -R demyx:demyx /demyx"

        demyx compose stack up -d --remove-orphans
    elif [[ "$DEMYX_STACK_SELECT" = upgrade ]]; then
        if [[ "$DEMYX_CHECK_TRAEFIK" = 1 ]]; then
            echo -en "\e[33m"
            read -rep "[WARNING] Upgrading the stack will stop all network activity. Update all configs? [yY]: " DEMYX_STACK_UPGRADE_CONFIRM
            echo -en "\e[39m"
            
            [[ "$DEMYX_STACK_UPGRADE_CONFIRM" != [yY] ]] && demyx_die 'Cancel upgrading'
            
            demyx_echo 'Starting stack upgrade container'
            demyx_execute docker run -dit --rm --name demyx_upgrade demyx/utilities sh

            demyx_echo 'Downloading and extracting Traefik Migration Tool'
            demyx_execute curl -sL https://github.com/containous/traefik-migration-tool/releases/download/v0.8.0/traefik-migration-tool_v0.8.0_linux_amd64.tar.gz -o /tmp/traefik-migration-tool_v0.8.0_linux_amd64.tar.gz; \
                tar -xzf /tmp/traefik-migration-tool_v0.8.0_linux_amd64.tar.gz -C /tmp

            demyx_echo 'Upgrading acme.json'
            demyx_execute docker cp demyx_traefik:/demyx/acme.json /tmp; \
                docker cp /tmp/traefik-migration-tool demyx_upgrade:/; \
                docker cp /tmp/acme.json demyx_upgrade:/; \
                docker exec -t demyx_upgrade sh -c "/traefik-migration-tool acme --input=/acme.json --output=/acme.json --resolver=demyx"; \
                docker cp demyx_upgrade:/acme.json /tmp; \
                docker cp /tmp/acme.json demyx_traefik:/demyx

            demyx_echo 'Stopping stack upgrade container'
            demyx_execute docker stop demyx_upgrade

            demyx_echo 'Updating Traefik'
            demyx_execute sed -i "s|traefik:v1.7.16|traefik|g" "$DEMYX_STACK"/docker-compose.yml; \
                docker pull traefik:latest

            demyx stack refresh
            demyx config all --refresh

            demyx_execute -v echo -e "\e[32m[SUCCESS]\e[39m Upgrade has finished, you will need to update the docker-compose labels for non Demyx apps."
        else
            demyx_die 'The stack is already updated.'
        fi
    else
        if [[ "$DEMYX_STACK_AUTO_UPDATE" = true ]]; then
            demyx_echo 'Turn on stack auto update'
            demyx_execute sed -i 's/DEMYX_STACK_AUTO_UPDATE=.*/DEMYX_STACK_AUTO_UPDATE=true/g' "$DEMYX_STACK"/.env
        elif [[ "$DEMYX_STACK_AUTO_UPDATE" = false ]]; then
            demyx_echo 'Turn off stack auto update'
            demyx_execute sed -i 's/DEMYX_STACK_AUTO_UPDATE=.*/DEMYX_STACK_AUTO_UPDATE=false/g' "$DEMYX_STACK"/.env
        fi
        if [[ "$DEMYX_STACK_BACKUP" = true ]]; then
            demyx_echo 'Turning on stack backup'
            demyx_execute sed -i 's/DEMYX_STACK_BACKUP=.*/DEMYX_STACK_BACKUP=true/g' "$DEMYX_STACK"/.env
        elif [[ "$DEMYX_STACK_BACKUP" = false ]]; then
            demyx_echo 'Turning off stack backup'
            demyx_execute sed -i 's/DEMYX_STACK_BACKUP=.*/DEMYX_STACK_BACKUP=false/g' "$DEMYX_STACK"/.env
        fi
        if [[ -n "$DEMYX_STACK_BACKUP_LIMIT" ]]; then
            demyx_echo 'Updating backup limit'
            demyx_execute sed -i "s/DEMYX_STACK_BACKUP_LIMIT=.*/DEMYX_STACK_BACKUP_LIMIT=$DEMYX_STACK_BACKUP_LIMIT/g" "$DEMYX_STACK"/.env
        fi
        if [[ "$DEMYX_STACK_CLOUDFLARE" = true ]]; then
            [[ -z "$DEMYX_STACK_CLOUDFLARE_API_EMAIL" ]] && demyx_die '--cf-api-email is missing'
            [[ -z "$DEMYX_STACK_CLOUDFLARE_API_KEY" ]] && demyx_die '--cf-api-key is missing'

            demyx_source env
            demyx_source yml

            demyx_echo 'Enabling Cloudflare as the certificate resolver'
            demyx_execute demyx_stack_env; \
                sed -i "s|DEMYX_STACK_CLOUDFLARE=.*|DEMYX_STACK_CLOUDFLARE=true|g" "$DEMYX_STACK"/.env; \
                sed -i "s|DEMYX_STACK_CLOUDFLARE_EMAIL=.*|DEMYX_STACK_CLOUDFLARE_EMAIL=$DEMYX_STACK_CLOUDFLARE_API_EMAIL|g" "$DEMYX_STACK"/.env; \
                sed -i "s|DEMYX_STACK_CLOUDFLARE_KEY=.*|DEMYX_STACK_CLOUDFLARE_KEY=$DEMYX_STACK_CLOUDFLARE_API_KEY|g" "$DEMYX_STACK"/.env; \
                demyx_stack_yml

            demyx compose stack up -d
        elif [[ "$DEMYX_STACK_CLOUDFLARE" = false ]]; then
            demyx_echo 'Disabling Cloudflare as the certificate resolver, switching back to HTTP'
            demyx_execute sed -i "s|DEMYX_STACK_CLOUDFLARE=.*|DEMYX_STACK_CLOUDFLARE=false|g" "$DEMYX_STACK"/.env

            demyx stack refresh
        fi
        if [[ "$DEMYX_STACK_HEALTHCHECK" = true ]]; then
            demyx_echo 'Turning on stack healthcheck'
            demyx_execute sed -i 's/DEMYX_STACK_HEALTHCHECK=.*/DEMYX_STACK_HEALTHCHECK=true/g' "$DEMYX_STACK"/.env
        elif [[ "$DEMYX_STACK_HEALTHCHECK" = false ]]; then
            demyx_echo 'Turning off stack healthcheck'
            demyx_execute sed -i 's/DEMYX_STACK_HEALTHCHECK=.*/DEMYX_STACK_HEALTHCHECK=false/g' "$DEMYX_STACK"/.env
        fi
        if [[ -n "$DEMYX_STACK_HEALTHCHECK_TIMEOUT" ]]; then
            demyx_echo 'Updating healthcheck timeout'
            demyx_execute sed -i "s|DEMYX_STACK_HEALTHCHECK_TIMEOUT=.*|DEMYX_STACK_HEALTHCHECK_TIMEOUT=$DEMYX_STACK_HEALTHCHECK_TIMEOUT|g" "$DEMYX_STACK"/.env
        fi
        if [[ "$DEMYX_STACK_MONITOR" = true ]]; then
            demyx_echo 'Turning on stack monitor'
            demyx_execute sed -i 's/DEMYX_STACK_MONITOR=.*/DEMYX_STACK_MONITOR=true/g' "$DEMYX_STACK"/.env
        elif [[ "$DEMYX_STACK_MONITOR" = false ]]; then
            demyx_echo 'Turning off stack monitor'
            demyx_execute sed -i 's/DEMYX_STACK_MONITOR=.*/DEMYX_STACK_MONITOR=false/g' "$DEMYX_STACK"/.env
        fi
        if [[ -n "$DEMYX_STACK_RESOURCE" ]]; then
            if [[ -n "$DEMYX_STACK_CPU" ]]; then
                demyx_echo "Updating stack CPU"
                if [[ "$DEMYX_STACK_CPU" = null ]]; then
                    demyx_execute sed -i "s/DEMYX_STACK_CPU=.*/DEMYX_STACK_CPU=/g" "$DEMYX_STACK"/.env
                else
                    demyx_execute sed -i "s/DEMYX_STACK_CPU=.*/DEMYX_STACK_CPU=$DEMYX_STACK_CPU/g" "$DEMYX_STACK"/.env
                fi
            fi
            if [[ -n "$DEMYX_STACK_MEM" ]]; then
                demyx_echo "Updating stack MEM"
                if [[ "$DEMYX_STACK_MEM" = null ]]; then
                    demyx_execute sed -i "s/DEMYX_STACK_MEM=.*/DEMYX_STACK_MEM=/g" "$DEMYX_STACK"/.env
                else
                    demyx_execute sed -i "s/DEMYX_STACK_MEM=.*/DEMYX_STACK_MEM=$DEMYX_STACK_MEM/g" "$DEMYX_STACK"/.env
                fi
            fi

            demyx compose stack up -d
        fi
        if [[ "$DEMYX_STACK_TELEMETRY" = true ]]; then
            demyx_echo 'Turning on stack telemetry'
            demyx_execute sed -i 's/DEMYX_STACK_TELEMETRY=.*/DEMYX_STACK_TELEMETRY=true/g' "$DEMYX_STACK"/.env
        elif [[ "$DEMYX_STACK_TELEMETRY" = false ]]; then
            demyx_echo 'Turning off stack telemetry'
            demyx_execute sed -i 's/DEMYX_STACK_TELEMETRY=.*/DEMYX_STACK_TELEMETRY=false/g' "$DEMYX_STACK"/.env
        fi
    fi
}
