---
layout: default
---
# :book: Uptime Kuma

## Pre-requirement

Install pre-required packages

```sh
sudo apt install curl git
```

> :information_source: Have some issue to run service as use privilege. This guide will install `uptime-kuma` as `root`.

### Install `Node.js`

Using nvm package manager, install pre-required package:

> :information_source: Installation with `nvm` required `curl` if not installed please run:
>
> ``` sh
> sudo apt install curl
> ```

```sh
# installs nvm (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

# Auto completion for nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# download and install Node.js (you may need to restart the terminal)
nvm install 22

# verifies the right Node.js version is in the environment
node -v # should print `v22.11.0`

# verifies the right npm version is in the environment
npm -v # should print `10.9.0`
```

## Installation

Clone git and build application package with `npm`

```sh
git clone https://github.com/louislam/uptime-kuma.git /opt/uptime-kuma
cd /opt/uptime-kuma
npm run setup
```

Install and setup to run in the background

```sh
# Install PM2 if you don't have it:
npm install pm2 -g && pm2 install pm2-logrotate

# Start Server
pm2 start server/server.js --name uptime-kuma
```

Configure to run on startup

```sh
pm2 save && pm2 startup
```

Uptime Kuma will be running on HTTP port 3001

## (Optional) Setup NGINX reverse proxy

Uptime Kuma is based on WebSocket. You need two more headers "Upgrade" and "Connection" in order to reverse proxy WebSocket.

```nginx
server {
  listen 443 ssl http2;
  # Remove '#' in the next line to enable IPv6
  # listen [::]:443 ssl http2;
  server_name sub.domain.com;
  ssl_certificate     /path/to/ssl/cert/crt;
  ssl_certificate_key /path/to/ssl/key/key;
  # *See "With SSL (Certbot)" below for details on automating ssl certificates

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

## How to update to current version

It just fetches current version and rebuild application to run with current version

```sh
cd ~/uptime-kuma

# Update from git
git fetch --all
git checkout 1.23.15 --force

# Install dependencies and prebuilt
npm install --production
npm run download-dist

# Restart
pm2 restart uptime-kuma
```

## Monitoring services

using `PM2` commands:

```sh
# If you want to see the current console output
pm2 monit
```

## Referrences

- [GitHub: Uptime Kuma](https://github.com/louislam/uptime-kuma/)
