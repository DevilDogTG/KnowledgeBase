---
layout: default
---
# Emergency Fix Cluster

**IMPORTANT:** don't do anything else on the nodes while doing the following steps, you are disabling safety checks that prevent bad things from happening!

since you haven't written anything about nodes actually going down/being fenced, I assume you don't have HA enabled/active ;) if you do, you need to stop HA services first!

```bash
# stop corosync and pmxcfs on all nodes
$ systemctl stop corosync pve-cluster

# start pmxcfs in local mode on all nodes
$ pmxcfs -l

# put correct corosync config into local pmxcfs and corosync config dir (make sure to bump the 'config_version' inside the config file)
$ cp correct_corosync.conf /etc/pve/corosync.conf
$ cp correct_corosync.conf /etc/corosync/corosync.conf

# kill local pmxcfs
$ killall pmxcfs

# start corosync and pmxcfs again
$ systemctl start pve-cluster corosync

# check status
$ journalctl --since '-5min' -u pve-cluster -u corosync
$ pvecm status
```
