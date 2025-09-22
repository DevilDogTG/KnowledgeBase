---
title: ตั้งค่าเพิ่มเติมหลังติดตั้ง Debian
author: DevilDogTG
date: 2025-09-18 10:09:00 +0700
categories: [Linux, Configuration]
tags: [tutorials, linux, debian, ภาษาไทย] # TAG names should always be lowercase
---

หลังทำการติดตั้ง `Debian` แบบพื้นฐาน, แนะนำให้ตั้งค่าเพิ่มเติม (ตัวเลือก)

## หลีกเลี่ยงการใช้ `root` user

เพื่อหลีกเลี่ยงการใช้งาน `root` user แต่ยังคงสามารถเข้าถึงสิทธิ์ admin ได้โดยใช้ user ที่กำหนดเอง สามารถทำได้ดังนี้

```shell
# Update repository database
apt update
# install `sudo` package
apt install sudo
```

เพิ่ม user ที่ต้องการเข้ากลุ่ม `sudo`

```shell
adduser username sudo
```

จากนั้น user ที่ระบุจะสามารถเข้าถึงสิทธิ์ admin ได้โดยใช้ `sudo` นำหน้าคำสั่งที่ต้องการ ซึ่งระบบจะให้เรายืนยันด้วยการกรอกรหัสผ่านของ user ปัจจุบันเมื่อร้องขอสิทธิ์ admin

```shell
sudo apt update
```

### ปิดการใช้งานของ `root`

แก้ไขไฟล์ `/etc/passwd` เพื่อเปลี่ยน default shell ของ `root`

```shell
sudo nano /etc/passwd

# แก้ไขบรรทัด root:x:0:0:root:/root:/usr/sbin/sh ให้เป็น
...
root:x:0:0:root:/root:/usr/sbin/nologin
...
```

จากนั้นทำการ lock user เพื่อไม่ให้ใช้งาน

```shell
sudo passwd -l root
```

### อนุญาตให้ใช้ `root` จาก Local Network เท่านั้น

หากไม่ต้องการปิดการใช้งาน `root` user เราสามารถจำกัดให้เข้าใช้งานได้จาก local network หรือผ่านทาง console หน้าเครื่องเท่านั้นได้

โดยให้ทำการแก้ไข `sshd_config` ดังนี้

```shell
sudo nano /etc/ssh/sshd_config

# ให้ uncomment PermitRootLogin แล้วปรับการตั้งค่าเป็น no หรือเพิ่มบรรทัดข้างล่างนี้
PermitRootLogin no
# อนุญาตเฉพาะการใช้งานหน้าเครื่อง โดยการเพิ่ม PermitRootLogin no
Match Address 127.0.0.1
  PermitRootLogin yes

```

เราสามารถระบุเป็นเครือข่ายที่กำหนดได้ ตัวอย่างเช่น

```shell
Match Address 192.168.1.*
  PermitRootLogin yes
```

จากนั้นให้ทำการ restart

### (ไม่แนะนำ) ตั้งค่าเพื่อใช้งาน `sudo` โดยไม่ต้องใส่รหัสผ่าน

> ❗**คำเตือน** การดำเนินการหัวข้อนี้มีข้อควรระวังเรื่องความปลอดภัย กรุณาทำความเข้าใจก่อนนำไปใช้

กรณีต้องการใช้ `sudo` โดยไม่ต้องกรอกรหัสผ่าน สามารถทำได้โดยใช้ `visudo` เพื่อแก้ไขไฟล์การตั้งค่า โดยให้เพิ่มบรรทัดนี้เข้าไปในไฟล์

```shell
usename ALL=(ALL) NOPASSWD:ALL
```

หรือสามารถทำได้โดยสร้างไฟล์ config ของ user ที่ต้องการได้เลย โดยใช้คำสั่งดังนี้

