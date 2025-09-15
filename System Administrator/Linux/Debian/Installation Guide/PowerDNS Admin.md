---
layout: default
---
# :book: PowerDNS Admin

Web Interface for PowerDNS easier to manage your PowerDNS server

## Pre-required installation

In case of use PostgreSQL for DB Backend install following:

```sh
sudo apt install python3-psycopg2
```

Following is required packages for PowerDNS admin

```sh
sudo apt install -y python3-dev git libsasl2-dev libldap2-dev python3-venv libmariadb-dev 
```

### Install `Node.Js`

This guide will be using `nvm`

> :information_source: Installation with `nvm` required `curl` if not installed please run:
>
> ``` sh
> sudo apt install curl
> ```

```sh
# installs nvm (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
```

Setup auto completion for `nvm`

```sh
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
```

Next install `Node.js`

```sh
# download and install Node.js (you may need to restart the terminal)
nvm install 22

# verifies the right Node.js version is in the environment
node -v # should print `v22.11.0`

# verifies the right npm version is in the environment
npm -v # should print `10.9.0`
```

Script as of November 2024 if need lasted version please check NodeJS official site.

### Install `yarn` to build asset files

Run command to setup repository and install:

```sh
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install -y yarn
```

## Checkout source-code and create virtual env

> :information_source: You can adjust `/opt/web/powerdns-admin` to your local application directory

Run this command:

```sh
sudo su
git clone https://github.com/PowerDNS-Admin/PowerDNS-Admin.git /opt/web/powerdns-admin
cd /opt/web/powerdns-admin
python3 -mvenv ./venv
```

Activate your python environment and install libraries:

```sh
source ./venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

## Finalizing package

Create PowerDNS-Admin config file and make the changes necessary for your use case. Make sure to change `SECRET_KEY` to a long random string that you generated yourself (see Flask docs), do not use the pre-defined one. E.g.:

```sh
cp /opt/web/powerdns-admin/configs/development.py /opt/web/powerdns-admin/configs/production.py
nano /opt/web/powerdns-admin/configs/production.py
export FLASK_CONF=../configs/production.py
```

run DB migration

```sh
export FLASK_APP=powerdnsadmin/__init__.py
flask db upgrade
flask db migrate -m "Init DB"
yarn install --pure-lockfile
flask assets build
deactivate
```

## Using `NGINX` as web server

Configure systemd service

```sh
sudo nano /etc/systemd/system/powerdns-admin.service
```

File content as

```sh
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

Create socket

```sh
sudo nano /etc/systemd/system/powerdns-admin.socket
```

socket file content as:

```sh
[Unit]
Description=PowerDNS-Admin socket

[Socket]
ListenStream=/run/powerdns-admin/socket

[Install]
WantedBy=sockets.target
```

Create tmp config

```sh
sudo nano /etc/tmpfiles.d/powerdns-admin.conf
```

Content as:

```sh
d /run/powerdns-admin 0755 pdns pdns -
```

Change powerdns-admin owner to pdns

```sh
sudo chown -R pdns: /run/powerdns-admin
sudo chown -R pdns: /opt/web/powerdns-admin
```

### Sample `NGINX` configuration

```nginx
server {
        listen                  80 default_server;
        server_name             "";
        return 301 https://$http_host$request_uri;
}

server {
        listen                  443 ssl http2 default_server;
        server_name             _;
        index                   index.html index.htm;
        error_log               /var/log/nginx/error_powerdnsadmin.log error;
        access_log              off;

        ssl_certificate                 path_to_your_fullchain_or_cert;
        ssl_certificate_key             path_to_your_key;
        ssl_prefer_server_ciphers       on;
        ssl_ciphers                     'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
        ssl_session_cache               shared:SSL:10m;

        client_max_body_size            10m;
        client_body_buffer_size         128k;
        proxy_redirect                  off;
        proxy_connect_timeout           90;
        proxy_send_timeout              90;
        proxy_read_timeout              90;
        proxy_buffers                   32 4k;
        proxy_buffer_size               8k;
        proxy_set_header                Host $http_host;
        proxy_set_header                X-Scheme $scheme;
        proxy_set_header                X-Real-IP $remote_addr;
        proxy_set_header                X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header                X-Forwarded-Proto $scheme;
        proxy_headers_hash_bucket_size  64;

        location ~ ^/static/  {
                include         mime.types;
                root            /opt/web/powerdns-admin/powerdnsadmin;
                location        ~* \.(jpg|jpeg|png|gif)$ { expires 365d; }
                location        ~* ^.+.(css|js)$ { expires 7d; }
        }

        location ~ ^/upload/  {
                include         mime.types;
                root            /opt/web/powerdns-admin;
                location        ~* \.(jpg|jpeg|png|gif)$ { expires 365d; }
                location        ~* ^.+.(css|js)$ { expires 7d; }
        }

        location / {
                proxy_pass              http://unix:/run/powerdns-admin/socket;
                proxy_read_timeout      120;
                proxy_connect_timeout   120;
                proxy_redirect          http:// $scheme://;
        }
}
```

## Referrences

- [PowerDNS-Admin](https://github.com/PowerDNS-Admin/PowerDNS-Admin/blob/master/docs/wiki/database-setup/README.md)
- [Node.js Download](https://nodejs.org/en/download/package-manager)
