---
layout: default
---
# Kubernetes Setup Guide

This guide refer <https://kubernetes.io/docs/setup/production-environment/> to setup production-like environment in home lab

## Preparation

before start setup kubernetes need to preparing VMs for example use 2 VMs for Master - Worker node example spec below

- **Master Node**: debian 12, 4 vCPUs, 2GB RAM, IP 192.168.0.1/24
- **Worker Node**: debian 12, 2 vCPUs, 2GB RAM, IP 192.168.0.2/24

need to fixed ip on both hosts

### OS Configuration

Kubernetes need preparation some configuration before setup, this required on all nodes

- Disabled SWAP
- Enable `ip_forward`
- (Optional) Enable `br_netfilter`

#### Disabled SWAP

If your system using SWAP your can disable by

```shell
sudo swapoff -a
```

but above command will disabled until next restart, to disabled to remove `swap` from `/etc/fstab` is required

```shell
sudo nano /etc/fstab
# Comment out or delete swap mounting file
```

#### Enable `ip_forward`

By default will be disable, easiest way to enable it just use command

```shell
sudo sysctl -w net.ipv4.ip_forward=1
```

tell `sysctl` to enabled when system start need to edit file `/etc/sysctl.conf`

```shell
sudo nano /etc/sysctl.conf
# Adding or uncomment line
## net.ipv4.ip_forward = 1
```

Or run following command

```shell
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

#### (Optional) Enable `br_netfilter`

Like `ip_forward` but we need extra step to enable bridge modules

```shell
sudo modprobe br_netfilter
echo br_netfilter | sudo tee /etc/modules-load.d/kubernetes.conf
```

this will enable every time os restart by default, next add configuration to `sysctl`

```shell
echo 'net.bridge.bridge-nf-call-iptables=1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

## Getting Started

Installation is flexible and allow your to choose your favorite component but required to run kubernetes cluster. 2 thing need to choose is **Container Runtime** and **CNI** in this guide will start setup step below

- Install **Container Runtime**: containerd.io
- Select node role to Continue Setup

### Container Runtime

Before install, you need to set up `apt` repository. `containerd.io` packages are distributed by Docker, we need to and docker source for `apt`

```shell
# Add Docker's official GPG key:
sudo apt update
sudo apt install -y ca-certificates curl runc gpg
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |  sudo tee /etc/apt/sources.list.d/docker.list
```

Then install `containerd.io` package

```shell
sudo apt update
sudo apt install -y containerd.io
```

> **Note:**
> If you installed containerd from a package (for example, RPM or `.deb`), you may find that the CRI integration plugin is disabled by default.
> You need CRI support enabled to use containerd with Kubernetes. Make sure that cri is not included in the `disabled_plugins` list within `/etc/containerd/config.toml`; if you made > changes to that file, also restart `containerd`.
> If you experience container crash loops after the initial cluster installation or after installing a CNI, the containerd configuration provided with the package might contain incompatible configuration parameters. Consider resetting the containerd configuration with `sudo su root -c "containerd config default > /etc/containerd/config.toml"` as specified in [getting-started.md](https://github.com/containerd/containerd/blob/main/docs/getting-started.md#advanced-topics) and then set the configuration parameters specified above accordingly.

After installed need to configuring the `systemd` cgroup driver

```shell
sudo nano /etc/containerd/config.toml
```

Find and update `SystemdCgroup` to `true`

```conf
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  ...
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
  ...
```

Overriding the sandbox (pause) image

```conf
[plugins."io.containerd.grpc.v1.cri"]
  ...
  sandbox_image = "registry.k8s.io/pause:3.10"
  ...
```

Restart `containerd` to take effect

```shell
sudo systemctl restart containerd.service
```

### Select node role to Continue Setup

You have done to prepared base of Kubernetes node next should specified role to setup guide below

- [Control Plane](./Setup%20Control%20Plane.md)
- [Worker](Setup%20Worker%20Node.md)
