---
title: "Install Monit on Debian"
author: DevilDogTG
date: 2025-04-30 08:00:00 +0700
categories: [System Administrator, Linux]
tags: [linux, debian, installation, monit, monitoring]
---

Monit is an open-source monitoring tool for Linux.

## Installation

Monit is available in Debian repositories:

```sh
sudo apt update
sudo apt install monit
```

Enable it to run as a service:

```sh
sudo systemctl enable monit.service
```

## Basic Setup

The default configuration file is at `/etc/monit/monitrc`:

```sh
sudo nano /etc/monit/monitrc
```

Example configuration with some options updated:

```conf
set daemon 20           # Update healthcheck interval to 20s
   with start delay 120 # Delay the first check by 2 minutes after Monit start
...
set httpd port 2812 and
    use address 127.0.0.1  # Your IP Address
    allow admin:monit      # Require user 'admin' with password 'monit'
```

This enables the web interface at <http://127.0.0.1:2812>.

> **Note:** Change the IP address in the configuration file to match your server.

![Example Monit Screenshot](/assets/contents/2025/linux-debian-installation/monit.png)

In this example, Monit monitors NGINX and restarts it when it stops unexpectedly. Enable the bundled NGINX config:

```sh
sudo ln -s /etc/monit/conf-available/nginx /etc/monit/conf-enabled/
```

Reload Monit to apply:

```sh
sudo systemctl reload monit.service
```

Done. Try stopping NGINX and watch Monit restart it automatically.

## References

- [Using Monit process monitoring on Ubuntu/Debian](https://www.servers.com/support/knowledge/linux-administration/using-monit-process-monitoring-on-ubuntu-debian)
