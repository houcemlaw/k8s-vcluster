# k8s-vcluster Vagrant Kubernetes Cluster

Bootstrap a local `Ubunto 22.04` or `Debian 12` **2 nodes** Kubernetes cluster using Vagrant.
This project aim to help quickly bootstrap a k8s training cluster for testing, devolpment or training purposes.

## Prerequisites

Please go ahead and install these two components from their official website.

- [Vagrant](https://www.vagrantup.com)
- [VirtualBox](https://www.virtualbox.org)

## Provision the Kubernetes cluster

```sh
vagrant up
```

Now Vagrant will start provisioning the cluster starting with the `controlplane` node and the the worker node.
This setup is available with 2 nodes: a master node (`controlplane`) and a worker node (`node01`).

If you wish to bootstrap additional worker nodes please feel free to update your `VagrantFile` accordingly.

Once the bootstrap process finished go ahead and inspect your cluster using the following command:

```sh
vagrant global-status
```

## Work with the cluster

```sh
vagrant ssh controlplane
```

Once into the cluster use `kubectl` command to manage kubernetes.

## Delete cluster

```sh
vagrant destroy -f
```

## Environment technical details

### Nodes

|     Name     |   IP address   |   CPU   |  Memory(Mi)  |
|--------------|----------------|---------|--------------|
| controlplane |  192.168.56.10 |    2    |     2048     |
|   node01     |  192.168.56.11 |    1    |     1024     |


### Container runtime

[containerd](https://containerd.io)

**Version:** `1.7.11`

### Pod network : Network Plugin

You should use one of the available CNI compliant network plugins available [here](https://v1-27.docs.kubernetes.io/docs/concepts/cluster-administration/addons/#networking-and-network-policy).

I recommend using one of the following three plugins depending on your needs:

|  Network Plugin Provider   |   Network Policy Support   |
|----------------------------|----------------------------|
|      Calico                |           YES              |
|      Weavenet              |           YES              |
|      Flunnel               |           NO               |

We will use [weavenet](https://www.weave.works/docs/net/latest/kubernetes/kube-addon/) for our environment.

**Pod Network CIDR**: `10.244.0.0/16`

### Components versions

|  Component   |             Version             |
|--------------|---------------------------------|
| containerd   |     1.7.11                      |
| runc         |     1.1.11                      |
| cni plugin   |     1.4.0                       |
| etcd         |     3.5.11 (or Latest)          |
| kubelet      |     1.29.1 (or Latest 1.29)     |
| kubeadm      |     1.29.1                      |

## Create a k8s cluster

Once all VMs are provisioned, follow this [guide](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/) to setup our cluster.

### Initializing `controlplane` node

SSH into `controplane` node:

```sh
vagrant ssh controlplane
```

initialize your k8s cluster using `kubeadm`:

```sh
sudo kubeadm init --apiserver-cert-extra-sans=controlplane --apiserver-advertise-address=192.168.56.10 --pod-network-cidr=10.244.0.0/16
```

>**Note:** Depending on your cluster configuration you may want to use `--ignore-preflight-errors=NumCPU` to bypass the minimum requirement of 2 CPU.
```sh
sudo kubeadm init --apiserver-cert-extra-sans=controlplane --apiserver-advertise-address=192.168.56.10 --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=NumCPU
```

Next, follow `kubeadm` instruction to complete your k8s configuration:

```sh
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### Deploy `weave` network plugin

A `Weave` deployment file is available under `resources/weave-daemonset-k8s.yaml`.

You may want to install `vagrant-scp` on your host in order to be able to transfer files from host to your VMs.

```sh
vagrant plugin install vagrant-scp
```

Then use the following command to transfer files:

```sh
vagrant scp resources/weave-daemonset-k8s.yaml controlplane:.
```

Go ahead and use that file in your vagrant `controlplane` node to add your network plugin:

```sh
kubectl apply -f resources/weave-daemonset-k8s.yaml
```
 >**Note:** the weave deployment file was updated according to the pod network CIDR `10.244.0.0/16` used above.<br/>
 If you use a different CIDR please update this file accordingly by setting `IPALLOC_RANGE` to the right CIDR.
 ```yaml
 containers:
            - name: weave
              env:
                - name: IPALLOC_RANGE
                  value: 10.244.0.0/16
```


### Joining worker node `node01`

SSH into every worker node (`node01`):

```sh
vagrant ssh node01
```

Use the join command printed out by the previous `kubeadm init` command:

```sh
sudo kubeadm join 192.168.56.10:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

Or generate a new join command by running the following command on the master node:

```sh
sudo kubeadm token create --print-join-command
```

### Check your k8s cluster

Use the following command to inspect your cluster:

```sh
kubectl cluster-info
kubectl get nodes -o wide
kubectl get all --all-namespaces
```

### Create a test pod

```sh
kubectl run test-pod --image=busybox -- sleep 1d
```
