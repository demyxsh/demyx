#!/bin/bash
# Demyx
# https://demyx.sh
# Feel free to edit/modify this file since it will not be updated.
# Below is an example of demyx monitor callback to Rocket.Chat via webhooks

#TYPE="$1"

#if [[ "$TYPE" = monitor-on ]]; then
#  DOMAIN=$(echo "$2" | tr a-z A-Z)
#  CPU="$3"
#  curl -X POST \
#  -H 'Content-Type: application/json' \
#  --data "
#      {
#          \"username\":\"Demyx\",
#          \"icon_url\":\"https://avatars2.githubusercontent.com/u/3078484?s=460&v=4\",
#          \"text\":\"$DOMAIN: HIGH CPU DETECTED\nACTION: \`ACTIVATING ANTI-DDOS\`\nCPU: ${CPU}%\nMODE: UNDER ATTACK\"
#      }
#  " \
#  https://domain.tld/hooks/Pvgdb3PEsaAcyKu7N/uEv9cq4sidmwKNfsnvK4ZHaYSy75XDmKzWAYwgA3uayMMLfD
#elif [[ "$TYPE" = monitor-off ]]; then
#  DOMAIN=$(echo "$2" | tr a-z A-Z)
#  CPU="$3"
#  curl -X POST \
#  -H 'Content-Type: application/json' \
#  --data "
#      {
#          \"username\":\"Demyx\",
#          \"icon_url\":\"https://avatars2.githubusercontent.com/u/3078484?s=460&v=4\",
#          \"text\":\"$DOMAIN: CPU LEVELS OPTIMAL\nACTION: \`DEACTIVATING ANTI-DDOS\`\nCPU: ${CPU}%\nMODE: HIGH\"
#      }
#  " \
#  https://domain.tld/hooks/Pvgdb3PEsaAcyKu7N/uEv9cq4sidmwKNfsnvK4ZHaYSy75XDmKzWAYwgA3uayMMLfD
#fi
