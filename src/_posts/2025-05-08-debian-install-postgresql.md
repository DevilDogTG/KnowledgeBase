---
title: "Install PostgreSQL on Debian"
author: DevilDogTG
date: 2025-05-08 08:00:00 +0700
categories: [System Administrator, Linux]
tags: [linux, debian, installation, postgresql, database]
---

## Adding PostgreSQL Repositories

There are multiple ways to add the PostgreSQL repository. Select one.

### Use the Automated Configuration Script

```sh
sudo apt install -y postgresql-common
sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
```

### Add Manually

```sh
sudo apt install curl ca-certificates
sudo install -d /usr/share/postgresql-common/pgdg
sudo curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
sudo sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
```

> **Note for LXC:** `lsb_release -cs` may not resolve automatically. Specify the distro manually. For Debian 12:
>
> ```sh
> sudo sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
> ```

Update the source list:

```sh
sudo apt update
```

## Installation

Install the latest version:

```sh
sudo apt install postgresql
```

Or install a specific version:

```sh
sudo apt install postgresql-[version]
```

Enable and verify the service:

```sh
sudo systemctl enable postgresql.service
sudo systemctl start postgresql.service
sudo systemctl status postgresql.service
```

Connect using the default `postgres` user:

```sh
sudo -u postgres psql
```

You'll see the prompt:

```
postgres=#
```

Set a strong password for the default user:

```sh
\password postgres
```

## References

- [PostgreSQL: Linux downloads (Debian)](https://www.postgresql.org/download/linux/debian/)
