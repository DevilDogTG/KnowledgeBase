---
title: "Create the LXC Template"
author: DevilDogTG
date: 2025-06-01 08:00:00 +0700
categories: [Home Lab, Proxmox]
tags: [proxmox, home lab, lxc, container]
---

In order to turn the container into a template, we need to delete the network interface then create a backup.

From Proxmox (not inside the container):

```sh
# Remove the network interface:
sudo pct set 250 --delete net0
# Create a backup:
vzdump 250 --mode stop --compress gzip --dumpdir /<vzdump-path>/data/template/cache/
```

The new file will be located in: `/<vzdump-path>/data/template/cache`

You can leave it as is or rename it to something:

```sh
# Change directories:
cd /media/sas/data/template/cache
# Rename it:
sudo mv new_vz_dump.tar.gz custom_debian_10.4.tar.gz
```

See `man vzdump` for more info.
