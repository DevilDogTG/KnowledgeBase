---
title: "Setup PowerShell Autocomplete"
author: DevilDogTG
date: 2025-06-10 08:00:00 +0700
categories: [System Administrator, Windows]
tags: [windows, powershell, configuration, autocomplete, productivity]
---

Enable Linux-style shell autocompletion in PowerShell using the `PSReadLine` module.

## Installation

```powershell
Install-Module PSReadLine
```

## Configuration

Edit your PowerShell profile:

```powershell
notepad $PROFILE
```

Add the following code:

```powershell
# Check if PSReadLine module is available, if not, install it
if (-not (Get-Module -ListAvailable -Name PSReadLine)) {
    Install-Module -Name PSReadLine -Force -Scope CurrentUser
}

# Check if PSReadLine is loaded, if not, import it
if (-not (Get-Module -Name PSReadLine)) {
    Import-Module PSReadLine
}

# Shows navigable menu of all options when hitting Tab
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Autocomplete for Arrow keys
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

Set-PSReadLineOption -ShowToolTips
Set-PSReadLineOption -PredictionSource History
```

This makes your terminal start slightly slower, but it's worth it.

## References

- [DEV Community: How to add autocomplete to PowerShell in 30 seconds](https://dev.to/dhravya/how-to-add-autocomplete-to-powershell-in-30-seconds-2a8p)
