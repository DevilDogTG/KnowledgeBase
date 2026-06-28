---
title: "Kubernetes Control Plane Setup"
author: DevilDogTG
date: 2025-05-18 08:00:00 +0700
categories: [Home Lab, Kubernetes]
tags: [kubernetes, home lab, control plane, calico]
---

This guide has a pre-requirement from the [Kubernetes Setup Guide](/posts/kubernetes-setup-guide/). Please complete it before following this guide.

## Getting Started

This document focuses on steps to setup the `Control Plane` only:

- Install Kubernetes with deployment tools
- Setup Kubernetes cluster
- Install **CNI**: Calico
- Print cluster join command

### Install Kubernetes with Deployment Tools

Install Kubernetes v1.33. Start by adding the `apt` source:

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

Update `apt` package index, install tools and pin their version:

```shell
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

### Setup Kubernetes Cluster

Before initializing the cluster, verify all nodes can communicate with each other. Then initialize the cluster (specifying `pod-network-cidr` and `service-cidr` to avoid conflicts):

```shell
sudo kubeadm init --apiserver-advertise-address=0.0.0.0 --pod-network-cidr=10.244.0.0/16 --service-cidr=10.96.0.0/16
```

After completion, set up `kubectl` for your user:

```shell
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Verify with:

```shell
kubectl get nodes
```

If the output shows the nodes list, everything is OK.

### Install Network Plugin: Calico

Reference: [Calico Quickstart](https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart)

After initializing the cluster, `coredns` will be stuck in `Pending` state — you need to install the pod network add-on first.

Download the Calico manifest:

```shell
curl https://raw.githubusercontent.com/projectcalico/calico/v3.30.0/manifests/calico.yaml -O
```

If you changed the pod CIDR to `10.244.0.0/16` (not the default `192.168.0.0/16`), update `CALICO_IPV4POOL_CIDR` before applying:

```shell
nano calico.yaml
# Update variable CALICO_IPV4POOL_CIDR to 10.244.0.0/16
```

Apply the manifest:

```shell
kubectl apply -f calico.yaml
```

Wait for `coredns` pods to reach `Running` state:

```shell
kubectl get pods -A
```

### Print Cluster Join Command

The system prints the join command after initialization. If you need it again later:

```shell
kubeadm token create --print-join-command
```

Use the output on worker nodes to join the cluster, then verify:

```shell
kubectl get nodes -o wide
```

New nodes take some time to start system pods; they will reach `Ready` state shortly.

Check all pods are running:

```shell
kubectl get pods -A
```

## (Optional) Install via Shell Script

A bash script is available to automate the installation:

```shell
curl https://github.com/DevilDogTG/knowledge-base/raw/refs/heads/main/System%20Administrator/Kubernetes/scripts/setup-controlplane.sh | sudo bash
```
