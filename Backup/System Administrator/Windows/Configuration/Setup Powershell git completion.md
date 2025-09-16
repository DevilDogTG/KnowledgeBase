---
layout: default
---
# :wrench: Setup `powershell` `git` completetion

posh-git is a PowerShell module that integrates Git and PowerShell by providing Git status summary information that can be displayed in the PowerShell prompt

posh-git also provides tab completion support for common git commands, branch names, paths and more

## Installation

posh-git is available on the [PowerShell Gallery](https://www.powershellgallery.com/packages/posh-git/) and can be installed using the built-in PowerShellGet module.

```powershell
# (A) You've never installed posh-git from the PowerShell Gallery
PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force

# (B) You've already installed a previous version of posh-git from the PowerShell Gallery
PowerShellGet\Update-Module posh-git
```

And then run:

```powershell
Add-PoshGitToProfile -AllHosts -Force
```

restart powershell to enjoy your `git` completion on powershell

## (Optional) Add code snippet to `$PROFILE`

For easier to use script sync multiple device via `OneDrive`, I prefer added this snippet to your powershell profile

```powershell
# Check posh-git autocomplete has been installed, if not, install it
if (-not (Get-Module -ListAvailable -Name posh-git)) {
    try {
        Install-Module posh-git -Force -Scope CurrentUser
    } catch {
        Write-Host "Failed to install posh-git module. Please install it manually using 'Install-Module posh-git'."
        return
    }
} else {
    Write-Host "posh-git module is already installed."
    # Check if posh-git is up to date
    $poshGitModule = Get-Module -Name posh-git
    if ($poshGitModule.Version -lt (Get-Module -ListAvailable -Name posh-git).Version) {
        Write-Host "Updating posh-git module to the latest version..."
        Update-Module posh-git -Force -Scope CurrentUser
    } else {
        Write-Host "posh-git module is up to date."
    }
}

# Check if posh-git is loaded, if not, import it
if (-not (Get-Module -Name posh-git)) {
    Import-Module posh-git
}
Add-PoshGitToProfile -AllHosts -Force
```

This snippet will automatically install or update `posh-git` to latest version and using them everytime you start `powershell`

## References

- [GitHub](https://github.com/dahlbyk/posh-git?tab=readme-ov-file)
