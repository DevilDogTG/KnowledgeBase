---
layout: default
---
# :gear: IP Address config in Ubuntu

This is very simple task on Ubuntu, but I don’t know how to change or fix IP address. This article will help you do it.

## Disabled initial network config

By default, Ubuntu will replace network configuration every time your reboot same as installed time. To disabled configuration and make your config persistent run command to create config file:
```sh
sudo nano /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
```

And in file tell them not config network for us
```sh
network: {config: disabled}
```

Remove old config
```sh
sudo rm /etch/netplan/50-cloud-init.yaml
```

## Create network configuration file

Before setup you need to create network configuration file examples:
```sh
sudo nano /etc/netplan/10-netcfg.yaml
```

Now config you IP address
```yaml
network:
    ethernets:
        enp6s18:
            addresses:
            - 192.168.30.67/24
            nameservers:
                addresses:
                - 192.168.30.250
                search:
                - dmnsn.com
            routes:
            -   to: default
                via: 192.168.30.254
    version: 2
```

if you need to use DHCP just specify
```yaml
network:
    ethernets:
        enp6s18:
          dhcp4: true
    version: 2
```

Before applying new configuration, update to file permission to 600
```sh
sudo chmod 600 /etc/netplan/10-netcfg.yaml
```

After configured, please apply netplan to take effect
```sh
sudo netplan apply
# Check your current IP
ip addr
```

For minimal ubuntu install maybe error with ovswitch please use follow command and run `netplan apply` again
```sh 
sudo apt-get install openvswitch-switch-dpdk
sudo netplan apply
```
