---
title: "Fix `winget` Not Recognized on Windows"
author: DevilDogTG
date: 2025-06-17 08:00:00 +0700
categories: [System Administrator, Windows]
tags: [windows, winget, troubleshooting, powershell]
---

To re-install the stable release of WinGet on Windows, run the following from a PowerShell prompt:

```powershell
Write-Host "Installing WinGet PowerShell module from PSGallery..."
Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null
Write-Host "Using Repair-WinGetPackageManager cmdlet to bootstrap WinGet..."
Repair-WinGetPackageManager -AllUsers
$PSVersionTable.PSVersion
Install-Module -Name PowerShellGet -Force
Install-Module -Name PackageManagement -Force
Write-Host "Done."
```
