#!/bin/bash

REPO_TOP=$(git rev-parse --show-toplevel)

err_exit() {
    echo "ERROR: Build error.  Stop."
    exit 1
}

[ "$REPO_TOP" -a -d "$REPO_TOP" ] || {
    echo "ERROR: Not in a repo.  Stop."
    exit 1
}

[ -d "$REPO_TOP"/depends ] || {
    mkdir "$REPO_TOP"/depends
}

build_json_c() {
    cd "$REPO_TOP"/depends || err_exit
    case $1 in
	uninstall)
	    sudo rm -rf /usr/local/include/json-c /usr/local/include/json
	    ;;
	*)
	    # pull source
	    [ -d json-c ] || {
		git clone https://github.com/json-c/json-c.git json-c || err_exit
	    }

	    # configure
	    cd json-c || err_exit
	    [ -d build ] || {
		mkdir build || err_exit
	    }
	    cd build || err_exit
	    cmake ../CMakeLists.txt || err_exit
	    ../cmake-configure --prefix=/usr/local || err_exit

	    # build
	    make || err_exit

	    # install
	    sudo make install || err_exit
	    sudo ln -sf /usr/local/include/json-c /usr/local/include/json || err_exit
	    sudo ln -sf /usr/local/lib/libjson-c.so /usr/lib/libjson-c.so || err_exit
	    sudo ln -sf /usr/local/lib/libblobmsg_json.so /usr/lib/libblobmsg_json.so || err_exit
	    ;;
    esac
}

build_libubox() {
    cd "$REPO_TOP"/depends || err_exit
    case $1 in
	uninstall)
	    sudo rm -rf /usr/local/lib/libubox.so /usr/lib/libubox.so
	    sudo rm -rf /usr/local/share/libubox/jshn.sh /usr/share/libubox/jshn.sh
	    sudo rm -rf /usr/share/libubox
	    ;;
	*)
	    # pull source
	    [ -d libubox ] || {
		git clone https://github.com/openwrt/libubox libubox || err_exit
	    }

	    # configure
	    cd libubox || err_exit
	    cmake CMakeLists.txt -DBUILD_LUA=OFF || err_exit

	    # build
	    make || err_exit

	    # install
	    sudo make install || err_exit
	    sudo ln -sf /usr/local/lib/libubox.so /usr/lib/libubox.so || err_exit
	    sudo mkdir -p /usr/share/libubox || err_exit
	    sudo ln -sf /usr/local/share/libubox/jshn.sh /usr/share/libubox/jshn.sh || err_exit
	    ;;
    esac
}

build_uci() {
    cd "$REPO_TOP"/depends || err_exit
    case $1 in
	uninstall)
	    sudo rm -f /usr/local/bin/uci /sbin/uci
	    sudo rm -f /usr/local/lib/libuci.so /usr/lib/libuci.so
	    ;;
	*)
	    # pull source
	    [ -d uci ] || {
		git clone https://github.com/openwrt/uci.git uci || err_exit
	    }

	    # configure
	    cd uci || err_exit
	    cmake CMakeLists.txt -DBUILD_LUA=OFF || err_exit

	    # build
	    make || err_exit

	    # install
	    class="western" || err_exit
	    sudo make install || err_exit
	    sudo ln -sf /usr/local/bin/uci /sbin/uci || err_exit
	    sudo ln -sf /usr/local/lib/libuci.so /usr/lib/libuci.so || err_exit
	    ;;
    esac
}

build_ubus() {
    cd "$REPO_TOP"/depends || err_exit
    case $1 in
	uninstall)
	    sudo rm -f /usr/local/sbin/ubusd /usr/sbin/ubusd
	    sudo rm -f /usr/local/lib/libubus.so /usr/lib/libubus.so
	    ;;
	*)
	    # pull source
	    [ -d ubus ] || {
		git clone https://github.com/openwrt/ubus.git ubus || err_exit
	    }

	    # configure
	    cd ubus || err_exit
	    cmake CMakeLists.txt -DBUILD_LUA=OFF || err_exit

	    # build
	    make || err_exit

	    # install
	    sudo make install || err_exit
	    sudo ln -sf /usr/local/sbin/ubusd /usr/sbin/ubusd || err_exit
	    sudo ln -sf /usr/local/lib/libubus.so /usr/lib/libubus.so || err_exit
	    ;;
    esac
}

build_microxml() {
    cd "$REPO_TOP"/depends || err_exit
    case $1 in
	uninstall)
	    sudo rm -rf /usr/lib/libmicroxml.so.1.0 /lib/libmicroxml.so /lib/libmicroxml.so.1
	    ;;
	clean)
	    rm -rf microxml
	    ;;
	*)
	    # pull source
	    [ -d microxml ] || {
		git clone https://github.com/pivasoftware/microxml.git microxml || err_exit
	    }

	    # configure
	    cd microxml || err_exit
	    autoconf -i || err_exit
	    ./configure --prefix=/usr --enable-threads --enable-shared --enable-static || err_exit

	    # build
	    make || err_exit

	    # install
	    sudo make install || err_exit
	    sudo ln -sf /usr/lib/libmicroxml.so.1.0 /lib/libmicroxml.so || err_exit
	    sudo ln -sf /usr/lib/libmicroxml.so.1.0 /lib/libmicroxml.so.1 || err_exit
	    ;;
    esac
}

main() {
    local action=$1
    [ "$action" = 'clean' ] && {
	rm -rf "$REPO_TOP"/depends
	exit 0
    }

    build_json_c $action
    build_libubox $action
    build_uci $action
    build_ubus $action
    build_microxml $action
}

main $*
