---
title: "Setup `watch` Alias in PowerShell"
author: DevilDogTG
date: 2025-05-27 08:00:00 +0700
categories: [System Administrator, Windows]
tags: [windows, powershell, configuration, productivity, shell]
---

The `watch` command is very helpful for monitoring commands in Linux. Unfortunately, Windows doesn't have this command. This guide creates a custom `watch` function in PowerShell.

## Create the Custom Function

Edit your `$PROFILE`:

```powershell
notepad $PROFILE
```

Add the following function:

```powershell
function watch {
    param (
        [int]$interval = 5,
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$command
    )

    if (-not $command -or $command.Count -eq 0) {
        Write-Host "❌ You must specify a command to watch. Example: watch 5 kubectl get pods"
        return
    }

    $prevLineCount = 0

    while ($true) {
        [Console]::SetCursorPosition(0, 0)

        try {
            $output = Invoke-Expression ($command -join " ") | Out-String
            $lines = $output -split "`r?`n"

            foreach ($line in $lines) {
                Write-Host $line
            }

            # Clear leftover lines from previous run
            if ($lines.Count -lt $prevLineCount) {
                for ($i = 0; $i -lt ($prevLineCount - $lines.Count); $i++) {
                    Write-Host (" " * [Console]::WindowWidth)
                }
            }

            $prevLineCount = $lines.Count
        } catch {
            Write-Host "`n❌ Error: $_"
        }

        Start-Sleep -Seconds $interval
    }
}
```

Reload the profile:

```powershell
. $PROFILE
```

## Usage

```powershell
watch 5 kubectl get pods
```

This runs `kubectl get pods` every 5 seconds.
