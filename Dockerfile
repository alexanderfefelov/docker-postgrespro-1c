FROM ubuntu:xenial

ENV DEBIAN_FRONTEND noninteractive

RUN groupadd postgres --gid=999 \
  && useradd --gid postgres --uid=999 postgres

ENV GOSU_VERSION 1.7
RUN apt-get -qq update \
  && apt-get -qq install --yes --no-install-recommends ca-certificates wget locales \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && wget --quiet -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true

RUN localedef --inputfile ru_RU --force --charmap UTF-8 --alias-file /usr/share/locale/locale.alias ru_RU.UTF-8
ENV LANG ru_RU.utf8

ENV SERVER_VERSION 9.4
ENV PATH /usr/lib/postgresql/$SERVER_VERSION/bin:$PATH
ENV PGDATA /data
RUN echo deb http://1c.postgrespro.ru/deb/ xenial main > /etc/apt/sources.list.d/postgrespro-1c.list \
  && wget --quiet -O- http://1c.postgrespro.ru/keys/GPG-KEY-POSTGRESPRO-1C | apt-key add - \
  && apt-get -qq update \
  && apt-get -qq install --yes --no-install-recommends postgresql-common-pro-1c \
  && sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf \
  && apt-get -qq install --yes --no-install-recommends postgresql-pro-1c-$SERVER_VERSION \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir --parent /var/run/postgresql "$PGDATA" /docker-entrypoint-initdb.d \
  && chown --recursive postgres:postgres /var/run/postgresql "$PGDATA" \
  && chmod g+s /var/run/postgresql

COPY container/docker-entrypoint.sh /
COPY container/postgresql.conf.sh /docker-entrypoint-initdb.d

ENTRYPOINT ["/docker-entrypoint.sh"]

VOLUME $PGDATA

EXPOSE 5432

CMD ["postgres"]
