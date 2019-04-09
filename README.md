# Demyx
A simple CLI wrapper for Docker to automate WordPress installations written in bash. Traefik for reverse proxy with Lets Encrypt SSL. WordPress sites are powered by NGINX, PHP, and MariaDB.

Demyx will be following a rolling release model, meaning there is only one version (master branch, no tags) to ensure you always have the latest version.

![https://i.imgur.com/6GDrTCT.gif](https://i.imgur.com/6GDrTCT.gif)

# Requirements
* Ubuntu 18.04 (for now)
* Dedicated/KVM server
* Port 80 and 443 must be open
* Primary domain must be pointed to server's IP and must have a wildcard CNAME subdomain

# Install
```
wget https://raw.githubusercontent.com/demyxco/demyx/master/install.sh && bash install.sh
```

# Getting Started
```
demyx wp --dom=domain.tld --run --ssl
```

# Commands
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

--restart           Shorthand for docker-compose restart
                    Example: demyx stack --service=traefik --restart, demyx stack --restart

--up                Shorthand for docker-compose up -d
                    Example: demyx stack --service=traefik --up, demyx stack --up

--service           Services: traefik, watchtower, logrotate
```

demyx wp -h
```
--action            Actions: up, down, restart, logs, and other available docker-compose commands
                    Example: demyx wp --dom=domain.tld --service=wp --action=up

--all               Selects all sites with some flags
                    Example: demyx wp --backup --all

--backup            Backs up a site to /srv/demyx/backup
                    Example: demyx wp --backup=domain.tld, demyx wp --dom=domain.tld --backup

--cli               Run commands to containers: wp, db
                    Example: demyx wp --dom=domain.tld --cli'ls -al'

--clone             Clones a site
                    Example: demyx wp --dom=new-domain.tld --clone=old-domain.tld --ssl

--dom, --domain     Primary flag to target your sites
                    Example: demyx wp --dom=domain.tld --flag

--dev               Editing files from host to container will reflect on page reload
                    Example: demyx wp --dom=domain.tld --dev, demyx wp --dom=domain.tld --dev=off

--down              Shorthand for docker-compose down
                    Example: demyx wp --down=domain.tld, demyx wp --dom=domain.tld --down

--du                Get a site's directory total size
                    Example: demyx wp --down=domain.tld --du, demyx wp --down=domain.tld --du=wp, demyx wp --down=domain.tld --du=db

--env               Shows all environment variables for a given site
                    Example: demyx wp --env=domain.tld, demyx wp --dom=domain.tld --env

--force             Force an override, only applies to --refresh for now
                    Example: demyx wp --refresh --all --force, demyx wp --dom=domain.tld --refresh --force

--import            Import a non demyx stack WordPress site, must be in a specific format
                    - Directory must be named domain.tld
                    - Archive must be in /srv/demyx/backup named domain.tld.tgz
                    - Database that will be imported must be named import.sql
                    Example: demyx wp --dom=domain.tld --import

--pma               Enable phpmyadmin: pma.prmary-domain.tld
                    Example: demyx wp --dom=domain.tld --pma, demyx wp --dom=domain.tld --pma=off

--refresh           Regenerate all config files for a site; use with caution
                    Example: demyx wp --refresh=domain.tld --ssl, demyx wp --dom=domain.tld --refresh --ssl

--remove            Removes a site
                    Example: demyx wp --rm=domain.tld, demyx wp --dom=domain.tld --rm, demyx wp --rm --all

--restart           Shorthand for docker-compose restart
                    Example: demyx wp --restart=domain.tld, demyx wp --dom=domain.tld --restart

--restore           Restore a site's backup
                    Example: demyx wp --restore=domain.tld, demyx wp --dom=domain.tld --restore

--run               Create a new site
                    Example: demyx wp --run=domain.tld --ssl, demyx wp --dom=domain.tld --run --ssl

--scale             Scale a site's container
                    Example: demyx wp --dom=domain.tld --service=wp --scale=3

--shell             Shell into a site's wp/db container
                    Example: demyx wp --dom=domain.tld --shell, demyx wp --dom=domain.tld --shell=db

--ssl               Enables SSL for your domain, provided by Lets Encrypt
                    Example: demyx wp --dom=domain.tld --ssl, demyx wp --dom=domain.tld --ssl=off

--up                Shorthand for docker-compose up -d
                    Example: demyx wp --up=domain.tld, demyx wp --dom=domain.tld --up

--wpcli             Send wp-cli commands to a site
                    Example: demyx wp --dom=domain.tld --wpcli='user list --all'
```

# Other Images
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

# Resources
* [Demyx](https://hub.docker.com/u/demyx) - NGINX, PHP, MariaDB, Logrotate, Utilities
* [Traefik](https://hub.docker.com/_/traefik) - Reverse Proxy with Lets Encrypt SSL
* [watchtower](https://hub.docker.com/r/v2tec/watchtower) - Auto pull new images from Docker Hub
* [WordPress](https://hub.docker.com/_/wordpress) - Using their `wordpress:cli` image
* [phpMyAdmin](https://hub.docker.com/r/phpmyadmin/phpmyadmin) - Web GUI used with Demyx stack
* [ctop](https://ctop.sh) - htop but for containers!
* [VirtuBox](https://github.com/VirtuBox/ubuntu-nginx-web-server) - Borrowed configs for NGINX and PHP