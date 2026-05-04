---
title: "Install SQL Server 2022 on Ubuntu 22.04"
author: DevilDogTG
date: 2025-04-30 08:00:00 +0700
categories: [System Administrator, Linux]
tags: [linux, ubuntu, installation, sql server, microsoft, database]
---

> This guide is based on the [Microsoft quickstart guide](https://learn.microsoft.com/en-us/sql/linux/quickstart-install-connect-ubuntu?view=sql-server-ver16&tabs=ubuntu2204) and focuses on installation on Ubuntu 22.04 only.

## Installation

Set up the Microsoft repository:

```sh
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg
curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
curl -fsSL https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2022.list | sudo tee /etc/apt/sources.list.d/mssql-server-2022.list
```

Install SQL Server:

```sh
sudo apt-get update
sudo apt-get install -y mssql-server
```

Run the configuration setup (select edition and set the SA password):

```sh
sudo /opt/mssql/bin/mssql-conf setup
```

## (Optional) Disable `sa` Account

As a security best practice, disable the default `sa` account after installation:

1. Create a new login and make it a member of the `sysadmin` server role
2. Connect to the SQL Server instance using the new login
3. Disable the `sa` account
