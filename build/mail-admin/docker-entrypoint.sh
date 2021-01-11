#!/bin/bash
set -eo pipefail

# usage: get_env_value VAR [DEFAULT]
#    ie: get_env_value 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
function get_env_value() {
	local varName="${1}"
	local fileVarName="${varName}_FILE"
	local defaultValue="${2:-}"

	if [ "${!varName:-}" ] && [ "${!fileVarName:-}" ]; then
		echo >&2 "error: both ${varName} and ${fileVarName} are set (but are exclusive)"
		exit 1
	fi

	local value="${defaultValue}"
	if [ "${!varName:-}" ]; then
	  value="${!varName}"
	elif [ "${!fileVarName:-}" ]; then
		value="$(< "${!fileVarName}")"
	fi

	echo ${value}
	exit 0
}

# Init vars for running script
POSTFIXADMIN_DB_TYPE=$(get_env_value 'POSTFIXADMIN_DB_TYPE' 'sqlite')
POSTFIXADMIN_DB_HOST=$(get_env_value "POSTFIXADMIN_DB_HOST" "")
POSTFIXADMIN_DB_PORT=$(get_env_value "POSTFIXADMIN_DB_PORT" "")
POSTFIXADMIN_DB_USER=$(get_env_value "POSTFIXADMIN_DB_USER" "")
POSTFIXADMIN_DB_PASSWORD=$(get_env_value "POSTFIXADMIN_DB_PASSWORD" "")
POSTFIXADMIN_SMTP_SERVER=$(get_env_value "POSTFIXADMIN_SMTP_SERVER" "localhost")
POSTFIXADMIN_SMTP_PORT=$(get_env_value "POSTFIXADMIN_SMTP_PORT" "25")
POSTFIXADMIN_DB_USE_SSL=$(get_env_value 'POSTFIXADMIN_DB_USE_SSL' false)
POSTFIXADMIN_DB_SSL_KEY=$(get_env_value 'POSTFIXADMIN_DB_SSL_KEY' NULL)
POSTFIXADMIN_DB_SSL_CERT=$(get_env_value 'POSTFIXADMIN_DB_SSL_CERT' NULL)
POSTFIXADMIN_DB_SSL_CA=$(get_env_value 'POSTFIXADMIN_DB_SSL_CA' NULL)
POSTFIXADMIN_DB_SSL_CA_PATH=$(get_env_value 'POSTFIXADMIN_DB_SSL_CA_PATH' NULL)
POSTFIXADMIN_DB_SSL_CIPHER=$(get_env_value 'POSTFIXADMIN_DB_SSL_CIPHER' NULL)
POSTFIXADMIN_ENCRYPT=$(get_env_value 'POSTFIXADMIN_ENCRYPT' 'dovecot:CRAM-MD5')
# topsecret99
DEFAULT_SETUP_PASSWORD="791eb4ead7fd996c01bed30707ae27dd:b7910d09773104bf84c4f4951205d2198c7cfc4f"
POSTFIXADMIN_SETUP_PASSWORD=$(get_env_value "POSTFIXADMIN_SETUP_PASSWORD" "${DEFAULT_SETUP_PASSWORD}")

