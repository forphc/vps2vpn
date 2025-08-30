#!/bin/bash

# This script finalizes the installation by starting services and setting up the firewall.
# It is called by the main vps2vpn script.

# The first argument is the absolute path to the script's root directory
SCRIPT_DIR="$1"

# Source the main settings and utility files
source "$SCRIPT_DIR/settings.conf"
source "$SCRIPT_DIR/installers/utils.sh"

_echo_info "Firing up services..."
SERVICE_NAME=(dropbear squid privoxy ziproxy nginx stunnel4 webmin openvpn-server@server_tcp openvpn-server@server_udp badvpn-udpgw fail2ban)
systemctl daemon-reload
for service in "${SERVICE_NAME[@]}"; do
	systemctl enable "$service"
	systemctl restart "$service"
done

RULES="/etc/iptables/rules.v4"
iptables-save > "$RULES"

[[ $(grep -c -- "-A POSTROUTING -s 10.8.0.0/16 -o "$IFACE" -j MASQUERADE" "$RULES") -eq 0 ]] && iptables -t nat -A POSTROUTING -s 10.8.0.0/16 -o "$IFACE" -j MASQUERADE
[[ $(grep -c -- "-A POSTROUTING -s 10.8.0.0/16 -o "$IFACE" -j SNAT --to-source "$PUBLIC_IP"" "$RULES") -eq 0 ]] && iptables -t nat -A POSTROUTING -s 10.8.0.0/16 -o "$IFACE" -j SNAT --to-source "$PUBLIC_IP"
[[ $(grep -c -- "-A FORWARD -s 10.8.0.0/16 -j ACCEPT" "$RULES") -eq 0 ]] && iptables -A FORWARD -s 10.8.0.0/16 -j ACCEPT

iptables-save > "$RULES"
netfilter-persistent save
systemctl enable netfilter-persistent
