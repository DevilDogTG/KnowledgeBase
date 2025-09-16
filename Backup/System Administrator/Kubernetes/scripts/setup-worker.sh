# This script sets up a worker node for Kubernetes on a Debian-based system.
#!/bin/bash
set -e

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

# Update the package list
sudo apt update
# Upgrade the installed packages
sudo apt upgrade -y
# Install necessary packages
sudo apt install -y ca-certificates curl runc gpg

# Ensure to disable swap
sudo swapoff -a
# Remove swap entry from /etc/fstab
sudo sed -i '/ swap / s/^/#/' /etc/fstab
# Enable IP forwarding
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
# Enable bridge networking
echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf
# Enable br_netfilter
sudo modprobe br_netfilter
echo "br_netfilter" | sudo tee /etc/modules-load.d/kubernetes.conf
sudo sysctl -p

# Install containerd
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list

# Configure containerd
sudo apt update
sudo apt install -y containerd.io
sudo containerd config default | sudo tee /etc/containerd/config.toml
# Enable systemd cgroup driver
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
# Override sandbox pause image
sudo sed -i 's|sandbox_image = "registry.k8s.io/pause:3.8"|sandbox_image = "registry.k8s.io/pause:3.10"|' /etc/containerd/config.toml
# Restart containerd to apply the configuration
sudo systemctl restart containerd

# Install necessary packages for worker node
KUBERNETES_VERSION=v1.33
curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update the package list again to include Kubernetes packages
sudo apt update
sudo apt install -y kubelet kubeadm

# Summary of installed packages
echo "Installed packages:"
dpkg -l | grep -E 'containerd|kubelet|kubeadm|runc|gpg|ca-certificates|curl'

# Enable and start kubelet service
sudo systemctl enable kubelet
sudo systemctl start kubelet

# Print the status of kubelet service
sudo systemctl status kubelet --no-pager
# Print the status of containerd service
sudo systemctl status containerd --no-pager
# Print the status of the system
echo "System setup completed successfully."