FROM postgres:10.15-alpine

RUN apk add --no-cache --update \
    bash

COPY init-user-db.sh /docker-entrypoint-initdb.d/
