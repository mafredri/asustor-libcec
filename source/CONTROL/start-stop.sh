#!/bin/sh

NAME="libCEC"
PACKAGE="libcec"

if [ -z "${APKG_PKG_DIR}" ]; then
	PKG_DIR=/usr/local/AppCentral/${PACKAGE}
else
	PKG_DIR=$APKG_PKG_DIR
fi

PYTHON_LIB="/usr/local/AppCentral/python/lib/python2.7"
LINK_PKG_SOURCE="${PKG_DIR}/usr/lib/python2.7/site-packages/cec"
LINK_PKG_TARGET="${PYTHON_LIB}/site-packages/cec"
LINK_SO_SOURCE="${LINK_PKG_SOURCE}/_cec.so"
LINK_SO_TARGET="${PYTHON_LIB}/lib-dynload/_cec.so"

start() {
	if ! /bin/ln -sn "$LINK_PKG_SOURCE" "$LINK_PKG_TARGET"; then
		echo "ERROR: could not link cec python module to site-packages..."
	fi
	if ! /bin/ln -sn "$LINK_SO_SOURCE" "$LINK_SO_TARGET"; then
		echo "ERROR: could not link cec python module to lib-dynload..."
	fi
}

stop() {
	if [ "$(/usr/bin/readlink -n "$LINK_PKG_TARGET")" = "$LINK_PKG_SOURCE" ]; then
		rm "$LINK_PKG_TARGET"
	else
		echo "ERROR: could not unlink cec python module..."
	fi

	if [ "$(/usr/bin/readlink -n "$LINK_SO_TARGET")" = "$LINK_SO_SOURCE" ]; then
		rm "$LINK_SO_TARGET"
	else
		echo "ERROR: could not unlink cec python module..."
	fi
}

case $1 in
	start)
		echo "Starting ${NAME}..."
		start
		;;

	stop)
		echo "Stopping ${NAME}..."
		stop
		;;
	*)
		echo "usage: $0 {start|stop}"
		exit 1
		;;
esac

exit 0
