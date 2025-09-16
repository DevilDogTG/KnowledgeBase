---
layout: default
---
# IP Address COnfiguration

You can check current IP Address with

```sh
ip a
```

default debian setup will use dhcp for IP address, in this case i need to assign manual IP address by edit `/etc/network/interfaces`

```sh
iface [ifname] inet static
    address 192.168.99.1/24
    gateway 192.168.99.254
```

Save and restart `networking.service` to use assigned IP

```sh
sudo systemctl restart networking.service
```
