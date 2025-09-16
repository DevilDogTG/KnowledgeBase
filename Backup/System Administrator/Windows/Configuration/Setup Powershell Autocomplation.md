---
layout: default
---
# :wrench: Setup `Powershell` autocomplation

Truely, I like shell completion of Linux terminal. It easy to find or guide something and make life easier with CLI

Now, we can get it on powershel by installing PSModule

```powershell
Install-Module PSReadLine
```

and then, Added code snippet into your `powershell` profile by using:

```powershell
notepad $PROFILE
```

Added this code

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

# Autocompleteion for Arrow keys
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

Set-PSReadLineOption -ShowToolTips
Set-PSReadLineOption -PredictionSource History
```

It make your terminal load longer on startup, but it worth to do that.

## References

- [DEV Community](https://dev.to/dhravya/how-to-add-autocomplete-to-powershell-in-30-seconds-2a8p)
