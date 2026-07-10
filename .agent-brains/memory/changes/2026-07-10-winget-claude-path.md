---
date: 2026-07-10
title: Fix winget-installed claude not recognized path issue
---

Identified that WinGet installs `Anthropic.ClaudeCode` as a portable package but fails to create shims in `C:\Users\devildogtg\AppData\Local\Microsoft\WinGet\Links` due to lack of admin/Developer Mode privileges. Created manual shims `claude.cmd` and `claude` (shell script) in the links directory. Documented the issue and fix in `docs/troubleshooting/winget-claude-path-issue.md`.
