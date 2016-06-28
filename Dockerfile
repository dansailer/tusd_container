#FROM ubuntu:xenial
FROM debian:jessie

# add our user and group first to make sure their IDs get assigned consistently
RUN groupadd -r tusd && useradd -r -m -g tusd tusd

RUN apt-get update && apt-get install -y \
		ca-certificates \
		wget \
	--no-install-recommends && rm -rf /var/lib/apt/lists/*

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true

# grab tini for signal processing and zombie killing
ENV TINI_VERSION v0.9.0
RUN set -x \
	&& wget -O /usr/local/bin/tini "https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini" \
	&& wget -O /usr/local/bin/tini.asc "https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini.asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 6380DC428747F6C393FEACA59A84159D7001A4E5 \
	&& gpg --batch --verify /usr/local/bin/tini.asc /usr/local/bin/tini \
	&& rm -r "$GNUPGHOME" /usr/local/bin/tini.asc \
	&& chmod +x /usr/local/bin/tini \
	&& tini -h


ENV TUSD_VERSION 0.4.0
RUN set -x \
  && mkdir /opt/tusd \
  && mkdir /opt/tusd/data \
  && chown -R tusd:tusd /opt/tusd \
  && wget -O /opt/tusd/tusd_linux_amd64.tar.gz "https://github.com/tus/tusd/releases/download/${TUSD_VERSION}/tusd_linux_amd64.tar.gz" \
  && tar xvf /opt/tusd/tusd_linux_amd64.tar.gz --strip=1 -C /opt/tusd/ tusd_linux_amd64/tusd \
  && rm -rf /opt/tusd/tusd_linux_amd64.tar.gz


ENV PATH /opt/tusd:$PATH

WORKDIR /opt/tusd/

VOLUME /opt/tusd/data

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh


EXPOSE 1080
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["tusd"]
