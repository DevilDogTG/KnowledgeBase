---
title: "Install NetBox on Debian"
author: DevilDogTG
date: 2025-04-30 08:00:00 +0700
categories: [System Administrator, Linux]
tags: [linux, debian, installation, netbox, ipam, nginx]
---

NetBox requires [PostgreSQL](/posts/debian-install-postgresql/) and [Redis](/posts/debian-install-redis/) as dependencies. This guide skips their installation — please complete those first.

Install pre-required packages:

```sh
sudo apt install -y curl python3 python3-pip python3-venv python3-dev build-essential libxml2-dev libxslt1-dev libffi-dev libpq-dev libssl-dev zlib1g-dev
```

Check the Python version:

```sh
python3 -V
```

## Download NetBox

Download the [latest stable release](https://github.com/netbox-community/netbox/releases) from GitHub and extract to `/opt/netbox`. This example uses version `4.1.7`:

```sh
sudo wget https://github.com/netbox-community/netbox/archive/refs/tags/v4.1.7.tar.gz
sudo tar -xzf v4.1.7.tar.gz -C /opt
sudo ln -s /opt/netbox-4.1.7/ /opt/netbox
```

## Create the NetBox System User

Create a system user named `netbox` and assign ownership of the media directories:

```sh
sudo adduser --system --group netbox
sudo chown --recursive netbox /opt/netbox/netbox/media/
sudo chown --recursive netbox /opt/netbox/netbox/reports/
sudo chown --recursive netbox /opt/netbox/netbox/scripts/
```

## Configuration

Copy the example configuration and update `ALLOWED_HOST`, `DATABASE`, `REDIS`, and `SECRET_KEY`:

```sh
cd /opt/netbox/netbox/netbox/
sudo cp configuration_example.py configuration.py
```

Generate a secret key using the pre-defined script:

```sh
python3 ../generate_secret_key.py
```

## Run the Upgrade Script

Run the packaged upgrade script to:
- Create a Python virtual environment
- Install all required Python packages
- Run database schema migrations
- Build documentation locally
- Aggregate static resource files

```sh
sudo /opt/netbox/upgrade.sh
```

## Create a Superuser

Activate the virtual environment:

```sh
source /opt/netbox/venv/bin/activate
```

Create the superuser:

```sh
cd /opt/netbox/netbox
python3 manage.py createsuperuser
```

## Schedule the Housekeeping Task

```sh
sudo ln -s /opt/netbox/contrib/netbox-housekeeping.sh /etc/cron.daily/netbox-housekeeping
```

## Gunicorn

NetBox ships with a default gunicorn configuration:

```sh
sudo cp /opt/netbox/contrib/gunicorn.py /opt/netbox/gunicorn.py
```

## Setup `systemd`

Copy the service files and reload systemd:

```sh
sudo cp -v /opt/netbox/contrib/*.service /etc/systemd/system/
sudo systemctl daemon-reload
```

Enable and start the services:

```sh
sudo systemctl enable --now netbox netbox-rq
```

Verify the service is running:

```sh
systemctl status netbox.service
```

## Setup NGINX

Install NGINX:

```sh
sudo apt install -y nginx
```

Copy the NetBox-provided NGINX configuration (update `server_name` with your domain or IP):

```sh
sudo cp /opt/netbox/contrib/nginx.conf /etc/nginx/sites-available/netbox
```

Remove the default site and enable NetBox:

```sh
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/netbox /etc/nginx/sites-enabled/netbox
```

## (Optional) Install NGINX-UI

To manage NGINX and automate SSL certificates with a UI:

```sh
bash <(curl -L -s https://raw.githubusercontent.com/0xJacky/nginx-ui/master/install.sh) install
```

Access NGINX-UI at `http://ip.address:9000`. Once configured, access NetBox at `https://ip.address`.

## References

- [NetBox Installation](https://netboxlabs.com/docs/netbox/en/stable/installation/)
