---
title: "Kubernetes Setup Guide"
author: DevilDogTG
date: 2025-05-09 08:00:00 +0700
categories: [Home Lab, Kubernetes]
tags: [kubernetes, home lab, linux, debian, container runtime]
---

This guide refers to <https://kubernetes.io/docs/setup/production-environment/> to setup a production-like environment in home lab.

## Preparation

Before starting Kubernetes setup, prepare VMs. Example using 2 VMs for Master-Worker nodes:

- **Master Node**: Debian 12, 4 vCPUs, 2GB RAM, IP 192.168.0.1/24
- **Worker Node**: Debian 12, 2 vCPUs, 2GB RAM, IP 192.168.0.2/24

Fix IP addresses on both hosts.

### OS Configuration

Kubernetes requires some configuration before setup, required on **all nodes**:

- Disable SWAP
- Enable `ip_forward`
- (Optional) Enable `br_netfilter`

#### Disable SWAP

Disable swap temporarily:

```shell
sudo swapoff -a
```

To disable permanently, remove `swap` from `/etc/fstab`:

```shell
sudo nano /etc/fstab
# Comment out or delete the swap mount line
```

#### Enable `ip_forward`

By default this is disabled. Enable it immediately:

```shell
sudo sysctl -w net.ipv4.ip_forward=1
```

To persist after reboot, edit `/etc/sysctl.conf`:

```shell
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

#### (Optional) Enable `br_netfilter`

Load the bridge module and persist it:

```shell
sudo modprobe br_netfilter
echo br_netfilter | sudo tee /etc/modules-load.d/kubernetes.conf
```

Add the sysctl configuration:

```shell
echo 'net.bridge.bridge-nf-call-iptables=1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

## Container Runtime

Before installing Kubernetes, set up the `containerd.io` container runtime. Packages are distributed by Docker, so add the Docker apt source first:

```shell
# Add Docker's official GPG key:
sudo apt update
sudo apt install -y ca-certificates curl runc gpg
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list
```

Install `containerd.io`:

```shell
sudo apt update
sudo apt install -y containerd.io
```

> **Note:** If you installed containerd from a package, the CRI integration plugin may be disabled by default. Make sure `cri` is not in the `disabled_plugins` list in `/etc/containerd/config.toml`. If needed, reset it with:
> ```shell
> sudo su root -c "containerd config default > /etc/containerd/config.toml"
> ```

Configure the `systemd` cgroup driver:

```shell
sudo nano /etc/containerd/config.toml
```

Find and update `SystemdCgroup` to `true`:

```conf
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  ...
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
  ...
```

Override the sandbox (pause) image:

```conf
[plugins."io.containerd.grpc.v1.cri"]
  ...
  sandbox_image = "registry.k8s.io/pause:3.10"
  ...
```

Restart `containerd` to apply changes:

```shell
sudo systemctl restart containerd.service
```

## Next Steps

Select your node role to continue:

- [Control Plane setup](/posts/kubernetes-setup-control-plane/)
- [Worker Node setup](/posts/kubernetes-setup-worker-node/)
