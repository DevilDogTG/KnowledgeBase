## What changed
Restructured the repository into a dual-purpose workspace:

- **`/docs`** — a local knowledge base of rough, internal notes organized into topic
  folders, each with its own `Index.md`, plus a master `docs/Index.md`. Seeded by copying
  seven existing notes (originals left untouched as a backup).
- **`/src`** — the existing Jekyll + Chirpy blog, relocated from the repo root via `git mv`
  so history is preserved (45 posts, CNAME, assets, theme config).

Supporting changes:
- Rewired both GitHub Pages workflows (`pages-build.yml`, `pages-deploy.yml`) to build from
  `/src` (`working-directory: src`, artifact `path: src/_site...`) and to skip deploys for
  `docs/**`-only changes.
- Repointed the `.gitmodules` submodule path and root-anchored `.gitignore` patterns to `src/`.
- Dropped stale `_config.yml` excludes that are now outside the Jekyll source.
- Removed the already-migrated `Backup/` tree.
- Rewrote `README.md` for the dual structure and the `/docs -> /src` promotion flow.
- Documented the structure and a "write it down" note-capture rule in `.agent-brains/AGENT.md`,
  and updated agent-brains plan/memory.

Validated locally: `bundle install` + production `jekyll build` + `htmlproofer` all pass
with 0 errors; CNAME is preserved in the built `_site`.

## Why
Make the repository serve both as a private working knowledge base and the public blog, with
a clear promotion path from rough notes to published posts. no issue

## Breaking changes
none -- the published site output and custom domain are unchanged; only the source layout and
build working directory moved to `src/`.
