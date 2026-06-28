---
title: "Debian IP Address Configuration"
author: DevilDogTG
date: 2025-05-16 08:00:00 +0700
categories: [System Administrator, Linux]
tags: [linux, debian, configuration, networking, ip address]
---

Check the current IP address with:

```sh
ip a
```

The default Debian setup uses DHCP for the IP address. To assign a static IP, edit `/etc/network/interfaces`:

```sh
iface [ifname] inet static
    address 192.168.99.1/24
    gateway 192.168.99.254
```

Save and restart the networking service to apply the new IP:

```sh
sudo systemctl restart networking.service
```
