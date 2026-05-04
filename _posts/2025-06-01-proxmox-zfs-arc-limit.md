---
title: "Setup ZFS ARC Limit"
author: DevilDogTG
date: 2025-06-01 08:00:00 +0700
categories: [Home Lab, Proxmox]
tags: [proxmox, home lab, zfs, storage]
---

Adaptive Replacement Cache (ARC) is used to improve IO performance, but this can reserved a lot of system memory, maybe reserve to 80% of your Proxmox system.

No problem! This value can be configured and for internet searching result, people recommend setup limit value depend on your ZFS pool size:

- Start 2GB
- Each storage 1TB increase ARC limit for 1GB

Example ZFS pool sizing 2TB we recommended 2GB + (1GB * 2) = 4GB

To change value edit `/etc/modprobe.d/zfs.conf` add value in bytes:

```sh
options zfs zfs_arc_max=8589934592
options zfs l2arc_noprefetch=0
```

After edit and save file you need to update system to each restart with follow command:

```sh
update-initramfs -u
```

Done.

For some value in bytes, calculated as below:

| Size | Bytes |
|---|---|
| 32GB | `34359738368` |
| 16GB | `17179869184` |
| 8GB | `8589934592` |
| 4GB | `4294967296` |
| 2GB | `2147483648` |
| 1GB | `1073741824` |
| 512MB | `536870912` |
