# CHANGELOG

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
