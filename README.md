## From vps to vpn
#### ***Installs the following services***
- Dropbear
- Squid Proxy
- Privoxy
- OpenVPN
- OpenHTTP Puncher Server
- Nginx (for .ovpn configs download links)
- Ziproxy (OHPserver's HTTP proxy)
- Stunnel4
- Badvpn-udpgw
- Webmin
- Fail2ban
#### ***Tested OS (AWS lightsail instance)***
- Ubuntu 18, 20
- Debian 9, 10
#### ***Pre-installation***
- Must be logged in as root before running the script
- Fresh vps is recommended to avoid conflict errors
- Tip: If your SSH client(e.g. Putty, Juicessh, Bitvise) keeps disconnecting due to unstable internet connection, run  `screen -S vpn` command first before using the script, and if ever you get disconnected just run `screen -r` to resume to your last session.
#### ***Installation***
Copy and paste to vps terminal then enter
```bash
wget -qO vps2vpn 'https://raw.githubusercontent.com/forphc/vps2vpn/main/vps2vpn' && bash vps2vpn
```
