#!/bin/sh

set -e
cd ${PS_PROJECT_PATH:-/var/www/html}

info() {
	echo
	echo "* $*"
}

query() {
	mysql -h$DB_SERVER ${DB_PORT:+-P$DB_PORT} "-u${DB_USER:-root}" ${DB_PASSWD:+-p"$DB_PASSWD"} "$@"
}

if [ "${DISABLE_MAKE:-0}" != "1" ]; then
	info "Running composer ..."
	run-user composer install --no-interaction

	info "Build assets ..."
	run-user ./tools/assets/build.sh
fi


if [ ${PS_INSTALL_AUTO:-1} != 1 ]; then
	: # won't need access to $DB_SERVER
elif [ -z "${DB_SERVER:-}" ]; then
	cat <<EOT >&2
error: You requested automatic PrestaShop installation but MySQL server address is not provided
  You need to specify DB_SERVER in order to proceed'
EOT
	exit 1
else
	while true; do
		info "Checking if $DB_SERVER is available..."

		if query -e "status" > /dev/null 2>&1; then
			break
		fi

		info "Waiting for confirmation of MySQL service startup"
		sleep 5
	done

	info "DB server $DB_SERVER is available, let's continue !"
fi

if [ -s ./config/settings.inc.php ]; then
	info "Prestashop Core already installed..."

elif [ "${PS_INSTALL_AUTO:-1}" = 1 ]; then

	info "Installing PrestaShop, this may take a while ..."

	if [ -z "${PS_DOMAIN:-}" ]; then
		export PS_DOMAIN=$(hostanem -i)
	fi

	run-user php $PWD/${PS_FOLDER_INSTALL:-install-dev}/index_cli.php \
	--domain="$PS_DOMAIN" --db_server=$DB_SERVER:$DB_PORT --db_name="$DB_NAME" --db_user=$DB_USER \
	--db_password=$DB_PASSWD --prefix="$DB_PREFIX" --firstname="John" --lastname="Doe" \
	--password=$ADMIN_PASSWD --email="$ADMIN_MAIL" --language=$PS_LANGUAGE --country=$PS_COUNTRY \
	--all_languages=$PS_ALL_LANGUAGES --newsletter=0 --send_email=0 --ssl=1
fi

info "Almost ! Starting web server now"
