---
title: "Install kubectl and kubecolor on Debian/Ubuntu via APT"
author: DevilDogTG
date: 2026-06-28 15:30:00 +0700
categories: [System Administrator, Kubernetes]
tags: [tutorials, linux, kubernetes, kubecolor, lang:en]
---

Managing Kubernetes clusters using `kubectl` is the day-to-day norm for DevOps engineers and system administrators. However, plain text output from `kubectl` can quickly become hard to read when parsing long lists of resources or troubleshooting issues.

In this guide, we will install **`kubectl`** and **`kubecolor`** (a wrapper that colorizes output for improved readability) on Debian/Ubuntu systems using native package management (`apt` / `dpkg`). We will also set up **`kctl`** as a convenient alias/symlink to `kubecolor` and configure tab auto-completion for all of them.

---

## Why Kubecolor?

`kubecolor` is a drop-in replacement wrapper for `kubectl` that intercepts command output and adds colors in real-time. 

- **Readability**: Clearly highlights statuses like `Running` (green), `Terminating` (yellow), and `CrashLoopBackOff` (red).
- **Auto TTY Detection**: Automatically disables color styling when output is piped to files, logs, or other scripts.
- **Paging Support**: Seamlessly integrates with tools like `less` for scrollable outputs.

By symlinking `kctl` to `kubecolor`, you get a fast, colorized terminal command that keeps all standard `kubectl` arguments and autocompletions intact.

---

## Option 1: Automated Idempotent Installer Script

Below is the complete shell script to automate the setup process. It validates your architecture (AMD64 or ARM64), downloads the GPG keys, registers the official Kubernetes APT repository, fetches the latest `kubecolor` release DEB package, verifies its SHA256 checksum, installs both packages natively via `apt`, and creates the `kctl` symlink.

Create a script file (e.g. `install-kubectl-kctl.sh`), paste the following content, and make it executable:

