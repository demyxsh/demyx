# demyx [![Demyx](https://github.com/demyxsh/demyx/actions/workflows/main.yml/badge.svg)](https://github.com/demyxsh/demyx/actions/workflows/main.yml) [![Version](https://img.shields.io/badge/dynamic/json?url=https://github.com/demyxsh/demyx/raw/master/version.json&label=version&query=$.demyx&color=blue)](https://hub.docker.com/r/demyx/demyx)

<p align="center"><a href="https://asciinema.org/a/608407" target="_blank"><img src="https://asciinema.org/a/608407.svg" /></a></p>

Demyx is a Docker image that automates and manages WordPress installations. Traefik for reverse proxy with Lets Encrypt SSL/TLS. WordPress sites are powered by OpenLiteSpeed/NGINX-PHP and MariaDB.

[![Code Size](https://img.shields.io/github/languages/code-size/demyxsh/demyx?style=flat&color=blue)](https://github.com/demyxsh/demyx)
[![Repository Size](https://img.shields.io/github/repo-size/demyxsh/demyx?style=flat&color=blue)](https://github.com/demyxsh/demyx)
[![Watches](https://img.shields.io/github/watchers/demyxsh/demyx?style=flat&color=blue)](https://github.com/demyxsh/demyx)
[![Stars](https://img.shields.io/github/stars/demyxsh/demyx?style=flat&color=blue)](https://github.com/demyxsh/demyx)
[![Forks](https://img.shields.io/github/forks/demyxsh/demyx?style=flat&color=blue)](https://github.com/demyxsh/demyx)
[![Docker Pulls](https://img.shields.io/docker/pulls/demyx/demyx?style=flat&color=blue)](https://hub.docker.com/r/demyx/demyx)
[![Architecture](https://img.shields.io/badge/linux-amd64-important?style=flat&color=blue)](https://hub.docker.com/r/demyx/demyx)
[![Alpine](https://img.shields.io/badge/dynamic/json?url=https://github.com/demyxsh/demyx/raw/master/version.json&label=alpine&query=$.alpine&color=blue)](https://hub.docker.com/r/demyx/demyx)
[![ctop](https://img.shields.io/badge/dynamic/json?url=https://github.com/demyxsh/demyx/raw/master/version.json&label=ctop&query=$.ctop&color=blue)](https://hub.docker.com/r/demyx/demyx)
[![Docker Client](https://img.shields.io/badge/dynamic/json?url=https://github.com/demyxsh/demyx/raw/master/version.json&label=docker&query=$.docker&color=blue)](https://hub.docker.com/r/demyx/demyx)
[![Docker Compose](https://img.shields.io/badge/dynamic/json?url=https://github.com/demyxsh/demyx/raw/master/version.json&label=docker-compose&query=$.docker_compose&color=blue)](https://hub.docker.com/r/demyx/demyx)
[![Buy Me A Coffee](https://img.shields.io/badge/buy_me_coffee-$5-informational?style=flat&color=blue)](https://www.buymeacoffee.com/VXqkQK5tb)
[![Become a Patron!](https://img.shields.io/badge/become%20a%20patron-$5-informational?style=flat&color=blue)](https://www.patreon.com/bePatron?u=23406156)

## NOTICE
This repository has been moved to the organization [demyxsh](https://github.com/demyxsh); please update the remote URL.
```
git remote set-url origin git@github.com:demyxsh/demyx.git
```

### Features
- Everything is in containers
- Site-wide or login only basic auth and/or IP whitelisted protection
- Secure NGINX/PHP configurations
- Backup/Restore/Clone
- FastCGI cache with nginx-helper plugin by rtCamp (WooCommerce ready)
- Auto activate rate requests and limit connections when CPU is high
- Custom healthchecks
- Development mode includes the tools code-server (with WPCS and Xdebug), BrowserSync, and demyx_helper plugin
- [Bedrock](https://roots.io/bedrock/)
- Browse Demyx file system using code-server (with capabilities of executing demyx commands inside the container and a full fledge terminal using oh-my-zsh)

### Requirements
- Dedicated/KVM server that can install Docker
- Port 80 and 443 must be open
- DNS must be pointed to the server IP before installing

### Tested Distros (x64)
- Alpine 3.1x
- Debian 10, 11
- RockyLinux 8.5
- Ubuntu 18.04, 19.10, 20.04

### Install
```
# Install demyx and ping home
bash -c "$(curl -sL https://demyx.sh/install)"

# Install demyx without pinging home
wget https://demyx.sh/install; bash install --no-ping
```

### Getting Started
- [Step-by-Step Guide](https://demyx.sh/docker/how-to-easily-manage-multiple-wordpress-sites-in-docker-using-demyx/)

```
# Create a WordPress site with cache
demyx run domain.tld --cache

# Create a WordPress site powered by Bedrock
demyx run domain.tld --stack=bedrock
```

### Demyx Image
Demyx needs access to the docker.sock as a non-root user, which the helper script will set that up for you. Sudo is installed to only allow the demyx user to execute specific scripts as root. The image has /bin/busybox and other binaries locked down. This prevents the non-privelege user to modify the script and do malicious things.

### host.sh
This is a helper script that gets installed on the host and configuration file is installed at `~/.demyx`. It wraps docker exec commands into the demyx container. It also restarts and removes the main demyx containers. See `demyx host help` for more info.

demyx host help
```
demyx host    <args>          Demyx helper commands
      shell                   Opens a root shell to the demyx container, leave <arg> empty to open a bash shell
              all             Targets both demyx and demyx_socket container, works with remove and restart
              edit            Edit Demyx config on the host (~/.demyx)
              install         Prompt users to enter details for ~/.demyx
              rm|remove       Stops and removes demyx container
              rs|restart      Stops, removes, and starts demyx container
              upgrade         Pull relevant images, refresh app configs, and delete old images (pass -f|--force to force upgrade)
```

### Commands
```
demyx <arg>                   Main demyx command, for more info: demyx help <arg>
      backup                  Backs up app's WordPress, code-server, MariaDB, logs, and SFTP volumes
      compose                 Execute docker-compose commands to apps
      config                  Configure demyx apps
      cp                      Outputs a table of container names for MariaDB, Nginx, and WordPress
      cron                    Execute demyx cron (daily|hourly|minute|six-hour|weekly)
      edit                    Uses nano to edit .env files
      exec                    Execute docker exec commands to apps
      healthcheck             Checks if WordPress apps are up
      info                    Prints useful information about demyx images, installed apps, and system
      log                     Show logs from various apps, can also logrotate
      maldet                  Linux Malware Detect
      monitor                 Watches for high CPU usage on MariaDB/WordPress container(s), will execute a callback script
      motd                    Message of the day
      pull                    Enter specific image or demyx pull all
      refresh                 Regenerate .env/docker-compose.yml files of an app
      restore                 Restore app's configs and volumes
      rm                      Deletes an app and its volumes
      run                     Creates a new app
      update                  Update demyx ccache
      util|utility            Generate credentials or execute shell commands to demyx/utilities
      -v|--version|version    Show demyx version
      wp                      Execute wp-cli commands
```

### Privacy
I have a telemetry setting that is enabled by default. It sends a curl request to demyx.sh server daily at midnight PST. No data is collected except your server's IP address, which is logged to the web server like any other visitor on a browser. I have this enabled so I can track how many active installs there are of Demyx. The curl request uses a token (generated by OpenSSL with a passphrase) to prevent abuse and duplicate entries. What I intend to do with this data is just show a graph of active Demyx installs, just like WordPress plugin stats.

If you are uncomfortable with this, then you can turn off telemetry by running the command below OR keep it turned on to show your support!

* [Curl](https://github.com/demyxsh/demyx/blob/master/function/cron.sh#L40)
* [Statistics](https://demyx.sh/statistics/)

```
# Edit demyx environment variables and set DEMYX_TELEMETRY=false
demyx host edit
```

### Resources
- [ctop](https://ctop.sh) - htop but for containers!
- [VirtuBox](https://github.com/VirtuBox/ubuntu-nginx-web-server) - Borrowed configs for NGINX and PHP
- [EasyEngine](https://easyengine.io/) - Using their nginx helper plugin

### Updates & Support
- Auto built weekly on Saturdays (America/Los_Angeles)
- Rolling release updates
- For support: [#demyx](https://web.libera.chat/?channel=#demyx)
