#!/bin/bash

# vps2vpn: A script to set up a VPN server.
# This is the main controller script that executes the installers.

# --- Load Utilities and Settings ---
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SCRIPT_DIR/installers/utils.sh"
source "$SCRIPT_DIR/settings.conf"

# --- Initial Checks ---
_echo_info "Performing initial system checks..."
[[ $EUID -ne 0 ]] && _echo_error "This script needs to be run as root, exiting..." && exit 1

source /etc/os-release
if [[ $ID == "ubuntu" ]]; then
	if [[ ${VERSION_ID%%.*} -lt 18 ]]; then
		_echo_error "This script is only compatible with Ubuntu 18.04 or later"
		exit 1
	fi
elif [[ $ID == "debian" ]]; then
	if [[ ${VERSION_ID%%.*} -lt 9 ]]; then
		_echo_error "This script is only compatible with Debian 9 or later"
		exit 1
	fi
else
	_echo_error "This script is only compatible with Ubuntu 18.04 or later or Debian 9 or later" >&2
	exit 1
fi

# --- Get Dynamic Info ---
_echo_info "Fetching network information..."
export PUBLIC_IP=$(wget -4qO - api.ipify.org)
export IFACE=$(ip route get 8.8.8.8 | awk -- '{printf $5}')

# --- Start Installation ---
cd $HOME
clear
echo "================================================="
echo "            vps2vpn Setup Script                 "
echo "================================================="
echo
read -rp " Proceed with installation? [Y/n]: "
[[ $REPLY =~ [nN] ]] && echo " Installation cancelled, exiting..." && exit

# --- Setup Logging ---
touch "$LOG_FILE"
chmod 644 "$LOG_FILE"
_echo_info "Full installation log will be available in: $LOG_FILE"
sleep 3
exec &> >(tee -a "$LOG_FILE")

export DEBIAN_FRONTEND=noninteractive
T1="$(date +%s)"

_echo_info "Updating system packages..."
apt-get update --fix-missing && apt-get upgrade -y

_echo_info "Starting component installation..."
_echo_info "This will take some time, please be patient..."
sleep 3

# --- Run Installers ---
_echo_info "Installing base packages..."
bash "$SCRIPT_DIR/installers/install_base_packages.sh" "$SCRIPT_DIR"

_echo_info "Installing OpenVPN..."
bash "$SCRIPT_DIR/installers/install_openvpn.sh" "$SCRIPT_DIR" &

_echo_info "Installing Badvpn..."
bash "$SCRIPT_DIR/installers/install_badvpn.sh" "$SCRIPT_DIR" &

_echo_info "Installing Fail2ban..."
bash "$SCRIPT_DIR/installers/install_fail2ban.sh" "$SCRIPT_DIR" &

_echo_info "Configuring system..."
bash "$SCRIPT_DIR/installers/configure_system.sh" "$SCRIPT_DIR"

_echo_info "Installing Neofetch..."
bash "$SCRIPT_DIR/installers/install_neofetch.sh" "$SCRIPT_DIR"

_echo_info "Installing Webmin..."
bash "$SCRIPT_DIR/installers/install_webmin.sh" "$SCRIPT_DIR"

_echo_info "Waiting for background installations to finish..."
wait

_echo_info "Finalizing setup..."
bash "$SCRIPT_DIR/installers/finalize.sh" "$SCRIPT_DIR"

# --- Completion ---
T2=$(date +%s)
TF=$(( T2 - T1 ))
clear
echo "================================================="
echo "            Installation Complete                "
echo "================================================="
echo -e " Duration: \033[1;32m$(date -d@$TF +%Mmin:%Ssec)\033[0m"
echo -e " Access management panel using the command → \033[1;32mmenu\033[0m"
echo ""
echo " A system reboot is required to apply all changes."
read -n1 -srp " Press any key to reboot..."
reboot
