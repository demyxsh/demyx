FROM alpine:3.10.0

LABEL image="demyx/eternal-terminal"
LABEL maintainer="Demyx <info@demyx.sh>"
LABEL url="https://demyx.sh"
LABEL github="https://github.com/demyxco/demyx"
LABEL registry="https://hub.docker.com/u/demyx"

COPY CMakeLists.txt /

RUN set -ex; \
    echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing/' >> /etc/apk/repositories; \
    apk add --no-cache --update dumb-init protobuf-dev libsodium-dev gflags-dev g++ gcc libc-dev libutempter-dev libexecinfo-dev ncurses-dev boost-dev; \
    apk add --no-cache --virtual .build-deps git make cmake m4 perl git; \
    mkdir -p /usr/src; \
    git clone https://github.com/MisterTea/EternalTerminal.git /usr/src/EternalTerminal; \
    mv /CMakeLists.txt /usr/src/EternalTerminal; \
    cd /usr/src/EternalTerminal; \
    mkdir build; \
    cd build; \
    cmake ../; \
    make && make install; \
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
    sed -i 's|http://dl-cdn.alpinelinux.org/alpine/edge/testing/||g' /etc/apk/repositories; \
    rm -rf /usr/src/EternalTerminal

COPY demyx-entrypoint.sh /usr/local/bin/demyx-entrypoint

RUN chmod +x /usr/local/bin/demyx-entrypoint

ENTRYPOINT ["dumb-init", "demyx-entrypoint"]
