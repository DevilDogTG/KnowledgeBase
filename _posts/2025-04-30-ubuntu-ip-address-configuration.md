---
title: "IP Address Configuration on Ubuntu"
author: DevilDogTG
date: 2025-04-30 08:00:00 +0700
categories: [System Administrator, Linux]
tags: [linux, ubuntu, configuration, networking, ip address, netplan]
---

## Disable Cloud Init Network Config

By default, Ubuntu replaces network configuration on every reboot. To make your config persistent, create this file:

```sh
sudo nano /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
```

Add the following content:

```
network: {config: disabled}
```

Remove the old config:

```sh
sudo rm /etc/netplan/50-cloud-init.yaml
```

## Create Network Configuration File

Create a new netplan configuration:

```sh
sudo nano /etc/netplan/10-netcfg.yaml
```

**Static IP example:**

```yaml
network:
    ethernets:
        enp6s18:
            addresses:
            - 192.168.30.67/24
            nameservers:
                addresses:
                - 192.168.30.250
                search:
                - dmnsn.com
            routes:
            -   to: default
                via: 192.168.30.254
    version: 2
```

**DHCP example:**

```yaml
network:
    ethernets:
        enp6s18:
          dhcp4: true
    version: 2
```

Set secure permissions on the file:

```sh
sudo chmod 600 /etc/netplan/10-netcfg.yaml
```

Apply the configuration:

```sh
sudo netplan apply
ip addr
```

> **Note:** On a minimal Ubuntu install you may get an error about `ovswitch`. Fix it with:
> ```sh
> sudo apt-get install openvswitch-switch-dpdk
> sudo netplan apply
> ```
