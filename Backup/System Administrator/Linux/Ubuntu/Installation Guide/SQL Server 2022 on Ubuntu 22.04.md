---
layout: default
---
# :book: SQL Server 2022 on Ubuntu 22.04

> This guide will walkthrough installation guide from Microsoft and not include step to install and config Ubuntu
> 
> **Source:** [https://learn.microsoft.com/en-us/sql/linux/quickstart-install-connect-ubuntu](https://learn.microsoft.com/en-us/sql/linux/quickstart-install-connect-ubuntu?view=sql-server-ver16&tabs=ubuntu2204)

Microsoft provide guide to installation SQL Server on Linux, but This will focus only installation on Ubuntu 22.04 only

Start with setup repository:
```sh
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg
curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
curl -fsSL https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2022.list | sudo tee /etc/apt/sources.list.d/mssql-server-2022.list
```

After added repository run to command to install SQL Server
```sh
sudo apt-get update
sudo apt-get install -y mssql-server
```

After installation complete, run command:
```sh
sudo /opt/mssql/bin/mssql-conf setup
```

This will complete your installation, like production version selected and setup super admin password.


## (Optional) Disable `sa` account

When you connect to your SQL Server instance using the sa account for the first time after installation, it's important for you to follow these steps, and then immediately disable the sa login as a security best practice.

1. Create a new login, and make it a member of the sysadmin server role.
2. Connect to the SQL Server instance using the new login you created.
3. Disable the `sa` account, as recommended for security best practice.
