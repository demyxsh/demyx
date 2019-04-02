#!/bin/bash
# Demyx
# URL: https://github.com/demyxco/demyx

echo
echo "Demyx"
echo "URL: https://github.com/demyxco/demyx"
echo

# Root check
[[ "$USER" = root ]] && echo -e "\e[31m[CRITICAL] Root user detected. Please run the script without sudo or root.\e[39m" && exit 1

# Prompts
echo -e "\e[34m[INFO] Used for Traefik's dashboard and phpMyAdmin as subdomains\e[39m"
read -ep "Primary Domain: " DOMAIN
SERVER_IP=$(curl -s https://ipecho.net/plain)
SUBDOMAIN_CHECK=$(/usr/bin/dig +short @1.1.1.1 traefik.${DOMAIN} | sed -e '1d')
[[ ! "$DOMAIN" ]] && echo -e "\e[31m[CRITICAL] Domain cannot be empty\e[39m" && exit 1
[[ ! -z "$SUBDOMAIN_CHECK" ]] && DOMAIN_IP=$SUBDOMAIN_CHECK || DOMAIN_IP=$(/usr/bin/dig +short @1.1.1.1 traefik.${DOMAIN})
[[ "$SERVER_IP" != "$DOMAIN_IP" ]] && echo -e "\e[31m[CRITICAL] Wildcard CNAME not detected. Please add * as a CNAME to your domain's DNS.\e[39m" && exit 1

echo
echo -e "\e[34m[INFO] Lets Encrypt SSL notifications\e[39m"
read -ep "Lets Encrypt Email: " EMAIL
[[ ! "$EMAIL" ]] && echo -e "\e[31m[CRITICAL] Email cannot be empty\e[39m" && exit 1

echo
echo -e "\e[34m[INFO] Enter username for Traefik dashboard\e[39m"
read -ep "Traefik Username: " TRAEFIK_USER
[[ ! "$TRAEFIK_USER" ]] && echo -e "\e[31m[CRITICAL] Username cannot be empty\e[39m" && exit 1
echo

# Install Docker and other packages
echo -e "\e[34m[INFO] Installing Docker and Docker Compose\e[39m"
sudo apt update
sudo apt install -y jq
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
apt-cache policy docker-ce
sudo apt install -y docker-ce
sudo usermod -aG docker $USER
sudo curl -L https://github.com/docker/compose/releases/download/1.24.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo sed -i 's|#DOCKER_OPTS="--dns 8.8.8.8 --dns 8.8.4.4"|DOCKER_OPTS="--dns 1.1.1.1 --dns 1.0.0.1"|g' /etc/default/docker
sudo service docker restart

# Pull the necessary images
sudo docker pull demyx/nginx-php-wordpress
sudo docker pull demyx/mariadb
sudo docker pull demyx/logrotate
sudo docker pull demyx/utilities
sudo docker pull traefik
sudo docker pull wordpress:cli
sudo docker pull phpmyadmin/phpmyadmin
sudo docker pull v2tec/watchtower
sudo docker pull quay.io/vektorlab/ctop

# Create our proxy network and group
sudo docker network create traefik
sudo groupadd demyx -g 82
sudo usermod -aG 82 $USER

# Create the initial directories and files
DIR="/srv/demyx"
PWGEN=$(sudo docker run -it --rm demyx/utilities sh -c "pwgen -cns 50 1" | sed -e 's/\r//g')
HTPASSWD=$(sudo docker run -it --rm demyx/utilities sh -c "htpasswd -nb $TRAEFIK_USER '$PWGEN'" | sed -e 's/\r//g')

sudo mkdir -p $DIR/etc
sudo chown $USER:$USER $DIR
mkdir -p $DIR/apps
mkdir -p $DIR/backup
mkdir -p $DIR/logs
git -C $DIR clone https://github.com/demyxco/demyx.git
mv $DIR/demyx $DIR/git
cp -R $DIR/git/etc/functions $DIR/etc
cp -R $DIR/git/etc/traefik $DIR/etc
sed -i "s|BASIC_AUTH|$HTPASSWD|g" $DIR/etc/traefik/traefik.toml
sed -i "s|EMAIL|$EMAIL|g" $DIR/etc/traefik/traefik.toml
sed -i "s|DOMAIN|$DOMAIN|g" $DIR/etc/traefik/traefik.toml
touch $DIR/logs/traefik.access.log
touch $DIR/logs/traefik.error.log
touch $DIR/etc/traefik/acme.json
chmod 600 $DIR/etc/traefik/acme.json

# Generate core .env and .yml
bash $DIR/etc/functions/etc-env.sh $DOMAIN $TRAEFIK_USER $PWGEN
bash $DIR/etc/functions/etc-yml.sh

# Create links
ln -s /srv/demyx $HOME/demyx
sudo ln -s /srv/demyx/git/cmd.sh /usr/local/bin/demyx

# Change directory and finally start the stack
cd $DIR/etc && sudo docker-compose up -d

echo
echo traefik.$DOMAIN
echo Username: $TRAEFIK_USER
echo Password: $PWGEN
echo
echo "To create your first site, run: demyx wp --dom=domain.tld --run --ssl"
echo

echo -e "\e[33m[WARNING] You must relogin or switch to another shell for new permissions to take effect.\e[39m"
read -ep "Switch shell? [yY]: " SWITCH
[[ "$SWITCH" = [yY] ]] && su $USER
