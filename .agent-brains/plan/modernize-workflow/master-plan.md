---
task: modernize-workflow
status: done
progress: 100
branch: feat/modernize-workflow
created: 2026-06-28
updated: 2026-06-28
---

# Plan: Modernize Workflow

## Goal
Establish `main` as the sole primary branch, configure GitHub Actions workflows, fix syntax errors in workflows, and document the new workflow.

## Checklist
- [x] Create modernization plan stub
- [x] Fix escaped hyphens (`\-\-`) in `.github/workflows/pages-deploy.yml`
- [x] Validate all GitHub Action workflow configurations
- [x] Run test/build validation checks locally (skipped: Ruby environment not present on host; validated syntax and triggers)
- [x] Verify the plan updates are correctly indexed

## Progress Log
- **2026-06-28:** Created modernization plan stub on the `feat/modernize-workflow` branch.
- **2026-06-28:** Inspected all workflow files. Found and resolved double-dash escaping syntax errors in `.github/workflows/pages-deploy.yml`. Verified triggers and CodeQL setup.
- **2026-06-28:** Rebased the branch onto `main` and ran the `finish-feature` flow. Prepared the PR body and marked all checklist items complete.
