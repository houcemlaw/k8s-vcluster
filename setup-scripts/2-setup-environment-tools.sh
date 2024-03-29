#!/usr/bin/env bash

# set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical

echo "grub-pc grub-pc/install_devices multiselect /dev/sda1" | sudo debconf-set-selections

sudo timedatectl set-timezone 'Europe/Paris'
sudo dpkg-reconfigure --frontend=${DEBIAN_FRONTEND} tzdata

sudo apt-get update

sudo apt-get --quiet --yes install git vim curl wget htop tmux jq net-tools resolvconf

echo "nameserver 1.1.1.1" | sudo tee /etc/resolvconf/resolv.conf.d/head
echo "nameserver 1.0.0.1" | sudo tee -a /etc/resolvconf/resolv.conf.d/head
sudo resolvconf -u

cp -v /vagrant/config/.vimrc ~/.vimrc
cp -v /vagrant/config/.tmux.conf ~/.tmux.conf

