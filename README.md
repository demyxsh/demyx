# Demyx
A simple CLI wrapper for Docker to automate WordPress installations written in bash. Traefik for reverse proxy with Lets Encrypt SSL. WordPress sites are powered by NGINX, PHP, and MariaDB.

Demyx will be following a rolling release model, meaning there is only one version (master branch, no tags) to ensure you always have the latest version.

<p align="center">
    <img src="https://i.imgur.com/WqMCNEd.gif">
</p>

### Stack
ALPINE | NGINX | MARIADB | PHP | WORDPRESS
------------- | ------------- | ------------- | ------------- | -------------
3.9.3 | 1.16.0 | 10.3.13 | 7.3.5 | 5.1.1

### Requirements
* Ubuntu 16.04/18.04, Debian 9.7
* Dedicated/KVM server
* Port 80 and 443 must be open
* Primary domain must be pointed to server's IP and must have a wildcard CNAME subdomain

### Install
```
wget https://raw.githubusercontent.com/demyxco/demyx/master/install.sh && bash install.sh
```

### Getting Started
```
demyx wp --dom=domain.tld --run --cdn --cache
```

### Commands
demyx -h
```
If you modified any of the files (.conf/.ini/.yml/etc) then delete the first comment at the top of the file(s)

-df                 Wrapper for docker system df
                    Example: demyx -df

--dom               Flag needed to run other Docker images
                    Example: demyx --dom=domain.tld --install=gitea

--email             Flag needed for Rocket.Chat
                    Example: demyx --dom=domain.tld --email=info@domain.tld --install=rocketchat

-f, --force         Forces an update
                    Example: demyx --force --update, demyx -f -u

--install           Install Rocket.Chat and Gitea

-p, --prune         Wrapper for docker system prune && docker volume prune
                    Example: demyx -p, demyx --prune

-t, --top           Runs ctop (htop for containers)
                    Example: demyx -t, demyx --top
```

demyx stack -h
```
--action            Actions: up, down, restart, logs, and other available docker-compose commands
                    Example: demyx stack --up, demyx stack --service=traefik --action=restart

--down              Shorthand for docker-compose down
                    Example: demyx stack --service=traefik --down, demyx stack --down

--refresh           Refreshes the stack's .env and .yml
                    Example: demyx stack --refresh

--restart           Shorthand for docker-compose restart
                    Example: demyx stack --service=traefik --restart, demyx stack --restart

--up                Shorthand for docker-compose up -d
                    Example: demyx stack --service=traefik --up, demyx stack --up

--service           Services: traefik, ouroboros, logrotate
```

demyx logs -h
```
-c, --clear         Clear the logs
                    Example: demyx logs -c, demyx logs --clear

-f, --follow        Shorthand for tail -f
                    Example: demyx logs -f, --follow
```

