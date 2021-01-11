<?php
		$CONF['database_type'] = getenv('POSTFIXADMIN_DB_TYPE');
		$CONF['database_host'] = getenv('POSTFIXADMIN_DB_HOST');
		$CONF['database_port'] = getenv('POSTFIXADMIN_DB_PORT');
		$CONF['database_user'] = getenv('POSTFIXADMIN_DB_USER');
		$CONF['database_password'] = getenv('POSTFIXADMIN_DB_PASSWORD');
		$CONF['database_name'] = getenv('POSTFIXADMIN_DB_NAME');
		$CONF['setup_password'] = getenv('POSTFIXADMIN_SETUP_PASSWORD');
		$CONF['smtp_server'] = getenv('POSTFIXADMIN_SMTP_SERVER');
		$CONF['smtp_port'] = getenv('POSTFIXADMIN_SMTP_PORT');
		$CONF['configured'] = true;

		// Database SSL Config
		if (getenv('POSTFIXADMIN_DB_USE_SSL')) {
			$CONF['database_use_ssl'] = getenv('POSTFIXADMIN_DB_USE_SSL');
			$CONF['database_ssl_key'] = getenv('POSTFIXADMIN_DB_SSL_KEY');
			$CONF['database_ssl_cert'] = getenv('POSTFIXADMIN_DB_SSL_CERT');
			$CONF['database_ssl_ca'] = getenv('POSTFIXADMIN_DB_SSL_CA');
			$CONF['database_ssl_ca_path'] = getenv('POSTFIXADMIN_DB_SSL_CA_PATH');
			$CONF['database_ssl_cipher'] = getenv('POSTFIXADMIN_DB_SSL_CIPHER');
		}

		# DOVECOT CONFIG
		$CONF['encrypt'] = getenv('POSTFIXADMIN_ENCRYPT');
