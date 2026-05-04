# Copilot Instructions

## Project Overview

This is a personal knowledge base / blog built with **Jekyll** using the [Chirpy theme](https://chirpy.cotes.page/) (`jekyll-theme-chirpy ~> 7.3`). It is deployed to GitHub Pages via GitHub Actions on every push to `main`.

## Build & Local Development

```powershell
# Install dependencies (first time; keeps gems local to the repo)
bundle config set path vendor/bundle
bundle install

# Serve locally with live reload
bundle exec jekyll clean && bundle exec jekyll serve --livereload

# Build for production
bundle exec jekyll b -d "_site"
```

## Testing

HTML is validated using `html-proofer` (defined in `Gemfile` under `group: :test`). This runs automatically in CI but can be run locally after a build:

```powershell
bundle exec htmlproofer _site --disable-external --ignore-urls "/^http:\/\/127.0.0.1/,/^http:\/\/0.0.0.0/,/^http:\/\/localhost/"
```

## CI/CD

- **`.github/workflows/pages-deploy.yml`** — builds, tests, and deploys to GitHub Pages on push to `main`
- **`.github/workflows/pages-build.yml`** — build/test on every PR targeting `main`
- **`.github/workflows/codeql.yml`** — CodeQL security scanning on push/PR to `main`

`main` is the sole primary branch. All work is done on feature branches (e.g. `feat/`, `fix/`) and merged via **rebase** — merge commits and squash merges are disabled.

## Post Conventions

All posts live in `_posts/` and must follow this naming pattern:

```
YYYY-MM-DD-slug-title.md
```

### Required Front Matter

```yaml
---
title: "Post Title"
author: DevilDogTG
date: 2025-09-15 08:00:00 +0700
categories: [PrimaryCategory, SubCategory]
tags: [lowercase, tags, here]
---
```

- **`author`** must match a key in `_data/authors.yml` (currently only `DevilDogTG`)
- **`tags`** must always be **lowercase**
- **`date`** timezone offset is `+0700` (Asia/Bangkok)
- `last_modified_at` is set **automatically** by `_plugins/posts-lastmod-hook.rb` using git history — do not set it manually

### Bilingual Posts

Thai-language posts use the filename suffix `-TH.md` and English equivalents use `-EN.md`. Thai posts are tagged with `lang:th`:

```yaml
tags: [tutorials, linux, lang:th]
```

### Images & Assets

Post images go under `assets/contents/YEAR/topic-name/`:

```
assets/contents/2024/middleware/custom-middleware-01.png
```

Reference them in posts as absolute paths: `/assets/contents/YEAR/topic/image.png`

## Key Configuration

- **`_config.yml`** — main site config (theme, URL, author info, collections, permalinks)
- **`_data/authors.yml`** — author profiles referenced by `author:` in front matter
- **`_data/contact.yml`** / **`_data/share.yml`** — sidebar contact links and share buttons
- **`_tabs/`** — static pages rendered as sidebar navigation tabs
- Post permalink pattern: `/posts/:title/`
- Categories and tags generate archive pages via `jekyll-archives`
