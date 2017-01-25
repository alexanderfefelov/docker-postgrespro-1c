#!/bin/sh

docker run --name postgrespro-1c \
  --net host  \
  --detach \
  --publish 5432:5432 \
  --volume /etc/localtime:/etc/localtime:ro \
  --env POSTGRES_PASSWORD=password \
  alexanderfefelov/postgrespro-1c
