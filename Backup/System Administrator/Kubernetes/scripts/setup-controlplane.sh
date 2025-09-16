# This script will help you set up a Kubernetes control plane node on Debian 12 (Bookworm).
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
# remove swap entry from /etc/fstab
sudo sed -i '/ swap / s/^/#/' /etc/fstab
# Enable IP forwarding
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
#enable bridge networking
echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf
# endable br filtering
sudo modprobe br_netfilter
echo "br_netfilter" | sudo tee /etc/modules-load.d/kubernetes.conf
sudo sysctl -p

# Add Docker's official GPG key:
sudo apt update
sudo apt install -y ca-certificates curl runc gpg
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |  sudo tee /etc/apt/sources.list.d/docker.list
# Configure containerd
sudo apt update
sudo apt install -y containerd.io
sudo containerd config default | sudo tee /etc/containerd/config.toml
# Endable systemd cgroup driver
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
# Override sanbox pause image
sudo sed -i 's|sandbox_image = "registry.k8s.io/pause:3.8"|sandbox_image = "registry.k8s.io/pause:3.10"|' /etc/containerd/config.toml
# Restart containerd to apply the configuration
sudo systemctl restart containerd

# Install nessary for worker node
KUBERNETES_VERSION=v1.33
curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
# Update the package list again to include Kubernetes packages
sudo apt update
sudo apt install -y kubelet kubeadm kubectl

# Setup Kubernetes control plane
sudo kubeadm init --apiserver-advertise-address=0.0.0.0 --pod-network-cidr=10.244.0.0/16 --service-cidr=10.96.0.0/16
# Setup kubeconfig for the root user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
# Setup kubeconfig for the devildogtg user
sudo mkdir -p /home/devildogtg/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/devildogtg/.kube/config
sudo chown devildogtg:devildogtg /home/devildogtg/.kube/config

# Install a pod network add-on (Calico)
curl https://raw.githubusercontent.com/projectcalico/calico/v3.30.0/manifests/calico.yaml -O

# Find CALICO_IPV4POOL_CIDR uncomment and set it to 10.244.0.0/16
# Backup the original calico.yaml before modification
cp calico.yaml calico.yaml.bak

# Set CALICO_IPV4POOL_CIDR with correct YAML indentation
awk '
/name: CALICO_IPV4POOL_CIDR/ {
    print "            - name: CALICO_IPV4POOL_CIDR";
    print "              value: \"10.244.0.0/16\"";
    skip=1; getline; next
}
skip { skip=0; next }
{ print }
' calico.yaml.bak > calico.yaml
kubectl apply -f calico.yaml

# Summary of installed packages
echo "Installed packages:"
dpkg -l | grep -E 'containerd|kubelet|kubeadm|kubectl|runc|gpg|ca-certificates|curl'

# Print joining command for worker nodes
echo "To join worker nodes to this control plane, run the following command on each worker node:"
kubeadm token create --print-join-command

# End of script