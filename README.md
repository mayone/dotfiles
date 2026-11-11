# dotfiles
- Shell: Zsh + Zinit + Powerlevel10k
- Terminal: iTerm (for macOS) + tmux
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

</details>

<details>
<summary>Optional Post Install Steps</summary>

1. iTerm2
  - If `zsh` is installed by Homebrew
    - Set Custom Shell to `/opt/homebrew/bin/zsh` on startup in iTerm2 settings
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

## Tools and packages (mise)
[mise](https://mise.jdx.dev) installs what `mise/global.toml` and `mise/dev.toml` list:
- `[tools]`: the runtimes (Node.js, pnpm, Yarn, Go, Java) and the command-line tools, on macOS and Linux alike.
- `[bootstrap.packages]`: the host packages, with apt on Debian and Ubuntu, and as Homebrew formulae and casks on macOS. mise installs the formulae into `/opt/homebrew` and the apps into `/Applications` itself, so the Homebrew program is not needed.

Rust stays with rustup.

`./install.sh` installs mise and runs `mise/apply.sh`. On a machine that is already set up, or on NixOS (where `nix/configuration.nix` provides mise), run:
```console
mise/apply.sh
```

It links `mise/global.toml` to `~/.config/mise/config.toml` and, unless `NO_DEV` is set, `mise/dev.toml` to `~/.config/mise/conf.d/dev.toml`. For login shells it adds the mise shims to `~/.zprofile`, and `/opt/homebrew/bin` on a Mac without Homebrew. Then it runs `mise bootstrap --only packages,tools`, which asks before it installs packages. `zsh/.zshrc` activates mise in interactive shells.

To add a tool, run `mise use -g <tool>`. It installs the tool and writes it through the link into `mise/global.toml`, so commit the change. For a tool that `NO_DEV` machines skip, add it to `mise/dev.toml`. To add a package, add a `"<manager>:<package>"` entry under `[bootstrap.packages]`, with `os = "macos"` on Homebrew entries. Then run `mise/apply.sh`.

## Update
```console
./update.sh
```

On NixOS this also upgrades the system through `nix/apply.sh --upgrade`. To apply `nix/configuration.nix` without upgrading:
```console
nix/apply.sh
```

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