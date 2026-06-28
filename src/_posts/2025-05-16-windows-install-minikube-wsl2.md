---
title: "Install minikube with WSL2 on Windows"
author: DevilDogTG
date: 2025-05-16 08:00:00 +0700
categories: [System Administrator, Windows]
tags: [windows, wsl2, minikube, kubernetes, docker, installation]
---

Minikube is a tool that runs a local Kubernetes cluster on your development machine. This guide sets it up on WSL2.

## Windows Preparation

Enable WSL and Virtual Machine Platform (run PowerShell as Administrator):

```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
bcdedit /set hypervisorlaunchtype auto
```

Set WSL default version to 2:

```powershell
wsl --set-default-version 2
```

Configure WSL resource limits by editing `$env:USERPROFILE\.wslconfig`:

```ini
[wsl2]
memory=4GB
processors=2
swap=2GB
```

Install Ubuntu:

```powershell
wsl --install Ubuntu-24.04
```

> **Note:** Ensure hypervisor functionality is enabled in your BIOS before proceeding.

## Install Docker Engine (inside WSL2)

Set up Docker's `apt` repository:

```sh
sudo apt update
sudo apt install -y ca-certificates curl gpg
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Install Docker:

```sh
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Configure Docker to run without root privileges:

```sh
sudo groupadd docker
sudo usermod -aG docker ${USER}
su - ${USER}
sudo service docker start
```

## Install minikube

```sh
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb
```

### Configure the Cluster

Use Docker as the driver and allocate all available resources:

```sh
minikube config set driver docker
minikube config set cpus max
minikube config set memory max
```

Verify configuration:

```sh
minikube config get driver
minikube config get cpus
minikube config get memory
```

Start minikube:

```sh
minikube start
```

Have fun with minikube!
