---
layout: default
---
# Migration VM from Hyper-V system

## Disk Converting

Import disk to **Proxmox** need to convert virtual hard disk to supported format like `raw`, `qcow2`

In this example we will migrate virtual machine from **Hyper-V**, We need to convert `vhdx` disk to `qcow2`, Use command:

``` shell
qemu-img convert -f vhdx -O qcow2 /path/source/image.vhdx /path/desc/image.qcow2
```

run `qemu-img -help` for more information.

After file converted run follow command to check disk image error

``` shell
qemu-img check -r all /path/desc/image.qcow2
```

## Importing disk

Next, We need to import converted disk to Proxmox, create you VM and use `VMID` to run this command and please

``` shell
qm importdisk [VMID] /path/desc/image.qcow2 [StorageID]
```

Please replace `[VMID]` and `[StorageID]` with your value.

Example import disk for VMID: `101` and place disk on `local-lvm` use this command

``` shell
qm importdisk 101 /path/desc/image.qcow2 local-lvm
```

Done. happy to run your VM.
