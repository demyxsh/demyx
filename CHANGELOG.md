# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.5.1] - 2023-09-28
### Fixes
- Add missing command to recreate all apps when doing an upgrade [495a908](https://github.com/demyxsh/demyx/commit/495a90875807606372e6e856045020391cabaf15)
- Remove tag due to errors when pulling, users can manually enter tag version [b85df64](https://github.com/demyxsh/demyx/commit/b85df64506a493814fd8de78ca82f2b16cf1dec7)
- Exit if there's no apps installed, causing notifications to fire off when there's no error [75c5563](https://github.com/demyxsh/demyx/commit/75c556357c9b92cf69987418eef745843db92fd7)
- Remove variable causing cache to not work properly on first run [809ff8d](https://github.com/demyxsh/demyx/commit/809ff8dae0015b79456a083a28cbec7229850c9c)

## [1.5.0] - 2023-09-26
### New
- All Demyx app stacks now supports Redis, either by `demyx run` or `demyx config` [08b6589](https://github.com/demyxsh/demyx/commit/08b65899ba34c06d4ef46c384edce7d5f3924420)
- New flag `--whitelist` for `demyx run` [c093346](https://github.com/demyxsh/demyx/commit/c0933462e54ccc42bf64d1c9b7841871dc974fa9)
- Host helper script can now print Demyx environment variables [bc78886](https://github.com/demyxsh/demyx/commit/bc7888600a65bbd4ffd16cf6b77c3a72f6245a05)
- Debugger mode (breaks demyx, use with caution) [3aa8af3](https://github.com/demyxsh/demyx/commit/3aa8af3afe7a7e8165f64fd11a8669256dd0c70b)
- Automatically adjust php-fpm values based on container memory [93cde6e](https://github.com/demyxsh/demyx/commit/93cde6e1e79588b87cdc2a1b0e8723e4032815a6)

### Fixes
- Fix www issues for Traefik labels [bb090cc](https://github.com/demyxsh/demyx/commit/bb090ccf3318bcb57634d55d814bb66a5c3d40d7)
- Fix cloning issue [344b0bd](https://github.com/demyxsh/demyx/commit/344b0bdf1ed3d1e99e3c6130e184b76fdd145b3a)
- Prevent file not found error [7768c06](https://github.com/demyxsh/demyx/commit/7768c069e8781e31c2d77589a6989e66d5b6a692)

### Changes
- Remove linebreak [c613013](https://github.com/demyxsh/demyx/commit/c613013bae135c4f54e26efd6592e0737bd56e91)
- Use values from `demyx_app_env` [280a7d7](https://github.com/demyxsh/demyx/commit/280a7d7a946949b665d28d42d980d1d0ff2d2643)
- Make sure to disable docker-compose binary for non-root user [ef59bf6](https://github.com/demyxsh/demyx/commit/ef59bf64aaaa41915cd5cbbe6dd6e054b64556f5)
- Reverting change [a97c853](https://github.com/demyxsh/demyx/commit/a97c8537fd7d52af6501003adad537dc6d5e28cb)

## [1.4.0] - 2023-09-19
### Highlights
  - The whole script is now in masochist mode: set -euo pipefail
  - Refactored 99% of functions using localize variables and internal functions
  - HUGE performance gains and tons of bug fixes
  - SSL has been disabled by default to prevent rate limiting from Lets Encrypt when DNS hasn't been setup properly
  - shellcheck approved (mostly)
  - Demyx image now has docker-compose installed
  - Separate log files for cron and error events
  - Error events will now show you what commands failed and its stdout (if any)
  - Example callback script now supports error reporting by webhooks
  - `demyx exec` defaults to bash if no argument is passed
  - Upgrading will now remove old Demyx images
  - All PHP-based stacks will now run PHP8 by default
  - Functions will now follow a code structure/template
  - Various event notifications by email (ssmtp) or webhook through Matrix
  - Several new environment variables for more control
  - Functions/commands will now go through a main function that checks for errors
  - Several flags are now 1 letter

### Added
- Entrypoint script
- SMTP script

### Changed
Backup
- All loop will skip to the next iteration if there are errors
- Temporary files are stored in the new DEMYX_TMP path
- New function to only backup the database
- New function to display each app's backups with total or per file size 

Bins
- Moved various commands from other scripts to the entrypoint script
- Skeletons are now generated in said entrypoint script
- Rename apps with www
- Move main demyx script to bin directory
- Generate main .env file in the demyx-yml script

Compose
- Flags to target specific containers (db/nginx/wp)

Config
- PHP/LSPHP versions can now switch between 8 and 8.1
- Convert/revert an app's www. prefix in url
- Removed unneeded flags
- SFTP flag will now output username/password instead

Cron
- Added every five minute cron function
- Custom callback scripts for daily, every 5 minute, hourly, every minute, every 6 hours, and weekly
- Pinging home will include demyx version and nothing else
- Healthcheck functions are placed in the daily and five minute functions

Dockerfile
- Add various environment variables
- Packages: apache2-utils, docker-compose, logrotate, and ssmtp
- Pre-install core demyx directories
- Every five minute cron
- Build time environment variable: DEMYX_BUILD

Edit
- When editing an app's .env file, use -r flag to refresh its config files

Env
- Moved several environment variables to the refreshable section

Exec
- Targeting db will now use the -d flag
- Targeting nginx will now use the -n flag

Global
- Major overhaul of several functions and added new ones too for internal use
- Better error handling and logging
- New function for email/webhook notifications
- Each script will now source specific scripts
- Tables have been replaced to a simpler output

Healthcheck
- Checks if an app's containers are down, disk usage, and cpu load
- Notifications are sent by emails or matrix webhooks
- No more restarting containers automatically

Help
- Update help menu since some commands were removed

Host
- The .env file is now generated through the demyx-yml script
- Removed install prompts
- Ctop will be using its official image
- When a new version of MariaDB is available, it will backup and restore the app's database only
- Remove dangling images after an upgrade
- Notifies users when there's an error
- MOTD commands will automatically be inserted in .bashrc/.zshrc

Info
- New flag to grep env variables: --env
- The -l flag will output login credentials and wp-cli login link
- Reduced the args for now
- Output of app's environment variables are now outputted via column command
- System info will now build date and server IP address

Install
- Only pull the bare minimum of images to get demyx started right away
- Pinging will include demyx version and nothing else

Logs
- Demyx now has separate logs for cron, main, error
- See cron logs from WP containers
- Display docker's logging on specific containers
- Log rotating has been replaced by internal logrotate

Motd
- Updated chat link
- Included docs link
- Notify new users to fix 2 environment variables for proper SSL provisioning

Name
- Sometimes the name generator outputs null, that has been fixed

Pull
- ctop is included in the pull list
- Checking if an image exist will now use a cached file

Refresh
- Replaced a few flags

Restore
- Removed some flags and added useful ones
- Database only restoration

Run
- Specify PHP/LSPHP versions
- For www only domains, there's a flag for that

Rm
- Removed the --wp flag

Run
- Removed several flags
- Users can now set PHP/LSPHP versions
- Added the --www flag
- Creating an app has been simplified since most of the work is done in the WP container
- After an app is created, output now shows login link and friends

SMTP
- Generates email template for email notifications via ssmtp
- Outbound only

Update
- Flag to see if there's any updates
- Merged update functions from global
- New output of update list

Utility
- Removed all flags but one
- The removed flags have been moved to top level

Wp
- Looping wp-cli commands to all apps will check for error first
- Checks for wp binary before executing to prevent breakage

Yml
- Merged the individual yml scripts into one
- Other services like sftp, pma, etc. are generated here

### Removed
- Merged changelogs into one
- Most scripts in bin directory
- Removed the following scripts: list, maldet, monitor, plugin, table, and yml-*
- Skeletons directory

## [1.3.1] - 2021-07-08
### Changed
- Alphabetize labels [ab35d1d](https://github.com/demyxco/demyx/commit/ab35d1d409f1ffa8ba18bc93e12e8dd9fcbdfb6a)
- Use two different middlewares for http and https [9c433e9](https://github.com/demyxco/demyx/commit/9c433e9230106846b2143062718712bfa35159f4)
- Update IRC link in MOTD [4b98703](https://github.com/demyxco/demyx/commit/4b9870350028a4c7bbb128c9dd400a13c881c1ba)

## [1.3.0] - 2021-06-04
### Changed
- Remove if statements [4668e77](https://github.com/demyxco/demyx/commit/4668e773f726982ce5098f3a49d87cff21e5da47)
- Remove while loop [1b09cb3](https://github.com/demyxco/demyx/commit/1b09cb373814bd17346891aa43913918db449fe5)
- Add extra conditional [4e1224a](https://github.com/demyxco/demyx/commit/4e1224a8b2037476a08cd9e5668d4b8663964258)
- Update code-server images when pulling [6c3d598](https://github.com/demyxco/demyx/commit/6c3d598561ba09a984a36c342de7e088f67db94e)
- Append :latest tag to docker images [9b68ba8](https://github.com/demyxco/demyx/commit/9b68ba8e18d50c56b2fd0922ce7c7824be405d9f)
- New flag: demyx config --fix-innodb [0f066fb](https://github.com/demyxco/demyx/commit/0f066fbb08c6b7a67ee59213b38d485765cb3379)
- Check DB container after compose with new flag [50e6d40](https://github.com/demyxco/demyx/commit/50e6d40ed2d44ec5599c36064fed3105d0538868)
- Make sure all HTTP requests are redirected to HTTPS for API URL [67a78fe](https://github.com/demyxco/demyx/commit/67a78feaf7f18df132ebaec2af4c0389a6a3152d)
- Remove update command on init [fb80a14](https://github.com/demyxco/demyx/commit/fb80a14b692fbcbefed429b95f9bc2ec86f0b90f)
- Use new flag to check if DB is running or not [5cb3aab](https://github.com/demyxco/demyx/commit/5cb3aab19ec470fa8707d99b220e65bd599d7794)
- Remove -f flag [382098b](https://github.com/demyxco/demyx/commit/382098b549b06e8ca35d4f19a88130690afaf025)

## [1.2.4] - 2021-05-10
### Changed
- function/global.sh
  - Add 2>&1 so error text can be piped
  - Add head command to demyx/docker-socket-proxy
  - Update demyx/wordpress path for version number
  - Hardcode lsphp version for demyx/openlitespeed
  - Remove old images list to prevent duplicates
  - Add an OR conditional to check if wp directory exists
- function/run.sh
  - Make sure domain isn't a flag
- function/wp.sh
  - Pass the PAGER environment variable when wp help is ran
- host.sh
  - Check for default editor first then use local editors if not found

## [1.2.3] - 2020-09-08
### Changed
- Fixed an issue where cloning an app wasn't working properly

## [1.2.2] - 2020-08-11
### Added
- Fixed: old backups weren't deleted due to find command using wrong environment variable

## [1.2.1] - 2020-07-19
### Changed
- Fixed: Refreshing an app while in development loses the value of DEMYX_CONFIG_DEV_BASE_PATH

## [1.2.0] - 2020-07-09
### Added

- Add demyx/code-server:browse when installing demyx
- demyx update now has a force flag

### Changed
- Update "upgrade" command for the demyx host script
- Update help menu for demyx pull
- Update help menu for demyx update
- Reworked demyx update functions

### Removed
- Don't pull demyx/browsersync when installing demyx

## [1.1.3] - 2020-07-05
### Changed
- WP container needs to run first then nginx
- Remove some changes in 1.1.2 to reflect changes in the wordpress/openlitespeed images
- Remove duplicate demyx refresh when creating a WP app

## [1.1.2] - 2020-07-03
### Changed
- function/config.sh
  - Restart WP container after using --auth-wp
- function/run.sh
  - Fixed a bug when cloning a bedrock stack
  - Misc updates

## [1.1.1] - 2020-06-22
### Changed
- Recreate nginx container when turning cache on/off
- Remove rule for subdomains

## [1.1.0] - 2020-06-21
### Changed
- Alphabetized yml keys and update redirect labels
- IP whitelisting now requires one flag
- Set code-server image to browse tag when doing update checks
- Remove the -L flag when doing healthchecks
- Update host rules when using www in domain names
- Remove CDN variable from demyx info
- Add code-server dev password in demyx info

## [1.0.1] - 2020-06-16
### Changed
- Fixed wrong variable for DEMYX_LOCAL_VERSION when generating update local cache
- Fixed command when generating variable for DEMYX_LOCAL_CODE_VERSION
- Update warning message when using demyx config <app> --sftp

## [1.0.0] - 2020-06-15
### Added
- bin/demyx-migrate.sh
  - Migrate old stack configs to host config
- bin/demyx-reset.sh
  - Script is used to reset permissions/ownership (might be temporary)
- function/refresh.sh
  - Script to replace the app config/yml regeneration from function/config.sh
- skel
  - Used by /bin/demyx-init.sh for installing demyx
- host.sh
  - Main script on the host that executes docker commands to demyx container
- New flags for demyx run and demyx config: --whitelist, --whitelist-type
- Add changelog directory to repo and each version's changelog will be in its own .md file

### Changed
- bin/demyx-init.sh
  - Doesn't run as root anymore
  - Migrated /bin/demyx-api.sh code
  - Clean out unused code
- bin/demyx-skel.sh
  - Copy the skel directory when installing demyx
  - Symlink /var/log/demyx to /demyx/log
- bin/demyx-yml.sh
  - Remove unused code
  - API labels will now redirect http to https
  - Updated template for main docker-compose.yml
  - Generate basic auth outside of the if statement
- function/compose.sh
  - Uses demyx socket as the docker host now
- function/config.sh
  - Removed --cdn, --refresh, and --no-backup flags
  - Removed related codes from flags above
  - Update variable names
  - --expose flag now fetches server IP from environment variable
  - Migrated refresh code to its own top level command
- function/cron.sh
  - Remove unused code
  - Update variable names
- function/edit.sh
  - Replaced stack with traefik
- function/env.sh
  - Remove cdn variable
  - Remove unused code
  - Add 3 environment variables for php
- function/global.sh
  - Remove unused code/functions
  - Update demyx_update_image function
- function/healthcheck.sh
  - Checks for a file before running healthcheck scripts
  - Getting container HTTP status using curl (again...I know I know)
- function/help.sh
  - Update help menu for demyx config
  - Update help menu for demyx info
  - Remove help menu for demyx install
  - Add help menu for demyx refresh
  - Update help menu for demyx run
  - Remove help menu for demyx stack
  - Update help menu for demyx update
  - Update help menu for demyx help
- function/info.sh
  - Remove unused code
  - Update sed command for WP apps
- function/list.sh
  - Remove unused code
- function/monitor.sh
  - Remove unused code
  - Update monitor variable
- function/motd.sh
  - Remove unused code
  - Added changelog url
- function/restore.sh
  - Add force flag when removing backup database
- function/run.sh
  - Remove --cdn flag and related code
  - Update environment variables
  - Update refresh commands
- function/update.sh
  - Added command to show updates: demyx update show
  - Added echo messages when executing update functions
  - Added command to update the demyx helper script on the host
- function/yml-bedrock-dev.sh
  - Add 3 new environment variables for php
- function/yml-bedrock.sh
  - Add 3 new environment variables for php
- function/yml-nginx-php-dev.sh
  - Add 3 new environment variables for php
- function/yml-nginx-php.sh
  - Add 3 new environment variables for php
- function/yml.sh
  - Put CA resolver logic outside of functions
  - Use environment variable to get server IP
  - Add function to generate code-server yml
  - Migrate demyx_stack_yml to demyx_traefik_yml
- .dockerignore
  - Include host.sh and skel directory
- demyx.sh
  - Remove source command
  - Remove install command
  - Add refresh command
  - Remove stack command
  - Add version command
- Dockerfile
  - Remove DEMYX_BUILD
  - Import majority of .config variables to ENV
  - Remove packages: dumb-init, git, htop, openssh, rsync, util-linux, and zsh
  - Remove code related to the removed packages
  - Various misc updates
- install.sh
  - Remove sudo/docker checks as it will error if either is missing
  - Remove skip checks conditional
  - Migrated prompts to host.sh
  - Install demyx helper script using docker run

### Removed
- bin/demyx-api.sh
- bin/demyx-crond.sh
- bin/demyx-dev.sh
- bin/demyx-prod.sh
- bin/demyx-ssh.sh
- chroot.sh
- function/install.sh
- .config

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

[1.5.1]: https://github.com/demyxsh/demyx/compare/1.5.0...1.5.1
[1.5.0]: https://github.com/demyxsh/demyx/compare/1.4.0...1.5.0
[1.4.0]: https://github.com/demyxsh/demyx/compare/1.3.1...1.4.0
[1.3.1]: https://github.com/demyxsh/demyx/compare/1.3.0...1.3.1
[1.3.0]: https://github.com/demyxsh/demyx/compare/1.2.4...1.3.0
[1.2.4]: https://github.com/demyxsh/demyx/compare/1.2.3...1.2.4
[1.2.3]: https://github.com/demyxsh/demyx/compare/1.2.2...1.2.3
[1.2.2]: https://github.com/demyxsh/demyx/compare/1.2.1...1.2.2
[1.2.1]: https://github.com/demyxsh/demyx/compare/1.2.0...1.2.1
[1.2.0]: https://github.com/demyxsh/demyx/compare/1.1.2...1.2.0
[1.1.2]: https://github.com/demyxsh/demyx/compare/1.1.1...1.1.2
[1.1.0]: https://github.com/demyxsh/demyx/compare/1.0.1...1.1.0
[1.0.1]: https://github.com/demyxsh/demyx/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/demyxsh/demyx/releases/tag/1.0.0
