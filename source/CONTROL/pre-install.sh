#!/bin/sh

if [ -z $APKG_PKG_DIR ]; then
    PKG_DIR=/usr/local/AppCentral/libcec
else
    PKG_DIR=$APKG_PKG_DIR
fi

case "$APKG_PKG_STATUS" in
	install)
		;;
	upgrade)
		;;
	*)
		;;
esac

exit 0
