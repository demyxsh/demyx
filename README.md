
# Demyx
A simple bash CLI wrapper for Docker to automate WordPress installations. Traefik for reverse proxy with Lets Encrypt SSL. WordPress sites are powered by NGINX, PHP, and MariaDB.

Demyx is now a Docker image and the code base has been completely rewritten, think of this as a "Version 2." The plan was to not "pollute" the host OS and go full Docker mode. This makes it easier to have a controlled and predictable environment. One can say Demyx is "Linux OS agnostic," as long as you have Docker installed.

<p align="center">
<img  src="https://i.imgur.com/sYNrgFh.gif">
</p>

### Stack
ALPINE | NGINX | MARIADB | PHP | WORDPRESS
------------- | ------------- | ------------- | ------------- | -------------
3.9.4 | 1.16.0 | 10.3.15 | 7.3.6 | 5.2.1

### WordPress Features
* SSL turned on by default
* Site-wide request rate limiting
* Secure NGINX/PHP configurations
* Backup/Restore/Clone
* CDN provided by Staticaly
* FastCGI cache with nginx-helper plugin by rtCamp (WooCommerce ready)
* Development mode includes the tools SSH, BrowserSync with UI, phpMyAdmin, and Demyx BrowserSync plugin
* Auto scale containers with callback (see the custom folder)
* WP-CLI

### Demyx Image
Since the image needs docker.sock to be mounted and the Docker binary is included, I've installed sudo to only allow the demyx user to execute only one script as root. The image is put in production mode by default, meaning that /demyx directory and all it's folders and files will be set to read-only mode. This prevents the non-privelege user to modify the script and do malicious things.

* User/Group: demyx:demyx
* Docker binary
* Eternal Terminal
* bash
* curl
* zsh
* oh-my-zsh
* sudo
* git
* gnupg
* tzdata
* jq

### Eternal Terminal
LOCAL MACHINE: Make ssh alias (~/.ssh/config)
```
Host example
     HostName example.com
     User demyx
     Port 2222
```
LOCAL MACHINE: Run et command using alias (assuming et is installed on local machine)
```
et example

# If you override the et port to something else than 2022, for example 3000
et example:3000
```

### Requirements
* Docker
* Bash
* Dedicated/KVM server with Linux
* Port 80 and 443 must be open
* Primary domain must be pointed to server's IP and must have a wildcard CNAME subdomain

### Install
```
wget demyx.sh/install && sudo bash install
```

### Upgrade
The script script takes 1 parameter (stack/test/wp) to upgrade each component individually, starting with the stack first. This will move the stack's configs to the demyx container, create a new Docker network, and update all docker-compose.yml to use the new network.
```
wget demyx.sh/upgrade && sudo bash upgrade stack
```
It is RECOMMENDED to test out a single site first to see if the site migrated successfully
```
sudo bash upgrade test domain.tld
```
Then you can migrate all sites in a loop. You can individually migrate them by just using the test parameter.
```
sudo bash upgrade wp
```

What's changed from "Version 1?"
* Demyx code base has been rewritten
* No more bind mounts, all data are stored in volumes
* Traefik's configs are now in docker-compose via cli
* Logrotate was taken off from the stack and now runs as cron by demyx container

### Getting Started
```
# Create a WordPress site on the host OS
demyx exec run domain.tld --auth --cdn --cache

# Create a WordPress site in the demyx container
demyx run domain.tld --auth --cdn --cache
```

### chroot.sh
This script helps you change root to the demyx container, it's installed on the host OS and lives in /usr/local/bin. Executing the install or upgrade script will automatically install the Demyx chroot script. The chroot script will start the demyx container, bind ports 2222 for SSH, and 2022 for Eternal Terminal by default. These ports can be overriden by the script.
```
docker run -dit \
    --name demyx \
    --restart unless-stopped \
    --hostname "$DEMYX_CHROOT_HOST" \
    --network demyx \
    -e DEMYX_HOST="$DEMYX_CHROOT_HOST" \
    -e DEMYX_SSH="$DEMYX_CHROOT_SSH" \
    -e DEMYX_ET="$DEMYX_CHROOT_ET" \
    -e DEMYX_MODE="$DEMYX_CHROOT_MODE" \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v demyx:/demyx \
    -v demyx_user:/home/demyx \
    -v demyx_log:/var/log/demyx \
    -e TZ=America/Los_Angeles \
    -p "$DEMYX_CHROOT_SSH":22 \
    -p "$DEMYX_CHROOT_ET":2022 \
    demyx/demyx
```
(host) demyx help
```
demyx <args>          Chroot into the demyx container
      exec            Send demyx commands from host
      help            Demyx help
      rm              Stops and removes demyx container
      rs              Stops, removes, and starts demyx container
      tty             Execute root commands to demyx container from host
      update          Update the demyx chroot
      --dev           Puts demyx container into development mode
      --nc            Starts demyx containr but prevent chrooting into container
      --et            Override et port
      --prod          Puts demyx container into production mode
      --ssh           Override ssh port
```

### Commands
```
demyx <arg>       Main demyx command
      backup      Back up an app
      compose     Accepts all docker-compose arguments
      config      Modifies an app's configuration
      ctop        Htop but for containers
      exec        Accepts all docker exec arguments
      info        Shows an app's .env and filter output
      log         Show or follow demyx.log
      monitor     For auto scaling purposes
      motd        Message of the day
      restore     Restore an app
      rm          Removes an app and its volumes
      run         Creates a new app
      stack       Control the stack via docker-compose arguments
      update      Update demyx code base
      util        Generates credentials or access util container
      wp          Execute wp-cli commands
```

### Questions?
You can reach me by these avenues
* [info@demyx.sh](mailto:info@demyx.sh)
* #demyx at freenode

### Resources
*  [Demyx](https://github.com/demyxco/demyx) - Demyx GitHub
*  [Traefik](https://hub.docker.com/_/traefik) - Reverse Proxy with Lets Encrypt SSL
*  [ouroboros](https://hub.docker.com/r/pyouroboros/ouroboros) - Auto pull new images from Docker Hub
*  [WordPress](https://hub.docker.com/_/wordpress) - Using their `wordpress:cli` image
*  [phpMyAdmin](https://hub.docker.com/r/phpmyadmin/phpmyadmin) - Web GUI used with Demyx stack
*  [ctop](https://ctop.sh) - htop but for containers!
*  [VirtuBox](https://github.com/VirtuBox/ubuntu-nginx-web-server) - Borrowed configs for NGINX and PHP
*  [EasyEngine](https://easyengine.io/) - Using their nginx helper plugin
*  [Staticaly](https://www.staticaly.com/) - Free CDN setup
