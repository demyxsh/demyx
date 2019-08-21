FROM alpine:3.10.1

LABEL sh.demyx.image demyx/eternal-terminal
LABEL sh.demyx.maintainer Demyx <info@demyx.sh>
LABEL sh.demyx.url https://demyx.sh
LABEL sh.demyx.github https://github.com/demyxco/demyx
LABEL sh.demyx.registry https://hub.docker.com/u/demyx

RUN set -ex; \
    echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing/' >> /etc/apk/repositories; \
    echo 'http://dl-cdn.alpinelinux.org/alpine/edge/community/' >> /etc/apk/repositories; \
    apk add --no-cache --update dumb-init protobuf-dev libsodium-dev gflags-dev g++ gcc libc-dev libutempter-dev libexecinfo-dev ncurses-dev boost-dev; \
    apk add --no-cache --virtual .build-deps git make cmake m4 perl git; \
    mkdir -p /usr/src; \
    git clone --recurse-submodules https://github.com/MisterTea/EternalTerminal.git /usr/src/EternalTerminal; \
    sed -i 's/-DELPP_FEATURE_CRASH_LOG//g' /usr/src/EternalTerminal/CMakeLists.txt; \
    cd /usr/src/EternalTerminal; \
    mkdir build; \
    cd build; \
    cmake ../; \
    make && make install; \
    sed -i 's|http://dl-cdn.alpinelinux.org/alpine/edge/testing/||g' /etc/apk/repositories; \
    sed -i 's|http://dl-cdn.alpinelinux.org/alpine/edge/community/||g' /etc/apk/repositories; \
    apk del .build-deps && rm -rf /var/cache/apk/*

RUN set -ex; \
    apk add --no-cache tzdata openssh; \
    addgroup -g 1000 -S demyx; \
    adduser -u 1000 -D -S -G demyx demyx; \
    mkdir -p /home/demyx/.ssh; \
    echo demyx:demyx | chpasswd; \
    sed -i "s|/home/demyx:/sbin/nologin|/home/demyx:/bin/ash|g" /etc/passwd; \
    sed -i "s|#PermitRootLogin prohibit-password|PermitRootLogin no|g" /etc/ssh/sshd_config; \
    sed -i "s|#PubkeyAuthentication yes|PubkeyAuthentication yes|g" /etc/ssh/sshd_config; \
    sed -i "s|#PasswordAuthentication yes|PasswordAuthentication no|g" /etc/ssh/sshd_config; \
    sed -i "s|#PermitEmptyPasswords no|PermitEmptyPasswords no|g" /etc/ssh/sshd_config; \
    rm -rf /usr/src/EternalTerminal

COPY demyx-entrypoint.sh /usr/local/bin/demyx-entrypoint

RUN chmod +x /usr/local/bin/demyx-entrypoint

ENTRYPOINT ["dumb-init", "demyx-entrypoint"]