```bash
#!/usr/bin/env bash
# install-kubectl-kctl.sh
# Idempotent installer/updater for kubectl, kubecolor, and kctl (symlink) on Debian/Ubuntu.

set -euo pipefail

TARGET_DIR="/usr/local/bin"
KUBECTL_BIN="/usr/bin/kubectl"
KUBECOLOR_BIN="/usr/bin/kubecolor"
KCTL_LINK="${TARGET_DIR}/kctl"
FORCE=false
DRY_RUN=false
KUBECTL_VERSION=""
KUBECOLOR_VERSION=""
SETUP_COMPLETION=false
TMP_DIR=""

log_info() { echo -e "\e[32m[INFO]\e[0m $*"; }
log_warn() { echo -e "\e[33m[WARN]\e[0m $*"; }
log_err()  { echo -e "\e[31m[ERROR]\e[0m $*" >&2; }

cleanup() {
  if [[ -n "${TMP_DIR:-}" && -d "$TMP_DIR" ]]; then
    rm -rf "$TMP_DIR"
  fi
}
trap cleanup EXIT

show_help() {
  cat << EOF
Usage: $(basename "$0") [options]

Install or update 'kubectl', 'kubecolor', and 'kctl' (symlink to kubecolor) on Debian/Ubuntu via APT.

Options:
  -v, --version VERSION       Install a specific kubectl version (e.g., v1.30.0) instead of latest stable.
  -k, --kubecolor-version VER Install a specific kubecolor version (e.g., v0.6.0) instead of latest stable.
  -f, --force                 Force installation/download even if already up-to-date.
  -c, --completion            Configure shell autocompletion for kubectl, kubecolor, and kctl in ~/.bashrc and ~/.zshrc.
  -d, --dry-run               Run preflight checks and version comparison, but do not download or install.
  -h, --help                  Show this help message.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -v|--version) KUBECTL_VERSION="$2"; shift 2 ;;
    -k|--kubecolor-version) KUBECOLOR_VERSION="$2"; shift 2 ;;
    -f|--force) FORCE=true; shift ;;
    -c|--completion) SETUP_COMPLETION=true; shift ;;
    -d|--dry-run) DRY_RUN=true; shift ;;
    -h|--help) show_help; exit 0 ;;
    *) log_err "Unknown option: $1"; show_help; exit 1 ;;
  esac
done

preflight_checks() {
  log_info "Running preflight checks..."
  if [[ ! -f /etc/os-release ]] || ! grep -qEi 'debian|ubuntu' /etc/os-release; then
    log_err "This script targets Debian/Ubuntu distributions."
    exit 1
  fi

  for cmd in curl gpg grep cut sha256sum dpkg apt-get; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      log_err "Required command '$cmd' is not installed. Please install it first."
      exit 1
    fi
  done

  if [[ "$DRY_RUN" = "false" ]] && [[ $EUID -ne 0 ]]; then
    if ! command -v sudo >/dev/null 2>&1 || ! sudo -n true 2>/dev/null; then
      log_info "Sudo privileges required. You may be prompted for your password."
    fi
  fi
}

detect_arch() {
  local machine
  machine=$(uname -m)
  case "$machine" in
    x86_64)  ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) log_err "Unsupported architecture: $machine."; exit 1 ;;
  esac
  log_info "Detected architecture: $ARCH ($machine)"
}

resolve_versions() {
  log_info "Fetching latest stable kubectl version..."
  local latest_kubectl
  latest_kubectl=$(curl -sSL https://dl.k8s.io/release/stable.txt)
  TARGET_KUBECTL_VERSION="${KUBECTL_VERSION:-$latest_kubectl}"
  [[ ! "$TARGET_KUBECTL_VERSION" =~ ^v ]] && TARGET_KUBECTL_VERSION="v${TARGET_KUBECTL_VERSION}"
  log_info "Target kubectl version: $TARGET_KUBECTL_VERSION"

  if command -v kubectl >/dev/null 2>&1; then
    INSTALLED_KUBECTL_VERSION=$(kubectl version --client 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || true)
    log_info "Currently installed kubectl version: ${INSTALLED_KUBECTL_VERSION:-none}"
  else
    INSTALLED_KUBECTL_VERSION="none"
  fi

  log_info "Fetching latest stable kubecolor version..."
  local redirect_url
  redirect_url=$(curl -sSfL -o /dev/null -w "%{url_effective}" https://github.com/kubecolor/kubecolor/releases/latest || true)
  local latest_kubecolor="v0.6.0"
  [[ -n "$redirect_url" ]] && latest_kubecolor="${redirect_url##*/}"
  TARGET_KUBECOLOR_VERSION="${KUBECOLOR_VERSION:-$latest_kubecolor}"
  [[ ! "$TARGET_KUBECOLOR_VERSION" =~ ^v ]] && TARGET_KUBECOLOR_VERSION="v${TARGET_KUBECOLOR_VERSION}"
  log_info "Target kubecolor version: $TARGET_KUBECOLOR_VERSION"

  if command -v kubecolor >/dev/null 2>&1; then
    INSTALLED_KUBECOLOR_VERSION=$(kubecolor --kubecolor-version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || true)
    log_info "Currently installed kubecolor version: ${INSTALLED_KUBECOLOR_VERSION:-none}"
  else
    INSTALLED_KUBECOLOR_VERSION="none"
  fi
}

install_kubectl() {
  if [[ "$INSTALLED_KUBECTL_VERSION" == "$TARGET_KUBECTL_VERSION" ]] && [[ "$FORCE" = "false" ]]; then
    log_info "kubectl is already at the target version ($TARGET_KUBECTL_VERSION). Skipping."
    return
  fi

  local version_xy
  version_xy=$(echo "$TARGET_KUBECTL_VERSION" | grep -oE '^v[0-9]+\.[0-9]+')

  if [[ "$DRY_RUN" = "true" ]]; then
    log_info "[DRY-RUN] Would setup Kubernetes APT repository for version $version_xy and install"
    return
  fi

  log_info "Setting up Kubernetes APT repository for version $version_xy..."
  if [[ $EUID -eq 0 ]]; then
    mkdir -p -m 755 /etc/apt/keyrings
    curl -fsSL "https://pkgs.k8s.io/core:/stable:/${version_xy}/deb/Release.key" | gpg --dearmor --yes -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${version_xy}/deb/ /" > /etc/apt/sources.list.d/kubernetes.list
    apt-get update && apt-get install -y kubectl
  else
    sudo mkdir -p -m 755 /etc/apt/keyrings
    curl -fsSL "https://pkgs.k8s.io/core:/stable:/${version_xy}/deb/Release.key" | sudo gpg --dearmor --yes -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${version_xy}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
    sudo apt-get update && sudo apt-get install -y kubectl
  fi
}

install_kubecolor() {
  if [[ "$INSTALLED_KUBECOLOR_VERSION" == "$TARGET_KUBECOLOR_VERSION" ]] && [[ "$FORCE" = "false" ]]; then
    log_info "kubecolor is already at the target version ($TARGET_KUBECOLOR_VERSION). Skipping."
    return
  fi

  if [[ "$DRY_RUN" = "true" ]]; then
    log_info "[DRY-RUN] Would download and install kubecolor deb package version $TARGET_KUBECOLOR_VERSION"
    return
  fi

  local kubecolor_no_v="${TARGET_KUBECOLOR_VERSION#v}"
  local deb_name="kubecolor_${kubecolor_no_v}_linux_${ARCH}.deb"

  log_info "Downloading kubecolor DEB package..."
  curl -L -sS -o "${TMP_DIR}/${deb_name}" "https://github.com/kubecolor/kubecolor/releases/download/${TARGET_KUBECOLOR_VERSION}/${deb_name}"
  curl -L -sS -o "${TMP_DIR}/checksums.txt" "https://github.com/kubecolor/kubecolor/releases/download/${TARGET_KUBECOLOR_VERSION}/checksums.txt"

  log_info "Verifying SHA256 checksum for kubecolor..."
  grep "$deb_name" "${TMP_DIR}/checksums.txt" > "${TMP_DIR}/kubecolor.sha256"
  if ! (cd "$TMP_DIR" && sha256sum --check --status kubecolor.sha256); then
    log_err "Checksum verification failed!"; exit 1
  fi

  log_info "Installing kubecolor DEB via APT..."
  if [[ $EUID -eq 0 ]]; then
    apt-get install -y "${TMP_DIR}/${deb_name}"
  else
    sudo apt-get install -y "${TMP_DIR}/${deb_name}"
  fi
}

create_symlink() {
  if [[ "$DRY_RUN" = "true" ]]; then
    log_info "[DRY-RUN] Would create symlink $KCTL_LINK -> $KUBECOLOR_BIN"
    return
  fi

  log_info "Ensuring 'kctl' symlink points to 'kubecolor'..."
  local link_dir=$(dirname "$KCTL_LINK")
  [[ ! -d "$link_dir" ]] && ( [[ $EUID -eq 0 ]] && mkdir -p "$link_dir" || sudo mkdir -p "$link_dir" )

  if [[ $EUID -eq 0 ]]; then
    ln -sf "$KUBECOLOR_BIN" "$KCTL_LINK"
  else
    sudo ln -sf "$KUBECOLOR_BIN" "$KCTL_LINK"
  fi
}

configure_completion() {
  if [[ "$SETUP_COMPLETION" = "false" ]]; then return; fi
  if [[ "$DRY_RUN" = "true" ]]; then return; fi

  local line="source <(kubectl completion \${SHELL##*/})"
  
  # Setup Bash completion
  if [[ -f "$HOME/.bashrc" ]] && ! grep -q "kubectl completion bash" "$HOME/.bashrc"; then
    cat << 'EOF' >> "$HOME/.bashrc"
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion bash)
  complete -o default -F __start_kubectl kubecolor 2>/dev/null || true
  complete -o default -F __start_kubectl kctl 2>/dev/null || true
fi
EOF
  fi

  # Setup Zsh completion
  if [[ -f "$HOME/.zshrc" ]] && ! grep -q "kubectl completion zsh" "$HOME/.zshrc"; then
    cat << 'EOF' >> "$HOME/.zshrc"
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
  compdef __start_kubectl kubecolor 2>/dev/null || true
  compdef __start_kubectl kctl 2>/dev/null || true
fi
EOF
  fi
}

main() {
  preflight_checks
  detect_arch
  resolve_versions
  if [[ "$DRY_RUN" = "false" ]]; then TMP_DIR=$(mktemp -d); fi
  install_kubectl
  install_kubecolor
  create_symlink
  configure_completion
  log_info "Finished successfully."
}

main "$@"
```

