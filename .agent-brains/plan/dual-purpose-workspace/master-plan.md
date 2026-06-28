---
task: dual-purpose-workspace
status: done
progress: 100
branch: feat/dual-purpose-workspace
created: 2026-06-28
updated: 2026-06-28
---

# Plan: Dual-Purpose Workspace (/docs + /src)

## Goal
Restructure the repo so `/docs` holds rough local knowledge-base notes (seeded from
`../help-desk`) and `/src` holds the relocated Jekyll/Chirpy web blog, with GitHub Pages
workflows rewired to build from `/src`.

## Confirmed Decisions (from user)
- Blog → `/src`: physically move the whole Jekyll site and rewire Pages workflows.
- `/docs` = rough internal notes; promotion to `/src` is a manual polish step (soft, not strict).
- help-desk notes: **copy** into `/docs` (leave `../help-desk` untouched as backup).
- `/docs` layout: topic folders, each with an `Index.md`, plus a root `docs/Index.md`.
- `Backup/`: **delete** (already migrated into `_posts`).

## Status Snapshot (2026-06-28)
- DONE: Branch `feat/dual-purpose-workspace` cut from `main`.
- DONE: This plan stub created; backlog re-rendered.
- PARTIAL: `/docs` scaffold — 8 topic folders + `docs/Index.md` exist. Per-folder
  `Index.md` files still missing (and empty dirs won't commit without them).
- TODO: Everything else pending. Nothing committed yet.

## Checklist
- [x] Create agent-brains task plan stub + branch
- [x] Scaffold /docs topic folders with Index files
- [x] Seed /docs by copying the 7 help-desk notes into mapped topics
- [x] Move Jekyll blog into /src and update .gitmodules submodule path
- [x] Rewire pages-build.yml and pages-deploy.yml to build from /src
- [x] Update .gitignore / meta / _config path assumptions
- [x] Delete Backup/ (already migrated)
- [x] Rewrite README for dual structure + promotion workflow
- [x] Validate relocated blog build (jekyll build + htmlproofer)
- [x] Update agent-brains memory overview

---

## Execution Playbook (run later, in order)

### 1. Finish /docs scaffold
Create a one-line `Index.md` in each topic folder (otherwise empty dirs are dropped at commit):
docs/cloud-storage, linux, windows, hardware, troubleshooting, home-lab, developers, misc.
Each `Index.md`: a `# <Topic>` heading, one-line description, and a "## Notes" list that
links the notes placed in that folder.

### 2. Seed /docs from ../help-desk  (COPY, do not move)
```bash
HD=../help-desk
cp "$HD/rclone-setup-config-guide.md"            docs/cloud-storage/
cp "$HD/rclone-gdrive-mount-guide.md"            docs/cloud-storage/
cp "$HD/rclone-gdrive-optimized-guide.md"        docs/cloud-storage/
cp "$HD/google_drive_mount_investigation.md"     docs/cloud-storage/
cp "$HD/edge_chrome_extension_pwa_isolation.md"  docs/windows/
cp "$HD/remote_desktop_troubleshooting.md"       docs/troubleshooting/
cp "$HD/chipsailing-cs9711-fingerprint-setup.md" docs/hardware/
```
Then add links to each copied note in the relevant folder `Index.md`. Light cleanup only
(ensure each file has a top `# Title`); these are rough notes, no front-matter required.

### 3. Move the Jekyll blog into /src
Use `git mv` so history is preserved. Move these into `src/`:
`_config.yml _data _plugins _posts _tabs assets tools index.html Gemfile CNAME .nojekyll LICENSE-Chirpy`
Do **not** move: `README.md`, `LICENSE`, `.gitignore`, `.editorconfig`, `.gitattributes`,
`.agent-brains/`, `.github/`, `.vscode/`, entry-point files (`CLAUDE.md`, `GEMINI.md`,
`.codexrules`, `.github/copilot-instructions.md`), and `docs/`.
```bash
mkdir -p src
git mv _config.yml _data _plugins _posts _tabs assets tools index.html \
       Gemfile CNAME .nojekyll LICENSE-Chirpy src/
```
Update the submodule path in `.gitmodules` to `path = src/assets/lib`, then:
```bash
git submodule sync
```
(Moving `assets/` already relocates `assets/lib`; just fix `.gitmodules` + sync.)

### 4. Rewire GitHub Pages workflows  (.github/workflows/pages-build.yml & pages-deploy.yml)
Both currently run from repo root. For each, make Jekyll steps run in `src/`:
- Ruby setup / build / htmlproofer steps: add `working-directory: src` (and/or env
  `BUNDLE_GEMFILE: src/Gemfile`).
- Build command stays `bundle exec jekyll b -d "_site${{ steps.pages.outputs.base_path }}"`
  (runs in src → output at `src/_site...`).
- Upload artifact (pages-deploy.yml only): `path: "src/_site${{ steps.pages.outputs.base_path }}"`.
- Add `docs/**` to `paths-ignore` on the deploy workflow so docs-only edits don't redeploy.
- Enable `submodules: recursive` on the checkout step if theme assets are needed at build time
  (currently commented out).

### 5. Update meta / config paths
- `.gitignore`: ensure Jekyll caches resolve under src (`_site`, `.jekyll-cache`, `vendor`,
  `.bundle` patterns are unanchored and already match nested paths — verify, anchor if needed).
- `_config.yml`: scan for root-relative path assumptions (Chirpy normally needs none).
- `CNAME` stays inside `src/` so Jekyll copies it into `_site` (keeps custom domain working).

### 6. Delete Backup/
```bash
git rm -r Backup/
```

### 7. Rewrite README.md
Document the dual `/docs` + `/src` structure, how to run the blog now
(`cd src && bundle install && bundle exec jekyll serve --livereload`), and the
`/docs → /src` promotion workflow. Repoint existing Ruby/Bundler notes at `src/`.

### 8. Validate
```bash
cd src
bundle install
JEKYLL_ENV=production bundle exec jekyll b -d _site
bundle exec htmlproofer _site --disable-external \
  --ignore-urls "/^http:\/\/127.0.0.1/,/^http:\/\/0.0.0.0/,/^http:\/\/localhost/"
```
If Ruby/Bundler isn't on the host (it wasn't for the prior workflow task — see memory),
skip local build and rely on a CI dry-run: push the branch and watch the Pages workflow.
Confirm the submodule resolves and CNAME lands in `_site`.

