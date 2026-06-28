# Installing kubectl, kubecolor, and kctl on Debian/Ubuntu via APT

This guide covers installing and upgrading `kubectl` (the official Kubernetes CLI), `kubecolor` (a wrapper that colorizes output for improved readability), and setting up `kctl` as a convenient command for `kubecolor`.

An automated, repeatable installer and updater script is available in this repository at:
[install-kubectl-kctl.sh](scripts/install-kubectl-kctl.sh)

## How It Works
1.  **kubectl Installation (APT Repo):** Registers the official Kubernetes APT repository (`pkgs.k8s.io`) and installs/upgrades `kubectl` to `/usr/bin/kubectl` via `apt-get`.
2.  **kubecolor Installation (DEB package):** Downloads the latest stable precompiled DEB package from `github.com/kubecolor/kubecolor`, verifies its cryptographic SHA256 checksum, and installs it via `apt-get` (allowing system tracking and dependency resolution). It is installed to `/usr/bin/kubecolor`.
3.  **kctl Symlink:** Links `/usr/local/bin/kctl` directly to `/usr/bin/kubecolor`. Running `kctl` invokes `kubecolor`, which runs `kubectl` under the hood and colorizes the output.
4.  **Tab Auto-Completion:** Automatically configures tab completion for `kubectl`, `kubecolor`, and `kctl` in `.bashrc` and `.zshrc`.

---

## Script Usage

Run the script directly from the repository root:

```bash
./docs/linux/scripts/install-kubectl-kctl.sh [options]
```

### Options

| Flag | Long Flag | Description |
|------|-----------|-------------|
| `-v` | `--version VERSION` | Install a specific kubectl version (e.g., `v1.30.0`) instead of the latest stable. |
| `-k` | `--kubecolor-version VER` | Install a specific kubecolor version (e.g., `v0.6.0`) instead of the latest stable. |
| `-f` | `--force` | Force repository setup and package reinstall even if already up to date. |
| `-c` | `--completion` | Automatically inject completion script settings into `~/.bashrc` and `~/.zshrc`. |
| `-d` | `--dry-run` | Run preflight check and version comparison, but do not download or install. |
| `-h` | `--help` | Display the usage menu. |

### Examples

**1. Dry-run to preview APT repository setup and package installation:**
```bash
./docs/linux/scripts/install-kubectl-kctl.sh --dry-run
```

**2. Standard install / update via APT with auto-completion configuration:**
```bash
./docs/linux/scripts/install-kubectl-kctl.sh --completion
```

**3. Install specific minor version of kubectl and specific version of kubecolor:**
```bash
./docs/linux/scripts/install-kubectl-kctl.sh --version v1.30.5 --kubecolor-version v0.6.0
```

---

## Manual Setup & Auto-Completion Details

If you choose not to run the script with the `-c` / `--completion` flag, you can set up autocompletion manually by appending the following configurations to your shell configuration file.

### Bash (`~/.bashrc`)
Add this block at the end of your `~/.bashrc`:
```bash
# Kubernetes and Kubecolor completion
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion bash)
  complete -o default -F __start_kubectl kubecolor 2>/dev/null || true
  complete -o default -F __start_kubectl kctl 2>/dev/null || true
fi
```
Then reload with:
```bash
source ~/.bashrc
```

### Zsh (`~/.zshrc`)
Add this block at the end of your `~/.zshrc`:
```bash
# Kubernetes and Kubecolor completion
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
  compdef __start_kubectl kubecolor 2>/dev/null || true
  compdef __start_kubectl kctl 2>/dev/null || true
fi
```
Then reload with:
```bash
source ~/.zshrc
```
