#!/bin/bash

# This script installs OpenVPN.
# It is called by the main vps2vpn script.

# Enable verbose debugging
set -x

# The first argument is the absolute path to the script's root directory
SCRIPT_DIR="$1"

# Source the main settings file
source "$SCRIPT_DIR/settings.conf"
# Source utils for _echo_info
source "$SCRIPT_DIR/installers/utils.sh"

_openvpn() {
	_echo_info "Downloading and compiling OpenVPN..."
	wget -qO openvpn.tar.gz "https://swupdate.openvpn.net/community/releases/openvpn-2.6.14.tar.gz"
	tar xzf openvpn.tar.gz && rm -f openvpn.tar.gz
	cd openvpn-2.6.14
	./configure --enable-systemd --disable-lz4
	make -j$(nproc)
	make install
	cd $HOME
	rm -rf openvpn-2.6.14
	_echo_info "Finished compiling OpenVPN."

	_echo_info "Setting up OpenVPN directories and certificates..."
	rm -rf /etc/openvpn/server && mkdir -p /etc/openvpn/server
	rm -rf /var/log/openvpn && mkdir -p /var/log/openvpn

	cp "$SCRIPT_DIR/rsa-1024.zip" .
	unzip -q -d '/etc/openvpn' rsa-1024.zip && rm -f rsa-1024.zip
	_echo_info "Finished setting up directories."

	_echo_info "Configuring OpenVPN server instances..."
	for item in "server_tcp" "server_udp"; do
		_echo_info "Configuring $item..."
		cp "$SCRIPT_DIR/configs/openvpn/$item.conf" "/etc/openvpn/server/$item.conf"
		printf "\nplugin %s /etc/pam.d/login" "$(find /usr -name openvpn-plugin-auth-pam.so | head -1)" | tee -a /etc/openvpn/server/"$item".conf
		sed -i "s/OVPN_TCP_PORT/${OVPN_TCP_PORT}/;s/OVPN_UDP_PORT/${OVPN_UDP_PORT}/" /etc/openvpn/server/"$item".conf

		rm -f /lib/systemd/system/openvpn-server@"$item".service
		cat >> /lib/systemd/system/openvpn-server@"$item".service << END
[Unit]
Description=OpenVPN service for %I
After=syslog.target network-online.target
Wants=network-online.target
Documentation=man:openvpn(8)
Documentation=https://community.openvpn.net/openvpn/wiki/Openvpn24ManPage
Documentation=https://community.openvpn.net/openvpn/wiki/HOWTO

[Service]
Type=notify
PrivateTmp=true
WorkingDirectory=/etc/openvpn/server
ExecStart=$(which openvpn) --status %t/openvpn-server/status-%i.log --status-version 2 --suppress-timestamps --config %i.conf
CapabilityBoundingSet=CAP_IPC_LOCK CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW CAP_SETGID CAP_SETUID CAP_SYS_CHROOT CAP_DAC_OVERRIDE CAP_AUDIT_WRITE
LimitNPROC=10
DeviceAllow=/dev/null rw
DeviceAllow=/dev/net/tun rw
ProtectSystem=true
ProtectHome=true
KillMode=process
RestartSec=5s
Restart=on-failure

[Install]
WantedBy=multi-user.target
END
	done
	_echo_info "Finished configuring server instances."

	_echo_info "Reloading systemd daemon..."
	systemctl daemon-reload
	_echo_info "Finished reloading systemd."

	# Nginx configuration for ovpn config DL site
	_echo_info "Configuring Nginx for client config download..."
	rm -f /etc/nginx/conf.d/ovpn.conf
	cat >> /etc/nginx/conf.d/ovpn.conf << END
server {
	listen 0.0.0.0:${NGINX_PORT};
	server_name localhost;
	root /var/www/openvpn;
	index index.html;
}
END
	rm -rf /etc/nginx/sites-*
	rm -rf /var/www/openvpn && mkdir -p /var/www/openvpn
	cp "$SCRIPT_DIR/configs/nginx/index.html" /var/www/openvpn/
	_echo_info "Finished Nginx configuration."

	_echo_info "Generating client .ovpn files..."
	local CLIENT_CONFIG=(client_tcp.ovpn client_udp.ovpn)
	local OPENVPN_SERVER_VERSION=$(openvpn --version | grep -w "^OpenVPN" | awk '{print $2}')
	local ISP=$(wget -qO - http://ipwhois.app/json/ | jq -r '.isp')
	local COUNTRY=$(wget -qO - http://ipwhois.app/json/ | jq -r '.country')
	local REGION=$(wget -qO - http://ipwhois.app/json/ | jq -r '.region')
	local DATE=$(date +%m-%d-%Y)
	for ovpn in "${CLIENT_CONFIG[@]}"; do
		cp "$SCRIPT_DIR/configs/openvpn/$ovpn" "/var/www/openvpn/$ovpn"
		echo -e "\n<ca>" >> /var/www/openvpn/"$ovpn"
		tee -a /var/www/openvpn/"$ovpn" < /etc/openvpn/ca.crt >/dev/null
		echo "</ca>" >> /var/www/openvpn/"$ovpn"
		sed -i "s/OVPN_VERSION/${OPENVPN_SERVER_VERSION}/;s/SERVER_ISP/${ISP}/;s/COUNTRY/${REGION}, ${COUNTRY}/;s/PUBLIC_IP/${PUBLIC_IP}/g;s/DATE/${DATE}/" /var/www/openvpn/"$ovpn"
		sed -i "s/OVPN_TCP_PORT/${OVPN_TCP_PORT}/g;s/OVPN_UDP_PORT/${OVPN_UDP_PORT}/g;s/PRIVOXY_PORT/${PRIVOXY_PORT}/g" /var/www/openvpn/"$ovpn"
	done
	_echo_info "Finished generating client files."
}

_openvpn
