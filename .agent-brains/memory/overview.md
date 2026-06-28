# Project Overview

Initial status.

## Recent Changes
<!-- begin:changes -->
### 2026-06-28 — Modernize CI/CD workflows and fix deploy syntax
Modernized the personal knowledge base workflows to target `main` as the sole primary branch. Fixed syntax errors in double-hyphen flags within `.github/workflows/pages-deploy.yml`.

### 2026-06-28 — Restructure into dual-purpose workspace (/docs + /src)
Restructured the repo into a dual-purpose workspace:
- `/docs` — local knowledge base of rough notes, organized into topic folders each with an
  `Index.md` (seeded by copying 7 notes from `../help-desk`; originals left as backup).
- `/src` — the relocated Jekyll/Chirpy web blog (moved from repo root via `git mv`).

Rewired both GitHub Pages workflows (`pages-build.yml`, `pages-deploy.yml`) to build from
`/src` using `defaults.run.working-directory: src` + `working-directory: src` on Ruby setup,
artifact `path: src/_site...`, and added `docs/**` to `paths-ignore`. Updated `.gitmodules`
submodule path to `src/assets/lib` (submodule is unused — theme comes from the
`jekyll-theme-chirpy` gem). Deleted the already-migrated `Backup/` folder. Validated locally:
`bundle install` + production `jekyll build` (45 posts, CNAME preserved) + htmlproofer passed
with 0 errors.

Promotion model: rough notes in `/docs` get polished and promoted into `/src` posts (soft,
non-strict; `/src` may also hold original posts).
<!-- end:changes -->

## Key Decisions
- [ADR-0001](../decisions/ADR-0001-relocate-blog-into-src.md) — relocate the Jekyll blog into
  `/src` and build GitHub Pages from there, with `/docs` as the local knowledge base.
