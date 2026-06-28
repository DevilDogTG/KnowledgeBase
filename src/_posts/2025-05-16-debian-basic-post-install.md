---
title: "Debian Basic Post Install"
author: DevilDogTG
date: 2025-05-16 08:00:00 +0700
categories: [System Administrator, Linux]
tags: [linux, debian, configuration, post install, security]
---

After installing Debian, these steps are recommended.

## Make User Admin with `sudo`

Install useful management packages:

```sh
apt install net-tools sudo
```

Then add the initial user to the sudo group:

```sh
adduser [username] sudo
```

## Disable `root` User Login

Now that you have an administrative `sudo` user, you can disable the `root` user login altogether.

Edit `/etc/passwd` and change the `root` line as shown below:

```
root:x:0:0:root:/root:/usr/sbin/nologin
```

After that, lock the `root` user:

```sh
passwd -l root
```

A user with a locked password can't login: `passwd -l` puts a `!` character in front of the password hash stored in `/etc/shadow`.
