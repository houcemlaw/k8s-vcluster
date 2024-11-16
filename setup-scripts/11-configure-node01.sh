#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

host_name=$(hostname)

if [ "$host_name" = "node01" ]; then 
    echo "########### JOIN NODE01 TO THE CLUSTER ##################"
    if [ -f /vagrant_shared/cluster-join-script.sh ]; then
        VALUE=$(cat /vagrant_shared/cluster-join-script.sh)
        sudo $VALUE
        echo "################ Executing the following join command: $VALUE ########################"
      else
        echo "cluster-join-script.sh file not found!"
      fi
fi;