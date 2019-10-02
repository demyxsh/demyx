FROM alpine

LABEL sh.demyx.image demyx/demyx
LABEL sh.demyx.maintainer Demyx <info@demyx.sh>
LABEL sh.demyx.url https://demyx.sh
LABEL sh.demyx.github https://github.com/demyxco/demyx
LABEL sh.demyx.registry https://hub.docker.com/u/demyx

# Set default timezone
ENV TZ America/Los_Angeles

# Install custom packages
RUN set -ex; \
    apk add --no-cache --update bash tzdata curl zsh openssh sudo gnupg jq htop rsync git

# Download latest Docker client binary
RUN set -ex; \
    export DEMYX_DOCKER_BINARY=$(curl -sL https://api.github.com/repos/docker/docker-ce/releases/latest | grep '"name":' | awk -F '[:]' '{print $2}' | sed -e 's/"//g' | sed -e 's/,//g' | sed -e 's/ //g' | sed -e 's/\r//g'); \
    # Set fixed version as a fallback if curling fails
    if [ -z "$DEMYX_DOCKER_BINARY" ]; then export DEMYX_DOCKER_BINARY=18.09.9; fi; \
    mkdir /usr/src; \
    wget -P /usr/src/ https://download.docker.com/linux/static/stable/x86_64/docker-"$DEMYX_DOCKER_BINARY".tgz; \
    tar -xzf /usr/src/docker-"$DEMYX_DOCKER_BINARY".tgz -C /usr/src; \
    mv /usr/src/docker/docker /usr/local/bin; \
    rm -rf /usr/src/*

# Create demyx user and configure ssh
RUN set -ex; \
    addgroup -g 1000 -S demyx; \
    adduser -u 1000 -D -S -G demyx demyx; \
    echo demyx:demyx | chpasswd; \
    sed -i "s|/home/demyx:/sbin/nologin|/home/demyx:/bin/zsh|g" /etc/passwd; \
    sed -i "s|#PermitRootLogin prohibit-password|PermitRootLogin no|g" /etc/ssh/sshd_config; \
	sed -i "s|#PubkeyAuthentication yes|PubkeyAuthentication yes|g" /etc/ssh/sshd_config; \
	sed -i "s|#PasswordAuthentication yes|PasswordAuthentication no|g" /etc/ssh/sshd_config; \
	sed -i "s|#PermitEmptyPasswords no|PermitEmptyPasswords no|g" /etc/ssh/sshd_config

# Install Oh-My-Zsh with ys as the default theme
RUN set -ex; \
    sed -i "s|/home/demyx:/sbin/nologin|/home/demyx:/bin/zsh|g" /etc/passwd; \
    \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"; \
    git clone https://github.com/zsh-users/zsh-autosuggestions.git /root/.oh-my-zsh/plugins/zsh-autosuggestions; \
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="ys"/g' /root/.zshrc; \
    sed -i "s/(git)/(git zsh-autosuggestions)/g" /root/.zshrc; \
    \
    su -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" -s /bin/sh demyx; \
    git clone https://github.com/zsh-users/zsh-autosuggestions.git /home/demyx/.oh-my-zsh/plugins/zsh-autosuggestions; \
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="ys"/g' /home/demyx/.zshrc; \
    sed -i "s/(git)/(git zsh-autosuggestions)/g" /home/demyx/.zshrc; \
    \
    # Symlink demyx command history with root
    ln -s /home/demyx/.zsh_history /root; \
    # Empty out Alpine Linux's MOTD and configure ours
    echo "" > /etc/motd; \
    echo 'cd /demyx && demyx motd' >> /root/.zshrc; \
    echo 'cd /demyx && sudo demyx motd' >> /home/demyx/.zshrc

# Allow demyx user to execute only one script and allow usage of environment variables
RUN set -ex; \
    echo "demyx ALL=(ALL) NOPASSWD:/demyx/etc/demyx.sh" >> /etc/sudoers; \
    echo 'Defaults env_keep +="DEMYX_MODE"' >> /etc/sudoers; \
    echo 'Defaults env_keep +="DEMYX_HOST"' >> /etc/sudoers; \
    echo 'Defaults env_keep +="DEMYX_SSH"' >> /etc/sudoers; \
    echo 'Defaults env_keep +="DEMYX_ET"' >> /etc/sudoers; \
    echo 'Defaults env_keep +="TZ"' >> /etc/sudoers; \
    mkdir /demyx; \
    ln -s /demyx /home/demyx; \
    \
    echo 'export GPG_TTY=$(tty)' >> /root/.zshrc; \
    echo 'export GPG_TTY=$(tty)' >> /home/demyx/.zshrc; \
    \
    chown -R demyx:demyx /demyx

# Set cron
RUN set -ex; \
    (echo "* * * * * /demyx/etc/cron/every-minute.sh") | crontab - ; \
    (crontab -l 2>/dev/null; echo "0 */6 * * * /demyx/etc/cron/every-6-hour.sh") | crontab - ; \
    (crontab -l 2>/dev/null; echo "0 0 * * * /demyx/etc/cron/every-day.sh") | crontab - ; \
    (crontab -l 2>/dev/null; echo "0 0 * * 0 /demyx/etc/cron/every-week.sh") | crontab - ; \
    mkdir -p /var/log/demyx; \
    touch /var/log/demyx/demyx.log

# Sudo wrapper for demyx executable so demyx user doesn't have to type sudo on each demyx command
RUN set -ex; \
    echo '#!/bin/bash' >> /usr/local/bin/demyx; \
    echo 'sudo /demyx/etc/demyx.sh "$@"' >> /usr/local/bin/demyx; \
    chmod +x /usr/local/bin/demyx

# s6-overlay
RUN set -ex; \
    export DEMYX_S6_VERSION=$(curl -sL https://api.github.com/repos/just-containers/s6-overlay/releases/latest | grep '"name"' | head -n1 | awk -F '[:]' '{print $2}' | sed -e 's/"//g' | sed -e 's/,//g' | sed -e 's/ //g' | sed -e 's/\r//g'); \
    wget https://github.com/just-containers/s6-overlay/releases/download/${DEMYX_S6_VERSION}/s6-overlay-amd64.tar.gz -qO /tmp/s6-overlay-amd64.tar.gz; \
    tar xzf /tmp/s6-overlay-amd64.tar.gz -C /; \
    rm -rf /tmp/*

COPY s6-overlay/00-init /etc/cont-init.d/00-init
COPY s6-overlay/run-crond /etc/services.d/crond/run
COPY s6-overlay/run-sshd /etc/services.d/sshd/run

# demyx-helper
COPY demyx-helper.sh /usr/local/bin/demyx-helper
RUN chmod +x /usr/local/bin/demyx-helper

EXPOSE 22
WORKDIR /demyx
ENTRYPOINT ["/init"]
