#!/bin/bash
# Demyx
# https://demyx.sh
# 0 0 * * *

# Active install tracker
echo -e "[$(date +%F-%T)] CROND: ACTIVE TRACKER"
DEMYX_STACK_TRACKER_CHECK=$(grep DEMYX_STACK_TRACKER /demyx/app/stack/.env | awk -F '[=]' '{print $2}')
if [[ "$DEMYX_STACK_TRACKER_CHECK" = on ]]; then
    /usr/bin/curl -s "https://demyx.sh/?action=active&token=V1VpdGNPcWNDVlZSUDFQdFBaR0Zhdz09OjrnA1h6ZbDFJ2T6MHOwg3p4" > /dev/null
fi

# Ouroboros is known to crash, so stop/rm it and have the updater bring it back up 
echo -e "[$(date +%F-%T)] CROND: RESTARTING OUROBOROS"
docker stop demyx_ouroboros
docker rm -f demyx_ouroboros

# Auto update Demyx core files
echo -e "[$(date +%F-%T)] CROND: UPDATE DEMYX CORE"
DEMYX_STACK_AUTO_UPDATE_CHECK=$(grep DEMYX_STACK_AUTO_UPDATE /demyx/app/stack/.env | awk -F '[=]' '{print $2}')
if [[ "$DEMYX_STACK_AUTO_UPDATE_CHECK" = on ]]; then
    /usr/local/bin/demyx update
fi

# Update demyx chroot.sh on the host using a container
echo -e "[$(date +%F-%T)] CROND: UPDATE DEMYX CHROOT"
docker run -t --rm -v /usr/local/bin:/usr/local/bin demyx/utilities "rm -f /usr/local/bin/demyx; curl -s https://raw.githubusercontent.com/demyxco/demyx/master/chroot.sh -o /usr/local/bin/demyx; chmod +x /usr/local/bin/demyx"

# Update Oh My Zsh and its plugin
echo -e "[$(date +%F-%T)] CROND: UPDATE OH-MY-ZSH"
cd /home/demyx/.oh-my-zsh && git pull
cd /home/demyx/.oh-my-zsh/plugins/zsh-autosuggestions && git pull

# Execute custom cron
echo -e "[$(date +%F-%T)] CROND: CUSTOM EVERY DAY"
if [[ -f /demyx/custom/cron/every-day.sh ]]; then
    bash /demyx/custom/cron/every-day.sh
fi

# Backup WordPress sites at midnight
echo -e "[$(date +%F-%T)] CROND: WORDPRESS BACKUP"
/usr/local/bin/demyx backup all

# WP auto update
echo -e "[$(date +%F-%T)] CROND: WORDPRESS UPDATE"
cd /demyx/app/wp
for i in *
do
    source /demyx/app/wp/"$i"/.env
    if [[ "$DEMYX_APP_WP_UPDATE" = on ]]; then
        demyx wp "$i" core update
        demyx wp "$i" theme update --all
        demyx wp "$i" plugin update --all
    fi
done