demyx wp -h
```
--action            Actions: up, down, restart, logs, and other available docker-compose commands
                    Example: demyx wp --dom=domain.tld --service=wp --action=up

--all               Selects all sites with some flags
                    Example: demyx wp --backup --all

--admin_user        Override the auto generated admin username in --run
                    Example: demyx wp --dom=domain.tld --run --admin_user=demo

--admin_pass        Override the auto generated admin username in --run
                    Example: demyx wp --dom=domain.tld --run --admin_pass=demo

--admin_email       Override the auto generated admin email in --run
                    Example: demyx wp --dom=domain.tld --run --admin_email=info@domain.tld

--backup            Backs up a site to /srv/demyx/backup
                    Example: demyx wp --backup=domain.tld, demyx wp --dom=domain.tld --backup

--cache             Enables FastCGI cache with WordPress plugin helper
                    Example: demyx wp --dom=domain.tld --run --cache

--cdn               Auto install CDN by Staticaly.com
                    Example: demyx wp --dom=domain.tld --run --cdn

--cli               Run commands to containers: wp, db
                    Example: demyx wp --dom=domain.tld --cli'ls -al'

--clone             Clones a site
                    Example: demyx wp --dom=new-domain.tld --clone=old-domain.tld --ssl

--dom, --domain     Primary flag to target your sites
                    Example: demyx wp --dom=domain.tld --flag

--dev               Creates a development environment: BrowserSync & UI, phpMyAdmin, SSH, autover WP plugin, and cache off
                    Example: demyx wp --dom=domain.tld --dev, demyx wp --dom=domain.tld --dev=off

--down              Shorthand for docker-compose down
                    Example: demyx wp --down=domain.tld, demyx wp --dom=domain.tld --down

--env               Shows all environment variables for a given site
                    Example: demyx wp --env=domain.tld, demyx wp --dom=domain.tld --env

--force             Force an override, only applies to --refresh for now
                    Example: demyx wp --refresh --all --force, demyx wp --dom=domain.tld --refresh --force

--info              Get detailed info about a site
                    Example: demyx wp --dom=domain.tld --info

--list              List all WordPress sites
                    Example: demyx wp --list

--monitor           Cron flag for auto scaling containers

--no-restart        Prevents a container from restarting when used with some flags
                    Example: demyx wp --dom=domain.tld --run --dev --no-restart

--rate-limit        Enable/disable rate limit requests for NGINX
                    Example: demyx wp --dom=domain.tld --rate-limit, demyx wp --dom=domain.tld --rate-limit=off

--refresh           Regenerate all config files for a site; use with caution
                    Example: demyx wp --refresh=domain.tld --ssl, demyx wp --dom=domain.tld --refresh --ssl

--remove            Removes a site
                    Example: demyx wp --rm=domain.tld, demyx wp --dom=domain.tld --rm, demyx wp --rm --all

--restart           Shorthand for --service that loops through all the sites
                    Example: demyx wp --restart=wp, demyx wp --restart=nginx-php

--restore           Restore a site's backup
                    Example: demyx wp --restore=domain.tld, demyx wp --dom=domain.tld --restore

--run               Create a new site
                    Example: demyx wp --run=domain.tld --ssl, demyx wp --dom=domain.tld --run --ssl

--scale             Scale a site's container
                    Example: demyx wp --dom=domain.tld --scale=3, demyx wp --dom=domain.tld --service=wp --scale=3

--service           Selects a service when used with --action
                    Available services: wp, db, nginx, php, nginx-php
                    Example: demyx wp --dom=domain.tld --action=restart --service=nginx-php

--shell             Opens a site's shell for the following containers: wp, db, ssh, bs (BrowserSync)
                    Example: demyx wp --dom=domain.tld --shell, demyx wp --dom=domain.tld --shell=db

--ssl               Enables SSL for your domain, provided by Lets Encrypt
                    Example: demyx wp --dom=domain.tld --ssl, demyx wp --dom=domain.tld --ssl=off

--up                Shorthand for docker-compose up -d
                    Example: demyx wp --up=domain.tld, demyx wp --dom=domain.tld --up

--update            This flag only updates old file structure
                    Example: demyx wp --dom=domain.tld --update=structure --ssl, demyx wp --update=structure --all --ssl

--wpcli             Send wp-cli commands to a site
                    Example: demyx wp --dom=domain.tld --wpcli='user list --all'
```

### Other Images
You can run other Docker images alongside the WordPress sites. Currently, only Rocket.Chat and Gitea are supported for automatic installs but you may use them as a base to proxy other non-demyx containers.

```
# Rocket.Chat
demyx --dom=domain.tld --email=info@domain.tld --install=rocketchat
```

```
# Gitea
# When running the command, it will create a new user called git and automatically setup SSH passthrough.
demyx --dom=domain.tld --install=gitea
```

### Resources
* [Demyx](https://hub.docker.com/u/demyx) - NGINX, PHP, MariaDB, Logrotate, Utilities
* [Traefik](https://hub.docker.com/_/traefik) - Reverse Proxy with Lets Encrypt SSL
* [ouroboros](https://hub.docker.com/r/pyouroboros/ouroboros) - Auto pull new images from Docker Hub
* [WordPress](https://hub.docker.com/_/wordpress) - Using their `wordpress:cli` image
* [phpMyAdmin](https://hub.docker.com/r/phpmyadmin/phpmyadmin) - Web GUI used with Demyx stack
* [ctop](https://ctop.sh) - htop but for containers!
* [VirtuBox](https://github.com/VirtuBox/ubuntu-nginx-web-server) - Borrowed configs for NGINX and PHP
* [EasyEngine](https://easyengine.io/) - Using their nginx helper plugin
* [Staticaly](https://www.staticaly.com/) - Free CDN setup