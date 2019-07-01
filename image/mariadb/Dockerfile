FROM webhippie/mariadb

LABEL sh.demyx.image demyx/mariadb
LABEL sh.demyx.maintainer Demyx <info@demyx.sh>
LABEL sh.demyx.url https://demyx.sh
LABEL sh.demyx.github https://github.com/demyxco/demyx
LABEL sh.demyx.registry https://hub.docker.com/u/demyx

ENV TZ=America/Los_Angeles

RUN set ex; \
	apk add --no-cache --update tzdata dumb-init

ENTRYPOINT ["dumb-init"]

CMD ["entrypoint", "/bin/s6-svscan", "/etc/s6"]
