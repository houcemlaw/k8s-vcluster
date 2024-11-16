#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

host_name=$(hostname)

if [ "$host_name" = "controlplane" ]; then 
    echo "########### INITIALIZE THE CONTROL PLANE ##################"

    sudo kubeadm init --apiserver-cert-extra-sans=controlplane --apiserver-advertise-address=192.168.56.10 --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=2
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    sudo kubeadm token create --print-join-command > /vagrant_shared/cluster-join-script.sh
    
fi;
