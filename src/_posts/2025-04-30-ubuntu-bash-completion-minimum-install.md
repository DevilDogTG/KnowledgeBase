---
title: "Bash Completion on Ubuntu Minimal Install"
author: DevilDogTG
date: 2025-04-30 08:00:00 +0700
categories: [System Administrator, Linux]
tags: [linux, ubuntu, configuration, bash, shell]
---

When you install Ubuntu as a minimal install, some utilities like command auto-completion are missing.

Here's how to bring autocomplete back:

```sh
sudo apt install bash-completion
```

Then add it to your `~/.bashrc`:

```bash
echo "source /etc/profile.d/bash_completion.sh" >> ~/.bashrc
```

Or use this idempotent version (won't duplicate if already present):

```bash
grep -wq '^source /etc/profile.d/bash_completion.sh' ~/.bashrc || echo 'source /etc/profile.d/bash_completion.sh' >> ~/.bashrc
```
