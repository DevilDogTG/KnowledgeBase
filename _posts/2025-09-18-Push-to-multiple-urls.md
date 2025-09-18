---
title: Setup Git push to multiple URLs with same origin
author: DevilDogTG
date: 2025-09-16 09:09:00 +0700
categories: [Developers, Git]
tags: [tutorials, git, version-control, push] # TAG names should always be lowercase
---

To push changes to multiple origins, you need to configure multiple push URLs.

## How to add multiple URLs

To check current origin using this command:

```bash
git remote show origin
```

You will see `Fetch` and `Push` URL, you can add new push destination like this example

```bash
git remote set-url --add --push origin https://github.com/your-group/your-repo.git
# if want to add another one, here is an example
git remote set-url --add --push origin https://gitlab.com/your-group/your-repo.git
```

You can use multiple URLs only for `Push`. `Fetch` need to specified only one URL
