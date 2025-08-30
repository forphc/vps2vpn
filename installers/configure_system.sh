#!/bin/bash

# This script handles the main system configuration tasks.
# It is called by the main vps2vpn script.

# The first argument is the absolute path to the script's root directory
SCRIPT_DIR="$1"

# Source the main settings file
source "$SCRIPT_DIR/settings.conf"

_configurations() {
	sed -i "s/NO_START=.*/NO_START=0/;s/DROPBEAR_PORT=.*/DROPBEAR_PORT=${DROPBEAR_PORT}/;s/DROPBEAR_BANNER=.*/DROPBEAR_BANNER='\/etc\/banner'/" /etc/default/dropbear
	rm -f /etc/banner && touch /etc/banner

	mv /etc/squid/squid.conf /etc/squid/squid.conf.bak
	cp "$SCRIPT_DIR/configs/squid/squid.conf" /etc/squid/squid.conf
	sed -i "s/PUBLIC_IP/${PUBLIC_IP}/g;s/SQUID_PORT/${SQUID_PORT}/g" /etc/squid/squid.conf

	mv /etc/privoxy/config /etc/privoxy/config.bak
	cp "$SCRIPT_DIR/configs/privoxy/privoxy_config" /etc/privoxy/config
	sed -i "s/PUBLIC_IP/${PUBLIC_IP}/g;s/PRIVOXY_PORT/${PRIVOXY_PORT}/g" /etc/privoxy/config

	mv /etc/ziproxy/ziproxy.conf /etc/ziproxy/ziproxy.conf.bak
	cat >> /etc/ziproxy/ziproxy.conf << END
Port = ${ZIPROXY_PORT}
Address = "127.0.0.1"
END

	mkdir -p /var/log/stunnel
	mv /etc/stunnel/stunnel.conf /etc/stunnel/stunnel.conf.bak
	cp "$SCRIPT_DIR/configs/stunnel/stunnel.conf" /etc/stunnel/stunnel.conf
	sed -i "s/STUNNEL_DROPBEAR_PORT/${STUNNEL_DROPBEAR_PORT}/;s/STUNNEL_OVPN_PORT/${STUNNEL_OVPN_PORT}/" /etc/stunnel/stunnel.conf
	sed -i "s/DROPBEAR_PORT/${DROPBEAR_PORT}/;s/OVPN_TCP_PORT/${OVPN_TCP_PORT}/" /etc/stunnel/stunnel.conf

	rm -f /etc/stunnel/stunnel.pem
	cp "$SCRIPT_DIR/configs/stunnel/stunnel.pem" /etc/stunnel/stunnel.pem
	sed -i "s/ENABLED=0/ENABLED=1/" /etc/default/stunnel4


	cp "$SCRIPT_DIR/configs/menu/menu.txt" /tmp/menu.txt
	while read -r FILE; do
		rm -f /usr/local/sbin/"$FILE"
		cp "$SCRIPT_DIR/configs/menu/$FILE" "/usr/local/sbin/$FILE"
		chmod 755 /usr/local/sbin/"$FILE"
		dos2unix /usr/local/sbin/"$FILE"
	done < /tmp/menu.txt
	rm -f /tmp/menu.txt

	[[ ! $(grep '/bin/false' /etc/shells) ]] && echo "/bin/false" >> /etc/shells
	[[ ! $(grep '/usr/sbin/nologin' /etc/shells) ]] && echo "/usr/sbin/nologin" >> /etc/shells

	if [[ $(sysctl net.ipv4.ip_forward | awk -F'= ' '{print $2}') -eq 0 ]]; then
		echo 1 > /proc/sys/net/ipv4/ip_forward
		echo "net.ipv4.ip_forward=1" >> /etc/sysctl.d/custom.conf
		sysctl -p /etc/sysctl.d/custom.conf
	fi

	timedatectl set-timezone Asia/Manila

	cp "$SCRIPT_DIR/utils/delexp.sh" "$HOME/.delexp.sh"
	chmod 755 $HOME/.delexp.sh

	crontab -l > mycron &>/dev/null
	cat >> mycron << END
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
0 1 * * * $HOME/.delexp.sh &>>$HOME/.delexp.log
END
	crontab mycron && rm mycron
	systemctl enable cron &>/dev/null

	echo -e "clear\nneofetch" > /etc/profile.d/login.sh
}

_configurations
