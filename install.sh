#!/bin/bash
# Demyx
# https://demyx.sh

DEMYX_DOCKER_CHECK=$(which docker)
DEMYX_SUDO_CHECK=$(id -u)

if [[ "$DEMYX_SUDO_CHECK" != 0 ]]; then
    echo -e "\e[31m[CRITICAL]\e[39m Must be ran as root or sudo"
    exit 1
fi

if [[ -z "$DEMYX_DOCKER_CHECK" ]]; then
    echo -e "\e[31m[CRITICAL]\e[39m Docker must be installed"
    exit 1
fi

docker pull demyx/demyx
docker pull demyx/browsersync
docker pull demyx/docker-compose
docker pull demyx/logrotate
docker pull demyx/mariadb
docker pull demyx/nginx-php-wordpress
docker pull demyx/ssh
docker pull demyx/utilities
docker pull wordpress:cli
docker pull phpmyadmin/phpmyadmin
docker pull pyouroboros/ouroboros
docker pull quay.io/vektorlab/ctop
docker network create demyx

echo -e "\e[34m[INFO]\e[39m Enter top level domain for Traefik dashboard"
read -rep "Domain: " DEMYX_INSTALL_DOMAIN
if [[ -z "$DEMYX_INSTALL_DOMAIN" ]]; then
    echo -e "\e[31m[CRITICAL]\e[39m Domain cannot be empty"
    exit 1
fi

DEMYX_WILDCARD_CHECK=$(docker run -t --rm demyx/utilities "dig +short '*.$DEMYX_INSTALL_DOMAIN'")
if [[ -z "$DEMYX_WILDCARD_CHECK" ]]; then
    echo -e "\e[31m[CRITICAL]\e[39m Wildcard CNAME not detected, please add * as a CNAME to your domain's DNS and rerun installation"
    exit
fi

echo -e "\e[34m[INFO\e[39m] Lets Encrypt SSL notifications"
read -rep "Email: " DEMYX_INSTALL_EMAIL
if [[ -z "$DEMYX_INSTALL_EMAIL" ]]; then
    echo -e "\e[31m[CRITICAL]\e[39m Email cannot be empty"
    exit 1
fi

echo -e "\e[34m[INFO]\e[39m Enter username for basic auth"
read -rep "Username: " DEMYX_INSTALL_USER
if [[ -z "$DEMYX_INSTALL_USER" ]]; then
    echo -e "\e[31m[CRITICAL]\e[39m Username cannot be empty"
    exit 1
fi

echo -e "\e[34m[INFO]\e[39m Enter password for basic auth"
read -rep "Password: " DEMYX_INSTALL_PASS
if [[ -z "$DEMYX_INSTALL_PASS" ]]; then
    echo -e "\e[31m[CRITICAL]\e[39m Password cannot be empty"
    exit 1
fi

echo -e "\e[34m[INFO\e[39m] Copying authorized_keys to installer container. If you can't SSH or if this fails, then please run on the host OS: 

docker cp \"\$HOME\"/.ssh/authorized_keys demyx:/home/demyx/.ssh
demyx rs
"
docker run -dt --rm \
--name demyx_install_container \
-v demyx_user:/home/demyx/.ssh \
demyx/utilities bash

DEMYX_AUTHORIZED_KEY=$(find /home -name "authorized_keys" | head -n 1)
docker cp "$DEMYX_AUTHORIZED_KEY" demyx:/home/demyx/.ssh
docker stop demyx_install_container

if [[ -f /usr/local/bin/demyx ]]; then
    rm /usr/local/bin/demyx
fi

echo -e "\e[34m[INFO\e[39m] Installing demyx chroot"
wget demyx.sh/chroot -qO /usr/local/bin/demyx
chmod +x /usr/local/bin/demyx

demyx --nc
echo -e "\e[34m[INFO\e[39m] Waiting for demyx container to fully initialize"
sleep 5
demyx exec install --domain="$DEMYX_INSTALL_DOMAIN" --email="$DEMYX_INSTALL_EMAIL" --user="$DEMYX_INSTALL_USER" --pass="$DEMYX_INSTALL_PASS"
demyx
