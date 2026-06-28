# 📖 DevilDogTG's Knowledge Base

![Last 7 days](https://wakapi.dev/api/badge/DevilDogTG/DevilDogTG/interval:7_days?label=Last%207%20Days)

A dual-purpose workspace combining a **local knowledge base** and a **public web blog**.

## 🗂️ Repository Structure

```
/
├── docs/   # Local knowledge base — rough working notes, organized by topic
└── src/    # Web blog — Jekyll + Chirpy site published to GitHub Pages
```

- **[`/docs`](docs/Index.md)** — my local, internal-use knowledge base. Notes here are
  low-ceremony: quick captures, investigations, and references organized into topic folders,
  each with its own `Index.md`. Start at [`docs/Index.md`](docs/Index.md).
- **[`/src`](src)** — the polished web blog (Jekyll + Chirpy theme) deployed to GitHub Pages
  at [devildogtg.dmnsn.com](https://devildogtg.dmnsn.com).

### ✍️ The `/docs → /src` workflow

Rough notes start their life in `/docs`. When a note is worth publishing, it gets cleaned up
and promoted into `/src` as a blog post. This is a **soft** flow:

- Not every note graduates — `/docs` is meant to hold more entries than `/src`.
- `/src` may also contain original posts (e.g. personal journey) that never lived in `/docs`.

## 🚀 Running the Blog Locally

The blog lives in [`/src`](src). **Run all commands from inside `src/`.**

### Preparing the environment (Windows)

Install `Ruby` (this project uses `3.4`). Download: [RubyInstaller](https://rubyinstaller.org/downloads/).

After the installation wizard completes, run `ridk install` and choose `MSYS2 base + dev toolchain`.

Reopen your terminal:

```powershell
. $PROFILE
```

> ⚠️ If reloading the terminal profile doesn't work, try re-logging into Windows.

Check the versions installed:

```powershell
ruby -v
gem -v
```

Install `bundler`:

```powershell
gem install bundler
bundle -v
```

### Install dependencies

From the `src/` directory:

```powershell
cd src
# Keep gems local to the repo (optional)
bundle config set path vendor/bundle
bundle install
```

### Run

```powershell
cd src
bundle exec jekyll clean && bundle exec jekyll serve --livereload
```

`--livereload` keeps the local site updating as you edit files.

## 🛠️ GitHub Actions

This repository uses GitHub Actions for CI/CD. The workflows build the Jekyll site **from
`/src`**:

- **Build & Test** (`pages-build.yml`) — runs on pull requests.
- **Build & Deploy** (`pages-deploy.yml`) — builds and deploys to GitHub Pages on pushes to `main`.

Changes limited to `/docs` do **not** trigger a deploy. See `.github/workflows/` for details.

## 🙏 Special Thanks

- **[Jekyll](https://jekyllrb.com/)**: Static site generator
- **[Chirpy Theme](https://chirpy.cotes.page/)**: Beautiful Jekyll theme
- **[GitHub](https://github.com/)**: Hosting and CI/CD platform
- **[Wakapi](https://wakapi.dev/)**: Coding activity tracking
- All open-source projects that make this possible!
