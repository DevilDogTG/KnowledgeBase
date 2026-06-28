---
title: "Install Uptime Kuma on Debian"
author: DevilDogTG
date: 2025-05-08 08:00:00 +0700
categories: [System Administrator, Linux]
tags: [linux, debian, installation, uptime kuma, monitoring, nodejs]
---

## Pre-requirements

Install required packages:

```sh
sudo apt install curl git
```

> **Note:** This guide installs Uptime Kuma as `root` due to some issues running as a non-root user.

### Install Node.js

Using `nvm`:

```sh
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

# Set up auto-completion
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Install Node.js 22
nvm install 22
node -v   # should print v22.11.0
npm -v    # should print 10.9.0
```

## Installation

Clone and build the application:

```sh
git clone https://github.com/louislam/uptime-kuma.git /opt/uptime-kuma
cd /opt/uptime-kuma
npm run setup
```

Install PM2 and start the server:

```sh
npm install pm2 -g && pm2 install pm2-logrotate
pm2 start server/server.js --name uptime-kuma
```

Configure to run on startup:

```sh
pm2 save && pm2 startup
```

Uptime Kuma runs on port 3001.

## (Optional) NGINX Reverse Proxy

Uptime Kuma uses WebSocket, so you need `Upgrade` and `Connection` headers:

```nginx
server {
  listen 443 ssl http2;
  server_name sub.domain.com;
  ssl_certificate     /path/to/ssl/cert/crt;
  ssl_certificate_key /path/to/ssl/key/key;

  location / {
    proxy_set_header   X-Real-IP $remote_addr;
    proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header   Host $host;
    proxy_pass         http://localhost:3001/;
    proxy_http_version 1.1;
    proxy_set_header   Upgrade $http_upgrade;
    proxy_set_header   Connection "upgrade";
  }
}
```

## How to Update

```sh
cd ~/uptime-kuma

# Fetch the latest version
git fetch --all
git checkout 1.23.15 --force

# Install dependencies and rebuild
npm install --production
npm run download-dist

# Restart
pm2 restart uptime-kuma
```

## Monitoring with PM2

```sh
pm2 monit
```

## References

- [GitHub: Uptime Kuma](https://github.com/louislam/uptime-kuma/)
