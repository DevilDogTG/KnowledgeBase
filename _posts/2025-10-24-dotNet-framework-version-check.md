---
title: ".Net Framework Version Check"
author: DevilDogTG
date: 2025-10-01 10:56:00 +0700
categories: [Blogs, Games]
tags: [games, dqm3, powershell, lang:th]
---
For current dotnet you can see installed runtime and sdk very simple by using `dotnet --info`, but old .NET framework has more difficult to take a look for it.

## Quick solution

Use following command to check installed versions of .NET framework on windows system

``` powershell
gci 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse | gp -name Version,Release -EA 0 |where { $_.PSChildName -match '^(?!S)\p{L}'} | select PSChildName, Version, Release
```

You will get result as below

![Command result](../assets/contents/2025/developer/dotnet-framework/version-check/version-result.png)
