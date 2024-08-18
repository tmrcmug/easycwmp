#!/bin/bash

REPO_TOP=$(git rev-parse --show-toplevel)

[ "$REPO_TOP" -a -d "$REPO_TOP" ] || {
    echo "ERROR: Not in repository. Nothing cleaned. Stop."
    exit 1
}

cd "$REPO_TOP"

# clean easycwmp build
[ -f Makefile ] && make clean

# 
rm -f	INSTALL
rm -f	Makefile
rm -f	Makefile.in
rm -f	aclocal.m4
rm -rf	autom4te.cache/
rm -f	bin/Makefile
rm -f	bin/Makefile.in
rm -f	compile
rm -f	config.log
rm -f	config.status
rm -f	configure
rm -f	configure~
rm -f	depcomp
rm -f	install-sh
rm -f	missing
rm -rf	src/.deps/
rm -f	src/.dirstamp

rm -rf	json-c/
rm -rf	libubox/
rm -rf	ubus/
rm -rf	uci/
rm -rf	microxml/
