#!/usr/bin/env bash
#
# install-kubectl-kctl.sh
# Idempotent installer/updater for kubectl and kctl on Debian/Ubuntu systems.
# Performs preflight checks, architecture detection, checksum validation,
# system-wide installation, and optional shell completion setup.
#

set -euo pipefail

# Default variables
TARGET_DIR="/usr/local/bin"
KUBECTL_BIN="${TARGET_DIR}/kubectl"
KCTL_LINK="${TARGET_DIR}/kctl"
FORCE=false
DRY_RUN=false
SPECIFIED_VERSION=""
SETUP_COMPLETION=false

# Print logs with colors
log_info() { echo -e "\e[32m[INFO]\e[0m $*"; }
log_warn() { echo -e "\e[33m[WARN]\e[0m $*"; }
log_err()  { echo -e "\e[31m[ERROR]\e[0m $*" >&2; }

# Help menu
show_help() {
  cat << EOF
Usage: $(basename "$0") [options]

Install or update 'kubectl' and 'kctl' (symlink) on Debian/Ubuntu.

Options:
  -v, --version VERSION  Install a specific version (e.g., v1.30.0) instead of latest stable.
  -f, --force            Force installation/download even if already up-to-date.
  -c, --completion       Configure shell autocompletion for kubectl and kctl in ~/.bashrc and ~/.zshrc.
  -d, --dry-run          Run preflight checks and version comparison, but do not download or install.
  -h, --help             Show this help message.
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -v|--version)
      SPECIFIED_VERSION="$2"
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
  for cmd in curl gpg grep cut sha256sum; do
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
  # Get latest stable version
  log_info "Fetching latest stable kubectl version..."
  LATEST_VERSION=$(curl -sSL https://dl.k8s.io/release/stable.txt)
  if [[ -z "$LATEST_VERSION" ]]; then
    log_err "Failed to fetch latest stable version from Kubernetes release site."
    exit 1
  fi
  log_info "Latest stable version is $LATEST_VERSION"

  TARGET_VERSION="${SPECIFIED_VERSION:-$LATEST_VERSION}"
  # Ensure version starts with 'v'
  if [[ ! "$TARGET_VERSION" =~ ^v ]]; then
    TARGET_VERSION="v${TARGET_VERSION}"
  fi
  log_info "Target version to install: $TARGET_VERSION"

  # Check installed version
  if command -v kubectl >/dev/null 2>&1; then
    # We parse version safely
    INSTALLED_VERSION=$(kubectl version --client 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || true)
    if [[ -n "$INSTALLED_VERSION" ]]; then
      log_info "Currently installed kubectl version: $INSTALLED_VERSION"
    else
      log_warn "kubectl binary found but version could not be parsed."
      INSTALLED_VERSION="none"
    fi
  else
    INSTALLED_VERSION="none"
    log_info "kubectl is not currently installed."
  fi
}

# 4. Perform Download and Installation
install_kubectl() {
  if [[ "$INSTALLED_VERSION" == "$TARGET_VERSION" ]] && [[ "$FORCE" = "false" ]]; then
    log_info "kubectl is already at the target version ($TARGET_VERSION). Skipping installation."
    return
  fi

  if [[ "$DRY_RUN" = "true" ]]; then
    log_info "[DRY-RUN] Would install kubectl version $TARGET_VERSION to $KUBECTL_BIN"
    return
  fi

  log_info "Downloading kubectl binary for $ARCH..."
  local tmp_dir
  tmp_dir=$(mktemp -d)
  trap 'rm -rf "$tmp_dir"' EXIT

  local bin_url="https://dl.k8s.io/release/${TARGET_VERSION}/bin/linux/${ARCH}/kubectl"
  local sha_url="${bin_url}.sha256"

  # Download binary and checksum
  curl -L -sS -o "${tmp_dir}/kubectl" "$bin_url"
  curl -L -sS -o "${tmp_dir}/kubectl.sha256" "$sha_url"

  # Validate checksum
  log_info "Verifying SHA256 checksum..."
  local expected_sha
  expected_sha=$(cat "${tmp_dir}/kubectl.sha256")
  local actual_sha
  actual_sha=$(sha256sum "${tmp_dir}/kubectl" | cut -d' ' -f1)

  if [[ "$expected_sha" != "$actual_sha" ]]; then
    log_err "Checksum verification failed!"
    log_err "Expected: $expected_sha"
    log_err "Actual:   $actual_sha"
    exit 1
  fi
  log_info "Checksum verification succeeded."

  # Install binary
  log_info "Installing kubectl binary to $KUBECTL_BIN..."
  chmod +x "${tmp_dir}/kubectl"
  if [[ $EUID -eq 0 ]]; then
    mv "${tmp_dir}/kubectl" "$KUBECTL_BIN"
  else
    sudo mv "${tmp_dir}/kubectl" "$KUBECTL_BIN"
    sudo chown root:root "$KUBECTL_BIN"
  fi
  log_info "kubectl version $(kubectl version --client | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -n1) installed successfully."
}

# 5. Create kctl symlink
create_symlink() {
  if [[ "$DRY_RUN" = "true" ]]; then
    log_info "[DRY-RUN] Would create symlink $KCTL_LINK -> $KUBECTL_BIN"
    return
  fi

  log_info "Ensuring 'kctl' symlink points to 'kubectl'..."
  if [[ -L "$KCTL_LINK" ]]; then
    local current_target
    current_target=$(readlink -f "$KCTL_LINK" || true)
    if [[ "$current_target" == "$KUBECTL_BIN" ]]; then
      log_info "Symlink $KCTL_LINK already exists and points to $KUBECTL_BIN."
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

  if [[ $EUID -eq 0 ]]; then
    ln -sf "$KUBECTL_BIN" "$KCTL_LINK"
  else
    sudo ln -sf "$KUBECTL_BIN" "$KCTL_LINK"
  fi
  log_info "Symlink $KCTL_LINK created successfully."
}

# 6. Configure Autocompletion
configure_completion() {
  if [[ "$SETUP_COMPLETION" = "false" ]]; then
    log_info "Skipping automatic shell completion setup. Use -c or --completion to configure it."
    log_info "Manual setup instructions:"
    log_info "  For Bash: echo 'source <(kubectl completion bash)' >> ~/.bashrc"
    log_info "            echo 'complete -o default -F __start_kubectl kctl' >> ~/.bashrc"
    log_info "  For Zsh:  echo 'source <(kubectl completion zsh)' >> ~/.zshrc"
    log_info "            echo 'compdef __start_kubectl kctl' >> ~/.zshrc"
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

# Kubernetes completion
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion bash)
  complete -o default -F __start_kubectl kctl
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

# Kubernetes completion
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
  compdef __start_kubectl kctl
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
  install_kubectl
  create_symlink
  configure_completion
  log_info "All tasks completed successfully."
}

main "$@"
