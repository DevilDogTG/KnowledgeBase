---
layout: default
---
# :gear: Kubernetes Control Plane setup

This guide has pre-required from [Kuberbnetes Setup Guide](Kubernetes%20Setup%20Guide.md) please completed it before follow this guide

## Getting Started

In this document will focused steps to setup `Control Plane` only

- Install Kubernetes with deployment tools
- Setup kubernetes cluster
- Install **CNI**: Calico (If you need other one, you can choose it freely)
- Print cluster join command

### Install Kubernetes with deployment tools

This install will install Kubenetes v1.33, start with add `apt` source

Specified version to stick with

```sh
```

```sh
# Add the Kubernetes repository
KUBERNETES_VERSION=v1.33
curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
# Add the CRI-O repository
CRIO_VERSION=v1.33
curl -fsSL https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/ /" | sudo tee /etc/apt/sources.list.d/cri-o.list
```

Update `apt` package index, install tools and pin their version

```shell
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

### Setup kubernetes cluster

Before intilizing cluster need to check all node can communicate with each others, then start setup cluster. For me specified `pod-network-cidr` and `service-cidr` to avoid my network setup

```shell
sudo kubeadm init --apiserver-advertise-address=0.0.0.0 --pod-network-cidr=10.244.0.0/16 --service-cidr=10.96.0.0/16
```

This will take some time, after done setup `kubectl` for user

```shell
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

verify by using:

```shell
kubectl get nodes
```

if output show nodes list, everything is ok

### Install network plugin **Calico**

[Calico Quickstart](https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart)
after initialed cluster your can see running pods in system by

```shell
kubectl get pods -A
```

You will see `coredns` will stuck in `Pending` state. you need to install pod network add-on before `coredns` network start setup

to install `calico` Download the Calico networking manifest for the Kubernetes API datastore

```shell
curl https://raw.githubusercontent.com/projectcalico/calico/v3.30.0/manifests/calico.yaml -O
```

if you are using pod CIDR `192.168.0.0/16` you can skip to the next step, for me changing pod CIDR to `10.244.0.0/16` need to update `CALICO_IPV4POOL_CIDR` before install

```shell
nano calico.yaml
# Update variable CALICO_IPV4POOL_CIDR to 10.244.0.0/16
```

Apply the manifest:

```shell
kubectl apply -f calico.yaml
```

Wait and see `coredns` pod state to `Running`

```shell
kubectl get pods -A
```

### Print cluster join command

after initialed cluster, system will print join command to output, if your need join command using:

```shell
kubeadm token create --print-join-command
```

Use output run on worker node to join the cluster

then you can check new nodes has joined

```shell
kubectl get nodes -o wide
```

New node take sometime to starting some system pods after that they will `Ready` state

Checking pods status by using

```shell
kubectl get pods -A
```

This will display all pods in all namespace, all pods should be `Running` state

## :information_source: (Optional) Install by shell script

I write up bash shell script to install please try to run [This script](./scripts/setup-controlplane.sh)

```shell
sudo bash ./setup-controlplane.sh
```

or your can run

```shell
curl https://github.com/DevilDogTG/knowledge-base/raw/refs/heads/main/System%20Administrator/Kubernetes/scripts/setup-controlplane.sh | sudo bash
```

To download script from GitHub and run it.
