#!/bin/bash

init_user_sql() {
echo "INIT USER SQL"
ON_ERROR_STOP=1 mysql -v -u $DB_ROOT -p$MYSQL_ROOT_PASSWORD <<-EOSQL
GRANT ALL PRIVILEGES ON *.* TO $DB_USER@'%' IDENTIFIED BY '$DB_PASSWORD';
EOSQL
}

init_postfixadmin_sql() {
echo "INIT POSTFIXADMIN SQL"
ON_ERROR_STOP=1 mysql -v -u $DB_ROOT -p$MYSQL_ROOT_PASSWORD <<-EOSQL
CREATE DATABASE $DB_NAME;
GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER;
EOSQL
}

init_roundcube_sql() {
echo "INIT ROUNDCUBE SQL"
ON_ERROR_STOP=1 mysql -v -u $DB_ROOT -p$MYSQL_ROOT_PASSWORD <<-EOSQL
CREATE DATABASE roundcube;
GRANT ALL PRIVILEGES ON roundcube.* TO $DB_USER;
EOSQL
}

# Create user and database
init_user_sql;
init_postfixadmin_sql;
init_roundcube_sql;