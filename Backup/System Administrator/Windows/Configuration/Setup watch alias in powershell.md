---
layout: default
---
# Setup `watch` alias command in `Powershell`

`watch` command is very helpful to monitor can using with any command in linux, Unfortunately in windows we doesn't have this command. This guide will try to create custom function to use `watch` in `powershell`

## Create custom function

you can edit `$PROFILE` to add `alias` or `custom script` in powershell eg:

```powershell
notepad $PROFILE
```

add you custom function:

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
            # Capture output in memory
            $output = Invoke-Expression ($command -join " ") | Out-String
            $lines = $output -split "`r?`n"

            # Write each line
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

and reload profile

```powershell
. $PROFILE
```

## Let's try

try to use new custom script like:

```powershell
watch 5 kubectl get pods
```

let fun, If you have more idea and improvement please let me know to improve it.
