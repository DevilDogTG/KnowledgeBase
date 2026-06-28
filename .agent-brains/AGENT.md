---
version: 1.0
profiles:
  - base-developer
strict_override: false
---

# Workspace Instructions

## Overview
This is a **dual-purpose workspace** that combines a local knowledge base and a public web blog.

## Repository Structure
```
/
├── docs/   # Local knowledge base — rough internal notes, organized by topic
│   ├── Index.md            # master index linking every topic
│   └── <topic>/Index.md    # one folder per topic (cloud-storage, linux, windows,
│                           # hardware, troubleshooting, home-lab, developers, misc),
│                           # each with its own Index.md listing that topic's notes
└── src/    # Web blog — Jekyll + Chirpy site deployed to GitHub Pages
    ├── _config.yml, _posts/, _tabs/, _data/, _plugins/, assets/, tools/, index.html
    ├── Gemfile, CNAME (devildogtg.dmnsn.com), .nojekyll
```
- **Run the blog from `src/`** (e.g. `cd src && bundle install && bundle exec jekyll serve --livereload`).
- GitHub Pages workflows (`.github/workflows/pages-*.yml`) build from `src/`; changes limited
  to `docs/**` do **not** trigger a deploy.
- The Chirpy theme comes from the `jekyll-theme-chirpy` gem; the `assets/lib` git submodule is unused.

## Workspace Rules
<!-- begin:framework -->
<!-- Global and profile rules are active automatically. Add project-specific overrides here. -->
<!-- end:framework -->

### Capturing notes ("write it down")
When the user asks to **write down**, **save**, **note**, or **document** a general
question, answer, or piece of knowledge (i.e. it is not blog content for publishing):
1. Save it as a Markdown note under the most fitting `docs/<topic>/` folder.
2. Give the file a clear, kebab-case name and a top-level `# Title` heading.
3. Add a link to the note in that topic's `docs/<topic>/Index.md` (under its `## Notes` list).
4. If no existing topic fits, create a new `docs/<topic>/` folder with its own `Index.md`,
   and add the topic to the table in `docs/Index.md`.
5. Keep `/docs` notes low-ceremony — no Jekyll front-matter is required; they are internal
   references, not published posts.

### Promotion to the blog (`/docs` → `/src`)
Rough notes live in `/docs`. When a note is worth publishing, polish it and add it as a
Jekyll post under `src/_posts/` (with proper front-matter). This is a **soft** flow: not every
note graduates, and `/src` may also contain original posts that never lived in `/docs`.
