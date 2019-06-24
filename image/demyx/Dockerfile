FROM alpine:3.10.0

LABEL image="demyx/demyx"
LABEL maintainer="Demyx <info@demyx.sh>"
LABEL url="https://demyx.sh"
LABEL github="https://github.com/demyxco/demyx"
LABEL registry="https://hub.docker.com/u/demyx"

COPY CMakeLists.txt /

RUN set -ex; \
    echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing/' >> /etc/apk/repositories; \
    apk add --no-cache --update git protobuf-dev libsodium-dev gflags-dev g++ gcc libc-dev libutempter-dev libexecinfo-dev ncurses-dev boost-dev; \
    apk add --no-cache --virtual .build-deps make cmake m4 perl; \
    mkdir -p /usr/src; \
    git clone https://github.com/MisterTea/EternalTerminal.git /usr/src/EternalTerminal/; \
    mv /CMakeLists.txt /usr/src/EternalTerminal; \
    cd /usr/src/EternalTerminal; \
    mkdir build; \
    cd build; \
    cmake ../; \
    make && make install; \
    apk del .build-deps && rm -rf /var/cache/apk/*

RUN set -ex; \
    sed -i 's|http://dl-cdn.alpinelinux.org/alpine/edge/testing/||g' /etc/apk/repositories; \
    apk add --no-cache --update bash tzdata curl zsh openssh sudo gnupg jq dumb-init htop rsync; \
    rm -rf /var/cache/apk/*

ENV DEMYX_DOCKER_BINARY=18.09.6

RUN set -ex; \
    curl -sS https://download.docker.com/linux/static/stable/x86_64/docker-"$DEMYX_DOCKER_BINARY".tgz --output /usr/src/docker-"$DEMYX_DOCKER_BINARY".tgz; \
    tar -xzf /usr/src/docker-"$DEMYX_DOCKER_BINARY".tgz -C /usr/src; \
    mv /usr/src/docker/docker /usr/local/bin; \
    rm -rf /usr/src/*

RUN set -ex; \
    addgroup -g 1000 -S demyx; \
    adduser -u 1000 -D -S -G demyx demyx; \
    echo demyx:demyx | chpasswd; \
    sed -i "s|/home/demyx:/sbin/nologin|/home/demyx:/bin/zsh|g" /etc/passwd; \
    sed -i "s|#PermitRootLogin prohibit-password|PermitRootLogin no|g" /etc/ssh/sshd_config; \
	sed -i "s|#PubkeyAuthentication yes|PubkeyAuthentication yes|g" /etc/ssh/sshd_config; \
	sed -i "s|#PasswordAuthentication yes|PasswordAuthentication no|g" /etc/ssh/sshd_config; \
	sed -i "s|#PermitEmptyPasswords no|PermitEmptyPasswords no|g" /etc/ssh/sshd_config

RUN set -ex; \
    sed -i "s|/home/demyx:/sbin/nologin|/home/demyx:/bin/zsh|g" /etc/passwd; \
    \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"; \
    git clone https://github.com/zsh-users/zsh-autosuggestions.git /root/.oh-my-zsh/plugins/zsh-autosuggestions; \
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/g' /root/.zshrc; \
    sed -i "s/(git)/(git zsh-autosuggestions)/g" /root/.zshrc; \
    \
    su -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" -s /bin/sh demyx; \
    git clone https://github.com/zsh-users/zsh-autosuggestions.git /home/demyx/.oh-my-zsh/plugins/zsh-autosuggestions; \
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/g' /home/demyx/.zshrc; \
    sed -i "s/(git)/(git zsh-autosuggestions)/g" /home/demyx/.zshrc; \
    \
    ln -s /home/demyx/.zsh_history /root; \
    echo "" > /etc/motd; \
    echo 'cd /demyx && demyx motd' >> /root/.zshrc; \
    echo 'cd /demyx && sudo demyx motd' >> /home/demyx/.zshrc

# Fix the annoying "prompt_git:40: vcs_info: function definition file not found"
COPY vcs_info /

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
    cat /vcs_info >> /root/.zshrc; \
    cat /vcs_info >> /home/demyx/.zshrc; \
    rm /vcs_info; \
    \
    chown -R demyx:demyx /demyx

RUN set -ex; \
    (echo "* * * * * /demyx/etc/cron/every-minute.sh") | crontab - ; \
    (crontab -l 2>/dev/null; echo "0 */6 * * * /demyx/etc/cron/every-6-hour.sh") | crontab - ; \
    (crontab -l 2>/dev/null; echo "0 0 * * * /demyx/etc/cron/every-day.sh") | crontab - ; \
    mkdir -p /var/log/demyx; \
    touch /var/log/demyx/demyx.log

RUN set -ex; \
    echo '#!/bin/bash' >> /usr/local/bin/demyx; \
    echo 'sudo /demyx/etc/demyx.sh "$@"' >> /usr/local/bin/demyx; \
    chmod +x /usr/local/bin/demyx

COPY demyx-entrypoint.sh /usr/local/bin/demyx-entrypoint

RUN chmod +x /usr/local/bin/demyx-entrypoint

WORKDIR /demyx

ENTRYPOINT ["dumb-init", "demyx-entrypoint"]
