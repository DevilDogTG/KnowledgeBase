---
title: "Setup VSCode as Markdown Reader"
author: DevilDogTG
date: 2025-05-18 08:00:00 +0700
categories: [System Administrator, Windows]
tags: [windows, vscode, markdown, configuration, productivity]
---

This guide is based on using Markdown for a knowledge base and wanting VSCode to open files in **preview mode by default** instead of the editor.

## Extensions

The main extension is [Markdown Preview Enhanced](https://marketplace.visualstudio.com/items?itemName=shd101wyy.markdown-preview-enhanced) — it supports full-page preview without split-screen.

Optional useful extensions:
- [Draw.io Integration](https://marketplace.visualstudio.com/items?itemName=hediet.vscode-drawio)
- [markdownlint](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)

## Custom Settings

Open user settings (JSON) and add:

```json
{
    "markdown-preview-enhanced.previewMode": "Previews Only",
    "workbench.editorAssociations": {
        "*.copilotmd": "vscode.markdown.preview.editor",
        "*.md": "markdown-preview-enhanced",
        "*.markdown": "markdown-preview-enhanced",
        "*.mdown": "markdown-preview-enhanced",
        "*.mkdn": "markdown-preview-enhanced",
        "*.mkd": "markdown-preview-enhanced",
        "*.rmd": "markdown-preview-enhanced",
        "*.qmd": "markdown-preview-enhanced",
        "*.mdx": "markdown-preview-enhanced"
    },
    "markdown-preview-enhanced.previewTheme": "github-dark.css",
    "markdown-preview-enhanced.automaticallyShowPreviewOfMarkdownBeingEdited": true
}
```

The key setting is `"markdown-preview-enhanced.previewMode": "Previews Only"` — this opens Markdown files in full-page preview mode by default.

## Create a Custom Shortcut

Create a VSCode profile named "Reader" for the knowledge base. Then create a desktop shortcut with arguments to open it directly:

```cmd
C:\<Path to VSCode>\Code.exe --profile "Reader" "<Path to Document Folder>"
```

Optionally, separate the configuration from the default instance:

```cmd
C:\<Path to VSCode>\Code.exe --profile "Reader" "<Path to Document Folder>" --user-data-dir="<path to custom vscode data>"
```

Done — you now have a reader shortcut that opens Markdown in preview mode by default.
