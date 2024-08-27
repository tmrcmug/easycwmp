1. EasyCwmp  
===========
EasyCwmp is a GPLv2 open source implementation of the TR069 cwmp standard. EasyCwmp is developed by PIVA Software (www.pivasoftware.com) and it is derived from the project freecwmp.The aim of this project is to be fully conform with the TR069 CWMP standard.

2.  EasyCwmp sources
====================

 http://www.easycwmp.org/index.php/downloads

3.  EasyCwmp dependencies
=========================

    libuci
    libcurl
    json-c
    libubox
    libubus
    microxml: microxml is a fork of Mini-XML, it's being used to parse XML blocks passed between ACS and the client and it's published by freecwmp guys:
		microxml source:
		git clone https://github.com/pivasoftware/microxml.git
		microxml OpenWRT package:
		wget http://easycwmp.org/download/libmicroxml.tar.gz

 

4.  EasyCwmp install for OpenWRT Linux
======================================

EachCwmp is not properly built in feeds package build system in OpenWRT 23.05 as is written in README at https://github.com/pivasoftware/easycwmp. Removing the section content from this fork to avoid confusion.


5. EasyCwmp install for other Linux distributions:
==================================================

general
=======

curl
====
Your distribution should already have curl development package. Use that for now.

Note: If you build libcurl with an SSL package dependency, it is recommended to build with OpenSSL since EasyCwmp was mainly tested with libcurl using OpenSSL.

The digest authentication with ACS server will not work if you build libcurl with PolarSSL.

json-c
======

git clone https://github.com/json-c/json-c.git json-c
cd json-c/

Configure:

mkdir build
cd build/
cmake ../CMakeLists.txt
../cmake-configure --prefix=/usr/local

Build:
make

Install:

sudo make install
sudo ln -sf /usr/local/include/json-c /usr/local/include/json
sudo ln -sf /usr/local/lib/libjson-c.so /usr/lib/libjson-c.so
sudo ln -sf /usr/local/lib/libblobmsg_json.so /usr/lib/libblobmsg_json.so

libubox
=======

Get the sources:

git git clone https://github.com/openwrt/libubox libubox
cd libubox/

Configure:

cmake CMakeLists.txt -DBUILD_LUA=OFF

Build:

make

Install:

sudo make install
sudo ln -sf /usr/local/lib/libubox.so /usr/lib/libubox.so
sudo mkdir -p /usr/share/libubox
sudo ln -sf /usr/local/share/libubox/jshn.sh /usr/share/libubox/jshn.sh
 

uci
===

Get the sources:

git clone https://github.com/openwrt/uci.git uci
cd uci/

Configure:

cmake CMakeLists.txt -DBUILD_LUA=OFF

Build:

make

Install:

class="western"
sudo make install
sudo ln -sf /usr/local/bin/uci /sbin/uci
sudo ln -sf /usr/local/lib/libuci.so /usr/lib/libuci.so


ubus
====

Get the sources:

git clone https://github.com/openwrt/ubus.git ubus
cd ubus/

Configure:

cmake CMakeLists.txt -DBUILD_LUA=OFF

Build:

make

Install:

sudo make install
sudo ln -sf /usr/local/sbin/ubusd /usr/sbin/ubusd
sudo ln -sf /usr/local/lib/libubus.so /usr/lib/libubus.so

 

microxml
========

Get the sources:

git clone https://github.com/pivasoftware/microxml.git microxml
cd microxml/

Generate configuration files:

autoconf -i

Configure:

./configure --prefix=/usr --enable-threads --enable-shared --enable-static

Build:

make

Install:

sudo make install
sudo ln -sf /usr/lib/libmicroxml.so.1.0 /lib/libmicroxml.so
sudo ln -sf /usr/lib/libmicroxml.so.1.0 /lib/libmicroxml.so.1
 

easycwmp
========

compiling:
Once the dependencies have been installed we can start compiling easycwmp.

Get the sources:

Clone git repository from fork: https://github.com/tmrcmug/easycwmp.git
cd easycwmp

Generate configuration files:

autoreconf -i

Configure:

./configure --enable-debug --enable-devel --enable-acs=multi --enable-jsonc=1

Build:

make

configuration

We won’t install easycwmp, we’ll use it from current directory.

Because we are using this setup for development we want that all our changes are visible in our git clone. Best way to do this is to use symlinks. First create the directory where scripts are located on actual device:

sudo mkdir -p /usr/share/easycwmp/functions
sudo mkdir -p /etc/easycwmp

Then create symlinks for easycwmp scripts:

sudo ln -sf $PWD/ext/openwrt/scripts/easycwmp.sh /usr/sbin/easycwmp
sudo ln -sf $PWD/ext/openwrt/scripts/defaults /usr/share/$PWD/defaults
sudo ln -sf $PWD/ext/openwrt/scripts/functions/common/common /usr/share/easycwmp/functions/common
sudo ln -sf $PWD/ext/openwrt/scripts/functions/common/device_info /usr/share/easycwmp/functions/device_info
sudo ln -sf $PWD/ext/openwrt/scripts/functions/common/management_server /usr/share/easycwmp/functions/management_server
sudo ln -sf $PWD/ext/openwrt/scripts/functions/common/ipping_launch /usr/share/easycwmp/functions/ipping_launch
sudo ln -sf $PWD/ext/openwrt/scripts/functions/tr181/root /usr/share/easycwmp/functions/root
sudo ln -sf $PWD/ext/openwrt/scripts/functions/tr181/ip /usr/share/easycwmp/functions/ip
sudo ln -sf $PWD/ext/openwrt/scripts/functions/tr181/ipping_diagnostic /usr/share/easycwmp/functions/ipping_diagnostic

