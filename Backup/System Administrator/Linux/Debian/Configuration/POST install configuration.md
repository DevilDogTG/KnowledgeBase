---
layout: default
---
# :wrench: POST install configuration

After installed debian. this recommend to setup

## Make user admin priviledge by `sudo`

Install package useful to manage

``` shell
apt install -y net-tools sudo curl
```

Then add initial user to sudo group

``` shell
adduser [username] sudo
```

## Disabling the `root` user login

Now we has an administrative `sudo` user. you can disable the `root` user login altogether.

Edit file `/etc/passwd` and changing `root` line as shown below

``` shell
root:x:0:0:root:/root:/usr/sbin/nologin
```

After that, lock `root` user with

``` shell
passwd -l root
```

A user with the password locked can't login: the `passwd -l` command has corrupted, by putting a `!` character, the `root` password hash stored in the `/etc/shadow` file.

## Passwordless configuration

### Generate key

If not have any key you can gen ssh key by

```shell
ssh-keygen -t rsa
```

command will create `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub` for you

Tes to register new key

```shell
ssh-copy-id -n -i ~/.ssh/id_rsa username@server.ip
```

When everything ok jus remove `-n` to register your key

```shell
ssh-copy-id -i ~/.ssh/id_rsa username@server.ip
```

### Make `sudo` without re-enter password

**Caution** Use with card this approch use for who want to make a passwordless system with use ssh with key only

Edit sudo config

```shell
visudo
```

add `[username] ALL=(ALL) NOPASSWD:ALL` to allow sudo without re-enter password

```shell
usename ALL=(ALL)   NOPASSWD:ALL
```

If you running on user has `sudo` priviledge you can use command to update your profile to use `sudo` without password

```sh
sudo bash -c "echo '$USER ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$USER && chmod 0440 /etc/sudoers.d/$USER"
```

### Remove account login with password

now you can lock user to login with password with

```shell
passwd -l username
```

Welcome to passwordless.
