#!/usr/bin/env bash
#
# install-kubectl-kctl.sh
# Idempotent installer/updater for kubectl, kubecolor, and kctl (symlink) on Debian/Ubuntu systems.
# Performs preflight checks, architecture detection, checksum validation,
# system-wide installation via APT/dpkg, and optional shell completion setup.
#

set -euo pipefail

# Default variables
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

# Print logs with colors
log_info() { echo -e "\e[32m[INFO]\e[0m $*"; }
log_warn() { echo -e "\e[33m[WARN]\e[0m $*"; }
log_err()  { echo -e "\e[31m[ERROR]\e[0m $*" >&2; }

# Cleanup hook for temp files
cleanup() {
  if [[ -n "${TMP_DIR:-}" && -d "$TMP_DIR" ]]; then
    rm -rf "$TMP_DIR"
  fi
}
trap cleanup EXIT

# Help menu
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

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -v|--version)
      KUBECTL_VERSION="$2"
      shift 2
      ;;
    -k|--kubecolor-version)
      KUBECOLOR_VERSION="$2"
      shift 2
      ;;
    -f|--force)
      FORCE=true
      shift
      ;;
    -c|--completion)
      SETUP_COMPLETION=true
      shift
      ;;
    -d|--dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      log_err "Unknown option: $1"
      show_help
      exit 1
      ;;
  esac
done

# 1. Preflight checks
preflight_checks() {
  log_info "Running preflight checks..."

  # OS Verification
  if [[ ! -f /etc/os-release ]]; then
    log_err "Cannot verify OS: /etc/os-release is missing. This script targets Debian/Ubuntu."
    exit 1
  fi

  # Support Debian or Ubuntu or derivatives
  if ! grep -qEi 'debian|ubuntu' /etc/os-release; then
    log_warn "This script targets Debian/Ubuntu. Your OS might not be fully compatible."
  fi

  # Check required commands
  for cmd in curl gpg grep cut sha256sum dpkg apt-get; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      log_err "Required command '$cmd' is not installed. Please install it first."
      exit 1
    fi
  done

  # Sudo verification (only if NOT dry-run, and installing/symlinking is needed)
  if [[ "$DRY_RUN" = "false" ]]; then
    if [[ $EUID -ne 0 ]]; then
      if ! command -v sudo >/dev/null 2>&1; then
        log_err "This script must be run as root (or with sudo), and 'sudo' is not installed."
        exit 1
      fi
      # Check if user has sudo privileges
      if ! sudo -n true 2>/dev/null; then
        log_info "Sudo privileges required. You may be prompted for your password."
      fi
    fi
  fi

  log_info "Preflight checks passed."
}

# 2. Detect System Architecture
detect_arch() {
  local machine
  machine=$(uname -m)
  case "$machine" in
    x86_64)  ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *)
      log_err "Unsupported architecture: $machine. Only x86_64 and arm64/aarch64 are supported."
      exit 1
      ;;
  esac
  log_info "Detected architecture: $ARCH ($machine)"
}

