---
title: "Setup MetalLB Load Balancer on Kubernetes"
author: DevilDogTG
date: 2025-06-05 08:00:00 +0700
categories: [Home Lab, Kubernetes]
tags: [kubernetes, home lab, metallb, load balancer, networking]
---

[MetalLB](https://metallb.io/) is a load-balancer implementation for bare metal Kubernetes clusters, using standard routing protocols.

## Installation by Manifest

Apply the MetalLB manifest:

```sh
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.15.2/config/manifests/metallb-native.yaml
```

Check for the latest version on the [MetalLB installation page](https://metallb.io/installation/).

## Allocate IP Pool for Load Balancing

Create the following configuration to allocate IPs for the cluster:

```yaml
# metallb.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  namespace: metallb-system
  name: local-pool
spec:
  addresses:
    - 192.168.99.100-192.168.99.110
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: advert
  namespace: metallb-system
```

Apply the configuration:

```sh
kubectl apply -f metallb.yaml
```
