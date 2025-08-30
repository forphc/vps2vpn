#!/bin/bash

# This script installs Neofetch.

wget -qO neofetch.tar.gz "https://github.com/dylanaraps/neofetch/archive/refs/tags/7.1.0.tar.gz"
tar xzf neofetch.tar.gz && rm -f neofetch.tar.gz
cd neofetch-7.1.0
make install
cd $HOME
rm -rf neofetch-7.1.0
