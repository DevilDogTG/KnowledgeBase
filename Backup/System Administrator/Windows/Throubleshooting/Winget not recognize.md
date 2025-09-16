---
layout: default
---
# :adhesive_bandage: Fix `winget` not recognize

Try to re-install the stable release of WinGet on Windows follow these steps from a Windows PowerShell command prompt:

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