then

chmod +x $PWD/ext/openwrt/scripts/functions/*

Also, you can create symlink for easycwmp configuration file:

sudo mkdir /etc/config
sudo ln -sf $PWD/ext/openwrt/config/easycwmp /etc/config/easycwmp

And finally create symlink for easycwmpd binary:

sudo ln -sf $PWD/bin/easycwmpd /usr/sbin/easycwmpd

We need to export few variables that are used in easycwmp scripts:

export UCI_CONFIG_DIR="/etc/config/"
export UBUS_SOCKET="/var/run/ubus.sock"

Install few shell scripts from OpenWrt (copied from debian which should be compatible):

```
sudo mkdir -p /lib/{config,functions}
sudo cp ext/debian/scripts/openwrt_compat/functions.sh /lib
sudo cp ext/debian/scripts/openwrt_compat/uci.sh /lib/config
sudo cp ext/debian/scripts/openwrt_compat/network.sh /lib/functions
```

If everything is configured properly when you run:

bash /usr/sbin/easycwmp get value Device.

You should see some output like this:

{ "parameter": "Device.DeviceInfo.Manufacturer", "fault_code": "", "value": "easycwmp", "type": "xsd:string" }
{ "parameter": "Device.DeviceInfo.ManufacturerOUI", "fault_code": "", "value": "FFFFFF", "type": "xsd:string" }
{ "parameter": "Device.DeviceInfo.ProductClass", "fault_code": "", "value": "easycwmp", "type": "xsd:string" }
{ "parameter": "Device.DeviceInfo.SerialNumber", "fault_code": "", "value": "FFFFFF123456", "type": "xsd:string" }
{ "parameter": "Device.DeviceInfo.HardwareVersion", "fault_code": "", "value": "example_hw_version", "type": "xsd:string" }
{ "parameter": "Device.DeviceInfo.SoftwareVersion", "fault_code": "", "value": "example_sw_version", "type": "xsd:string" }
{ "parameter": "Device.DeviceInfo.UpTime", "fault_code": "", "value": "429120", "type": "xsd:string" }
...

Depending on your system you might need to:

export PATH=$PATH:/usr/sbin:/sbin
sudo ln -sf bash /bin/sh

Please note that your system /bin/sh symbolic link should be pointed to the bash interpretor.

Make changes in /etc/config/easycwmp and in /usr/share/easycwmp/defaults so easycwmpd can connect to your ACS server. But before you run easycwmpd make sure that you have in another terminal running ubusd:

/usr/sbin/ubusd -s /var/run/ubus.sock

Finally run easycwmpd as root:

/usr/sbin/easycwmpd -f -b

Note: A third party application could trigger EasyCwmp daemon to send notify (inform with value change event) by calling the command:

ubus call tr069 notify

If the EasyCwmp daemon receive the ubus call notify then it will check if there is a value changed of parameters with notification not equal to 0


6. EasyCwmp development environment setup on Debian 12:
=======================================================

To setup development environment of EasyCwmp on Debian 12 host, follow the steps below:

    - Install Debian 12
    - Clone git repository from fork: https://github.com/tmrcmug/easycwmp.git
    - Run `ext/debian/build/setup-build-environment.sh` to install necessary packages to build.
    - Run `ext/debian/build/setup-runtime-environment.sh` to install necessary pacakge to run.
    - Run `ext/debian/build/build-depends.sh` to build and install dependent libraries and header files.
    - Run `ext/debian/build/build-easycwmp-devenv.sh config` to prepare for agent binary build
    - Run `ext/debian/build/build-easycwmp-devenv.sh build` to build agent binary
    - Run `ext/debian/build/build-easycwmp-devenv.sh install` to install and initialize the run-time environment.
    - Setup test ACS - this is outside scope of this README -
    - Configure factory default file /var/lib/easycwmp/factory_defaults/easycwmp.conf
    - Run `ext/debian/test/run-easycwmpd.sh booststrap` to manually connect to ACS and start test.
    - Ctrl-C to terminate the program.
    - Run `ext/debian/test/run-easycwmpd.sh normal` to manually connect to ACS and start test.
    - Run `ext/debian/test/run-easycwmpd.sh boot` to simulate reboot scenario.
    - Run `ext/debian/test/run-easycwmpd.sh booststrap` to simulate factory reset scenario.

For the factory default, Use easycwmp.conf.in in the same directory as template.

To setup deployment environment (restart on reboot) on Debian 12 host, follow the steps below:

    - Using sudo, copy ext/debian/systemd/easycwmp.service file to /etc/systemd/system/easycwmp.service
    - Run `sudo systemctl daemon-reload && sudo systemctl enable easycwmp.service && sudo systemctl start easycwmp.service` to register and start in systemd daemon.
    - To monitor log output, use -f option on journalctl like `sudo journalctl -u easycwmp -f`

HTTP Proxy
==========

OPTIONAL: If ACS is reachable only through HTTP proxy, configure HTTP proxy in /etc/default/easycwmp

```
http_proxy=https://user:password@host:port
HTTP_PROXY=https://user:password@host:port
https_proxy=https://user:password@host:port
HTTPS_PROXY=https://user:password@host:port
no_proxy="192.168.0.0/16, 172.16.0.0/12, 10.0.0.0/8, 127.0.0.0/8, localhost"
NO_PROXY="192.168.0.0/16, 172.16.0.0/12, 10.0.0.0/8, 127.0.0.0/8, localhost"
```
