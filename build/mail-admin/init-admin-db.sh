#!/bin/bash

export HEREDOC=$(cat <<EOF
[client]
password="$DB_ROOT_PASSWORD"
EOF
) ; echo "$HEREDOC"


if [ ! -f ~/.mylogin.cnf ]; then
    echo "$HEREDOC" > ~/.mylogin.cnf
    chmod 0600 ~/.mylogin.cnf
fi

until nc -z -v -w30 $DB_HOST $DB_PORT; do
  echo "$DB_HOST is unavailable - sleeping"
  sleep 2
done

if [ -f /var/backups/mail.sql.gz ]; then
    gunzip /var/backups/mail.sql.gz
    ON_ERROR_STOP=1 mysql -v -h mariadb -u $DB_ROOT -p$MYSQL_ROOT_PASSWORD $DB_NAME < /var/backups/mail.sql
    rm /var/backups/mail.sql
    for tbl in `mysql -qAt -h mariadb -u $DB_ROOT -p$MYSQL_ROOT_PASSWORD -c "select tablename from pg_tables where schemaname = 'public';" $DB_NAME`;
        do
            mysql -h mariadb -u $DB_ROOT -p$MYSQL_ROOT_PASSWORD -c "alter table \"$tbl\" owner to $USER_NAME" $DB_NAME;
        done
fi

exec "$@"
