# Project Overview

Initial status.

## Recent Changes
<!-- begin:changes -->
### 2026-07-10 - Fix winget-installed claude not recognized path issue
Identified that WinGet installs `Anthropic.ClaudeCode` as a portable package but fails to create shims in `C:\Users\devildogtg\AppData\Local\Microsoft\WinGet\Links` due to lack of admin/Developer Mode privileges. Created manual shims `claude.cmd` and `claude` (shell script) in the links directory. Documented the issue and fix in `docs/troubleshooting/winget-claude-path-issue.md`.

### 2026-06-28 - Modernize CI/CD workflows and fix deploy syntax
Modernized the personal knowledge base workflows to target `main` as the sole primary branch. Fixed syntax errors in double-hyphen flags within `.github/workflows/pages-deploy.yml`.

### 2026-06-28 - Add kubectl and kctl installation script and guide
Created an idempotent install and update script for `kubectl` and `kctl` on Debian/Ubuntu systems, featuring preflight checks, architecture detection, checksum validation, and automated shell auto-completion. Added a corresponding documentation guide under `docs/linux/install-kubectl-kctl.md` and linked it in the Linux topic index.

### 2026-06-28 - Restructure into dual-purpose workspace (/docs + /src)
Restructured the repo into a dual-purpose workspace:
- `/docs` â€” local knowledge base of rough notes, organized into topic folders each with an
  `Index.md` (seeded by copying 7 notes from `../help-desk`; originals left as backup).
- `/src` â€” the relocated Jekyll/Chirpy web blog (moved from repo root via `git mv`).

Rewired both GitHub Pages workflows (`pages-build.yml`, `pages-deploy.yml`) to build from
`/src` using `defaults.run.working-directory: src` + `working-directory: src` on Ruby setup,
artifact `path: src/_site...`, and added `docs/**` to `paths-ignore`. Updated `.gitmodules`
submodule path to `src/assets/lib` (submodule is unused â€” theme comes from the
`jekyll-theme-chirpy` gem). Deleted the already-migrated `Backup/` folder. Validated locally:
`bundle install` + production `jekyll build` (45 posts, CNAME preserved) + htmlproofer passed
with 0 errors.

Promotion model: rough notes in `/docs` get polished and promoted into `/src` posts (soft,
non-strict; `/src` may also hold original posts).
<!-- end:changes -->

## Key Decisions
- [ADR-0001](../decisions/ADR-0001-relocate-blog-into-src.md) â€” relocate the Jekyll blog into
  `/src` and build GitHub Pages from there, with `/docs` as the local knowledge base.
