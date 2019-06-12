#!/bin/bash
# Demyx
# https://demyx.sh
# Feel free to edit/modify this file since it will not be updated.
# Below is an example of demyx monitor callback to Rocket.Chat via webhooks

#DEMYX_CALLBACK_TYPE="$1"

#if [[ "$DEMYX_CALLBACK_TYPE" = healthcheck ]]; then
#    DEMYX_CALLBACK_DOMAIN=$(echo "$2" | tr a-z A-Z)
#    DEMYX_CALLBACK_RESPONSE="$3"
#    curl -X POST \
#    -H 'Content-Type: application/json' \
#    --data "
#        {
#            \"username\":\"Demyx\",
#            \"icon_url\":\"https://avatars2.githubusercontent.com/u/3078484?s=460&v=4\",
#            \"text\":\"$DEMYX_CALLBACK_DOMAIN: WEBSITE DOWN\nSTATUS: $DEMYX_CALLBACK_RESPONSE\"
#        }
#    " \
#    https://domain.tld/hooks/Pvgdb3PEsaAcyKu7N/uEv9cq4sidmwKNfsnvK4ZHaYSy75XDmKzWAYwgA3uayMMLfD
#elif [[ "$DEMYX_CALLBACK_TYPE" = monitor-on ]]; then
#  DEMYX_CALLBACK_DOMAIN=$(echo "$2" | tr a-z A-Z)
#  DEMYX_CALLBACK_CPU="$3"
#  curl -X POST \
#  -H 'Content-Type: application/json' \
#  --data "
#      {
#          \"username\":\"Demyx\",
#          \"icon_url\":\"https://avatars2.githubusercontent.com/u/3078484?s=460&v=4\",
#          \"text\":\"$DEMYX_CALLBACK_DOMAIN: HIGH CPU DETECTED\nACTION: \`ACTIVATING ANTI-DDOS\`\nCPU: ${DEMYX_CALLBACK_CPU}%\nMODE: UNDER ATTACK\"
#      }
#  " \
#  https://domain.tld/hooks/Pvgdb3PEsaAcyKu7N/uEv9cq4sidmwKNfsnvK4ZHaYSy75XDmKzWAYwgA3uayMMLfD
#elif [[ "$DEMYX_CALLBACK_TYPE" = monitor-off ]]; then
#  DEMYX_CALLBACK_DOMAIN=$(echo "$2" | tr a-z A-Z)
#  DEMYX_CALLBACK_CPU="$3"
#  curl -X POST \
#  -H 'Content-Type: application/json' \
#  --data "
#      {
#          \"username\":\"Demyx\",
#          \"icon_url\":\"https://avatars2.githubusercontent.com/u/3078484?s=460&v=4\",
#          \"text\":\"$DEMYX_CALLBACK_DOMAIN: CPU LEVELS OPTIMAL\nACTION: \`DEACTIVATING ANTI-DDOS\`\nCPU: ${DEMYX_CALLBACK_CPU}%\nMODE: HIGH\"
#      }
#  " \
#  https://domain.tld/hooks/Pvgdb3PEsaAcyKu7N/uEv9cq4sidmwKNfsnvK4ZHaYSy75XDmKzWAYwgA3uayMMLfD
#fi
