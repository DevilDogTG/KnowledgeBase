---
layout: default
---
# :book: NetBox: IPAM Tool

NetBox required `PostgreSQL` and `Redis` as dependency this guide will skip installation process for it.

Installing pre-required packages

```sh
sudo apt install -y curl python3 python3-pip python3-venv python3-dev build-essential libxml2-dev libxslt1-dev libffi-dev libpq-dev libssl-dev zlib1g-dev
```

Check python version running

```sh
python3 -V
```

## Download NetBox

Download the [latest stable release](https://github.com/netbox-community/netbox/releases) from GitHub as a tarball or ZIP archive and extract it to your desired path. In this example, we'll use `/opt/netbox` as the NetBox root, In this guide using version `4.1.7`

```sh
sudo wget https://github.com/netbox-community/netbox/archive/refs/tags/v4.1.7.tar.gz
sudo tar -xzf v4.1.7.tar.gz -C /opt
sudo ln -s /opt/netbox-4.1.7/ /opt/netbox
```

## Create the NetBox System User

Create a system user account named `netbox`. We'll configure the WSGI and HTTP services to run under this account. We'll also assign this user ownership of the media directory. This ensures that NetBox will be able to save uploaded files.

```sh
sudo adduser --system --group netbox
sudo chown --recursive netbox /opt/netbox/netbox/media/
sudo chown --recursive netbox /opt/netbox/netbox/reports/
sudo chown --recursive netbox /opt/netbox/netbox/scripts/
```

## Configuration

Start with example configuration and update `ALLOWED_HOST` `DATABASE` `REDIS` `SECRET_KEY` as of your setting.

```sh
cd /opt/netbox/netbox/netbox/
sudo cp configuration_example.py configuration.py
```

for secret key. you can generate it with pre-defined script

```sh
python3 ../generate_secret_key.py
```

## Run the upgrade script

Once NetBox has been configured, we're ready to proceed with the actual installation. We'll run the packaged upgrade script (upgrade.sh) to perform the following actions:

- Create a Python virtual environment
- Installs all required Python packages
- Run database schema migrations
- Builds the documentation locally (for offline use)
- Aggregate static resource files on disk

```sh
sudo /opt/netbox/upgrade.sh
```

## Create a Super User

Enter the Python virtual environment created by the upgrade script:

```sh
source /opt/netbox/venv/bin/activate
```

Once the virtual environment has been activated, you should notice the string (`venv`) prepended to your console prompt.

```sh
cd /opt/netbox/netbox
python3 manage.py createsuperuser
```

## Schedule the Housekeeping Task

```sh
sudo ln -s /opt/netbox/contrib/netbox-housekeeping.sh /etc/cron.daily/netbox-housekeeping
```

## Gunicorn

NetBox ships with a default configuration file for gunicorn.

```sh
sudo cp /opt/netbox/contrib/gunicorn.py /opt/netbox/gunicorn.py
```

## Setup `systemd`

copy `contrib/netbox.service` and `contrib/netbox-rq.service` to the `/etc/systemd/system/` directory and reload the systemd daemon.

```sh
sudo cp -v /opt/netbox/contrib/*.service /etc/systemd/system/
sudo systemctl daemon-reload
```

Then, start the netbox and netbox-rq services and enable them to initiate at boot time:

```sh
sudo systemctl enable --now netbox netbox-rq
```

Verify that the WSGI service is running:

```sh
systemctl status netbox.service
```

## Setup HTTP Server

Install `NGINX` as HTTP server

```sh
sudo apt install -y nginx
```

after installed, copy configuration file provide by NetBox. Please check server_name with domain or IP address of your installation.

```sh
sudo cp /opt/netbox/contrib/nginx.conf /etc/nginx/sites-available/netbox
```

Then, delete `/etc/nginx/sites-enabled/default` and create a symlink in the sites-enabled directory to the configuration file you just created.

```sh
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/netbox /etc/nginx/sites-enabled/netbox
```

## (Optional) Install NGINX-UI for easy manage host

To manage `NGINX` and automatically certificate with UI, run this command to install as root:

```sh
bash <(curl -L -s https://raw.githubusercontent.com/0xJacky/nginx-ui/master/install.sh) install
```

you can access `NGINX-UI` with url <http://ip.address:9000>

site configuration will manage by `NGINX-UI` you can re-issue certificate or config certificate use for netbox site. when everything done you can access by url <https://ip.address>

## Referrences

- [NetBox Installation](https://netboxlabs.com/docs/netbox/en/stable/installation/)
