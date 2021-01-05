#!/bin/bash

until ping -c 3 $DOVECOT_DB_HOST 2>1 > /dev/null; do
  echo "$DOVECOT_DB_HOST is unavailable - sleeping"
  sleep 1
done

while [ ! -f /etc/ssl/certs/imap.$DOVECOT_DOMAIN.crt ]
do
  sleep 1
done

# Update db credentials
sed -i "s/DOVECOT_DB_HOST/$DOVECOT_DB_HOST/g" /etc/dovecot/dovecot-*sql.conf.ext
sed -i "s/DOVECOT_DB_NAME/$DOVECOT_DB_NAME/g" /etc/dovecot/dovecot-*sql.conf.ext
sed -i "s/DOVECOT_DB_USER/$DOVECOT_DB_USER/g" /etc/dovecot/dovecot-*sql.conf.ext
sed -i "s/DOVECOT_DB_PASSWORD/$DOVECOT_DB_PASSWORD/g" /etc/dovecot/dovecot-*sql.conf.ext
# Update domain
sed -i "s/example.com/$DOVECOT_DOMAIN/g" /etc/dovecot/conf.d/10-ssl.conf
sed -i "s/example.com/$DOVECOT_DOMAIN/g" /etc/dovecot/dovecot.conf

# Run dovecot
exec "$@"
