#!/bin/sh -e

NAME=libcec

if [ -z $APKG_PKG_DIR ]; then
    PKG_DIR=/usr/local/AppCentral/libcec
else
    PKG_DIR=$APKG_PKG_DIR
fi

. /lib/lsb/init-functions

start_daemon () {
    # Load kernel module
    MOD_PATH=$PKG_DIR/modules
    lsmod | grep -q '^cdc_acm' || insmod ${MOD_PATH}/cdc-acm.ko || true
}

stop_daemon () {
    lsmod | grep -q '^cdc_acm' && modprobe -r cdc_acm || true
}


case "$1" in
    start)
        log_daemon_msg "Starting" "$NAME"
        start_daemon
        log_end_msg 0
        ;;
    stop)
        log_daemon_msg "Stopping" "$NAME"
        stop_daemon
        log_end_msg 0
        ;;
    reload)
        log_daemon_msg "Reloading" "$NAME"
        stop_daemon
        start_daemon
        log_end_msg 0
        ;;
    restart|force-reload)
        log_daemon_msg "Restarting" "$NAME"
        stop_daemon
        start_daemon
        log_end_msg 0
        ;;
    *)
        echo "Usage: start-stop.sh {start|stop|reload|force-reload|restart}"
        exit 2
        ;;
esac

exit 0