```shell
echo '$USER ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$USER && chmod 0440 /etc/sudoers.d/$USER

# กรณีรันด้วย user ที่ไม่ใช่ root และต้องการทำให้ตัวเองใช้งาน sudo ได้โดยไม่ต้องระบุรหัสผ่าน
sudo bash -c "echo '$USER ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$USER && chmod 0440 /etc/sudoers.d/$USER"
```

log-out และ log-in ใหม่จะสามารถใช้งานได้เลย

## เปิด/ปิด การใช้งาน SWAP

`swap` เป็น Virtual Memory เพื่อให้เราสามารถใช้หน่วยความจำได้มากขึ้น โดยบางงานอาจจะจำเป็นต้องมีการปิด (เช่น K8S) เพื่อให้ระบบทำงานได้ตามปกติ, ทั้งนี้ ตัวอย่างนี้จะใช้งานรูปแบบ swap file เป็นหลัก เนื่องจากสะดวกในการใช้งานมากกว่า

สามารถตรวจสอบ swap ที่ใช้งานปัจจุบันได้โดย

```shell
sudo swapon --show
# Output
NAME      TYPE  SIZE   USED PRIO
/swapfile file 1024M 507.4M   -1

# หรือ
sudo free -h
# Output
              total        used        free      shared  buff/cache   available
Mem:           488M        158M         83M        2.3M        246M        217M
Swap:          1.0G        506M        517M
```

### เปิดใช้งาน SWAP

สร้าง file ใน path ที่ต้องการ โดยใช้ `fallocate`

```shell
sudo fallocate -l 2G /swapfile
# อนุญาตให้ root เท่านั้นที่สามารถใช้งานไฟล์นี้ได้
sudo chmod 600 /swapfile
```

กำหนดให้ไฟล์เป็น swap area ของ Linux

```shell
sudo mkswap /swapfile
# Temporary enable swap
sudo swapon /swapfile
```

กรณีต้องการกำหนดให้ใช้งาน swap ถาวร สามารถทำได้โดยเพิ่มในไฟล์ `fstab`

```shell
/swapfile swap swap defaults 0 0
```

### ปิดใช้งาน SWAP

หากต้องการปิดใช้งานชั่วคราว สามารถรันคำสั่ง

```shell
swapoff -a
```

หรือทำการแก้ไขไฟล์ `fstab` เพื่อปิดใช้งานถาวร

```shell
sudo nano /etc/fstab
```

โดยทำการ comment หรือ remove บรรทัดของ swap ออก

```shell
# /swapfile swap swap defaults 0 0
```

## ตั้งค่าการ log-in ด้วย SSH Key

เราสามารถใช้ SSH Key ในการเข้าระบบแทนการใช้ รหัสผ่านได้ โดยสามารถทำได้ดังนี้

### สร้าง SSH Key (ไม่บังคับ)

ถ้าหากมี Key สำหรับใช้งานอยู่แล้ว สามารถข้ามขั้นตอนนี้ไปได้เลย, หากไม่มี สามารถสร้างได้ดังนี้

```shell
ssh-keygen -t rsa
```

ระบบจะทำการสร้างไฟล์ `id_rsa` และ `id_rsa.pub` ภายใต้โฟล์เดอร์ `~/.ssh`

- `id_rsa`: เป็น Private key จะใช้ที่เครื่องต้นทางเพื่อเป็นกุญแจในการเข้าใช้งาน
- `id_rsa.pub`: เป็น Public key หน้าที่ไว้สำหรับการตรวจสอบว่ากุญแจที่เข้าใช้นั้นถูกต้องหรือไม่

หลังจากได้ `Public Key` มาแล้ว ให้สร้างไฟล์ `authorized_keys` และใส่ public key ของเราไป

```shell
mkdir ~/.ssh
nano ~/.ssh/authorized_keys

# จากนั้นให้นำข้อมูลจากไฟล์ id_rsa.pub ใส่ในไฟล์ที่สร้าง
rsa xxxxxxxxx keyname
```

เท่านี้เราก็จะสามารถเข้าสู่ระบบโดยใช้ private key เข้าใช้งานงานได้เลย
