---
title: "Kubernetes Worker Node Setup"
author: DevilDogTG
date: 2025-05-18 08:00:00 +0700
categories: [Home Lab, Kubernetes]
tags: [kubernetes, home lab, worker node]
---

This guide has a pre-requirement from the [Kubernetes Setup Guide](/posts/kubernetes-setup-guide/). Please complete it before following this guide.

## Getting Started

This guide covers steps to setup the Worker Node only:

- Install Kubernetes with deployment tools
- Join worker node to cluster

### Install Kubernetes with Deployment Tools

Install Kubernetes v1.33. Add the `apt` source:

```sh
# Add the Kubernetes repository
KUBERNETES_VERSION=v1.33
curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

Update `apt` package index and install tools:

```shell
sudo apt update
sudo apt install -y kubelet kubeadm
```

### Join Worker Node to Cluster

Run the join command obtained from the control plane:

```shell
sudo kubeadm join [MASTER_NODE_IP]:6443 --token [TOKEN] --discovery-token-ca-cert-hash [HASH]
```

If the join is successful, verify from the control plane:

```shell
kubectl get nodes
```

Optionally, label the node as a worker for clarity:

```sh
kubectl label node <node-name> node-role.kubernetes.io/worker=""
```

## (Optional) Install via Shell Script

A bash script is available to automate the installation:

```shell
curl https://github.com/DevilDogTG/knowledge-base/raw/refs/heads/main/System%20Administrator/Kubernetes/scripts/setup-worker.sh | sudo bash
```
