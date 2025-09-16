---
layout: default
---
# :gear: Bash completion on minimum install

When you install Ubuntu as minimal require. They lack some utility that we commonly used like command auto completed.

Here method to bring autocomplete back
```sh
sudo apt install bash-completion
```

You can add `/etc/profile.d/bash_completion.sh` to your `~/.bashrc` file as follows: 
```bash
## source it from ~/.bashrc or ~/.bash_profile ##
echo "source /etc/profile.d/bash_completion.sh" >> ~/.bashrc
 
## Another example Check and load it from ~/.bashrc or ~/.bash_profile ##
grep -wq '^source /etc/profile.d/bash_completion.sh' ~/.bashrc || echo 'source /etc/profile.d/bash_completion.sh'>>~/.bashrc
```
