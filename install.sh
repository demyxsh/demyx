#!/bin/bash
# Demyx
# https://demyx.sh

DEMYX_DOCKER_CHECK=$(which docker)
DEMYX_BASH_CHECK=$(which bash)
DEMYX_ZSH_CHECK=$(which zsh)
DEMYX_SUDO_CHECK=$(id -u)

if [ "$DEMYX_SUDO_CHECK" != 0 ]; then
    echo -e "\e[31m[CRITICAL]\e[39m Must be ran as root or sudo"
    exit 1
fi

if [ -z "$DEMYX_DOCKER_CHECK" ]; then
    echo -e "\e[31m[CRITICAL]\e[39m Docker must be installed"
    exit 1
fi

echo -e "\e[34m[INFO] Enter top level domain for Traefik dashboard\e[39m"
read -ep "Domain: " DEMYX_INSTALL_DOMAIN 
if [ -z "$DEMYX_INSTALL_DOMAIN" ]; then
    echo -e "\e[31m[CRITICAL]\e[39m Domain cannot be empty"
    exit 1
fi

DEMYX_WILDCARD_CHECK=$(docker run -t --rm demyx/utilities "dig +short '*.$DEMYX_INSTALL_DOMAIN'")
if [ -z "$DEMYX_WILDCARD_CHECK" ]]; then
    echo -e "\e[31m[CRITICAL]\e[39m Wildcard CNAME not detected, please add * as a CNAME to your domain's DNS and rerun installation"
    exit
fi

echo -e "\e[34m[INFO\e[39m] Lets Encrypt SSL notifications"
read -ep "Email: " DEMYX_INSTALL_EMAIL
if [ -z "$DEMYX_INSTALL_EMAIL" ]; then
    echo -e "\e[31m[CRITICAL]\e[39m Email cannot be empty"
    exit 1
fi

echo -e "\e[34m[INFO]\e[39m Enter username for basic auth"
read -ep "Username: " DEMYX_INSTALL_USER
if [ -z "$DEMYX_INSTALL_USER" ]; then
    echo -e "\e[31m[CRITICAL]\e[39m Username cannot be empty"
    exit 1
fi

echo -e "\e[34m[INFO]\e[39m Enter password for basic auth"
read -ep "Password: " DEMYX_INSTALL_USER
if [ -z "$DEMYX_INSTALL_USER" ]; then
    echo -e "\e[31m[CRITICAL]\e[39m Password cannot be empty"
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

docker run -dt --rm \
--name demyx_install_container \
-v demyx_ssh:/home/demyx/.ssh \
demyx/utilities bash

docker cp "$HOME"/.ssh/authorized_keys demyx_install_container:/home/demyx/.ssh
docker stop demyx_install_container

if [ -f /usr/local/bin/demyx ]; then
    rm /usr/local/bin/demyx
fi

wget demyx.sh/chroot -qO /usr/local/bin/demyx
chmod +x /usr/local/bin/demyx

if [ -n "$DEMYX_BASH_CHECK" ]; then
    sed -i "s|#!/bin/sh|#!/bin/bash|g" /usr/local/bin/demyx
    echo "demyx" >> "$HOME"/.bashrc
else
    echo "demyx" >> "$HOME"/.profile
fi

if [ -n "$DEMYX_ZSH_CHECK" ]; then
    echo "demyx" >> "$HOME"/.zshrc
fi

docker exec -t demyx demyx install --domain="$DEMYX_INSTALL_DOMAIN" --email="$DEMYX_INSTALL_EMAIL" --user="$DEMYX_INSTALL_USER" --pass="$DEMYX_INSTALL_PASS"
demyx
