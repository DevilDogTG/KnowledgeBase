---
title: Passthrough physical disk to VM
author: DevilDogTG
date: 2025-09-21 20:53:00 +0700
categories: [Proxmox, Configuration]
tags: [tutorials, proxmox]
---

This guide will passthrough physical disk(s) into a virtual machine and use it like normal disk

> This guide uses partial content from the original, summarized based on my understanding and for reference
> **Source:** [Proxmox Wiki](https://pve.proxmox.com/wiki/Passthrough_Physical_Disk_to_Virtual_Machine_(VM))

## List the physical disks

In our case, we will use disk-id to identify disks, using `lsblk` to list your disks installed on the Proxmox host

```shell
find /dev/disk/by-id/ -type l|xargs -I{} ls -l {}|grep -v -E '[0-9]$' |sort -k11|cut -d' ' -f9,10,11,12
```

You will get output like:

```shell
/dev/disk/by-id/ata-ST8000DM004-2CX188_ZCT1DNY1 -> ../../sda
/dev/disk/by-id/wwn-0x5000c500c35cd719 -> ../../sda
/dev/disk/by-id/usb-Generic_STORAGE_DEVICE-0:0 -> ../../sdb
/dev/disk/by-id/usb-JMicron_Generic_0123456789ABCDEF-0:0 -> ../../sdc
/dev/disk/by-id/ata-ST2000DX001-1CM164_Z1E783H2 -> ../../sdd
/dev/disk/by-id/wwn-0x5000c500661eeebd -> ../../sdd
```

## Assign disk to VM

After noting your disk by-id from previous step, just assign it to your virtual machine

```shell
qm set <vmid> -scsi<scsi_number> /dev/disk/by-id/wwn-0x5000c500661eeebd
```

> Replace `<vmid>` with your VM ID and `<scsi_number>` with the running number of `scsi` on your VM (starting with 0)

## Check result

After assigning the disk to the VM, you will see the disk in the `Hardware` section.

![Disk List](../assets/contents/2025/proxmox/passthrough-disk/disk-backup-false.png)

(Optional) Most of the time, I disable backup for the physical disk (for personal reasons) by unchecking the `backup` option

![Backup option](../assets/contents/2025/proxmox/passthrough-disk/backup-option.png)
