#!/bin/sh

set -eu
cd /var/www/html

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
