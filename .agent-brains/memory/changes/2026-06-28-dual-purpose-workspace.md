---
date: 2026-06-28
title: Restructure into dual-purpose workspace (/docs + /src)
---

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
