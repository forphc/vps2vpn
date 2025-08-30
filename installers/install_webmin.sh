#!/bin/bash

# This script installs Webmin.

wget -qO webmin_latest.deb http://www.webmin.com/download/deb/webmin-current.deb
dpkg --install webmin_latest.deb
rm -f webmin_latest.deb
sed -i "s/ssl=1/ssl=0/" /etc/webmin/miniserv.conf
