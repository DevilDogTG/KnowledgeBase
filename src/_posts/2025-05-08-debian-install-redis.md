---
title: "Install Redis on Debian"
author: DevilDogTG
date: 2025-05-08 08:00:00 +0700
categories: [System Administrator, Linux]
tags: [linux, debian, installation, redis, database, cache]
---

Redis is a key-value database. This guide installs it on Debian 12.

## Setup Repositories

Add the Redis repository to APT:

```sh
sudo apt-get install lsb-release curl gpg
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
sudo chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
```

> **Note for LXC:** If `lsb_release` fails, enable `nesting` or specify the distro name manually. For Debian 12, use `bookworm`.

## Install Redis

```sh
sudo apt update
sudo apt install redis
```

The default configuration file is at:

```sh
sudo nano /etc/redis/redis.conf
```

Test that Redis is running:

```sh
redis-cli ping
```

A successful response returns `PONG`.

## References

- [Redis Docs — Install on Linux](https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/install-redis-on-linux/)
