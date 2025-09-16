---
layout: default
---
# :gear: Kubernetes Worker setup

This guide has pre-required from [Kuberbnetes Setup Guide](Kubernetes%20Setup%20Guide.md) please completed it before follow this guide

## Getting Started

in this guide will start setup step below

- Install Kubernetes with deployment tools
- Join worker node to cluster

### Install Kubernetes with deployment tools

This install will install Kubenetes v1.33, start with add `apt` source

Specified version to stick with

```sh
# Add the Kubernetes repository
KUBERNETES_VERSION=v1.33
curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

Update `apt` package index, install tools and pin their version

```shell
sudo apt update
sudo apt install -y kubelet kubeadm
```

### Join worker node to cluster

Worker node need to join running command to join cluster

```shell
sudo kubeadm join [MASTER_NODE_IP]:6443 --token [TOKEN] --discovery-token-ca-cert-hash [HASH]
```

If join successful please check cluster nodes has been `READ` by using `kubectl`

After join just for clearify in furture you can mark node as a work by using:

```sh
kubectl label node <node name> node-role.kubernetes.io/worker=""
```

## :information_source: (Optional) Install by shell script

I write up bash shell script to install please try to run [This script](./scripts/setup-worker.sh)

```shell
sudo bash ./setup-worker.sh
```

or your can run

```shell
curl https://github.com/DevilDogTG/knowledge-base/raw/refs/heads/main/System%20Administrator/Kubernetes/scripts/setup-worker.sh | sudo bash
```

To download script from GitHub and run it.
