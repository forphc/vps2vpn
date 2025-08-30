#!/bin/bash

# This script installs Badvpn.
# It is called by the main vps2vpn script.

# The first argument is the absolute path to the script's root directory
SCRIPT_DIR="$1"

# Source the main settings file
source "$SCRIPT_DIR/settings.conf"

_badvpn() {
	local ZIP="1.999.130.zip"
	rm -f "$ZIP"
	wget -q 'https://github.com/ambrop72/badvpn/archive/refs/tags/1.999.130.zip'
	unzip -q "$ZIP" && rm -f "$ZIP"
	cd badvpn-1.999.130
	mkdir build && cd build
	cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local/ -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1
	make install
	cd $HOME
	rm -rf badvpn-1.999.130
	rm -f /lib/systemd/system/badvpn-udpgw.service
	cp "$SCRIPT_DIR/configs/systemd/badvpn-udpgw.service" /lib/systemd/system/badvpn-udpgw.service
	sed -i "s/BADVPN_PORT/${BADVPN_PORT}/" /lib/systemd/system/badvpn-udpgw.service
}

_badvpn
