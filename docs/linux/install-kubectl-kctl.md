# Installing kubectl and kctl on Debian/Ubuntu

This guide covers installing and upgrading `kubectl` (the official Kubernetes CLI) and `kctl` (a convenient symlink/alias for faster typing) on Debian/Ubuntu systems.

An automated, repeatable installer and updater script is available in this repository at:
[install-kubectl-kctl.sh](scripts/install-kubectl-kctl.sh)

## Features
- **Preflight Checks:** Verifies compatibility and that necessary dependencies (`curl`, `sudo`, `gpg`, `sha256sum`) are available.
- **Idempotency:** Only downloads and installs when a new version is available or when forced.
- **Checksum Verification:** Verifies the cryptographic SHA256 checksum of the downloaded binary before moving it to `/usr/local/bin`.
- **System-Wide CLI Link:** Creates `/usr/local/bin/kctl` pointing to `/usr/local/bin/kubectl`.
- **Shell Auto-Completion:** Automatically configures tab autocompletion for both `kubectl` and `kctl` in `.bashrc` and `.zshrc`.

---

## Script Usage

Run the script directly from the repository root:

```bash
./docs/linux/scripts/install-kubectl-kctl.sh [options]
```

### Options

| Flag | Long Flag | Description |
|------|-----------|-------------|
| `-v` | `--version <VERSION>` | Install a specific version (e.g., `v1.30.0`) instead of the latest stable. |
| `-f` | `--force` | Force download and installation even if already up to date. |
| `-c` | `--completion` | Automatically inject completion script settings into `~/.bashrc` and `~/.zshrc`. |
| `-d` | `--dry-run` | Run preflight check and print actions, without modifying any files or downloading binaries. |
| `-h` | `--help` | Display the usage menu. |

### Examples

**1. Dry-run to preview actions:**
```bash
./docs/linux/scripts/install-kubectl-kctl.sh --dry-run
```

**2. Standard install / update to latest stable with auto-completion configuration:**
```bash
./docs/linux/scripts/install-kubectl-kctl.sh --completion
```

**3. Install or downgrade to a specific version (e.g., v1.31.1):**
```bash
./docs/linux/scripts/install-kubectl-kctl.sh --version v1.31.1
```

---

## Manual Setup & Auto-Completion Details

If you choose not to run the script with the `-c` / `--completion` flag, you can set up autocompletion manually by appending the following configurations to your shell configuration file.

### Bash (`~/.bashrc`)
Add this block at the end of your `~/.bashrc`:
```bash
# Kubernetes completion
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion bash)
  complete -o default -F __start_kubectl kctl
fi
```
Then reload with:
```bash
source ~/.bashrc
```

### Zsh (`~/.zshrc`)
Add this block at the end of your `~/.zshrc`:
```bash
# Kubernetes completion
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
  compdef __start_kubectl kctl
fi
```
Then reload with:
```bash
source ~/.zshrc
```