To execute the script and configure tab completion automatically for your active shells, run:
```bash
bash install-kubectl-kctl.sh --completion
```

---

## Option 2: Step-by-Step Manual Installation

If you prefer to perform the configuration steps manually, follow the process outlined below.

### Step 1: Install kubectl via Official APT Repository

First, download the official signing key and register the repository for the Kubernetes package pool.

```bash
# Create the keyrings folder if it does not exist
sudo mkdir -p -m 755 /etc/apt/keyrings

# Download the key (e.g. for Kubernetes version 1.36)
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.36/deb/Release.key | sudo gpg --dearmor --yes -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Register the APT source repository
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.36/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update package lists and install kubectl
sudo apt-get update
sudo apt-get install -y kubectl
```

### Step 2: Download and Install kubecolor DEB Package

Download the appropriate `.deb` package for your CPU architecture from the official GitHub Release page.

```bash
# Fetch latest version (e.g., v0.6.0)
VERSION="v0.6.0"
VERSION_NO_V="0.6.0"
ARCH=$(dpkg --print-architecture) # amd64 or arm64

# Download the DEB package
wget https://github.com/kubecolor/kubecolor/releases/download/${VERSION}/kubecolor_${VERSION_NO_V}_linux_${ARCH}.deb

# Install the package via apt (which manages standard system registration)
sudo apt-get install -y ./kubecolor_${VERSION_NO_V}_linux_${ARCH}.deb

# Clean up
rm kubecolor_${VERSION_NO_V}_linux_${ARCH}.deb
```

