---
layout: default
---
# Debian post install configuration

After installed debian. this recommended to setup

## Make user admin priviledge by `sudo`

Install package useful to manage

```sh
apt install net-tools sudo
```

Then add initial user to sudo group

```sh
adduser [username] sudo
```

## Disabling the `root` user login

Now we has an administrative `sudo` user. you can disable the `root` user login altogether.

Edit file `/etc/passwd` and changing `root` line as shown below

```sh
root:x:0:0:root:/root:/usr/sbin/nologin
```

After that, lock `root` user with

```sh
passwd -l root
```

A user with the password locked can't login: the `passwd -l` command has corrupted, by putting a `!` character, the `root` password hash stored in the `/etc/shadow` file.
