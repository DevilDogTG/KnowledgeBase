---
layout: default
---
# How to extend LVM in Linux

Extending a Logical Volume Manager (LVM) in Linux involves adding more space to an existing logical volume. Follow these steps to extend your LVM:

## Extend the Volume Group (VG)

If you use virtual disk, you can resize disk and create new partition use to extend existing volumn group by using `fdisk` or you can add more disk to extend VG too.

You can check your VG list by using `sudo vgs` and extend by:

```sh
sudo vgextend vg_name /dev/<partition>
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

Done
