---
layout: default
---
# :book: Redis

Redis server is key-value database. This guide will install on Debian 12

## Setup repositories

Add the repository to the APT index

```sh
sudo apt-get install lsb-release curl gpg
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
sudo chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
```

> :information_source: If you install on LXC please enable `nesting`. you will get error when call `lsb_release` please manually specified distro name of your OS, for Debian 12 is `bookworm`

## Install `Redis`

run command:

```sh
sudo apt update
sudo apt install redis
```

default configuration file is:

```sh
sudo nano /etc/redis/redis.conf
```

Test `redis` is running normally

```sh
redis-cli ping
```

Successfully, you will get `PONG`

## Conclusion

I my opinion, I thought use redis each instance per application run on it. It need install separately in case of scalable that run application on multiple hosts.

## Referrences

- [Redis Docs](https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/install-redis-on-linux/)
