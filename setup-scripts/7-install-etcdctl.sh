#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
ETCD_RELEASE=$(curl -s https://api.github.com/repos/etcd-io/etcd/releases/latest|grep tag_name | cut -d '"' -f 4)


curl -LfsS https://github.com/etcd-io/etcd/releases/download/${ETCD_RELEASE}/etcd-${ETCD_RELEASE}-linux-amd64.tar.gz -o etcd.tar.gz
sudo tar xvf etcd.tar.gz
sudo mv etcd-${ETCD_RELEASE}-linux-amd64/etcd etcd-${ETCD_RELEASE}-linux-amd64/etcdctl etcd-${ETCD_RELEASE}-linux-amd64/etcdutl /usr/local/bin 
sudo rm -rv etcd-${ETCD_RELEASE}-linux-amd64
rm -fv etcd.tar.gz
    
    