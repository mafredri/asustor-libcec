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

# Create a symlink to the correct module version
(cd $PKG_DIR/modules; ln -sf ${AS_NAS_ARCH}/cdc-acm.ko cdc-acm.ko)
# Symlink for the binary
(cd $PKG_DIR/bin; ln -sf cec-client-${AS_NAS_ARCH} cec-client-)
# Symlink for the lib directory
(cd $PKG_DIR; ln -sf lib-${AS_NAS_ARCH} lib)

exit 0
