FROM webhippie/mariadb

LABEL image="demyx/mariadb"
LABEL maintainer="Demyx <info@demyx.sh>"
LABEL url="https://demyx.sh"
LABEL github="https://github.com/demyxco/demyx"
LABEL registry="https://hub.docker.com/u/demyx"

ENV TZ=America/Los_Angeles

RUN set ex; \
	apk add --no-cache --update tzdata dumb-init

ENTRYPOINT ["dumb-init"]

CMD ["entrypoint", "/bin/s6-svscan", "/etc/s6"]
