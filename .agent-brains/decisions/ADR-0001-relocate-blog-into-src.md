# ADR-0001: Relocate the Jekyll blog into /src for a dual-purpose workspace

**Date:** 2026-06-28
**Status:** accepted
**Deciders:** @DevilDogTG (with Copilot CLI)

## Context
The repository began as a root-level Jekyll + Chirpy blog deployed to GitHub Pages at the
custom domain `devildogtg.dmnsn.com`. The goal was to make the same repository serve two
purposes: a **local knowledge base** of rough internal notes, and the existing **public web
blog**, with a soft promotion path from notes to published posts.

Constraints:
- Jekyll/GitHub Pages conventionally build from the repository root.
- The published site output and custom domain must not change.
- The Chirpy theme is consumed via the `jekyll-theme-chirpy` gem (the `assets/lib` submodule
  is declared but unused).
- `main` is a protected branch; all changes land through PRs.

## Options Considered

### Option A: Move the blog into `/src`, add `/docs`; rewire Pages to build from `/src`
The whole Jekyll site is relocated under `src/`, and the GitHub Pages workflows build with
`working-directory: src`. Notes live under `docs/`.
- **Pros:** Matches the desired `/docs` + `/src` mental model; clean separation; `docs/**`
  changes can skip deploys; symmetrical, predictable layout.
- **Cons:** Requires rewiring both Pages workflows, repointing the submodule path and
  root-anchored `.gitignore` patterns, and ensuring `CNAME` stays in the Jekyll source root.

### Option B: Keep the blog at the repo root, add only `/docs`
Leave Jekyll building from root; add a `docs/` folder for notes.
- **Pros:** Lowest risk; no workflow changes.
- **Cons:** Does not match the requested layout; root stays cluttered with blog internals;
  weaker conceptual separation between "notes" and "published site".

### Option C: Split into two repositories (docs-only here, blog elsewhere)
- **Pros:** Maximal isolation.
- **Cons:** Loses the single-repo promotion workflow; more overhead; over-engineered for a
  personal knowledge base.

## Decision
Adopt **Option A**: relocate the entire Jekyll site into `src/` and build GitHub Pages from
there, with `docs/` holding the local knowledge base — because it best matches the intended
dual-purpose structure while keeping the published site and domain unchanged.

## Consequences
**Easier:** Clear separation of rough notes (`/docs`) from the published blog (`/src`);
`docs/**`-only edits skip deploys; a predictable home for the `/docs → /src` promotion flow.

**Harder:** Blog tooling must run from `src/` (e.g. `cd src && bundle ...`); the Pages
workflows carry `working-directory: src` and a `src/_site` artifact path; `CNAME` must remain
inside `src/` so it is copied into the built site.

**Follow-up:** None outstanding — implemented and verified (local build + htmlproofer, CI, and
a live HTTP 200 at `devildogtg.dmnsn.com`). The unused `assets/lib` submodule may be removed
in a future cleanup.
