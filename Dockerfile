FROM msoap/shell2http as demyx_api
FROM quay.io/vektorlab/ctop:0.7.1 as demyx_ctop
FROM docker as demyx_docker
FROM alpine

LABEL sh.demyx.image demyx/demyx
LABEL sh.demyx.maintainer Demyx <info@demyx.sh>
LABEL sh.demyx.url https://demyx.sh
LABEL sh.demyx.github https://github.com/demyxsh
LABEL sh.demyx.registry https://hub.docker.com/u/demyx

# Set default environment variables
ENV DEMYX                               /demyx
ENV DEMYX_CONFIG                        /etc/demyx
ENV DEMYX_LOG                           /var/log/demyx
ENV DEMYX_APP                           "$DEMYX"/app
ENV DEMYX_CODE                          "$DEMYX_APP"/code
ENV DEMYX_TRAEFIK                       "$DEMYX_APP"/traefik
ENV DEMYX_WP                            "$DEMYX_APP"/wp
ENV DEMYX_PHP                           "$DEMYX_APP"/php
ENV DEMYX_HTML                          "$DEMYX_APP"/html
ENV DEMYX_BACKUP                        "$DEMYX"/backup
ENV DEMYX_BACKUP_WP                     "$DEMYX_BACKUP"/wp
ENV DEMYX_FUNCTION                      "$DEMYX_CONFIG"/function
ENV DEMYX_API                           false
ENV DEMYX_AUTH_USERNAME                 demyx
ENV DEMYX_AUTH_PASSWORD                 demyx
ENV DEMYX_BACKUP_ENABLE                 true
ENV DEMYX_BACKUP_LIMIT                  true
ENV DEMYX_CODE_DOMAIN                   code
ENV DEMYX_CODE_ENABLE                   false
ENV DEMYX_CODE_PASSWORD                 demyx
ENV DEMYX_CF_KEY                        false
ENV DEMYX_CPU                           .50
ENV DEMYX_DOCKER_COMPOSE                2.4
ENV DEMYX_DOMAIN                        false
ENV DEMYX_EMAIL                         false
ENV DEMYX_HEALTHCHECK_ENABLE            true
ENV DEMYX_HEALTHCHECK_TIMEOUT           30
ENV DEMYX_HOSTNAME                      demyx
ENV DEMYX_IMAGE_VERSION                 latest
ENV DEMYX_IP                            false
ENV DEMYX_MEM                           512m
ENV DEMYX_MONITOR_ENABLE                true
ENV DEMYX_SERVER_IP                     false
ENV DEMYX_TELEMETRY                     true
ENV DEMYX_TRAEFIK_LOG                   INFO
ENV DEMYX_VERSION                       1.3.1
ENV DOCKER_HOST                         tcp://demyx_socket:2375
ENV TZ                                  America/Los_Angeles

# Install custom packages
RUN set -ex; \
    apk add --no-cache --update \
    bash \
    bind-tools \
    curl \
    jq \
    htop \
    nano \
    sudo \
    tzdata \
    util-linux

# Configure Demyx
RUN set -ex; \
    addgroup -g 1000 -S demyx; \
    adduser -u 1000 -D -S -G demyx demyx; \
    \
    install -d -m 0755 -o demyx -g demyx "$DEMYX"; \
    install -d -m 0755 -o demyx -g demyx "$DEMYX_CONFIG"; \
    install -d -m 0755 -o demyx -g demyx "$DEMYX_LOG"; \
    \
    # Update .bashrc
    echo 'PS1="$(whoami)@\h:\w \$ "' > /home/demyx/.bashrc; \
    echo 'PS1="$(whoami)@\h:\w \$ "' > /root/.bashrc; \
    \
    echo "$DEMYX_HOSTNAME" /etc/hostname; \
    \
    ln -s "$DEMYX" /home/demyx; \
    ln -s "$DEMYX_LOG" "$DEMYX"/log

# Configure sudo
RUN set -ex; \
    echo -e "demyx ALL=(ALL) NOPASSWD:SETENV: /etc/demyx/demyx.sh, /etc/demyx/bin/demyx-yml.sh, /etc/demyx/bin/demyx-reset.sh, /etc/demyx/bin/demyx-skel.sh, /usr/sbin/crond" > /etc/sudoers.d/demyx; \
    \
    # Supresses the sudo warning for now
    echo "Set disable_coredump false" > /etc/sudo.conf

# Set cron and log
RUN set -ex; \
    echo -e "SHELL=/bin/bash\n\
        * * * * * /usr/local/bin/demyx cron minute\n\
        0 * * * * /usr/local/bin/demyx cron hourly\n\
        0 */6 * * * /usr/local/bin/demyx cron six-hour\n\
        0 0 * * * /usr/local/bin/demyx cron daily\n\
        0 0 * * 0 /usr/local/bin/demyx cron weekly\n\
    " | sed "s|        ||g" > /etc/crontabs/demyx

# Copy files and binaries
COPY . /etc/demyx
COPY --from=demyx_api /app/shell2http /usr/local/bin/shell2http
COPY --from=demyx_ctop /ctop /usr/local/bin/ctop
COPY --from=demyx_docker /usr/local/bin/docker /usr/local/bin/docker

# Sudo wrappers
RUN set -ex; \
    echo '#!/bin/bash' >> /usr/local/bin/demyx; \
    echo 'sudo -E /etc/demyx/demyx.sh "$@"' >> /usr/local/bin/demyx; \
    chmod +x /etc/demyx/demyx.sh; \
    chmod +x /usr/local/bin/demyx; \
    \
    echo '#!/bin/bash' >> /usr/local/bin/demyx-reset; \
    echo 'sudo -E /etc/demyx/bin/demyx-reset.sh' >> /usr/local/bin/demyx-reset; \
    chmod +x /etc/demyx/bin/demyx-reset.sh; \
    chmod +x /usr/local/bin/demyx-reset; \
    \
    echo '#!/bin/bash' >> /usr/local/bin/demyx-skel; \
    echo 'sudo -E /etc/demyx/bin/demyx-skel.sh' >> /usr/local/bin/demyx-skel; \
    chmod +x /etc/demyx/bin/demyx-skel.sh; \
    chmod +x /usr/local/bin/demyx-skel; \
    \
    echo '#!/bin/bash' >> /usr/local/bin/demyx-yml; \
    echo 'sudo -E /etc/demyx/bin/demyx-yml.sh "$@"' >> /usr/local/bin/demyx-yml; \
    chmod +x /etc/demyx/bin/demyx-yml.sh; \
    chmod +x /usr/local/bin/demyx-yml

# Finalize
RUN set -ex; \
    # Lockdown
    chmod o-x /bin/busybox; \
    chmod o-x /bin/echo; \
    chmod o-x /usr/bin/curl; \
    chmod o-x /usr/bin/nano; \
    chmod o-x /usr/local/bin/docker; \
    \
    # demyx-init
    mv "$DEMYX_CONFIG"/bin/demyx-init.sh /usr/local/bin/demyx-init; \
    chmod +x /usr/local/bin/demyx-init; \
    \
    # Set ownership
    chown -R root:root /usr/local/bin

EXPOSE 8080

WORKDIR "$DEMYX"

USER demyx

ENTRYPOINT ["demyx-init"]
