## What changed
Added a repeatable installer script, guide, and blog post for setting up `kubectl` and `kubecolor` on Debian/Ubuntu systems using `apt` and `.deb` packaging:
- **`docs/linux/scripts/install-kubectl-kctl.sh`**: Installs `kubectl` via the official Kubernetes repository and `kubecolor` via the official release DEB package (verifying its SHA256 checksum). Creates a `kctl` symlink pointing to `kubecolor` for colorized output. Sets up tab completion for all commands.
- **`docs/linux/install-kubectl-kctl.md`**: Guide explaining the installer script and manual step-by-step setup.
- **`src/_posts/2026-06-28-debian-ubuntu-install-kubectl-kubecolor.md`**: Blog post promoting the setup guide.
- Linked the guide in the Linux index and tracked it in agent-brains plan and memory structures.

## Why
Make the setup and update of `kubectl` and `kubecolor` fully repeatable, utilizing the native `apt` package manager for clean dependency tracking and system integration, and alias `kubecolor` as `kctl` for faster typing.

## Breaking changes
none
