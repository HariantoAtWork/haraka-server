FROM alpine:latest

RUN apk add --no-cache --update \
    openssl \
    ca-certificates \
    bash

COPY docker-entrypoint.sh /
COPY ca-openssl.cnf /ca-openssl.cnf
COPY dovecot-openssl.cnf /dovecot-openssl.cnf
COPY haraka-openssl.cnf /haraka-openssl.cnf

# Clean up
RUN rm -rf /var/cache/apk/*

ENTRYPOINT ["/docker-entrypoint.sh"]
