---
task: install-kubectl-kctl
status: active
progress: 90
branch: feature/install-kubectl-kctl
created: 2026-06-28
updated: 2026-06-28
---

# Plan: Install kubectl, kubecolor, and kctl on Debian/Ubuntu via APT

Create a repeatable installation and update script for `kubectl` (via Kubernetes APT repo), `kubecolor` (via DEB package), and `kctl` (symlink to `kubecolor`), along with a local knowledge base document.

## Checklist

- [x] Design the shell script features (preflight checks, architecture mapping, and APT-based installation logic)
- [x] Implement APT-based installation of kubectl and DEB-based installation of kubecolor
- [x] Update the documentation note at `docs/linux/install-kubectl-kctl.md`
- [x] Link the note in `docs/linux/Index.md`
- [x] Verify/Test the script locally using dry-run or verification commands
- [x] Update the Plan Index and Project Roadmap
- [ ] Ask the user for confirmation and final review
