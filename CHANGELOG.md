# CHANGELOG

## 2020-05-14
### Changed
- docker exec needs to be run as root when checking for updated image cache in demyx helper script

## 2020-05-13
### Changed
- Fixed Traefik labels where host rules weren't being generated in the yml when creating a site without SSL

## 2020-05-07
### Changed
- Set root as the owner of all executable scripts/binaries in /usr/local/bin

## 2020-05-05
### Changed
- Demyx helper script now pulls other code-server images if it exists first

## 2020-05-03
### Changed
- Echo out message when restarting PHP and use docker exec directly
- Update message when restarting NGINX

## 2020-04-22
### Changed
- Make sure DEMYX_RUN_CLOUDFLARE env uses variable from run.sh

## 2020-04-21
### Added
- Hourly cron for WP cron events
### Changed
- Use a better conditial when detecting subdomains for Traefik labels
- Include cron event name in echos

## 2020-04-20
### Added
- demyx config --cf was missing stack environment variables
### Changed
- Replace brackets with parenthesis when doing arithmetics
- Only add www host rule when domain is a TLD

## 2020-04-19
### Added
- Cloudflare as the second certificate resolver
- New flag for demyx run: --cf and make sure to check for Cloudflare email and key
- Add DEMYX_APP_CLOUDFLARE to env.sh
- New function to output correct challenge for Traefik: demyx_certificate_challenge

### Changed
- Use wget instead of curl for healthchecks
- Add demyx_update_image to weekly cron
- Pull additional code-server tags when code-server updates
- Use Cloudflare if email and keys are present for main .yml file
- Current sites can now switch between resolvers
- Merge HTTP and Cloudflare resolvers for Traefik yml
- Update help menu for demyx run
- WP apps utilize demyx_certificate_challenge in yml generation
- Check if Cloudflare variables exists first when using demyx config
- Make demyx helper remove all update files before rebuilding cache
- Bump lsphp max connections to 20000 for OLS stack

### Removed
- Remove tag for code-server when generating update image list

## 2020-04-18
### Changed
- Set shebang to dumb-init
- Move commands to a different file when sourcing zsh symlink
- Missing -v flag for update commands

## 2020-04-17
### Added
- --refresh can now use --force to force refresh non-essential variables
- New commands to let users know of updates: demyx_update_remote, demyx_update_local, and demyx_update_count
- demyx_motd_update_check lets users know if updates are available in MOTD
- Add update sub command to demyx list
- Add --json to demyx list help menu
- chroot.sh
    - New command: upgrade
### Changed
- Prefix sudo when reloading nginx
- Moved global functions to the top
- Rearrange environment variables from essentials to non-essentials
- Disable auto rate limit for now
- Prevent down containers from going up when doing loops
- Suppress update message when update count is 0
- Fix symlink error message
- Fix broken healthcheck
- Update install images
- Echo out code-server:wp tag instead
- Add conditionals to MOTD
- Use docker run instead of exec when updating local update cache
- Only output MOTD update message when all conditionals are met
- Use jq to get Bedrock version
- Use curly brackets for OLS variable
- MOTD stack install message using wrong command
- Move stack refresh command to demyx-init.sh
- Replace MOTD update check commands
- Remove unused code and rearrange code
- Use conditional when using cat
- chroot.sh
    - demyx update now shows updates if available
    - Show an update notice if available
    - Remove carriage return
    - Missing user when pulling images
    - Output messages to user and update docker command
### Removed
- demyx_motd_update_wp_yml
- Code for demyx repository was skipped
- Remove commented code
- init.sh
- Remove init.sh from main script
- Extra flags in healthcheck curl


## 2020-04-15
### Added
### Changed
- Restart php-fpm without restarting container
- Set browsersync watch files to themes
- demyx_dev_password sets a fixed password for code-server
- WP auto update checks for stack type now
- Use absolute path for composer update
- New variable DEMYX_APP_DEV_PASSWORD for code-server
- Update default variables for env.sh
- Switch to nginx-php as the default stack
- Add hostname key and use app ID as part of volume name
### Removed
