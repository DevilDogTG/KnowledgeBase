---
title: "Setup PowerShell Git Completion with posh-git"
author: DevilDogTG
date: 2025-06-10 08:00:00 +0700
categories: [System Administrator, Windows]
tags: [windows, powershell, git, configuration, productivity]
---

`posh-git` is a PowerShell module that integrates Git and PowerShell, providing:
- Git status summary in the prompt
- Tab completion for common git commands, branch names, and paths

## Installation

```powershell
# First-time installation
PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force

# Update if already installed
PowerShellGet\Update-Module posh-git
```

Add it to your profile:

```powershell
Add-PoshGitToProfile -AllHosts -Force
```

Restart PowerShell to enjoy git completion.

## (Optional) Auto-Install Snippet for `$PROFILE`

For syncing the profile across multiple devices (e.g., via OneDrive), add this snippet to auto-install/update `posh-git`:

```powershell
# Check if posh-git is installed, install or update if needed
if (-not (Get-Module -ListAvailable -Name posh-git)) {
    try {
        Install-Module posh-git -Force -Scope CurrentUser
    } catch {
        Write-Host "Failed to install posh-git module. Please install it manually using 'Install-Module posh-git'."
        return
    }
} else {
    $poshGitModule = Get-Module -Name posh-git
    if ($poshGitModule.Version -lt (Get-Module -ListAvailable -Name posh-git).Version) {
        Update-Module posh-git -Force -Scope CurrentUser
    }
}

# Import if not already loaded
if (-not (Get-Module -Name posh-git)) {
    Import-Module posh-git
}
Add-PoshGitToProfile -AllHosts -Force
```

## References

- [posh-git on GitHub](https://github.com/dahlbyk/posh-git?tab=readme-ov-file)
