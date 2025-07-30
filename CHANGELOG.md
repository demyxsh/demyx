# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.9.0] - 2025-07-28

### Added
- New app environment variable to set when fastcgi cache will expire `DEMYX_APP_CACHE_INACTIVE` [2a554a2](https://github.com/demyxsh/demyx/commit/2a554a2ef945c5ea1b27772e934f4b59a266bf4c)
- New flag `demyx config --maintenance` to activate WP's core maintenance mode [5cbe9c7](https://github.com/demyxsh/demyx/commit/5cbe9c773c91af1c286508630ea3e8a2611e0db4)
- New flag `demyx config --convert` to convert container and volume names to the new format [983c243](https://github.com/demyxsh/demyx/commit/983c243c956c0de1353f24b5d82a49d663efb33d)
- New flag `demyx config -f` to skip confirmation [04f03de](https://github.com/demyxsh/demyx/commit/04f03de28465d5d0e1e9f4f1d68e6e49f464caa4)
- New argument `demyx exec code` to open a shell for the Browser container [23814b4](https://github.com/demyxsh/demyx/commit/23814b465b5dbc5aa0524fac8496b33d5851af3b)
- New argument `demyx exec traefik` to open a shell for the Traefik container [cd7a87c](https://github.com/demyxsh/demyx/commit/cd7a87ca55e89d90f45561f7d36d945f718f759e)
- New argument `demyx backup traefik` to backup acme.json and docker-compose.yml files [22318bb](https://github.com/demyxsh/demyx/commit/22318bb99ab384e7868d79af17d0741687861666)
- New argument `demyx restore traefik` to restore acme.json and docker-compose.yml files [edf664a](https://github.com/demyxsh/demyx/commit/edf664ad9124a812a10880089bcb8a5d63d7df9f)
- New flag `demyx config <app> --php-average` [949163e](https://github.com/demyxsh/demyx/commit/949163ee76dbf17e2a07e399de0df3af5d7d4851)
- New commands to start up or bring down an app's containers [1ff5bd1](https://github.com/demyxsh/demyx/commit/1ff5bd18c03e59ac8fe3961ea630d6669566468d)
- New host command `demyx host up` [bbcc620](https://github.com/demyxsh/demyx/commit/bbcc620c7871c34a0eb0899fc69892787f3b7cf8)
- Add timeout for `demyx_app_login()` [f422b19](https://github.com/demyxsh/demyx/commit/f422b1931feb131b167d8051cbbe1e433bfd4e14)
- Add check for Traefik compose file in demyx_entrypoint_skeleton to refresh Traefik if missing [f7c7991](https://github.com/demyxsh/demyx/commit/f7c7991b3ade2f8ad93daad0d00f5544fe563e1a)

### Changed
- `demyx refresh` doesn't force recreate by default anymore [ab393da](https://github.com/demyxsh/demyx/commit/ab393da2c57fc5c21bf80e1e6a17eef689ed11c8)
- Enable http3/quic [22becfa](https://github.com/demyxsh/demyx/commit/22becfa8181d783954b96bd18756cd1797e8a73c)
- A+ in SSL grade [2209f4e](https://github.com/demyxsh/demyx/commit/2209f4e8f452577015d3c8fbaafde1c733a4f101)
- `demyx config --auth` will now take effect without restarting the nginx container [f57ac95](https://github.com/demyxsh/demyx/commit/f57ac954ac666f76df6429e7860513ecbccee534)
- `demyx config --auth-wp` will now take effect without restarting the nginx container [f245bbd](https://github.com/demyxsh/demyx/commit/f245bbd8712e440afd30e226a6a72a4ba65eb9d6)
- `demyx config --rate-limit` will now take effect without restarting the nginx container [8d8ad47](https://github.com/demyxsh/demyx/commit/8d8ad4733369593dfad5e5d3523ed7147f3aa7c0)
- `demyx config --whitelist` will now take effect without restarting the nginx container [7d9d615](https://github.com/demyxsh/demyx/commit/7d9d615b5e354246d03459011bf29dbae4a2d3eb)
- Browser's password auth can now be disabled [a32fd26](https://github.com/demyxsh/demyx/commit/a32fd2613c619b630eaed9a2e15a577862fffd8d)
- Update default php version to 8.2/8.3 [3e94e31](https://github.com/demyxsh/demyx/commit/3e94e3133d165c10a2a908f531da00f03a7c4fa6)
- Use dig to get server IP for better distro compatibility [7c0ba57](https://github.com/demyxsh/demyx/commit/7c0ba57bdf7870fc4d69f1d3ee4bad1008502ea0)
- `demyx backup` now uses rsync with backwards compatibility [3f6e8b9](https://github.com/demyxsh/demyx/commit/3f6e8b9e945a28ea90c748a09fe01b2ecc475046)
- `demyx restore` now uses rsync with backwards compatibility [24979e4](https://github.com/demyxsh/demyx/commit/24979e41c8c1a1641f1b5fc332619f9ca9eb4d97)
- Enhance demyx installation process by updating Docker run command to include volume mounts for demyx and Docker socket, and set environment variables for stable host mode. [5628d65](https://github.com/demyxsh/demyx/commit/5628d65e0c2fe382b7aa377fd49dede6080ed242)
- Disable data conversion in demyx_config_convert function with a custom error message. [d318237](https://github.com/demyxsh/demyx/commit/d318237ad654b187900b8486873f14009be9e6bf)

### Removed
- Remove `demyx_container_name_update()` in favor of hard coding the container names [30197cd](https://github.com/demyxsh/demyx/commit/30197cd243e27f91ab30b32ee78e0a3f4a86f434)
- Remove old logging code [63794cf](https://github.com/demyxsh/demyx/commit/63794cf81bd59fb2c2f79bdd0d0cda2b2d392608)
- Remove capitalize characters from ID generator [874a9f1](https://github.com/demyxsh/demyx/commit/874a9f149a712f536626237da56f9dca47bc2026)
- Remove cpu/mem restrictions [ae95253](https://github.com/demyxsh/demyx/commit/ae9525355623c793fdcc6366bec0496f1660e3fe)
- Remove `demyx_yml_nginx_basic_auth()` and `demyx_yml_nginx_whitelist()` [9167aa0](https://github.com/demyxsh/demyx/commit/9167aa058f452cf69f71cd73f7a1645e3d313382)
- Remove these flags: `--php-max-children --php-max-spare-servers --php-min-spare-servers --php-pm --php-process-idle-timeout --php-start-servers` [fd5fa74](https://github.com/demyxsh/demyx/commit/fd5fa7499b7dc16563e6de9d2bc770e0aa918ada)
- Remove `demyx config --php-pm-calc` [044767c](https://github.com/demyxsh/demyx/commit/044767c64fd8caf8bb1772b0041a45afbda72e16)
- Remove developer mode option from help output and add exit command in dev mode for demyx_host function. [394121e](https://github.com/demyxsh/demyx/commit/394121e34e8a370c269cbca3a6bfc8fae2048971)
- Refactor demyx_yml function by removing unused DEMYX_HOST_MODE assignment and deleting obsolete demyx_yml_env and demyx_yml_tag functions for cleaner code. [aa17557](https://github.com/demyxsh/demyx/commit/aa175570d2e909e02473f9c89336ba2b832963ea)

### Fixed
- Fix variable typo [efa2577](https://github.com/demyxsh/demyx/commit/efa25776e028700f340b689e14c4c428cb0eb95a)
- Fix the external volume not found error [ba4eca8](https://github.com/demyxsh/demyx/commit/ba4eca8627ec69b8c3a54c57e6162927dab08959)
- Fix typo [86d7dba](https://github.com/demyxsh/demyx/commit/86d7dba8e07d774a774aef792c3e1bd01b2d8b0f)
- Create demyx_user volume if it doesn't exist [a16ae5e](https://github.com/demyxsh/demyx/commit/a16ae5ec85ed1881534d6bceb37b66ecd66de925)
- Fix DEMYX_APP_WP_VOLUME assignment to use the correct container variable [5e6eb5a](https://github.com/demyxsh/demyx/commit/5e6eb5a596f41bbd5e7583ea896ee89e04ae913b)
- Fix demyx_host_upgrade to remove carriage return characters from version output for consistent version comparison. [b39e32c](https://github.com/demyxsh/demyx/commit/b39e32c157c1bb161d3bd94b536fde4899b85a39)

## [1.8.3] - 2024-04-08
### Upgrading
This version requries updating the host helper script first.
```
# Update the demyx image to the latest version
docker pull demyx/demyx

# Update the host helper script
docker run -t --rm \
    -v /usr/local/bin:/tmp \
    --user=root \
    --entrypoint=bash \
    demyx/demyx -c 'cp -f /etc/demyx/host.sh /tmp/demyx; chmod +x /tmp/demyx'

# Use the latest version of demyx
demyx host restart

# Finally upgrade
demyx host upgrade -f
```

### Fixes
- Move update counter commands to its own function so `demyx host restart` can work properly [5c782e3](https://github.com/demyxsh/demyx/commit/5c782e366ef0b101ea97005cb0dc0e5c83886827)
- The script will error and exit if there are containers still using an old image [c68a85b](https://github.com/demyxsh/demyx/commit/c68a85bf42030f389dff9e0a23e6281f61b280b4)
- Suppress external network warning [483d57a](https://github.com/demyxsh/demyx/commit/483d57a87c2db71a0bb8adc4fab6285697f54989)
- Replace `demyx_host_dangling_images()` with a single line command to make sure all dangling images gets deleted [aaf660a](https://github.com/demyxsh/demyx/commit/aaf660a1512a101ad05a422269532876cd19f88b)
- The image docker:cli should be included here [331f73b](https://github.com/demyxsh/demyx/commit/331f73bc9fcca690f131bc813a5ba140b908a261)
- Use `demyx refresh` to ensure containers are properly restarted [74bfa4e](https://github.com/demyxsh/demyx/commit/74bfa4ec0fcb45ffb086a8e0c6553ca65edce5ec)
- Requires the `--remove-orphans` flag when refreshing configs [856ec86](https://github.com/demyxsh/demyx/commit/856ec86cd6ce87ab42dff647ee836580cbb913f2)
- `demyx config --opcache` wasn't recreating the WP container [734e01b](https://github.com/demyxsh/demyx/commit/734e01b2faed1991907ea0cbdba8623b5e970f9f)
- `demyx config --bedrock` should error on non bedrock stacks [21e111a](https://github.com/demyxsh/demyx/commit/21e111af1345582c4cf31bde63d629fb7543354e)
- IPWhiteList is deprecated [8987f31](https://github.com/demyxsh/demyx/commit/8987f319aeac796b42b1f05187b4fd586891e048)
- Use official Docker CLI image to fix the `KeyConfig` error [0fa5d52](https://github.com/demyxsh/demyx/commit/0fa5d52de3685a17e82dd5afb92d305a7b1cb20b)
- Should be able to bypass "No updates available" and be able to upgrade demyx and host helper script only [df2bec1](https://github.com/demyxsh/demyx/commit/df2bec1d93f9a9155ab77b7a546a21948f9ec4f7)
- Move commands into a global function since backups are using the old container name format which would break `demyx restore` [8f3f808](https://github.com/demyxsh/demyx/commit/8f3f808ff63d573a1430d1833d8b8032197175c4)

## [1.8.2] - 2024-03-27
### Upgrading
Due to a lot of changes with Docker, there had to be a lot of fixes/workarounds made in order to ease the burden of upgrading. Follow these steps for a smooth transition.
```
# Update the demyx image to the latest version
docker pull demyx/demyx

# Update the host helper script
docker run -t --rm \
    -v /usr/local/bin:/tmp \
    --user=root \
    --entrypoint=bash \
    demyx/demyx -c 'cp -f /etc/demyx/host.sh /tmp/demyx; chmod +x /tmp/demyx'

# Use the latest version of demyx
demyx host restart

# Force the upgrade
demyx host upgrade -f
```

### Fixes
- Remove limitations on subdomains so SSL wildcards and www works on international domains and/or several levels deep of prefixes of subdomains [74fecb0](https://github.com/demyxsh/demyx/commit/74fecb0edd1afef8073c7b1c46295f3df702b039)
- The `-f` flag should also bypass the no updates check [bab05a1](https://github.com/demyxsh/demyx/commit/bab05a1b28504666413688fe8af9811c8caf4fbf)
- Fix GitHub Action failure [570991d](https://github.com/demyxsh/demyx/commit/570991df1bed1526cf14a2155e915ad672614801)
- Suppress the existing volume warning [e4decaf](https://github.com/demyxsh/demyx/commit/e4decaf333f5ba5ea886941b8b68ea172e1c7c17)
- Nginx would fail if the container names aren't updated to the new format [87eac07](https://github.com/demyxsh/demyx/commit/87eac07d2f418b672c96e6b24a5ee2aba5b05f22)
- Remove the `version` is obsolete warning [57fdd73](https://github.com/demyxsh/demyx/commit/57fdd730dfd3921635dbfb1a7dcc98ba2200420b)
- Upgrade to latest Docker version to fix `KeyError: 'ContainerConfig'` errors and docker-compose is now deprecated [87c3be1](https://github.com/demyxsh/demyx/commit/87c3be1b03f6c998d92ce01191b8dae60e8ff772)

## [1.8.1] - 2024-03-19
### Fixes
- Creating new apps were erroring on subdomains using `--ssl` flag [72fd7da](https://github.com/demyxsh/demyx/commit/72fd7da7fdde1daf1d377376cb7edf035a5617ea)
- Docker versions would mismatch between local and remote versions [7b18cb7](https://github.com/demyxsh/demyx/commit/7b18cb7ab046d6a712b92dfcc0f10c3a4f7226a3)
- `demyx host dev` was targeting the wrong string [87398c4](https://github.com/demyxsh/demyx/commit/87398c4043d9825a3a28e01ba3393bc5f984229c)
- Apparently the code-server service crashes when `mem_limit` is too low [a08eef2](https://github.com/demyxsh/demyx/commit/a08eef25c9de30418cf468a5c1295ec4dd3f16e5)
- This was supposed to be included in the last update but phpmyadmin needed this upload limit bump [f57aa3a](https://github.com/demyxsh/demyx/commit/f57aa3a1acfc2faca7ba8d9c8729847a2f65d0d0)
- `demyx restore` with sftp enabled was failing due to missing port [5c8883b](https://github.com/demyxsh/demyx/commit/5c8883b4e539ffcf9fa918c4d1f068a2a4f6c124)
- Shorthand was causing pipe errors for nginx which also crashed `demyx update`, so might as well remove all shorthands [a40d189](https://github.com/demyxsh/demyx/commit/a40d189561e24247e3803fffd531419f1c93ed78)
- Use `demyx_app_path` since the function `demyx_app_domain` was also affected by the `find` bug [b567ed9](https://github.com/demyxsh/demyx/commit/b567ed9d57208397393a70ce6f14112dcd39311e)
- `find` found multiple paths matching the app's domain which was crashing `demyx restore` [345b44f](https://github.com/demyxsh/demyx/commit/345b44f06b67a1eedcfe9d02c1cb03da43d899cd)
- `--dev` should enable/disable debug mode for WordPress [9ba3c32](https://github.com/demyxsh/demyx/commit/9ba3c32841292d4fbdba4c945c4d4b1d8f68caba)
- Config flag `--redis` was outputting `pop_var_context` error [5e25da5](https://github.com/demyxsh/demyx/commit/5e25da5107b7a426b9ac512b1b765288514ad1f4)
- Missing key `workflow_dispatch` for manual build [909e993](https://github.com/demyxsh/demyx/commit/909e993c3db879430e49d0ca9ca90aa946529df1)

## [1.8.0] - 2024-03-01

### Highlights
- Default PHP versions are now 8.1 and 8.2
- WP Rocket + rocket-nginx is now supported
- Wildcard SSL is now supported for any app, only for top level domains
- Weekly updates and showing updates should now be "smarter"
- General logging now only logs the function name
- Better error logging, simliar to PHP stack trace
- Thanks @NuclearMonster for the PR to fix one of my many errors

```
# Example of the new error log stack trace entry

"docker exec" requires at least 2 arguments.
See 'docker exec --help'.

Usage:  docker exec [OPTIONS] CONTAINER COMMAND [ARG...]

Execute a command in a running container

[2024-02-20-00:43:55] Fatal Error: 'docker exec' with exit code '1' in /etc/demyx/function/backup.sh:113

Stack Trace:
#0 /etc/demyx/function/backup.sh(113): demyx_backup_app
#1 /etc/demyx/function/backup.sh(66): demyx_backup
#2 /etc/demyx/bin/demyx.sh(22): demyx
#3 /etc/demyx/bin/demyx.sh(97): main
#4 backup domain.tld
```

### New
- Custom stack trace for better error logging and debugging [47cb92f](https://github.com/demyxsh/demyx/commit/47cb92ff0b8980e6215435e3ae5af42f9fd3cd2e)
- `demyx_event()` will replace general logging and will log every function when executed [7906b4c](https://github.com/demyxsh/demyx/commit/7906b4cafab7b9fdcbabea73c1d8c2f88ff110ec)
- Add support for WP Rocket + rocket-nginx [e72f8ef](https://github.com/demyxsh/demyx/commit/e72f8ef47780e8f6132c49543ada7e04ea804fb6)
- Add support for wildcard SSL [f99be89](https://github.com/demyxsh/demyx/commit/f99be89f791bf171a1e1aba5917efba75cc3fefa)
### Changes
- Match help text with the KB [c9c5530](https://github.com/demyxsh/demyx/commit/c9c5530c2e92a238612283214d8fec5bb3b12314)
- Remove/replace old logging function [07f3d59](https://github.com/demyxsh/demyx/commit/07f3d59c8c2c58bcb5a313ff8adf7fe057ba6e35)
- Only use demyx_execute to supress outputs from specific commands [04e8d09](https://github.com/demyxsh/demyx/commit/04e8d09c36a772082062ff49905264e3526e0fe2)
- Bump default PHP versions to 8.1 and 8.2 [3f1ef22](https://github.com/demyxsh/demyx/commit/3f1ef2269f555f55ff9ff263bc76c38d25939983)
- `--www` will error if using with a subdomain [4cbaa65](https://github.com/demyxsh/demyx/commit/4cbaa655c577b39a46075f04bb7043b5971e831a)
- Error on `--whitelist` if DEMYX_IP isn't set [d9738a8](https://github.com/demyxsh/demyx/commit/d9738a85a5653fb1f441585391e97c7711856d67)
- Make sure two core variables are set in order to enable SSL [5119d1a](https://github.com/demyxsh/demyx/commit/5119d1ac645099e0264df37630cae2d20f7d70f8)
- Update both php and lsphp versions when using `--php` [0f94720](https://github.com/demyxsh/demyx/commit/0f94720c623bbcb580b7d8af3c95b2431f1bdf01)
- Move disk healthcheck to hourly [7377be3](https://github.com/demyxsh/demyx/commit/7377be359f2d1e8d4ea4eec29365d4cefcd674d8)
- Add new/missing variables for OLS [99060d7](https://github.com/demyxsh/demyx/commit/99060d72d5960b259b9748efa60fbbcefad54507)
- Double the upload limit [b147698](https://github.com/demyxsh/demyx/commit/b1476980bf30f8f816b8044984ac030b0684f9db)
- Use exec to override the subshell [080bc99](https://github.com/demyxsh/demyx/commit/080bc99b4ee6ee708deae47e301447506d45a4b6)
- Move delete prompt and make sure to clear out old variables [31fa70b](https://github.com/demyxsh/demyx/commit/31fa70b9f83a6d18144a99ba509499113bc4748a)
- When checking for local image versions, make sure to only check if image is installed first [e21414a](https://github.com/demyxsh/demyx/commit/e21414a08ab55dec08728ecbc9fa533da4496fe5)
- Show updates if these images are installed only [73ab751](https://github.com/demyxsh/demyx/commit/73ab751eb5f636fb38b699c15e6ca54c5c37e3d2)
- Remove old conditional code [0136da6](https://github.com/demyxsh/demyx/commit/0136da61de0a6d0a0596e7661987865d7dc62497)
- Hardcode the CPU for only the code-server services [2b21b47](https://github.com/demyxsh/demyx/commit/2b21b47c40152dc37fbc53b1f81bf4dbbda9665a)
- Add/remove environment variables for yml.sh [6724490](https://github.com/demyxsh/demyx/commit/6724490b1b642b90c7598ba257722fef2ee7d133)
- One service was missing the custom volume [fea20d7](https://github.com/demyxsh/demyx/commit/fea20d7ac64a3804dfd3fad6fcfc0a65921d2b81)
- Hardcode the htpasswd instead of using .env [c6c0967](https://github.com/demyxsh/demyx/commit/c6c0967263f2ab3f41955428ffb4070f7a25f992)
- Output the latest error on the host if there is one [f2a2813](https://github.com/demyxsh/demyx/commit/f2a28136e6e24fb85765529ad187c6a8e0e42349)
- Miscellaneous changes/updates [bb84dd3](https://github.com/demyxsh/demyx/commit/bb84dd37106dfa33843bb1953475ab716964a10b)
- Output containers with cpu != 0% [6e75d6a](https://github.com/demyxsh/demyx/commit/6e75d6ade1f58e40daacabc9982ed83dd554f646)
- Utility needs to be sourced again for non alpine [380f5c3](https://github.com/demyxsh/demyx/commit/380f5c309f89a71e8e2ab4d0ac994341638b4153)
- Set fixed width [c8a2491](https://github.com/demyxsh/demyx/commit/c8a2491baad5d36c44a4aba8b3607b5e8048d556)
- @NuclearMonster "Update pull.sh to pull OLS and resolve out of date OLS installs." [82a1b6d](https://github.com/demyxsh/demyx/commit/82a1b6d0b1c6ba813bf78b8322d8facc4c4b6013)
### Fixes
- Be sure to exit on error for subshells [c44e466](https://github.com/demyxsh/demyx/commit/c44e4661bca6965e3989f2cfd8ba07c9f4ddf8b5)
- Redis wasn't configuring properly when switching stacks [7b1c1cd](https://github.com/demyxsh/demyx/commit/7b1c1cdb44919018ed79222b9f4ae27048147be5)
- Fix incorrect filename [6d4bcf3](https://github.com/demyxsh/demyx/commit/6d4bcf3ef30e5d2af0d3867ecb82412c289fb408)
- This is supposed to be defaulted at 7 [e0ffd28](https://github.com/demyxsh/demyx/commit/e0ffd28177cfc34a79df9cafbf98d27a53ce7091)
- Add missing logrotate rule [faa2056](https://github.com/demyxsh/demyx/commit/faa20566a300411d1b601aadaed942b2f6164cbc)

## [1.7.1] - 2023-11-16
### Changes
- Missing backup/restore commands for custom volume [aa8e543](https://github.com/demyxsh/demyx/commit/aa8e5431b104261ada0ac75be43329c7175b6c84)

## [1.7.0] - 2023-11-14
### New
- Add new volume `custom` for user customizations [5a1d155](https://github.com/demyxsh/demyx/commit/5a1d1553554bb10c06c3d5a34bfbb63d1366789d)
- `demyx config <app> --backup` new flag to skip backups of a specifc app [a2497a3](https://github.com/demyxsh/demyx/commit/a2497a36d7b3a9b257b040a991519daccf332d96)
- Add new variable DEMYX_APP_BACKUP [04cfb4c](https://github.com/demyxsh/demyx/commit/04cfb4c04058b6964ee55f2fdca24dcace297b6d)
### Changes
- Use `demyx_wordpress_ready` in `demyx_run_extras` [974fed2](https://github.com/demyxsh/demyx/commit/974fed212e4a75b264fe25b7d72fd3304d1bb7fb)
- Log error for `demyx_wordpress_ready` [7d377cb](https://github.com/demyxsh/demyx/commit/7d377cb451a10b408094c6e84961d675bd23583d)
- Skip app backup if DEMYX_APP_BACKUP is set to false [14bd04e](https://github.com/demyxsh/demyx/commit/14bd04e2b0683c1b3387bf53037908b3a511adf7)

## [1.6.0] - 2023-10-18
### Changes
- Update logic [b5a0984](https://github.com/demyxsh/demyx/commit/b5a0984d8babbeacc6256b93a0f8afc3391a2842)
- Revert back to old traefik rules for www and non www labels [371070b](https://github.com/demyxsh/demyx/commit/371070b7bcfede6443318846eb76e55ab9c5195e)
- `demyx config <app> --www` can't be used for sub domains [ef338ae](https://github.com/demyxsh/demyx/commit/ef338ae6252f95782d7660f7eca3c96fe528c6c7)

### Fixes
- Fix not installed error when using `--www` in `demyx run` [f111e06](https://github.com/demyxsh/demyx/commit/f111e0633c6b883e7467cfa1b7fce02153c77882)

### New
- New function `demyx_wordpress_ready()` loops checks if wp core is installed [99ed589](https://github.com/demyxsh/demyx/commit/99ed5896b938e05cda26644ef5902b86f49f84f7)
- New function `demyx_subdomain()` returns a string if it's a subdomain [8eec3bb](https://github.com/demyxsh/demyx/commit/8eec3bb753c0c9da8b4be7db84aae506086eef89)

## [1.5.2] - 2023-10-10
### Fixes
- Merge pull request #31 from NuclearMonster/master [adac58f](https://github.com/demyxsh/demyx/commit/adac58fd5e32280e95915f408a696b00cc91b686)
- Fix netwwork typo in host.sh [094cb60](https://github.com/demyxsh/demyx/commit/094cb60d56feee6a9732ee6a7c3bbe9b4920a2f0)

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

[1.9.0]: https://github.com/demyxsh/demyx/compare/1.8.3...1.9.0
[1.8.3]: https://github.com/demyxsh/demyx/compare/1.8.2...1.8.3
[1.8.2]: https://github.com/demyxsh/demyx/compare/1.8.1...1.8.2
[1.8.1]: https://github.com/demyxsh/demyx/compare/1.8.0...1.8.1
[1.8.0]: https://github.com/demyxsh/demyx/compare/1.7.1...1.8.0
[1.7.1]: https://github.com/demyxsh/demyx/compare/1.7.0...1.7.1
[1.7.0]: https://github.com/demyxsh/demyx/compare/1.6.0...1.7.0
[1.6.0]: https://github.com/demyxsh/demyx/compare/1.5.2...1.6.0
[1.5.2]: https://github.com/demyxsh/demyx/compare/1.5.1...1.5.2
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