### 9. Update agent-brains memory
Record the new structure + promotion workflow in `./.agent-brains/memory/overview.md`
(via `scripts/brains-index` change-block, not by hand-editing generated sections).

---

## Risks / Gotchas
- **Highest risk:** workflow rewiring + submodule move. Get `working-directory` / artifact
  `path:` right or the Pages deploy breaks.
- Empty `/docs` subfolders are dropped at commit unless they contain a file (the Index.md).
- `Gemfile.lock` & `vendor/` are gitignored → `bundle install` re-resolves after the move.
- Custom domain (`devildogtg.dmnsn.com`) set in repo Settings; CNAME file must stay in the
  Jekyll source root (now `src/`) so it's copied into the built site.
- Ruby may be absent locally (per memory from the prior workflow task) — plan for CI validation.

## Progress Log
- **2026-06-28:** Created plan stub on `feat/dual-purpose-workspace`. Scaffolded 8 `/docs`
  topic folders + `docs/Index.md`. Paused at user request; wrote full execution playbook +
  handover for later execution. No commits yet.

- **2026-06-28 (exec):** Executed full playbook. Seeded /docs (edge PWA note re-mapped to linux/ as it's Linux-focused). Moved blog to /src, rewired both workflows, fixed .gitmodules + .gitignore + _config excludes, deleted Backup/, rewrote README. Installed Ruby 3.3 locally and validated: bundle install + production jekyll build (45 posts, CNAME preserved in _site) + htmlproofer 0 errors. Updated memory. Nothing committed yet.
