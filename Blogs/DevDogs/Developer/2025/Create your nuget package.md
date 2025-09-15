# Create your nuget package

This is simple guide to setup and create basic package to upload to nuget.org, in other server type please read server document to integrate it.

## Setup NuGet command line tool

You can download nuget cli from [NuGet download] or download latest version here [NuGet Latest]

after downloaded. Placed executable to path as your need and add folder to your `PATH` environment

Example: `C:\Nuget\Directory\Path`

```ps1
# Added folder to PATH
$env:PATH += ";C:\Nuget\Directory\Path"
```

Then re-open your terminal to reload environment (or re-login Windows).

try to check working version by `nuget help` command, you will see nuget response if success

```ps1
NuGet Version: 6.14.0.116
usage: NuGet <command> [args] [options]
Type 'NuGet help <command>' for help on a specific command.
```

## Get the api key from nuget.org

Go to website [Nuget], log-in to your account and go to `API Keys` menu

![API Keys Menu](assets/nuget-api-keys-menu.png)

Select key name, expires time and scope as you need, you can specified `Glob Pattern` to `*` for manager all packages.

![Create API Key](assets/nuget-create-api-key.png)

after created your can copy your api key here

![Copy Key](assets/nuget-key-copy.png)

## Configure your api key on local

After preparation process. Before upload your package to NuGet server you need to configure local machine to access nuget server

Check your current source

```ps1
nuget sources list
## Registered Sources:
##   1.  nuget.org [Enabled]
##       https://api.nuget.org/v3/index.json
```

to configure api key for nuget.org using

```ps1
nuget setapikey <your-api-key> -source https://api.nuget.org/v3/index.json
```

## Publish your package

Try to publishing your package, First you need to publish project type `Class Library` and run command to pack nuget package (please setup package information in .csproj property before pack)

```ps1
dotnet pack <project-file.csproj> --configuration [Debug/Release] --output "directory\path"
```

after run, you will get `.nupkg` file contain your library, you can use this file upload directly to nuget.org to list item

```ps1
nuget push "directory\path\project-name-<version>.nupkg" --source https://api.nuget.org/v3/index.json
```

After uploaded successfully, waiting for 5-15 mins NuGet will send your e-mail to confirm package has list.

Let's fun

> For private nuget server feed eg. Artifactory, MyGet, AzureDevOps. Process has same as above you need to change source url when configure and push package

## References

- [NuGet Cli](https://learn.microsoft.com/en-us/nuget/reference/nuget-exe-cli-reference?tabs=windows)
- [NuGet setapikey command](https://learn.microsoft.com/en-us/nuget/reference/cli-reference/cli-ref-setapikey)

## URLs definitions

[NuGet]: http://www.nuget.org
[NuGet download]: https://www.nuget.org/downloads
[NuGet Latest]: https://dist.nuget.org/win-x86-commandline/latest/nuget.exe
