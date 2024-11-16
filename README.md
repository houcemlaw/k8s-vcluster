# k8s-vcluster Vagrant Kubernetes Cluster

Bootstrap a local `Ubunto 22.04` or `Debian 12` **2 nodes** Kubernetes cluster using Vagrant.
This project aim to help quickly bootstrap a k8s training cluster for testing, devolpment or training purposes.

## What does `k8s-vcluster` application do ?

`k8s-vcluster` will :
- create a 2 nodes kubernetes cluster: a control plane `controlplane` and a worker node `node01`
- install and configure `containerd`
- deploy a network plugin (`weavenet`)
- configure and deploy the k8s cluster:
  - initialize the `controlplane`
  - join `node01` to the cluster

## Prerequisites

Please go ahead and install these two components from their official website.

- [Vagrant](https://www.vagrantup.com)
- [VirtualBox](https://www.virtualbox.org)

## Create the Kubernetes cluster

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

## Manage the cluster

```sh
vagrant ssh controlplane
```

Once logged into the `controlplane` use `kubectl` command to manage your kubernetes cluster.

## Delete cluster

```sh
vagrant destroy -f
```

## Environment technical details

Below are the main technical configuration used while creating your `kubernetes` cluster.

### Components versions

|  Component   |    Version      |
|--------------|-----------------|
| containerd   |     2.0.0       |
| runc         |     1.2.1       |
| cni plugin   |     1.6.0       |
| etcd         |     3.5.15      |
| kubelet      |     1.31.x      |
| kubeadm      |     1.31.x      |
| kubectl      |     1.31.x      |

### Nodes details

|      Name      |     IP address     |   CPU   |  Memory(Mi)  |  Network Interface  |
|----------------|--------------------|---------|--------------|---------------------|
| `controlplane` |   `192.168.56.10`  |    2    |     2048     |      `enp0s8`       |
|   `node01`     |   `192.168.56.11`  |    1    |     1024     |      `enp0s8`       |

>NOTE:
 The project uses the network interface `enp0s8`.
 You may need to update this value according to your configuration.


### Container runtime

[containerd](https://containerd.io)

**Version:** `2.0.0`

### Pod network / Network Plugin

The process will setup and configure [weavenet](https://www.weave.works/docs/net/latest/kubernetes/kube-addon/) for you.<br/>

However, if you wish to configure another network plugin, then you will need to use one of the available CNI compliant network plugins available [here](https://v1-27.docs.kubernetes.io/docs/concepts/cluster-administration/addons/#networking-and-network-policy).

I recommend using one of the following three plugins depending on your needs, that is, if you intend to use Network Policies then you should definately look for plugins that support this capability:

|  Network Plugin Provider   |   Network Policy Support   |
|----------------------------|----------------------------|
|      Calico                |           YES              |
|      Weavenet              |           YES              |
|      Flunnel               |           NO               |



**Pod Network CIDR**: `10.244.0.0/16`


## Create k8s cluster : Performed actions details

This section describes all the actions performed by the application in order to prepare the environment and create the cluster. <br/>

The application will provision all needed VMs then will bootstarp a ready-to-use two nodes k8s cluster. <br/>

For further details on how to create a kubernetes cluster please refer to this [guide](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/).

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

Next, the application will execute the following instructions in order to complete k8s configuration:

```sh
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### Deploy `weave` network plugin

A `Weave` deployment file is available under `resources/weave-daemonset-k8s.yaml`.

The application will install `vagrant-scp` on your host in order to be able to transfer files from host to your VMs.

```sh
vagrant plugin install vagrant-scp
```

Then it will use the following command to transfer files:

```sh
vagrant scp resources/weave-daemonset-k8s.yaml controlplane:.
```

Finally, the application will deploy `weavenet` using that file in your vagrant `controlplane` node in order to setup your network plugin:

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

The application will automatically join `node01` to the cluster once finishing configuring `controlplane`. <br/>

However, if you wish to manually join your `node01` or additional worker nodes to your cluster please executes the following steps: <br/>

SSH into every worker node (`node01`):

```sh
vagrant ssh node01
```

Use the join command printed out by the previous `kubeadm init` command:

```sh
sudo kubeadm join 192.168.56.10:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

Or generate a new join command by running the following command on the master node, then execute it on the worker nodes:

```sh
sudo kubeadm token create --print-join-command
```

## Check your k8s cluster

Once the cluster is ready use the following command to inspect it:

```sh
kubectl cluster-info
```
![Cluster Information](/assets/cluster-info.png "Cluster Information")


```sh
kubectl get nodes -o wide
```

![Cluster Nodes](/assets/nodes.png "Cluster Nodes")


```sh
kubectl get all --all-namespaces
```

![All pods in cluster](/assets/all-pods.png "All pods in cluster")

### Create a test pod

Try to deploy a new pod to check that the environment is fully funtional.
```sh
kubectl run test-pod --image=busybox -- sleep 1d
```
