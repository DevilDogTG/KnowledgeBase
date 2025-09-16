---
layout: default
---
# Setup VSCode as Markdown Reader

This idea has been create base on my setup using note everthing in `Markdown` format like a Knowledge Base, my problem start with need to read by default than editting, and annoy if I need to press `Ctrl+Shift+V` everytime to preview it in pretty format

## Getting Started

My issue has been solve by setup some configuration and extension, I split step has below

- Extensions usage
- Custom Settings
- Shortcut Create

### Extensions usage

Mainly focus on [Markdown Preview Enhance](https://marketplace.visualstudio.com/items?itemName=shd101wyy.markdown-preview-enhanced) this extension matched my requiredment to see preview in full page without side by side mode

Just install as normarly and configure for it will be wrote detail in next section

another is optional for each person, I using it as reader and sometime edit with this profile, that recommended to install [Draw.io integration](https://marketplace.visualstudio.com/items?itemName=hediet.vscode-drawio) and [markdownlint](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint) too.

### Custom Settings

I need simple setting from `Markdown Preview Enhance` settings to complete my goal, Just open user settings in JSON and add:

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

Important thing is `"markdown-preview-enhanced.previewMode": "Previews Only"` to make sure you can open markdown in full page preview mode by default.

### Shortcut Create

I create new VSCode profile as a reader for sperate extensions use and my knowledge base has store in one folder, that need me to create custom shortcut to open my documents directly without switch VSCode profile and select open folder.

After create custom shortcut to `code.exe` just add argument to specified `Profile` and `Target Folder` to be opened

Example:

```cmd
C:\<Path to VSCode>\Code.exe --profile "Reader" "<Path to Document Folder>"
```

In extra configure you can specified user data dir to sperate configuration from normal instance by added:

```cmd
 --user-data-dir="<path to custom vscode data>"
```

Done, I can get reader shortcut that open markdown in preview mode by default. In extra I added `--profile "Default"` to default shortcut to open VSCode for work with Default profile too.
