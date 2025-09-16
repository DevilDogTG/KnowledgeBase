---
layout: default
---
# Move `recovery partition` in Windows

Basically, here are the steps:

- Disable the existing Windows Recovery Partition by running `reagentc /disable`
- Use `diskpart` to remove the recovery partition

```ps1
list disk
# where `#` is the disk needing the recovery partition removed
select disk #
list partition
# where `#` is the recovery partition
select partition #
# to force deletion of the recovery partition
delete partition override
```

- Expand the disk using **Disk Management**, leaving ~1024 MB at the end of the drive for recreating the recovery partition
- Create **New Simple Volume** for Recovery, NTFS, no drive letter
- use `diskpart` to set the recovery partition attributes

```ps1
list partition
# where `#` is the new recovery partition
select partition #

# For GPT disks run
set id=de94bba4-06d1-4d40-a16a-bfd50179d6ac
gpt attributes=0x8000000000000001

# For MBR disks, run
set id=27

# Re-enable the recovery partition by running
reagentc /enable
```
