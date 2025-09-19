# 📖 DevilDogTG's Knowledge Base

![Last 7 days](https://wakapi.dev/api/badge/DevilDogTG/DevilDogTG/interval:7_days?label=Last%207%20Days)

Welcome to my personal knowledge base! This space is powered by Jekyll and serves as a collection of notes, tutorials, and resources for development, system administration, and more.

## 🚀 Getting Started: Run Locally

### Preparing Environment (Windows)

Install `Ruby`, In this case I'm using `3.1.7` on Windows

Download: [RubyInstaller](https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.1.7-1/rubyinstaller-devkit-3.1.7-1-x64.exe)

After installation wizard completed, run `ridk install` and choose `MSYS2 base + dev toolchain`

Reopen your terminal

```powershell
. $PROFILE
```

> ⚠️ If command to reload terminal profile is not work, try to re-login your windows

Check version installed

```powershell
ruby -v
gem -v
```

Install `bundler` after install 

```powershell
gem install bundler
# Check bundle version
bundle -v
```

### Install dependencies

If you need to install dependencies packages in local folder, run this command:

```powershell
# Install gems for this project (kept local to the repo)
bundle config set path vendor/bundle
```

Then to install required packages, simple to run

```powershell
bundle install
```

### Run

Run it on local system

```powershell
bundle exec jekyll clean && bundle exec jekyll serve --livereload
```

`--livereload` will help local site keep updating when you editted files.

## 🛠️ GitHub Actions

This repository uses GitHub Actions for CI/CD. On every push or pull request, the workflow will:

- Build the Jekyll site
- Run tests to ensure everything works
- Deploy to GitHub Pages (if on the main branch)

See `.github/workflows/` for workflow details.

## 🙏 Special Thanks

- **[Jekyll](https://jekyllrb.com/)**: Static site generator
- **[Chirpy Theme](https://chirpy.cotes.page/)**: Beautiful Jekyll theme
- **[GitHub](https://github.com/)**: Hosting and CI/CD platform
- **[Wakapi](https://wakapi.dev/)**: Coding activity tracking
- All open-source projects that make this possible!
