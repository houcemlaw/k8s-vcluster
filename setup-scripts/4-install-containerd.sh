#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

sudo apt-get install --reinstall --quiet --yes systemd

echo "################### INSTALLING CONTAINERD ###################"
####### STEP-1: INSTALL CONTAINERD #############
CONTAINERD_VERSION="2.0.0"

#SANDBOX_IMAGE="registry.k8s.io/pause:3.10"
#you may wish to override the sandbox in the future=> change it in /etc/containerd/config.toml

curl -LfsS https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz -o containerd.tar.gz
sudo tar Cxzvf /usr/local containerd.tar.gz
rm -fv containerd.tar.gz

#### Configuring the systemd cgroup driver (SystemdCgroup = true in config.tom)
sudo mkdir -pv /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/^\(\s*SystemdCgroup\)\s*=\s*false$/\1 = true/' /etc/containerd/config.toml
# update containerd.service file
sudo mkdir -pv /usr/local/lib/systemd/system
sudo cp -v /vagrant/config/containerd.service /usr/local/lib/systemd/system/containerd.service
sudo systemctl daemon-reload
sudo systemctl enable --now containerd

echo "################### INSTALLING RUNC ###################"
####### STEP-2: INSTALL RUNC #############
RUNC_VERSION="1.2.1"
curl -LfsSO https://github.com/opencontainers/runc/releases/download/v${RUNC_VERSION}/runc.amd64
sudo install -o root -g root -m 755 runc.amd64 /usr/local/sbin/runc
rm -fv runc.amd64

echo "################### INSTALLING CNI PLUGIN ###################"
####### STEP-3: INSTALL CNI PLUGIN #############
CNI_PLUGINS_VERSION="1.6.0"
curl -LfsS https://github.com/containernetworking/plugins/releases/download/v${CNI_PLUGINS_VERSION}/cni-plugins-linux-amd64-v${CNI_PLUGINS_VERSION}.tgz -o cni-plugins.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins.tgz
rm -fv cni-plugins.tgz

# configure crictl
sudo cp -v /vagrant/config/crictl.yaml /etc/crictl.yaml


sudo systemctl restart containerd
