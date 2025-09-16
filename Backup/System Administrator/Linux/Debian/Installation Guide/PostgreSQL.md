---
layout: default
---
# 📖 PostgreSQL

This guide will instruction how to install PostgreSQL for newbie

## Adding `PostgreSQL` repositories

multiple way to added repositories please select 1 of it.

### Use automates configuration script

to add your repositories automatically, you can install package and run script

```sh
sudo apt install -y postgresql-common
# Run command to auto added source for any version of PostgreSQL
sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
```

### Added by yourself

Manually configure the apt repository, follow these steps:

```sh
sudo apt install curl ca-certificates
sudo install -d /usr/share/postgresql-common/pgdg
sudo curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
sudo sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
```

> ℹ️ For LXC we cannot resolve `$lsb_release -cs` automatically, please specify distro you used, eg. Debian 12 is `bookworm`
>
> ```sh
> sudo sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
> ```

After added repositories you need to update source list

```sh
sudo apt update
```

## Installation

Easy install by using:

```sh
sudo apt install postgresql
```

If you want to be specified version you can uses follow command:

```sh
sudo apt install postgresql-[version]
```

Replace `version` to number you need to install
enable and verify services

```sh
sudo systemctl enable postgresql.service 
sudo systemctl start postgresql.service
sudo systemctl status postgresql.service 
```

Connecting database by default user `postgres`

```sh
sudo -u postgres psql
```

You will see to prompt when logged in:

```sh
postgres=#
```

To ensure database security, please setup strong password for default user

```sh
\password postgres
```

## Referrences

- [PostgreSQL: Linux downloads (Debian)](https://www.postgresql.org/download/linux/debian/)
