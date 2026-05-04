---
title: "Install pgAdmin 4 on Debian"
author: DevilDogTG
date: 2025-05-08 08:00:00 +0700
categories: [System Administrator, Linux]
tags: [linux, debian, installation, pgadmin4, postgresql, web ui]
---

pgAdmin 4 helps manage [PostgreSQL](/posts/debian-install-postgresql/) servers with a web-based interface.

## Setup Repositories

Install the pgAdmin public key:

```sh
curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg
```

Add the repository and update:

```sh
sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/bookworm pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'
```

Install for web mode:

```sh
sudo apt install pgadmin4-web
```

Other install options:

```sh
# Desktop mode only
sudo apt install pgadmin4-desktop
# Both desktop and web
sudo apt install pgadmin4
```

## Post-Installation Setup

Run the setup script to configure the web server:

```sh
sudo /usr/pgadmin4/bin/setup-web.sh
```

Access pgAdmin at <http://127.0.0.1/pgadmin4>.

## (Optional) Change URL Base Path

To run pgAdmin at the root URL (without `/pgadmin4` suffix):

```sh
sudo nano /etc/apache2/conf-available/pgadmin4.conf
```

Replace:

```apache
# From original
WSGIScriptAlias /pgadmin4 /usr/pgadmin4/web/pgAdmin4.wsgi
# Changed to
WSGIScriptAlias / /usr/pgadmin4/web/pgAdmin4.wsgi
```

Restart Apache:

```sh
sudo systemctl restart apache2.service
```

Access pgAdmin at <http://127.0.0.1>.

![pgAdmin 4 Web Interface](/assets/contents/2025/linux-debian-installation/pgAdmin4.png)

## References

- [pgAdmin - PostgreSQL Tools](https://www.pgadmin.org/)
