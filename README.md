# demyx 
[![Build Status](https://img.shields.io/travis/demyxco/demyx?style=flat)](https://travis-ci.org/demyxco/demyx)
[![Docker Pulls](https://img.shields.io/docker/pulls/demyx/demyx?style=flat&color=blue)](https://hub.docker.com/r/demyx/demyx)
[![Architecture](https://img.shields.io/badge/linux-amd64-important?style=flat&color=blue)](https://hub.docker.com/r/demyx/demyx)
[![Alpine](https://img.shields.io/badge/alpine-3.11.3-informational?style=flat&color=blue)](https://hub.docker.com/r/demyx/demyx)
[![Docker Client](https://img.shields.io/badge/docker_client-19.03.7-informational?style=flat&color=blue)](https://hub.docker.com/r/demyx/demyx)
[![Buy Me A Coffee](https://img.shields.io/badge/buy_me_coffee-$5-informational?style=flat&color=blue)](https://www.buymeacoffee.com/VXqkQK5tb)
[![Become a Patron!](https://img.shields.io/badge/become%20a%20patron-$5-informational?style=flat&color=blue)](https://www.patreon.com/bePatron?u=23406156)

Demyx is a Docker image that automates and manages WordPress installations. Traefik for reverse proxy with Lets Encrypt SSL/TLS. WordPress sites are powered by NGINX, PHP, and MariaDB.

<p align="center"><img  src="https://i.imgur.com/kwKTZHE.gif"></p>

### Updates & Support
[![Code Size](https://img.shields.io/github/languages/code-size/demyxco/demyx?style=flat&color=blue)](https://github.com/demyxco/demyx)
[![Repository Size](https://img.shields.io/github/repo-size/demyxco/demyx?style=flat&color=blue)](https://github.com/demyxco/demyx)
[![Watches](https://img.shields.io/github/watchers/demyxco/demyx?style=flat&color=blue)](https://github.com/demyxco/demyx)
[![Stars](https://img.shields.io/github/stars/demyxco/demyx?style=flat&color=blue)](https://github.com/demyxco/demyx)
[![Forks](https://img.shields.io/github/forks/demyxco/demyx?style=flat&color=blue)](https://github.com/demyxco/demyx)

* Auto built weekly on Sundays (America/Los_Angeles)
* Rolling release updates
* For support: [#demyx](https://webchat.freenode.net/?channel=#demyx)

### Features
* SSL turned on by default
* Basic auth site-wide or wp-login.php
* Secure NGINX/PHP configurations
* Backup/Restore/Clone
* CDN provided by Staticaly
* FastCGI cache with nginx-helper plugin by rtCamp (WooCommerce ready)
* Auto activate rate requests and limit connections when CPU is high
* Custom healthchecks
* Development mode includes the tools code-server, BrowserSync, and demyx_helper plugin
* [Bedrock](https://roots.io/bedrock/)

### Requirements
* Docker
* Dedicated/KVM server with Linux
* Port 80 and 443 must be open
* CentOS/Fedora/RHEL requires [selinux-dockersock](https://github.com/dpw/selinux-dockersock) or similar fix

### Tested Distros
- Alpine 3.10 x64
- Debian 10 x64
- Ubuntu 19.10 x64
- CentOS 7.6 x64 (Probably works on Fedora and RHEL)

### Install
```
bash -c "$(curl -fsSL https://demyx.sh/install)"
```

### Getting Started
- [Step-by-Step Guide](https://demyx.sh/docker/how-to-easily-manage-multiple-wordpress-sites-in-docker-using-demyx/)

```
# Create a WordPress site on the host OS
demyx cmd run domain.tld --cdn --cache

# Create a WordPress site in the demyx container
demyx run domain.tld --cdn --cache

# Create a WordPress site powered by Bedrock in the demyx container
demyx run domain.tld --bedrock
```

### Demyx Image
Demyx needs access to the docker.sock as a non-root user, which the chroot helper script will set that up for you. Sudo is installed to only allow the demyx user to execute specific scripts as root. The image is put in production mode by default, meaning that /demyx directory and all its folders and files will be set to read-only mode by root. This prevents the non-privelege user to modify the script and do malicious things.

* user/group: demyx:demyx (1000:1000)
* docker (binary)
* bash
* curl
* git
* gnupg
* jq
* nano
* oh-my-zsh
* sudo
* tzdata
* util-linux
* rsync
* zsh

### chroot.sh
This script helps you change root to the demyx container, it's installed on the host OS and lives in /usr/local/bin. The script will generate a docker-compose.yml for demyx and the [demyx/docker-socket-proxy](https://github.com/demyxco/docker-socket-proxy). Executing the install script will automatically install the Demyx chroot script. The chroot script will start the demyx container and binds port 2222 for SSH. SSH port can be overriden by the script.

(host) demyx help
```
demyx <args>          Chroot into the demyx container
      cmd             Send demyx commands from host
      help            Demyx help
      rm              Stops and removes demyx container
      rs|restart      Stops, removes, and starts demyx container
      sh              Execute root commands to demyx container from host
      update          Update chroot.sh from GitHub
      -a, --all       Targets both demyx and demyx_socket container
      --cpu           Set container CPU usage, --cpu=null to remove cap
      -d|--dev        Puts demyx container into development mode
      --edge          Use latest code updates from git repo
      --mem           Set container MEM usage, --mem=null to remove cap
      --nc            Starts demyx containr but prevent chrooting into container
      -p|--prod       Puts demyx container into production mode
      -r, --root      Execute as root user
      --ssh           Override ssh port
      --system        Pulls all demyx images, updates demyx helper script, and force recreates the demyx_socket and demyx containers when using demyx update --system
      --tz            Set timezone
```

### Commands
```
demyx <arg>           Main demyx command
      backup          Back up an app
      compose         Accepts all docker-compose arguments
      config          Modifies an app's configuration
      cp              Wrapper for docker cp
      cron            Execute demyx cron
      edit            Opens nano to edit .env and docker-compose.yml files
      exec            Accepts all docker exec arguments
      healthcheck     Checks if WordPress apps are up
      info            Shows an app's .env and filter output
      list            List all apps
      log             Show or follow demyx.log
      maldet          Linux Malware Detect
      monitor         For auto scaling purposes
      motd            Message of the day
      pull            Pull one or all demyx images from Docker hub
      restore         Restore an app
      rm              Removes an app and its volumes
      run             Creates a new app
      stack           Control the stack via docker-compose arguments
      update          Update demyx code base
      util            Generates credentials or access util container
      wp              Execute wp-cli commands
```

### Privacy
I have a telemetry setting that is enabled by default. It sends a curl request to demyx.sh server daily at midnight PST. No data is collected except your server's IP address, which is logged to the web server like any other visitor on a browser. I have this enabled so I can track how many active installs there are of Demyx. The curl request uses a token (generated by OpenSSL with a passphrase) to prevent abuse and duplicate entries. What I intend to do with this data is just show a graph of active Demyx installs, just like WordPress plugin stats. 

If you are uncomfortable with this, then you can turn off telemetry by running the command below OR keep it turned on to show your support!

* [Curl](https://github.com/demyxco/demyx/blob/master/function/cron.sh#L40)
* [Statistics](https://demyx.sh/statistics/)

```
# Execute in the host OS
demyx cmd stack --telemetry=false

# Execute in the demyx container
demyx stack --telemetry=false
```

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
