#################################################################
#     Vagrant script for deploying two nodes k8s cluster        #
#                                                               #
#     CREATED BY: HOUSSEMEDDINE LAOUITI                         #
#                                                               #
#################################################################

## define the box to use
VM_BOX = "ubuntu/jammy64"
# VM_BOX = "bento/debian-12"

## define master node parameters
CONTROLPLANE_NODE_NAME = "controlplane"
CONTROLPLANE_IP_ADD = "192.168.56.10"
CONTROLPLANE_CPU = "2048"
CONTROLPLANE_MEMORY = "2"

## define worker node(s) parameters
WORKER_NODE_NAME = "node01"
WORKER_IP_ADD = "192.168.56.11"
WORKER_CPU = "1024"
WORKER_MEMORY = "1"

## define the cluster network interface
NETWORK_INTERFACE = "enp0s8" #please use the appropriate interface depending on your configuration
# NETWORK_INTERFACE = "eth1"


vNodes = [
    {
        :name => CONTROLPLANE_NODE_NAME, 
        :ipadd => CONTROLPLANE_IP_ADD,
        :mem => CONTROLPLANE_CPU,
        :cpu => CONTROLPLANE_MEMORY
    },
    {
        :name => WORKER_NODE_NAME,
        :ipadd => WORKER_IP_ADD,
        :mem => WORKER_CPU,
        :cpu => WORKER_MEMORY
    }
]

Vagrant.configure("2") do |config|
  config.vm.box = VM_BOX
  config.vm.box_check_update = false
  config.vbguest.auto_update = true if Vagrant.has_plugin?("vagrant-vbguest")

  vNodes.each do |node|
    config.vm.define node[:name] do |config|
      config.vm.hostname = node[:name]
        config.vm.provider "virtualbox" do |v|
          v.customize ["modifyvm", :id, "--memory", node[:mem]]
          v.customize ["modifyvm", :id, "--cpus", node[:cpu]]
          v.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
          v.customize ["modifyvm", :id, "--uartmode1", "file", File::NULL]
        end
      config.vm.network "private_network", ip: node[:ipadd]
    end
  end
  config.vm.provision "shell", name: "1-disable-swap", path: "setup-scripts/1-disable-swap.sh", privileged: false
  config.vm.provision "shell", name: "2-setup-environment-tools", path: "setup-scripts/2-setup-environment-tools.sh", privileged: false
  config.vm.provision "shell", name: "3-allow-bridge-nf-traffic", path: "setup-scripts/3-allow-bridge-nf-traffic.sh", privileged: false
  config.vm.provision "shell", name: "4-install-containerd", path: "setup-scripts/4-install-containerd.sh", privileged: false
  config.vm.provision "shell", name: "5-install-kubeadm", path: "setup-scripts/5-install-kubeadm.sh", privileged: false
  config.vm.provision "shell", name: "6-update-kubelet-config", path: "setup-scripts/6-update-kubelet-config.sh", args: [NETWORK_INTERFACE], privileged: false
  config.vm.provision "shell", name: "7-install-etcdctl", path: "setup-scripts/7-install-etcdctl.sh", privileged: false
  config.vm.provision "shell", name: "8-kubectl-config", path: "setup-scripts/8-kubectl-config.sh", privileged: false
end
