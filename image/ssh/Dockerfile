FROM alpine:3.10.0

LABEL image="demyx/ssh"
LABEL maintainer="Demyx <info@demyx.sh>"
LABEL url="https://demyx.sh"
LABEL github="https://github.com/demyxco/demyx"
LABEL registry="https://hub.docker.com/u/demyx"

RUN set -ex; \
	apk add --no-cache --update openssh dumb-init; \
	addgroup -g 82 -S www-data; \
	adduser -u 82 -D -S -G www-data www-data; \
	echo www-data:www-data | chpasswd; \
	mkdir -p /home/www-data/.ssh; \
	mkdir -p /var/www/html; \
	ln -s /var/www/html /home/www-data; \
	sed -i "s|/home/www-data:/sbin/nologin|/home/www-data:/bin/sh|g" /etc/passwd; \
	sed -i "s|#PermitRootLogin prohibit-password|PermitRootLogin no|g" /etc/ssh/sshd_config; \
	sed -i "s|#PubkeyAuthentication yes|PubkeyAuthentication yes|g" /etc/ssh/sshd_config; \
	sed -i "s|#PasswordAuthentication yes|PasswordAuthentication no|g" /etc/ssh/sshd_config; \
	sed -i "s|#PermitEmptyPasswords no|PermitEmptyPasswords no|g" /etc/ssh/sshd_config

COPY demyx-entrypoint.sh /usr/local/bin/demyx-entrypoint

RUN chmod +x /usr/local/bin/demyx-entrypoint

ENTRYPOINT ["dumb-init", "demyx-entrypoint"]
