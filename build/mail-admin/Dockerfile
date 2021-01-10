FROM postfixadmin:3.2

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -q -y --no-install-recommends mariadb-client netcat

COPY config.inc.php /var/www/html/config.inc.php
COPY config.local.php /var/www/html/config.local.php
COPY config.inc.php /etc/postfixadmin/config.inc.php
COPY config.local.php /etc/postfixadmin/config.local.php

# Copy sample database dump
#COPY mail.sql.gz /var/backups/

# COPY docker-entrypoint.sh /

# ENTRYPOINT ["/docker-entrypoint.sh"]

# CMD [ "/usr/sbin/apache2", "-DFOREGROUND" ]
