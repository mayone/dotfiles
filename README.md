# dotfiles
- Shell: Zsh + Zinit + Powerlevel10k
- Terminal: iTerm (for macOS) + tmux (TPM + Catppuccin + SessionX)
- Editor: Vim, VSCode

---

## Install
```console
./install.sh
```

### Install (excluding devtools)
```console
NO_DEV=1 ./install.sh
```

<details>
<summary>Post Install Setup</summary>

- zsh use `p10k` theme
  - Open iTerm2 and type `p10k configure` to
    1. Download `MesloLGS NF`
    2. Configure prompt style
- tmux installs its plugins on first start
  - Needs `git`, network access and a [Nerd Font](https://www.nerdfonts.com)
  - `prefix + I` installs plugins, `prefix + U` updates them
  - `prefix + O` opens the SessionX session switcher (needs `fzf`)

</details>

<details>
<summary>Optional Post Install Steps</summary>

1. iTerm2
  - If `zsh` is installed by Homebrew
    - Set Custom Shell to `/opt/homebrew/bin/zsh` on startup in iTerm2 settings
  - Use the Nerd Fonts v3 `MesloLGS Nerd Font Mono` that `install.sh` installs
    - Go to: `Preferences → Profiles → Text → Font`
    - Set `POWERLEVEL9K_MODE=nerdfont-v3` in `~/.p10k.zsh`, or run `p10k configure` again
  - Use different [iTerm2-Color-Schemes](https://github.com/mbadolato/iTerm2-Color-Schemes)
    - Clone the repo, double-click the scheme to import
  - [Option + Left/Right Arrow Keys to move cursor by word](http://tgmerritt.github.io/jekyll/update/2015/06/23/option-arrow-in-iterm2.html)
    - Go to: `Preferences → Profiles → Keys → Key Mappings`
      - Keyboard Shortcut:
        - `⌥← (Option+Left Arrow)`
        - `⌥→ (Option+Right Arrow)`
      - Action: `Send Escape Sequence`
      - ESC+:
        - `b` for backward
        - `f` for forward
  - Configure Status Bar
    - Go to: `Preferences → Profiles → Session`
      - Enable status bar and configure

2. VSCode
  - [VSCode - Launching from the command line](https://code.visualstudio.com/docs/setup/mac#_launching-from-the-command-line) to add `code` command to terminals

</details>

## Update
```console
./update.sh
```

On NixOS this also upgrades the system through `nix/apply.sh --upgrade`. To apply `nix/configuration.nix` without upgrading:
```console
nix/apply.sh
```

tmux plugins update through TPM. Catppuccin is pinned to a tag in `tmux/.tmux.conf`: to upgrade it, change the tag, remove `~/.tmux/plugins/tmux` and press `prefix + I`.

## Uninstall
```console
./uninstall.sh
```

---

## Exception Handling

#### Cannot choose prompt style in `p10k configure`
- Make sure Terminal
  - Use Powerline glyphs
  - Use `xterm-256color`

#### Powerline Font not installed after `p10k configure`
- Manually install [MesloLGS NF](https://github.com/romkatv/powerlevel10k#manual-font-installation) and set Terminal font

#### tmux status line has no theme, or icons show as boxes
- Plugins install on the first start with network access, press `prefix + I` to retry and `prefix + r` to reload
- Set a Nerd Font as Terminal font; the SessionX key hints need Nerd Fonts v3

---

## References
- [Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [Nerd Fonts - Homebrew Fonts](https://github.com/ryanoasis/nerd-fonts#option-4-homebrew-fonts)
- [Zinit](https://github.com/zdharma-continuum/zinit)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [How to Install GCC (build-essential) on Ubuntu 20.04](https://linuxize.com/post/how-to-install-gcc-on-ubuntu-20-04/)

#### dotfiles
- [dt665m/dotfiles](https://github.com/dt665m/dotfiles)

#### zsh
- [awesome-zsh-plugins](https://github.com/unixorn/awesome-zsh-plugins)
- [Zinit wiki](https://zdharma-continuum.github.io/zinit/wiki/)
- [zdharma/zinit-configs/zshrc.zsh](https://github.com/zdharma-continuum/zinit-configs/blob/master/psprint/zshrc.zsh)
- [dgo-/dotfiles/zsh/zshrc](https://github.com/dgo-/dotfiles/blob/master/zsh/zshrc)

#### vim
- [lwhsu/rc/.vimrc](https://github.com/lwhsu/rc/blob/master/.vimrc)
- [amix/vimrc](https://github.com/amix/vimrc)
- [pellaeon/Dotfiles/vimrc](https://github.com/pellaeon/Dotfiles/blob/master/vimrc)
- [Characters per line (CPL)](https://en.wikipedia.org/wiki/Characters_per_line)

#### tmux
- [gpakosz/.tmux](https://github.com/gpakosz/.tmux)
- [tmux-plugins/tpm](https://github.com/tmux-plugins/tpm)
- [catppuccin/tmux](https://github.com/catppuccin/tmux)
- [omerxx/tmux-sessionx](https://github.com/omerxx/tmux-sessionx)