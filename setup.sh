#!/bin/bash
set -e

FETCH_PACKAGES=0

show_help() {
    echo "Options:
  -f    Fetch packages instead of using local ones
  -h    This help"
    exit 0
}

while getopts :fgh opts; do
   case $opts in
        f)
            FETCH_PACKAGES=1
            ;;
        h)
            show_help
            ;;
   esac
done


ROOT=$(cd $(dirname "${0}") && pwd)
PACKAGE=$(basename "${ROOT}")
VERSION=$(<version.txt)

# This defines the arches available and from where to fetch the files
# ARCH:PREFIX
ADM_ARCH=(
    "x86-64:/cross/x86_64-asustor-linux-gnu"
    "i386:/cross/i686-asustor-linux-gnu"
)

# Set hostname (ssh) from where to fetch the files
HOST=asustorx

cd $ROOT

if [[ ! -d dist ]]; then
    mkdir dist
fi

for arch in ${ADM_ARCH[@]}; do
    cross=${arch#*:}
    arch=${arch%:*}

    echo "Building ${arch} from ${HOST}:${cross}"

    # Create temp directory and copy the APKG template
    PKG_DIR=build/packages/$arch
    if [ ! -d $PKG_DIR ]; then
        mkdir -p $PKG_DIR
    fi
    if [ $FETCH_PACKAGES -eq 1 ]; then
        rm -rf $PKG_DIR/*
        echo "Rsyncing packages..."
        rsync -ramv --include-from=packages.txt --exclude="*/*" --exclude="Packages" $HOST:$cross/packages/* $PKG_DIR
        PKG_INSTALLED=$(cd $PKG_DIR; ls -1 */*.tbz2 | sort)
        echo -e "# This file is auto-generated.\n${PKG_INSTALLED//.tbz2/}" > pkgversions_$arch.txt
    else
        echo "Using cached packages..."
    fi

    WORK_DIR=build/$arch
    if [ ! -d $WORK_DIR ]; then
        mkdir -p $WORK_DIR
    fi
    echo "Cleaning out ${WORK_DIR}..."
    rm -rf $WORK_DIR/*
    chmod 0755 $WORK_DIR

    echo "Unpacking files..."
    (cd $WORK_DIR; for pkg in $ROOT/$PKG_DIR/*/*.tbz2; do tar xjf $pkg; done)

    # echo "Grabbing required files..."

    (cd $WORK_DIR;
        cp usr/bin/cec-client $ROOT/source/bin/cec-client-$arch
        [ ! -d $ROOT/source/lib-$arch ] && mkdir $ROOT/source/lib-$arch
        find . -not -name "libudev.so" -name "*.so*" -exec cp -af {} $ROOT/source/lib-$arch \;)
    (cd $ROOT/source/lib-$arch;
        ln -sf $(readlink libudev.so.1) libudev.so)

done

# echo "Copying apkg skeleton..."
APKG_DIR=$(mktemp -d /tmp/${PACKAGE}.XXXXXX)
rsync -ra source/* $APKG_DIR

echo "Finalizing..."
echo "Setting version to ${VERSION}"
sed -i '' -e "s^ADM_ARCH^any^" -e "s^APKG_VERSION^${VERSION}^" $APKG_DIR/CONTROL/config.json

echo "Building APK..."
# APKs require root privileges, make sure priviliges are correct
sudo chown -R 0:0 $APKG_DIR
sudo scripts/apkg-tools.py create $APKG_DIR --destination dist/
sudo chown -R $(whoami) dist

# Clean up
sudo rm -rf $APKG_DIR

echo "Done!"