# 3. Determine versions
resolve_versions() {
  # Get latest stable kubectl version
  log_info "Fetching latest stable kubectl version..."
  local latest_kubectl
  latest_kubectl=$(curl -sSL https://dl.k8s.io/release/stable.txt)
  if [[ -z "$latest_kubectl" ]]; then
    log_err "Failed to fetch latest stable kubectl version."
    exit 1
  fi
  TARGET_KUBECTL_VERSION="${KUBECTL_VERSION:-$latest_kubectl}"
  if [[ ! "$TARGET_KUBECTL_VERSION" =~ ^v ]]; then
    TARGET_KUBECTL_VERSION="v${TARGET_KUBECTL_VERSION}"
  fi
  log_info "Target kubectl version: $TARGET_KUBECTL_VERSION"

  # Check installed kubectl version
  if command -v kubectl >/dev/null 2>&1; then
    INSTALLED_KUBECTL_VERSION=$(kubectl version --client 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || true)
    if [[ -n "$INSTALLED_KUBECTL_VERSION" ]]; then
      log_info "Currently installed kubectl version: $INSTALLED_KUBECTL_VERSION"
    else
      log_warn "kubectl binary found but version could not be parsed."
      INSTALLED_KUBECTL_VERSION="none"
    fi
  else
    INSTALLED_KUBECTL_VERSION="none"
    log_info "kubectl is not currently installed."
  fi

  # Get latest stable kubecolor version
  log_info "Fetching latest stable kubecolor version..."
  local redirect_url
  redirect_url=$(curl -sSfL -o /dev/null -w "%{url_effective}" https://github.com/kubecolor/kubecolor/releases/latest || true)
  local latest_kubecolor="v0.6.0"
  if [[ -n "$redirect_url" ]]; then
    latest_kubecolor="${redirect_url##*/}"
  fi
  TARGET_KUBECOLOR_VERSION="${KUBECOLOR_VERSION:-$latest_kubecolor}"
  if [[ ! "$TARGET_KUBECOLOR_VERSION" =~ ^v ]]; then
    TARGET_KUBECOLOR_VERSION="v${TARGET_KUBECOLOR_VERSION}"
  fi
  log_info "Target kubecolor version: $TARGET_KUBECOLOR_VERSION"

  # Check installed kubecolor version
  if command -v kubecolor >/dev/null 2>&1; then
    INSTALLED_KUBECOLOR_VERSION=$(kubecolor --kubecolor-version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || true)
    if [[ -n "$INSTALLED_KUBECOLOR_VERSION" ]]; then
      log_info "Currently installed kubecolor version: $INSTALLED_KUBECOLOR_VERSION"
    else
      log_warn "kubecolor binary found but version could not be parsed."
      INSTALLED_KUBECOLOR_VERSION="none"
    fi
  else
    INSTALLED_KUBECOLOR_VERSION="none"
    log_info "kubecolor is not currently installed."
  fi
}

# 4. Perform Download and Installation of kubectl
install_kubectl() {
  if [[ "$INSTALLED_KUBECTL_VERSION" == "$TARGET_KUBECTL_VERSION" ]] && [[ "$FORCE" = "false" ]]; then
    log_info "kubectl is already at the target version ($TARGET_KUBECTL_VERSION). Skipping installation."
    return
  fi

  # Extract minor version (e.g. v1.36.2 -> v1.36)
  local version_xy
  version_xy=$(echo "$TARGET_KUBECTL_VERSION" | grep -oE '^v[0-9]+\.[0-9]+')
  if [[ -z "$version_xy" ]]; then
    log_err "Failed to extract minor version from $TARGET_KUBECTL_VERSION (e.g. v1.36)"
    exit 1
  fi

  if [[ "$DRY_RUN" = "true" ]]; then
    log_info "[DRY-RUN] Would setup Kubernetes APT repository for version $version_xy"
    log_info "[DRY-RUN] Would install kubectl via apt-get"
    return
  fi

  log_info "Setting up Kubernetes APT repository for version $version_xy..."

  # Ensure keyrings directory exists
  if [[ $EUID -eq 0 ]]; then
    mkdir -p -m 755 /etc/apt/keyrings
  else
    sudo mkdir -p -m 755 /etc/apt/keyrings
  fi

  # Download signing key
  local key_url="https://pkgs.k8s.io/core:/stable:/${version_xy}/deb/Release.key"
  local keyring_file="/etc/apt/keyrings/kubernetes-apt-keyring.gpg"
  
  log_info "Downloading signing key from $key_url..."
  if [[ $EUID -eq 0 ]]; then
    curl -fsSL "$key_url" | gpg --dearmor --yes -o "$keyring_file"
    chmod 644 "$keyring_file"
  else
    curl -fsSL "$key_url" | sudo gpg --dearmor --yes -o "$keyring_file"
    sudo chmod 644 "$keyring_file"
  fi

  # Add repository sources file
  local repo_line="deb [signed-by=$keyring_file] https://pkgs.k8s.io/core:/stable:/${version_xy}/deb/ /"
  local sources_file="/etc/apt/sources.list.d/kubernetes.list"
  log_info "Adding repository line to $sources_file..."
  if [[ $EUID -eq 0 ]]; then
    echo "$repo_line" > "$sources_file"
  else
    echo "$repo_line" | sudo tee "$sources_file" > /dev/null
  fi

  # Run apt-get update and install
  log_info "Updating package lists and installing kubectl via APT..."
  if [[ $EUID -eq 0 ]]; then
    apt-get update
    apt-get install -y kubectl
  else
    sudo apt-get update
    sudo apt-get install -y kubectl
  fi

  log_info "kubectl version $(kubectl version --client 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -n1) installed successfully via APT."
}

# 5. Perform Download and Installation of kubecolor
install_kubecolor() {
  if [[ "$INSTALLED_KUBECOLOR_VERSION" == "$TARGET_KUBECOLOR_VERSION" ]] && [[ "$FORCE" = "false" ]]; then
    log_info "kubecolor is already at the target version ($TARGET_KUBECOLOR_VERSION). Skipping installation."
    return
  fi

  if [[ "$DRY_RUN" = "true" ]]; then
    log_info "[DRY-RUN] Would download kubecolor deb package version $TARGET_KUBECOLOR_VERSION"
    log_info "[DRY-RUN] Would install kubecolor via apt-get"
    return
  fi

  local kubecolor_no_v="${TARGET_KUBECOLOR_VERSION#v}"
  local deb_name="kubecolor_${kubecolor_no_v}_linux_${ARCH}.deb"
  local bin_url="https://github.com/kubecolor/kubecolor/releases/download/${TARGET_KUBECOLOR_VERSION}/${deb_name}"
  local sha_url="https://github.com/kubecolor/kubecolor/releases/download/${TARGET_KUBECOLOR_VERSION}/checksums.txt"

  log_info "Downloading kubecolor DEB package..."
  curl -L -sS -o "${TMP_DIR}/${deb_name}" "$bin_url"
  curl -L -sS -o "${TMP_DIR}/checksums.txt" "$sha_url"

  # Validate checksum
  log_info "Verifying SHA256 checksum for kubecolor DEB..."
  if ! grep -q "$deb_name" "${TMP_DIR}/checksums.txt"; then
    log_err "DEB package entry '$deb_name' not found in checksums.txt."
    exit 1
  fi

  # Extract matching line
  grep "$deb_name" "${TMP_DIR}/checksums.txt" > "${TMP_DIR}/kubecolor.sha256"
  
  if ! (cd "$TMP_DIR" && sha256sum --check --status kubecolor.sha256); then
    log_err "kubecolor DEB checksum verification failed for $deb_name!"
    exit 1
  fi
  log_info "kubecolor DEB checksum verification succeeded."

  # Install package using apt-get (which handles dependencies and registers it cleanly)
  log_info "Installing kubecolor DEB package via APT..."
  if [[ $EUID -eq 0 ]]; then
    apt-get install -y "${TMP_DIR}/${deb_name}"
  else
    sudo apt-get install -y "${TMP_DIR}/${deb_name}"
  fi

  log_info "kubecolor version $(kubecolor --kubecolor-version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -n1) installed successfully via APT."
}

# 6. Create kctl symlink
create_symlink() {
  if [[ "$DRY_RUN" = "true" ]]; then
    log_info "[DRY-RUN] Would create symlink $KCTL_LINK -> $KUBECOLOR_BIN"
    return
  fi

  log_info "Ensuring 'kctl' symlink points to 'kubecolor'..."
  if [[ -L "$KCTL_LINK" ]]; then
    local current_target
    current_target=$(readlink -f "$KCTL_LINK" || true)
    if [[ "$current_target" == "$KUBECOLOR_BIN" ]]; then
      log_info "Symlink $KCTL_LINK already exists and points to $KUBECOLOR_BIN."
      return
    fi
    log_warn "Symlink $KCTL_LINK points to $current_target. Re-creating..."
  elif [[ -e "$KCTL_LINK" ]]; then
    log_warn "A non-symlink file exists at $KCTL_LINK. Removing..."
    if [[ $EUID -eq 0 ]]; then
      rm -f "$KCTL_LINK"
    else
      sudo rm -f "$KCTL_LINK"
    fi
  fi

  # Create directories if they do not exist
  local link_dir
  link_dir=$(dirname "$KCTL_LINK")
  if [[ ! -d "$link_dir" ]]; then
    if [[ $EUID -eq 0 ]]; then
      mkdir -p "$link_dir"
    else
      sudo mkdir -p "$link_dir"
    fi
  fi

  if [[ $EUID -eq 0 ]]; then
    ln -sf "$KUBECOLOR_BIN" "$KCTL_LINK"
  else
    sudo ln -sf "$KUBECOLOR_BIN" "$KCTL_LINK"
  fi
  log_info "Symlink $KCTL_LINK created successfully."
}

# 7. Configure Autocompletion
configure_completion() {
  if [[ "$SETUP_COMPLETION" = "false" ]]; then
    log_info "Skipping automatic shell completion setup. Use -c or --completion to configure it."
    log_info "Manual setup instructions:"
    log_info "  For Bash: echo 'source <(kubectl completion bash)' >> ~/.bashrc"
    log_info "            echo 'complete -o default -F __start_kubectl kubecolor kctl' >> ~/.bashrc"
    log_info "  For Zsh:  echo 'source <(kubectl completion zsh)' >> ~/.zshrc"
    log_info "            echo 'compdef __start_kubectl kubecolor kctl' >> ~/.zshrc"
    return
  fi

  if [[ "$DRY_RUN" = "true" ]]; then
    log_info "[DRY-RUN] Would configure completion in ~/.bashrc and ~/.zshrc"
    return
  fi

  # For Bash
  if [[ -f "$HOME/.bashrc" ]]; then
    log_info "Configuring autocompletion in ~/.bashrc..."
    if ! grep -q "kubectl completion bash" "$HOME/.bashrc"; then
      cat << 'EOF' >> "$HOME/.bashrc"

# Kubernetes and Kubecolor completion
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion bash)
  complete -o default -F __start_kubectl kubecolor 2>/dev/null || true
  complete -o default -F __start_kubectl kctl 2>/dev/null || true
fi
EOF
      log_info "Bash completion added. Run 'source ~/.bashrc' to apply."
    else
      log_info "Bash completion already configured in ~/.bashrc."
    fi
  fi

  # For Zsh
  if [[ -f "$HOME/.zshrc" ]]; then
    log_info "Configuring autocompletion in ~/.zshrc..."
    if ! grep -q "kubectl completion zsh" "$HOME/.zshrc"; then
      cat << 'EOF' >> "$HOME/.zshrc"

# Kubernetes and Kubecolor completion
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
  compdef __start_kubectl kubecolor 2>/dev/null || true
  compdef __start_kubectl kctl 2>/dev/null || true
fi
EOF
      log_info "Zsh completion added. Run 'source ~/.zshrc' to apply."
    else
      log_info "Zsh completion already configured in ~/.zshrc."
    fi
  fi
}

main() {
  preflight_checks
  detect_arch
  resolve_versions
  
  # Create temp workspace
  if [[ "$DRY_RUN" = "false" ]]; then
    TMP_DIR=$(mktemp -d)
  fi

  install_kubectl
  install_kubecolor
  create_symlink
  configure_completion
  log_info "All tasks completed successfully."
}

main "$@"
