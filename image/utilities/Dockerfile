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
	dumb-init \
    nano \
	clamav \
	clamdscan \
	net-tools

RUN apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

ENV MALDET_VERSION=1.6.4

RUN set -ex; \
	cd /tmp; \
	curl -O http://www.rfxn.com/downloads/maldetect-current.tar.gz; \
	tar -xzf maldetect-current.tar.gz; \
	cd maldetect-${MALDET_VERSION}; \
	bash install.sh; \
	sed -i 's/scan_ignore_root="1"/scan_ignore_root="0"/g' /usr/local/maldetect/conf.maldet; \
	freshclam; \
	maldet -u; \
	rm -rf /tmp/*
	
RUN mkdir /demyx

COPY table.sh /usr/local/bin/demyx-table
COPY proxy.sh /usr/local/bin/demyx-proxy
COPY maldet.sh /usr/local/bin/demyx-maldet
COPY port.sh /usr/local/bin/demyx-port

RUN chmod +x /usr/local/bin/demyx-table; \
	chmod +x /usr/local/bin/demyx-proxy; \
	chmod +x /usr/local/bin/demyx-maldet; \
	chmod +x /usr/local/bin/demyx-port

ENTRYPOINT ["dumb-init", "bash", "-c"]
