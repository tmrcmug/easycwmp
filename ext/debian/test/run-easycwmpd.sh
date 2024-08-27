#!/bin/bash
SCRIPT_DIR=$(cd $(dirname $0) && pwd)
SCRIPT_NAME=$(basename $0)

err_exit() {
    echo "$*"
    exit 1
}

setup_env_var() {
    export UCI_CONFIG_DIR="/etc/config"
    export UBUS_SOCKET="/var/run/ubus.sock"
    [ -f /etc/default/easycwmp ] && {
        set -o allexport
        . /etc/default/easycwmp
        set +o allexport
    }
}

verify_root_access() {
    [ $(id -u) -eq 0 ] || {
	err_exit "ERROR: Please run as root user. Stop.  (TODO: allow it to run in non-root.)"
    }
}

main() {
    [ -f /var/lib/easycwmp/factory_defaults/easycwmp.conf ] || {
	echo "ERROR: No factory defaults (easycwmp.conf) file is found."
	err_exit "See /var/lib/easycwmp/factory_defaults/README. Stop."
    }
    case "$1" in
	bootstrap)
	    verify_root_access
	    cp /var/lib/easycwmp/factory_defaults/easycwmp.conf /etc/config/easycwmp
	    rm -f /var/lib/easycwmp/data/.backup.xml
	    setup_env_var
	    /usr/sbin/easycwmpd -f -b
	    ;;
	boot)
	    [ -f /etc/config/easycwmp ] || {
		err_exit "ERROR: No configuration file found in /etc/config. Stop"
	    }
	    verify_root_access
	    setup_env_var
	    /usr/sbin/easycwmpd -f -b
	    ;;
	normal)
	    [ -f /etc/config/easycwmp ] || {
		err_exit "ERROR: No configuration file found in /etc/config. Stop"
	    }
	    verify_root_access
	    setup_env_var
	    /usr/sbin/easycwmpd -f
	    ;;
	*)
	    echo "Usage: $SCRIPT_NAME bootstrap|boot|normal"
	    exit 1
    esac
}

main $*
