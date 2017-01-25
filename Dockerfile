FROM ubuntu:xenial

ENV PG_MAJOR 9.4

ENV PGDATA /data
ENV PATH /usr/lib/postgresql/$PG_MAJOR/bin:$PATH
ENV GOSU_VERSION 1.7

ENV DEBIAN_FRONTEND noninteractive

RUN groupadd postgres --gid=999 \
  && useradd --gid postgres --uid=999 postgres

RUN apt-get -qq update \
  && apt-get -qq install --yes --no-install-recommends ca-certificates wget locales \
  && wget --quiet -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true

RUN localedef --inputfile ru_RU --force --charmap UTF-8 --alias-file /usr/share/locale/locale.alias ru_RU.UTF-8
ENV LANG ru_RU.utf8

RUN echo deb http://1c.postgrespro.ru/deb/ xenial main > /etc/apt/sources.list.d/postgrespro-1c.list \
  && wget --quiet -O- http://1c.postgrespro.ru/keys/GPG-KEY-POSTGRESPRO-1C-92 | apt-key add - \
  && apt-get -qq update \
  && apt-get -qq install --yes --no-install-recommends postgresql-common-pro-1c \
  && sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf \
  && apt-get -qq install --yes --no-install-recommends postgresql-pro-1c-$PG_MAJOR

RUN mkdir --parent /var/run/postgresql \
  && chown --recursive postgres:postgres /var/run/postgresql \
  && chmod g+s /var/run/postgresql \
  && mkdir --parent "$PGDATA" \
  && chown --recursive postgres:postgres "$PGDATA" \
  && mkdir /docker-entrypoint-initdb.d

COPY container/docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

VOLUME $PGDATA

EXPOSE 5432

CMD ["postgres"]
