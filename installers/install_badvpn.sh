#!/bin/bash

# This script installs Badvpn.

# Source the main settings file
source ../settings.conf

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
	wget -qO /lib/systemd/system/badvpn-udpgw.service "$REPO_BASE_URL"/configs/systemd/badvpn-udpgw.service
	sed -i "s/BADVPN_PORT/${BADVPN_PORT}/" /lib/systemd/system/badvpn-udpgw.service
}

_badvpn