### Step 3: Create the `kctl` Command Symlink

Create a symbolic link in `/usr/local/bin` pointing to `/usr/bin/kubecolor`. This provides a global, shorter alias without polluting `/usr/bin`.

```bash
sudo ln -sf /usr/bin/kubecolor /usr/local/bin/kctl
```

---

## Configure Shell Autocompletion

`kubecolor` operates as a wrapper around the `kubectl` CLI. Therefore, you must configure the standard `kubectl` autocompletion and then instruct the shell to reuse that completion function (`__start_kubectl`) for `kubecolor` and `kctl`.

### Bash Setup
Append the following lines to your `~/.bashrc` file:

```bash
# Kubernetes and Kubecolor completion
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion bash)
  complete -o default -F __start_kubectl kubecolor 2>/dev/null || true
  complete -o default -F __start_kubectl kctl 2>/dev/null || true
fi
```
Then reload your configuration:
```bash
source ~/.bashrc
```

### Zsh Setup
Append the following lines to your `~/.zshrc` file:

```bash
# Kubernetes and Kubecolor completion
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
  compdef __start_kubectl kubecolor 2>/dev/null || true
  compdef __start_kubectl kctl 2>/dev/null || true
fi
```
Then reload your configuration:
```bash
source ~/.zshrc
```

Now, try running `kctl get p[TAB]` and watch the resource name autocomplete while rendering in beautiful, colorized terminal styles!
