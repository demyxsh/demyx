# demyx [![Build Status](https://img.shields.io/travis/demyxco/demyx?style=flat)](https://travis-ci.org/demyxco/demyx) [![demyx](https://img.shields.io/badge/version-1.3.1-informational?style=flat&color=blue)](https://hub.docker.com/r/demyx/demyx)

<p align="center"><img  src="https://i.imgur.com/kwKTZHE.gif"></p>

Demyx is a Docker image that automates and manages WordPress installations. Traefik for reverse proxy with Lets Encrypt SSL/TLS. WordPress sites are powered by OpenLiteSpeed/NGINX-PHP and MariaDB.

[![Docker Pulls](https://img.shields.io/docker/pulls/demyx/demyx?style=flat&color=blue)](https://hub.docker.com/r/demyx/demyx)
[![Architecture](https://img.shields.io/badge/linux-amd64-important?style=flat&color=blue)](https://hub.docker.com/r/demyx/demyx)
[![Alpine](https://img.shields.io/badge/alpine-3.14.0-informational?style=flat&color=blue)](https://hub.docker.com/r/demyx/demyx)
[![Docker Client](https://img.shields.io/badge/docker_client-v19.03.14-informational?style=flat&color=blue)](https://hub.docker.com/r/demyx/demyx)
[![Buy Me A Coffee](https://img.shields.io/badge/buy_me_coffee-$5-informational?style=flat&color=blue)](https://www.buymeacoffee.com/VXqkQK5tb)
[![Become a Patron!](https://img.shields.io/badge/become%20a%20patron-$5-informational?style=flat&color=blue)](https://www.patreon.com/bePatron?u=23406156)

### Features
- Everything is in containers
- SSL turned on by default
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
- CentOS/Fedora/RHEL requires [selinux-dockersock](https://github.com/dpw/selinux-dockersock) or similar fix

### Tested Distros (x64)
- Alpine 3.1x
- Debian 10.x
- Ubuntu 18.04, 19.10, 20.04
- CentOS 7.6 (Probably works on Fedora and RHEL)

### Install
```
bash -c "$(curl -sL https://demyx.sh/install)"
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
This is a helper script that gets installed on the host and configuration file is installed at `~/.demyx`. It wraps docker exec commands into the demyx container. It also restarts and removes the main demyx containers. See demyx host help for more info.

demyx host help
```
demyx host <args>          Chroot into the demyx container
           all             Targets both demyx and demyx_socket container, works with remove and restart
           config          Edit Demyx config on the host (~/.demyx)
           help            Demyx helper help menu
           remove|rm       Stops and removes demyx container
           restart|rs      Stops, removes, and starts demyx container
           shell           Run commands into demyx container from the host, leave blank to open a shell
           update          List available updates
           upgrade         Upgrade the demyx stack
```

### Commands
```
demyx <arg>           Main demyx command
      backup          Back up an app
      compose         Accepts all docker-compose arguments
      config          Modifies an app's configuration
      cp              Wrapper for docker cp
      cron            Execute demyx cron
      edit            Opens nano to edit .env files
      exec            Accepts all docker exec arguments
      host            Command only available on the host OS, for more info: demyx host help
      healthcheck     Checks if WordPress apps are up
      info            Shows an app's .env and filter output
      list            List all apps
      log             Show or follow demyx.log
      maldet          Linux Malware Detect
      monitor         For auto scaling purposes
      motd            Message of the day
      pull            Pull one or all demyx images from Docker hub
      refresh         Refresh env and yml files of an app
      restore         Restore an app
      rm              Removes an app and its volumes
      run             Creates a new app
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
# Edit demyx environment variables and set DEMYX_TELEMETRY=false
demyx host edit
```

### Resources
- [ctop](https://ctop.sh) - htop but for containers!
- [VirtuBox](https://github.com/VirtuBox/ubuntu-nginx-web-server) - Borrowed configs for NGINX and PHP
- [EasyEngine](https://easyengine.io/) - Using their nginx helper plugin

### Updates & Support
[![Code Size](https://img.shields.io/github/languages/code-size/demyxco/demyx?style=flat&color=blue)](https://github.com/demyxco/demyx)
[![Repository Size](https://img.shields.io/github/repo-size/demyxco/demyx?style=flat&color=blue)](https://github.com/demyxco/demyx)
[![Watches](https://img.shields.io/github/watchers/demyxco/demyx?style=flat&color=blue)](https://github.com/demyxco/demyx)
[![Stars](https://img.shields.io/github/stars/demyxco/demyx?style=flat&color=blue)](https://github.com/demyxco/demyx)
[![Forks](https://img.shields.io/github/forks/demyxco/demyx?style=flat&color=blue)](https://github.com/demyxco/demyx)

- Auto built weekly on Saturdays (America/Los_Angeles)
- Rolling release updates
- For support: [#demyx](https://webchat.freenode.net/?channel=#demyx)
