---
title: "Debian POST Install Configuration"
author: DevilDogTG
date: 2025-05-10 08:00:00 +0700
categories: [System Administrator, Linux]
tags: [linux, debian, configuration, post install, security, ssh]
---

After installing Debian, the following setup is recommended.

## Make User Admin with `sudo`

Install useful management packages:

```shell
apt install -y net-tools sudo curl
```

Then add the initial user to the sudo group:

```shell
adduser [username] sudo
```

## Disable `root` User Login

Now that you have an administrative `sudo` user, you can disable the `root` user login altogether.

Edit `/etc/passwd` and change the `root` line as shown below:

```
root:x:0:0:root:/root:/usr/sbin/nologin
```

After that, lock the `root` user:

```shell
passwd -l root
```

A user with a locked password can't login: `passwd -l` puts a `!` character in front of the password hash in `/etc/shadow`.

## Passwordless SSH Configuration

### Generate SSH Key

If you don't have a key, generate one:

```shell
ssh-keygen -t rsa
```

This creates `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`.

Test registering the key (dry-run with `-n`):

```shell
ssh-copy-id -n -i ~/.ssh/id_rsa username@server.ip
```

When everything looks good, remove `-n` to register:

```shell
ssh-copy-id -i ~/.ssh/id_rsa username@server.ip
```

### Make `sudo` Passwordless

> **Caution:** Use with care — this approach is for passwordless systems that use SSH key authentication only.

Edit the sudo config:

```shell
visudo
```

Add `[username] ALL=(ALL) NOPASSWD:ALL` to allow sudo without re-entering password:

```
username ALL=(ALL)   NOPASSWD:ALL
```

Or use this one-liner if you already have sudo privileges:

```sh
sudo bash -c "echo '$USER ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$USER && chmod 0440 /etc/sudoers.d/$USER"
```

### Lock Password-Based Login

Lock the user account from password login:

```shell
passwd -l username
```

Welcome to passwordless.
