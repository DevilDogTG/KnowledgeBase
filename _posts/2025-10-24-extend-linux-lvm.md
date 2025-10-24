---
title: "How to extend LVM in Linux"
author: DevilDogTG
date: 2025-10-24 11:27:00 +0700
categories: [Linux, Configuration]
tags: [tutorials, linux, lvm, lang:en]
---

Extending a Logical Volume Manager (LVM) in Linux involves adding more space to an existing logical volume. Follow these steps to extend your LVM:

## Extend the Volume Group (VG)

If you use virtual disk, you can resize disk and create new partition use to extend existing volumn group by using `fdisk` or you can add more disk to extend VG too.

You can check your VG list by using `sudo vgs` and extend by:

```sh
sudo vgextend vg_name /dev/<partition>
sudo vgs
```

## Extend the Logical Volume (LV)

After extend VG you need to allocate free space to current logical volume:

```sh
sudo lvextend -l +100%FREE /dev/vg_name/lv_name
```

Please note you can list your lv by using `sudo lvs`

## Resize the filesystem

Extened space for filesystem without restarting by:

```sh
sudo resize2fs /dev/vg_name/lv_name
```

## (Optional) Add new disk to VG


If you attached a brand-new disk, add it to your VG as a new Physical Volume (PV):

Identify the new disk

```sh
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT
```

(Recommended) Create an LVM partition on the disk

- Using fdisk (MBR/GPT): create a new partition and set type to LVM (`8e`)

```sh
sudo fdisk /dev/sdb
# n (new) -> accept defaults
# t (type) -> 8e (Linux LVM)
# w (write)
sudo partprobe /dev/sdb   # reload partition table
```

- Or using parted (GPT):

```sh
sudo parted /dev/sdb --script mklabel gpt \ 
  mkpart primary 0% 100% \ 
  set 1 lvm on
sudo partprobe /dev/sdb
```

Note: You can also use the whole disk directly as a PV (skip partitioning) if that suits your policy.

Update existing PV or create a new PV

- If you expanded the same underlying device (existing PV grew):

```sh
# find your PV device path
pvs
# then resize the existing PV to claim the new space
sudo pvresize /dev/<pv_device>   # e.g. /dev/sda3 or /dev/nvme0n1p3
```

- If you added a brand‑new disk/partition:

```sh
sudo pvcreate /dev/sdb1          # or /dev/sdb if using whole disk
```