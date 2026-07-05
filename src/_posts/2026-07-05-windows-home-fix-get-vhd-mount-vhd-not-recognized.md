---
title: "Fix `Get-VHD`/`Mount-VHD` Not Recognized on Windows Home"
author: DevilDogTG
date: 2026-07-05 21:45:00 +0700
categories: [System Administrator, Windows]
tags: [windows, powershell, hyper-v, vhd, troubleshooting]
---

I use a startup Scheduled Task to auto-mount a `.vhdx` file (a "Dev Drive") to a drive letter, using the Hyper-V PowerShell cmdlets `Get-VHD` and `Mount-VHD`. It had worked fine before, but running it manually one day gave:

```powershell
Get-VHD: The term 'Get-VHD' is not recognized as a name of a cmdlet, function, script file, or executable program.
Mount-VHD: The term 'Mount-VHD' is not recognized as a name of a cmdlet, function, script file, or executable program.
```

## Why this happens

`Get-VHD` and `Mount-VHD` ship with the **Hyper-V** PowerShell module, which is only installed as part of the Hyper-V optional feature. That feature is not officially supported on **Windows Home** editions.

You can confirm the module is genuinely missing (not just unloaded) by checking that its folder doesn't exist anywhere on disk:

```powershell
Test-Path "$env:SystemRoot\System32\WindowsPowerShell\v1.0\Modules\Hyper-V"
Test-Path "$env:ProgramFiles\WindowsPowerShell\Modules\Hyper-V"
# Both return False on Windows Home
```

```powershell
(Get-CimInstance Win32_OperatingSystem).Caption
# Microsoft Windows 11 Home Single Language
```

If it worked before, that was most likely through some unsupported Hyper-V-on-Home enablement (or the module was present on a different install) that later got reset — relying on it is fragile on Home edition.

## The fix: use the Storage module instead

Windows client ships the **Storage** module (`Get-DiskImage`, `Mount-DiskImage`) out of the box, no Hyper-V feature required. It mounts VHD/VHDX files just as well for this use case:

```powershell
Get-Command Get-DiskImage, Mount-DiskImage | Select-Object Name, ModuleName
# Name            ModuleName
# ----            ----------
# Get-DiskImage   Storage
# Mount-DiskImage Storage
```

Here's the auto-mount script, before and after:

```powershell
# Before (Hyper-V module - requires Hyper-V feature)
$vhd = Get-VHD -Path $vhdPath -ErrorAction SilentlyContinue
if ($vhd -and $vhd.Attached) { exit 0 }

Mount-VHD -Path $vhdPath -Access ReadWrite

$partition = Get-VHD -Path $vhdPath | Get-Disk | Get-Partition | ...
```

```powershell
# After (Storage module - works on Windows Home)
$vhd = Get-DiskImage -ImagePath $vhdPath -ErrorAction SilentlyContinue
if ($vhd -and $vhd.Attached) { exit 0 }

Mount-DiskImage -ImagePath $vhdPath

$partition = Get-DiskImage -ImagePath $vhdPath | Get-Disk | Get-Partition | ...
```

Note `Mount-DiskImage` has no `-Access` parameter — VHD/VHDX files mount read-write by default, so behavior is unchanged.

Full script:

```powershell
$vhdPath = "D:\Disks\Repositories.vhdx"
$driveLetter = "R"

# Skip if already mounted
$vhd = Get-DiskImage -ImagePath $vhdPath -ErrorAction SilentlyContinue
if ($vhd -and $vhd.Attached) { exit 0 }

# Attach the VHD
Mount-DiskImage -ImagePath $vhdPath

Start-Sleep -Seconds 3

# Assign drive letter R: if the partition doesn't already have it
$partition = Get-DiskImage -ImagePath $vhdPath |
    Get-Disk |
    Get-Partition |
    Where-Object { $_.Type -notin @('Reserved', 'System', 'Recovery') } |
    Select-Object -First 1

if ($partition -and $partition.DriveLetter -ne $driveLetter) {
    $partition | Set-Partition -NewDriveLetter $driveLetter
}
```

No changes are needed to the Scheduled Task itself — it runs as `SYSTEM` on the `AtStartup` trigger either way; only the cmdlets used inside the script change.

## Verifying

```powershell
Get-DiskImage -ImagePath D:\Disks\Repositories.vhdx | Select-Object ImagePath, Attached, StorageType
```

Run the script directly and confirm it exits cleanly (`$LASTEXITCODE -eq 0`), hitting the "already mounted" path if the drive is already attached, or actually mounting it otherwise.
