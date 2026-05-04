---
title: "Install SFTPGo on Debian"
author: DevilDogTG
date: 2025-05-08 08:00:00 +0700
categories: [System Administrator, Linux]
tags: [linux, debian, installation, sftpgo, sftp, file transfer]
---

SFTPGo is an event-driven file transfer solution. It supports multiple protocols (SFTP, SCP, FTP/S, WebDAV, HTTP/S) and multiple storage backends.

## Installation

Install pre-required packages:

```sh
sudo apt install gnupg curl
```

Import the public key:

```sh
curl -sS https://ftp.osuosl.org/pub/sftpgo/apt/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/sftpgo-archive-keyring.gpg
```

Add the SFTPGo source list:

```sh
CODENAME=`lsb_release -c -s`
echo "deb [signed-by=/usr/share/keyrings/sftpgo-archive-keyring.gpg] https://ftp.osuosl.org/pub/sftpgo/apt ${CODENAME} main" | sudo tee /etc/apt/sources.list.d/sftpgo.list
```

Install via `apt`:

```sh
sudo apt update
sudo apt install sftpgo
```

## Data Provider Configuration

Before starting SFTPGo, configure and initialize the data provider.

- **SQLite**: created automatically at startup
- **PostgreSQL / MySQL / CockroachDB**: create the database first

Edit the configuration:

```sh
sudo nano /etc/sftpgo/sftpgo.json
```

Update the `data_provider` section:

```json
"data_provider": {
    "driver": "postgresql",
    "name": "dbname",
    "host": "db.ip.address",
    "port": 0,
    "username": "username",
    "password": "password",
    "sslmode": 0,
...
```

Or initialize the provider manually:

```sh
sudo sftpgo initprovider
```

Open a browser and go to <http://your.ip.address:8080>. On first access, you will create the admin account.

![Initial SFTPGo admin account setup](/assets/contents/2025/linux-debian-installation/sftpgo.png)

## References

- [SFTPGo Documentation](https://docs.sftpgo.com/latest/)
