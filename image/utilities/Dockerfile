FROM ubuntu

LABEL image="demyx/utilities"
LABEL maintainer="Demyx <info@demyx.sh>"
LABEL url="https://demyx.sh"
LABEL github="https://github.com/demyxco/demyx"
LABEL registry="https://hub.docker.com/u/demyx"

RUN set -ex; \
	apt-get update && apt-get install -y --no-install-recommends \
    bash \
	jq \
	curl \
	ca-certificates \
	pv \
	pwgen \
	gpw \
	dnsutils \
	uuid-runtime \
	git \
    bsdmainutils \
    less \
	apache2-utils \
    nano

RUN apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

RUN mkdir /demyx

COPY table.sh /
COPY proxy.sh /

ENTRYPOINT ["bash", "-c"]
