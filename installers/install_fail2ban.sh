#!/bin/bash

# This script installs Fail2ban.
# It is called by the main vps2vpn script.

# The first argument is the absolute path to the script's root directory
SCRIPT_DIR="$1"

# Source the main settings file
source "$SCRIPT_DIR/settings.conf"

_fail2ban() {
	wget -qO fail2ban.tar.gz "https://github.com/fail2ban/fail2ban/archive/refs/tags/1.1.0.tar.gz"
	tar xzf fail2ban.tar.gz && rm -f fail2ban.tar.gz
	cd fail2ban-1.1.0
	python setup.py install
	cp build/fail2ban.service /etc/systemd/system/fail2ban.service
	cd /etc/fail2ban
	cp fail2ban.conf fail2ban.local
	mv jail.conf jail.conf.bak
	mv fail2ban.conf fail2ban.conf.bak
	cp "$SCRIPT_DIR/configs/fail2ban/jail.local" /etc/fail2ban/jail.local
	cd $HOME && rm -rf fail2ban-1.1.0
}

_fail2ban
