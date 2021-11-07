#!/bin/sh

set -eu
cd /var/www/html

info() {
	echo
	echo "* $*"
}

if [ "${DISABLE_MAKE:-0}" != "1" ]; then
	info "Running composer ..."
	run-user composer install --no-interaction

	info "Build assets ..."
	run-user ./tools/assets/build.sh
fi
