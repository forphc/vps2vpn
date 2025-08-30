#!/bin/bash

# This script installs the base packages required by the vps2vpn setup.

apt-get install -y build-essential cmake unzip jq libssl-dev liblzo2-dev libnl-genl-3-dev libcap-ng-dev libsystemd-dev libpam0g-dev pkg-config nginx

apt-get install -y curl net-tools zip iptables-persistent dos2unix cmatrix\
 perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python3 shared-mime-info libxml-parser-perl \
 dropbear squid privoxy ziproxy stunnel4
