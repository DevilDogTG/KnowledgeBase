---
task: winget-claude-path
status: done
progress: 100
branch: bugfix/winget-claude-path
created: 2026-07-10
updated: 2026-07-10
---

# Plan: Fix winget-installed 'claude' Not Recognized

## Goal
Diagnose why `claude` (installed via winget) is not recognized as a command, verify the PATH configuration, resolve it, and document the solution in the knowledge base.

## Checklist
- [x] Research/Diagnose: Check winget package installation status and location.
- [x] Check if the WinGet shims/links directory (e.g., `AppData\Local\Microsoft\WinGet\Links`) contains the `claude` shim.
- [x] Check if the WinGet Links directory is in the PATH environment variable.
- [x] Implement Fix: Add WinGet Links directory to the PATH if missing, or recreate the shim.
- [x] Verify: Test calling `claude` in a fresh terminal session.
- [x] Document: Add a troubleshooting entry to `docs/troubleshooting/` and update its `Index.md`.
