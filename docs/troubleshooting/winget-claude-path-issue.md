# WinGet Claude Code Command Not Found

## Problem
After installing Claude Code (`Anthropic.ClaudeCode`) via WinGet, trying to call `claude` in the terminal results in:
```
claude: The term 'claude' is not recognized as a name of a cmdlet, function, script file, or executable program.
```
Even after restarting the terminal, the command remains unrecognized.

## Root Cause
WinGet installs `Anthropic.ClaudeCode` as a **portable** package in:
`%LOCALAPPDATA%\Microsoft\WinGet\Packages\Anthropic.ClaudeCode_Microsoft.Winget.Source_8wekyb3d8bbwe\claude.exe`

By default, WinGet creates command-line aliases (symbolic links or shims) in:
`%LOCALAPPDATA%\Microsoft\WinGet\Links`

However, creating symbolic links on Windows requires either administrator privileges or Developer Mode enabled. When installing as a non-admin, WinGet silently fails to create the link/shortcut for the `claude.exe` binary in the `Links` folder, meaning it cannot be resolved even though the `Links` folder itself is in the user's `PATH`.

## Solution
Create manual shims in the `%LOCALAPPDATA%\Microsoft\WinGet\Links` directory so they resolve within the existing PATH.

### 1. Windows Command Prompt & PowerShell (`claude.cmd`)
Create a file at `%LOCALAPPDATA%\Microsoft\WinGet\Links\claude.cmd` containing:
```cmd
@echo off
"C:\Users\devildogtg\AppData\Local\Microsoft\WinGet\Packages\Anthropic.ClaudeCode_Microsoft.Winget.Source_8wekyb3d8bbwe\claude.exe" %*
```

### 2. Git Bash & WSL (`claude` shell script)
Create a file at `%LOCALAPPDATA%\Microsoft\WinGet\Links\claude` (no extension) containing:
```bash
#!/bin/sh
exec "C:/Users/devildogtg/AppData/Local/Microsoft/WinGet/Packages/Anthropic.ClaudeCode_Microsoft.Winget.Source_8wekyb3d8bbwe/claude.exe" "$@"
```

Once these shims are placed in the links folder, the `claude` command will work in any terminal session.
