#!/bin/bash

DEMYX_MALDET_TYPE="$1"

if [[ "$DEMYX_MALDET_TYPE" = db ]]; then
    DEMYX_MALDET_SCAN=$(maldet -a /var/lib/mysql | grep "to view run" | awk '{print $NF}')
else 
    DEMYX_MALDET_SCAN=$(maldet -a /var/www/html | grep "to view run" | awk '{print $NF}')
fi

maldet --report "$DEMYX_MALDET_SCAN"
