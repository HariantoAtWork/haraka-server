FROM roundcube/roundcubemail:1.4.x-fpm-alpine

EXPOSE 80

RUN apk add --no-cache --update \
    bash

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

# CMD [ "/usr/sbin/apache2", "-DFOREGROUND" ]
