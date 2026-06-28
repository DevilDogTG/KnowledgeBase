---
task: install-kubectl-kctl
status: active
progress: 85
branch: feature/install-kubectl-kctl
created: 2026-06-28
updated: 2026-06-28
---

# Plan: Install kubectl and kctl on Debian/Ubuntu

Create a repeatable installation and update script for `kubectl` and `kctl` (as a symlink/alias), along with a local knowledge base document.

## Checklist

- [x] Design the shell script features (preflight checks, architecture mapping, version comparison, `/usr/local/bin` installation, and shell auto-completion setup)
- [x] Create the script file at `docs/linux/scripts/install-kubectl-kctl.sh`
- [x] Create the documentation note at `docs/linux/install-kubectl-kctl.md`
- [x] Link the note in `docs/linux/Index.md`
- [x] Verify/Test the script locally using dry-run or verification commands
- [x] Update the Plan Index and Project Roadmap
- [ ] Ask the user for confirmation and final review
