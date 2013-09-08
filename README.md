B-Con's dotfiles
===
These are my notable and sharable dotfiles. Dotfiles are part of what makes \*nix awesome.

Installation
---
I have a custom script that installs/removes the dotfiles to a $HOME directory: `setup.sh`. Before executing `setup.sh`, edit it and set the path variables in the header. (The default values are my own.)

I use the symlink approach for installing the Git repo's dotfiles to my system. I keep the dotfiles that are under Git in a separate directory from $HOME and symlink each individual file to its corresponding file in the Git repo. The Git repo file layout is identical to how it is in $HOME.

Removal removes all symlinks that point to the Git repo. There are two ways to perform removal: By removing known links (fast, may miss dangling links), or by searching for all links to the Git repo (slow, will find everything). Removal only removes syslinks that lead into the configured Git repo, if a syslink was changed to a file or to link elsewhere, then removal will not touch it.

Usage
---
* `setup.sh install` - For every file in the Git repo, create a symlink in $HOME with the same relative path as the repo file and point it to the repo file. If the file already exists, back it up first.
* `setup.sh uninstall` - For every file in the Git repo, remove the corresponding symlink in $HOME and restore the backed up file if it exists. If file names change in the repo before `uninstall` is used, the corresponding symlinks will be left abandoned.
* `setup.sh purge` - For every file in $HOME, if it links into the repo, remove it and restore the backed up file if it exists. (This is not done by default because it is potentially very slow and unnecessary.)
* `setup.sh help` - Output information about the options and some details about how it works.

Contributions
---
You are welcome to contribute. However, I won't add anything that I'm not intersted in keeping on my own personal setup.

Bug reports are absolutely always welcome.

License
---
My code and configurations are released under the MIT license. See `LICENSE.md` for details.

