---
title: "Migration VM from Hyper-V to Proxmox"
author: DevilDogTG
date: 2025-06-01 08:00:00 +0700
categories: [Home Lab, Proxmox]
tags: [proxmox, home lab, hyper-v, migration, vm]
---

## Disk Converting

Import disk to **Proxmox** requires converting the virtual hard disk to a supported format like `raw` or `qcow2`.

In this example we will migrate a virtual machine from **Hyper-V**. We need to convert a `vhdx` disk to `qcow2`:

```shell
qemu-img convert -f vhdx -O qcow2 /path/source/image.vhdx /path/desc/image.qcow2
```

Run `qemu-img -help` for more information.

After the file is converted, run the following command to check for disk image errors:

```shell
qemu-img check -r all /path/desc/image.qcow2
```

## Importing Disk

Next, import the converted disk to Proxmox. Create your VM and use its `VMID` to run this command:

```shell
qm importdisk [VMID] /path/desc/image.qcow2 [StorageID]
```

Replace `[VMID]` and `[StorageID]` with your values.

Example — import disk for VMID `101` to storage `local-lvm`:

```shell
qm importdisk 101 /path/desc/image.qcow2 local-lvm
```

Done. Happy running your VM!
