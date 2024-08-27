#!/bin/bash

REPO_TOP=$(git rev-parse --show-toplevel)

err_exit() {
    echo "${*}"
    exit 1
}

[ "$REPO_TOP" -a -d "$REPO_TOP" ] || {
    echo "ERROR: Not in a repo.  Stop."
    exit 1
}

build_easycwmp() {
    cd "$REPO_TOP" || err_exit
    case $1 in
	uninstall)
	    [ -f /var/lib/easycwmp/factory_defaults/easycwmp.conf ] && {
		echo "ERROR: Found factory default easycwmp.conf. Please take a backup"
		echo "copy /var/lib/easycwmp/factory_defaults/easycwmp.conf and remove"
		echo "(or use mv command). Then retry."
		err_exit "Stop."
	    }
	    sudo rm -f /usr/sbin/easycwmp
	    sudo rm -rf /usr/share/easycwmp/
	    sudo rm -f /etc/easycwmp
	    sudo rm -f /etc/config
	    sudo rm -f /lib/functions.sh
	    sudo rm -rf /lib/config/
	    sudo rm -rf /lib/functions/
	    sudo rm -f /usr/sbin/easycwmpd
	    sudo rm -rf /var/lib/easycwmp
	    ;;
	install)
	    # main script
	    sudo rm -f /usr/sbin/easycwmp
	    sudo ln -sf "$REPO_TOP"/ext/debian/scripts/easycwmp.sh /usr/sbin/easycwmp

	    # schema dir
	    [ -d /usr/share/easycwmp ] || sudo mkdir /usr/share/easycwmp

	    # defaults
	    sudo rm -f /usr/share/easycwmp/defaults
	    sudo ln -sf "$REPO_TOP"/ext/debian/scripts/defaults /usr/share/easycwmp/defaults

	    # schema scripts
	    local sdir="$REPO_TOP"/ext/debian/scripts/functions
	    local ddir=/usr/share/easycwmp/functions/
	    [ -d $ddir ] || sudo mkdir $ddir
	    #     schema scripts - common
	    sudo ln -sf $sdir/common/common		$ddir/common
	    sudo ln -sf $sdir/common/device_info	$ddir/device_info
	    sudo ln -sf $sdir/common/management_server	$ddir/management_server
	    sudo ln -sf $sdir/common/ipping_launch	$ddir/ipping_launch
	    #     schema scripts - tr181
	    sudo ln -sf $sdir/tr181/root		$ddir/root
	    sudo ln -sf $sdir/tr181/ip			$ddir/ip
	    sudo ln -sf $sdir/tr181/ipping_diagnostic	$ddir/ipping_diagnostic

	    # runtime-config
	    for ddir in easycwmp easycwmp/config easycwmp/data easycwmp/factory_defaults; do
		[ -d "/var/lib/$ddir" ] || sudo mkdir "/var/lib/$ddir"
	    done
	    ddir=/var/lib/easycwmp/factory_defaults
	    [ -f $ddir/easycwmp.conf.in ] || {
		sudo cp "$REPO_TOP"/ext/debian/config/easycwmp \
		     $ddir/easycwmp.conf.in
	    }
	    [ -f $ddir/README ] || {
		echo "1. Go to /var/lib/easycwmp/factory_defaults dir." | sudo tee $ddir/README
		echo "2. Copy easycwmp.conf.in to easycwmp.conf." | sudo tee $ddir/README
		echo "3. Update parameters in easycwmp.conf." | sudo tee -a $ddir/README
	    }
	    [ -L /etc/config ] || sudo ln -sf /var/lib/easycwmp/config /etc/config
	    [ -d /var/lib/easycwmp/data ] || sudo mkdir /var/lib/easycwmp/data
	    [ -L /etc/easycwmp ] || sudo ln -sf /var/lib/easycwmp/data /etc/easycwmp
	    [ -d /lib/config ] || sudo mkdir -p /lib/config

	    # OpenWRT compatiblility scripts (override always)
	    [ -d /lib/functions ] || sudo mkdir -p /lib/functions
	    sdir="$REPO_TOP"/ext/debian/scripts/openwrt_compat
	    sudo cp -p $sdir/functions.sh /lib/
	    sudo cp -p $sdir/uci.sh /lib/config/
	    sudo cp -p $sdir/network.sh /lib/functions/

	    # easycwmp daemom
	    [ -L /usr/sbin/easycwmpd ] || sudo ln -sf "$REPO_TOP"/bin/easycwmpd /usr/sbin/easycwmpd
	    ;;
	config)
	    autoreconf -i || err_exit
	    ./configure --enable-debug --enable-devel --enable-acs=multi --enable-jsonc=1 || err_exit
	    ;;
	build)
	    make
	    ;;
	clean)
	    make clean
	    ;;
	*)
	    echo "$SCRIPT_NAME: config|build|clean|install|uninstall"
	    exit 1
	    ;;
    esac
}

main() {
    local action=$1
    build_easycwmp $action
}

main $*
