---
title: "Install PowerDNS on Debian"
author: DevilDogTG
date: 2025-05-08 08:00:00 +0700
categories: [System Administrator, Linux]
tags: [linux, debian, installation, powerdns, dns]
---

## Setup Repositories & Install

Add the PowerDNS repository key and source:

```sh
sudo install -d /etc/apt/keyrings
sudo apt install curl
curl https://repo.powerdns.com/FD380FBB-pub.asc | sudo tee /etc/apt/keyrings/auth-49-pub.asc
```

Add the `pdns` repository:

```sh
echo 'deb [signed-by=/etc/apt/keyrings/auth-49-pub.asc] http://repo.powerdns.com/debian bookworm-auth-49 main' | sudo tee /etc/apt/sources.list.d/pdns.list
```

Create `/etc/apt/preferences.d/auth-49` to prioritize this repository:

```
Package: auth*
Pin: origin repo.powerdns.com
Pin-Priority: 600
```

Install PowerDNS:

```sh
sudo apt-get update
sudo apt-get install pdns-server
```

## Configure Database Backend

This guide uses `pdns-backend-pgsql`. Install it:

```sh
sudo apt install pdns-backend-pgsql
```

The schema file is at `/usr/share/pdns-backend-pgsql/schema/schema.pgsql.sql`. Apply it to your PostgreSQL database to create the required tables.

## Configuration

Edit the PowerDNS configuration:

```sh
sudo nano /etc/powerdns/pdns.conf
```

Example configuration:

```sh
api=yes
api-key=[StrongAPIKey]
include-dir=/etc/powerdns/pdns.d
launch=gpgsql
gpgsql-host=[dbhost]
gpgsql-dbname=[dbname]
gpgsql-user=[dbuser]
gpgsql-password=[Strong password]
gpgsql-dnssec=yes

log-timestamp=yes
loglevel-show=no
webserver=yes
webserver-address=0.0.0.0
webserver-allow-from=0.0.0.0/0,::/0
webserver-port=8081
```

Test the configuration (should see successful database connection):

```sh
sudo systemctl stop pdns.service
sudo pdns_server --daemon=no --guardian=no --loglevel=9
```

After successful test, enable and start the service:

```sh
sudo systemctl restart pdns
sudo systemctl enable pdns
```

Verify port 53 is open for DNS:

```sh
sudo ss -alnp4 | grep pdns
```

## References

- [PowerDNS repositories](https://repo.powerdns.com/)
- [Computing for Geeks](https://computingforgeeks.com/install-powerdns-and-powerdns-admin-on-debian/)
