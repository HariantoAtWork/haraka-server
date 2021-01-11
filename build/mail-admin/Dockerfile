FROM postfixadmin:3.2

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -q -y --no-install-recommends mariadb-client netcat dovecot-core

# Clean up
RUN apt-get clean; rm -r /var/lib/apt/lists/*

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["apache2-foreground"]
