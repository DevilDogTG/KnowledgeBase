---
layout: default
---
# Create the LXC template

In order to turn the container into a template, we need to delete the network interface then create a backup.

From proxmox (not inside the container):

```sh
# Remove the network interface:
sudo pct set 250 --delete net0
#Create a backup:
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

See `man vzdump` for info.
