---
layout: default
---
# Setup ZFS ARC Limit

Adaptive Replacement Cache  (ARC) is used to improve IO performance, But this can reserved a lot of system memory, maybe reserve to 80% of your Proxmox system

No problem! This value can be config and for internet searching result. people recommend setup limit value depend on your ZFS pool size

- Start 2GB
- Each storage 1TB increase ARC limit for 1GB

Example ZFS pool sizing 2TB we recommended 2GB + (1GB * 2) = 4GB

to change value edit `/etc/modprobe.d/zfs.conf` add value in bytes.

```sh
options zfs zfs_arc_max=8589934592
options zfs l2arc_noprefetch=0
```

After edit and save file you need to update system to each restart with follow command

```sh
update-initramfs -u
```

Done.

For some value in byte we calculated as below.

32GB: `34359738368`
16GB: `17179869184`
8GB: `8589934592`
4GB: `4294967296`
2GB: `2147483648`
1GB: `1073741824`
512MB: `536870912`