if [[ "$1" == apache2* ]] || [ "$1" == php-fpm ]; then

	if [ "${POSTFIXADMIN_SETUP_PASSWORD}" = "${DEFAULT_SETUP_PASSWORD}" ]; then
		echo >&2 "WARNING: Using default setup.php password of : topsecret99"
	fi

	if ! [ -e index.php -a -e scripts/postfixadmin-cli.php ]; then
		echo >&2 "Postfixadmin not found in $PWD - copying now..."
		if [ "$(ls -A)" ]; then
			echo >&2 "WARNING: $PWD is not empty - press Ctrl+C now if this is an error!"
			( set -x; ls -A; sleep 10 )
		fi
		tar cf - --one-file-system -C /usr/src/postfixadmin . | tar xf -
		echo >&2 "Complete! Postfixadmin has been successfully copied to $PWD"
	fi

	case "${POSTFIXADMIN_DB_TYPE}" in
		sqlite)
			;;
		mysqli)
			: "${POSTFIXADMIN_DB_PORT:=3306}"
			;;
		pgsql)
			: "${POSTFIXADMIN_DB_PORT:=5432}"
		;;
		*)
		echo >&2 "${POSTFIXADMIN_DB_TYPE} is not a supported value."
		exit 1
		;;
	esac

	if [ "${POSTFIXADMIN_DB_TYPE}" != "sqlite" ]; then
		if [ -z "${POSTFIXADMIN_DB_USER}" -o -z "${POSTFIXADMIN_DB_PASSWORD}" ]; then
			echo >&2 'Error: POSTFIXADMIN_DB_USER and POSTFIXADMIN_DB_PASSWORD must be specified. '
			exit 1
		fi
		timeout 15 bash -c "until echo > /dev/tcp/${POSTFIXADMIN_DB_HOST}/${POSTFIXADMIN_DB_PORT}; do sleep 0.5; done"
	fi

	if [ "${POSTFIXADMIN_DB_TYPE}" = 'sqlite' ]; then
		: "${POSTFIXADMIN_DB_NAME:=/var/tmp/postfixadmin.db}"

		if [ ! -f "${POSTFIXADMIN_DB_NAME}" ]; then
			echo "Creating sqlite db"
			touch $POSTFIXADMIN_DB_NAME
			chown www-data:www-data $POSTFIXADMIN_DB_NAME
			chmod 0700 $POSTFIXADMIN_DB_NAME
		fi
	fi

	if [ ! -e config.local.php ]; then
		touch config.local.php
		echo "Write config to $PWD/config.local.php"
		echo "<?php
		\$CONF['database_type'] = '${POSTFIXADMIN_DB_TYPE}';
		\$CONF['database_host'] = '${POSTFIXADMIN_DB_HOST}';
		\$CONF['database_port'] = '${POSTFIXADMIN_DB_PORT}';
		\$CONF['database_user'] = '${POSTFIXADMIN_DB_USER}';
		\$CONF['database_password'] = '${POSTFIXADMIN_DB_PASSWORD}';
		\$CONF['database_name'] = '${POSTFIXADMIN_DB_NAME}';
		\$CONF['setup_password'] = '${POSTFIXADMIN_SETUP_PASSWORD}';
		\$CONF['smtp_server'] = '${POSTFIXADMIN_SMTP_SERVER}';
		\$CONF['smtp_port'] = '${POSTFIXADMIN_SMTP_PORT}';
		\$CONF['configured'] = true;

		// Database SSL Config
		\$CONF['database_use_ssl'] = ${POSTFIXADMIN_DB_USE_SSL};
		\$CONF['database_ssl_key'] = ${POSTFIXADMIN_DB_SSL_KEY};
		\$CONF['database_ssl_cert'] = ${POSTFIXADMIN_DB_SSL_CERT};
		\$CONF['database_ssl_ca'] = ${POSTFIXADMIN_DB_SSL_CA};
		\$CONF['database_ssl_ca_path'] = ${POSTFIXADMIN_DB_SSL_CA_PATH};
		\$CONF['database_ssl_cipher'] = ${POSTFIXADMIN_DB_SSL_CIPHER};

		// DOVECOT Config
		\$CONF['encrypt'] = '${POSTFIXADMIN_ENCRYPT}';
		?>" | tee config.local.php
	else
		echo "WARNING: $PWD/config.local.php already exists."
		echo "Postfixadmin related environment variables have been ignored."
	fi

	if [ -f public/upgrade.php ]; then
		echo " ** Running database / environment upgrade.php "
		php public/upgrade.php
	fi
fi

exec "$@"