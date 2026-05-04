---
title: "Install PowerDNS Admin on Debian"
author: DevilDogTG
date: 2025-05-08 08:00:00 +0700
categories: [System Administrator, Linux]
tags: [linux, debian, installation, powerdns, dns, web ui, nginx]
---

PowerDNS Admin is a web interface for managing your [PowerDNS](/posts/debian-install-powerdns/) server.

## Pre-required Installation

For PostgreSQL backend:

```sh
sudo apt install python3-psycopg2
```

Required packages for PowerDNS Admin:

```sh
sudo apt install -y python3-dev git libsasl2-dev libldap2-dev python3-venv libmariadb-dev
```

### Install Node.js

This guide uses `nvm`.

> **Note:** `nvm` requires `curl`:
> ```sh
> sudo apt install curl
> ```

```sh
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

# Set up auto-completion
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
```

Install Node.js:

```sh
nvm install 22
node -v   # should print v22.11.0
npm -v    # should print 10.9.0
```

### Install `yarn`

```sh
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install -y yarn
```

## Checkout Source Code and Create Virtual Environment

> **Note:** Adjust `/opt/web/powerdns-admin` to your preferred application directory.

```sh
sudo su
git clone https://github.com/PowerDNS-Admin/PowerDNS-Admin.git /opt/web/powerdns-admin
cd /opt/web/powerdns-admin
python3 -mvenv ./venv

source ./venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

## Finalize Configuration

Create the production config and update `SECRET_KEY` (generate a long random string):

```sh
cp /opt/web/powerdns-admin/configs/development.py /opt/web/powerdns-admin/configs/production.py
nano /opt/web/powerdns-admin/configs/production.py
export FLASK_CONF=../configs/production.py
```

Run DB migration and build assets:

```sh
export FLASK_APP=powerdnsadmin/__init__.py
flask db upgrade
flask db migrate -m "Init DB"
yarn install --pure-lockfile
flask assets build
deactivate
```

## Setup `systemd` Service

Create `/etc/systemd/system/powerdns-admin.service`:

```ini
[Unit]
Description=PowerDNS-Admin
Requires=powerdns-admin.socket
After=network.target

[Service]
Environment="FLASK_CONF=../configs/production.py"
PIDFile=/run/powerdns-admin/pid
User=pdns
Group=pdns
WorkingDirectory=/opt/web/powerdns-admin
ExecStartPre=+mkdir -p /run/powerdns-admin/
ExecStartPre=+chown pdns:pdns -R /run/powerdns-admin/
ExecStart=/opt/web/powerdns-admin/venv/bin/gunicorn --pid /run/powerdns-admin/pid --bind unix:/run/powerdns-admin/socket 'powerdnsadmin:create_app()'
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

Create `/etc/systemd/system/powerdns-admin.socket`:

```ini
[Unit]
Description=PowerDNS-Admin socket

[Socket]
ListenStream=/run/powerdns-admin/socket

[Install]
WantedBy=sockets.target
```

Create `/etc/tmpfiles.d/powerdns-admin.conf`:

```
d /run/powerdns-admin 0755 pdns pdns -
```

Set ownership:

```sh
sudo chown -R pdns: /run/powerdns-admin
sudo chown -R pdns: /opt/web/powerdns-admin
```

## NGINX Configuration

```nginx
server {
    listen 80 default_server;
    server_name "";
    return 301 https://$http_host$request_uri;
}

server {
    listen 443 ssl http2 default_server;
    server_name _;
    error_log /var/log/nginx/error_powerdnsadmin.log error;
    access_log off;

    ssl_certificate path_to_your_fullchain_or_cert;
    ssl_certificate_key path_to_your_key;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
    ssl_session_cache shared:SSL:10m;

    client_max_body_size 10m;
    proxy_set_header Host $http_host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

    location ~ ^/static/ {
        include mime.types;
        root /opt/web/powerdns-admin/powerdnsadmin;
    }

    location / {
        proxy_pass http://unix:/run/powerdns-admin/socket;
        proxy_read_timeout 120;
        proxy_connect_timeout 120;
        proxy_redirect http:// $scheme://;
    }
}
```

## References

- [PowerDNS-Admin](https://github.com/PowerDNS-Admin/PowerDNS-Admin/blob/master/docs/wiki/database-setup/README.md)
- [Node.js Download](https://nodejs.org/en/download/package-manager)
