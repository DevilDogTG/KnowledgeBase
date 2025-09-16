---
layout: default
---
# Setup `minikube` on WSL2

Minikube is a tool that allows you to run a local Kubernetes cluster on your development machine. Setting up Minikube on WSL2 (Windows Subsystem for Linux 2) involves several steps, including enabling necessary features, installing dependencies, and configuring Minikube.

## Windows Preparation

- Enable Hypervisor Functionality: Ensure that hypervisor functionality is enabled in your BIOS. If it is already enabled, disable it, restart your machine, and enable it again to avoid issues
- Enable WSL and Virtual Machine Platform: Open a PowerShell prompt in Administrator mode and run the following commands:

```ps
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
bcdedit /set hypervisorlaunchtype auto
```

- Set WSL Default Version to 2: Run the following command in PowerShell:

```ps
wsl --set-default-version 2
```

- Setting WSL resource limit with edit file `$env:USERPROFILE\.wslconfig` example:

```sh
[wsl2]
memory=4GB
processors=2
swap=2GB
```

- Install Ubuntu: Install the Ubuntu distribution from the Windows Store and verify the WSL version using:

```ps
wsl --install Ubuntu-24.04
```

## Install `Docker Engine`

Before you install Docker Engine for the first time on a new host machine, you need to set up the Docker apt repository. Afterward, you can install and update Docker from the repository.

- Set up Docker's `apt` repository.

```sh
# Add Docker's official GPG key:
sudo apt update
sudo apt install -y ca-certificates curl gpg
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

- Install the Docker packages.

```sh
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

- Configure Docker to run without root priviledge

```sh
sudo groupadd docker
sudo usermod -aG docker ${USER}
su - ${USER}
sudo service docker start
```

You have now successfully installed and started Docker Engine.

## Install `minikube`

minikube is local Kubernetes, focusing on making it easy to learn and develop for Kubernetes.

All you need is Docker (or similarly compatible) container or a Virtual Machine environment, and Kubernetes is a single command away: `minikube start`

```sh
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb
```

### Configure your cluster

In my case we're using all resource from `wsl` to run and run with `docker` we can config minukube like these.

```sh
minikube config set driver docker
minikube config set cpus max
minikube config set memory max
```

To verify configure

```sh
minikube config get driver
minikube config get cpus
minikube config get memory
```

Have fund with minikube
