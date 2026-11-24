# dotfiles
- Shell: Zsh + Zinit + Powerlevel10k
- Terminal: Ghostty + tmux (TPM + Catppuccin + SessionX) + herdr
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
  - Open Ghostty and type `p10k configure` to configure prompt style
  - Ghostty uses `MesloLGS NF` if it is installed, else the `MesloLGS Nerd Font Mono` that `install.sh` installs. `p10k configure` downloads `MesloLGS NF` only in iTerm2
- tmux installs its plugins on first start
  - Needs `git`, network access and a [Nerd Font](https://www.nerdfonts.com)
  - `prefix + I` installs plugins, `prefix + U` updates them
  - `prefix + C-f` opens the SessionX session switcher (needs `fzf`)
- `gsync` needs the [gh-poi](https://github.com/seachicken/gh-poi) extension of `gh`
  - `./install.sh` installs it when `gh` is logged in
  - Otherwise run `gh auth login`, then `gh extension install seachicken/gh-poi`

</details>

<details>
<summary>Optional Post Install Steps</summary>

1. Ghostty
  - Use the Nerd Fonts v3 `MesloLGS Nerd Font Mono` that `install.sh` installs
    - Remove `font-family = MesloLGS NF` from `ghostty/config.ghostty`
    - Set `POWERLEVEL9K_MODE=nerdfont-v3` in `~/.p10k.zsh`, or run `p10k configure` again
  - Use a different theme
    - `ghostty +list-themes` previews the themes that Ghostty includes
    - Set `theme` in `ghostty/config.ghostty`

2. VSCode
  - [VSCode - Launching from the command line](https://code.visualstudio.com/docs/setup/mac#_launching-from-the-command-line) to add `code` command to terminals

</details>

## Tools and packages (mise)
[mise](https://mise.jdx.dev) installs what `mise/global.toml` and `mise/dev.toml` list:
- `[tools]`: the runtimes (Node.js, pnpm, Yarn, Go, Java, Deno) and the command-line tools, such as kubectl, on macOS and Linux alike. Entries with `os = ["macos"]`, such as tmux, ffmpeg, Python, and Claude Code, replace the Homebrew formulae and casks that the Mac used to get.
- `[bootstrap.packages]`: the host packages: apt packages on Debian and Ubuntu, and on macOS the apps and the Nerd Font as Homebrew casks. mise installs the casks into `/Applications` and `~/Library/Fonts` itself, so the Homebrew program is not needed.

Rust stays with rustup.

`./install.sh` installs mise and runs `mise/apply.sh`. On a machine that is already set up, or on NixOS (where `nix/configuration.nix` provides mise), run:
```console
mise/apply.sh
```

It links `mise/global.toml` to `~/.config/mise/config.toml` and, unless `NO_DEV` is set, `mise/dev.toml` to `~/.config/mise/conf.d/dev.toml`. For login shells it adds the mise shims to `~/.zprofile`, and `/opt/homebrew/bin` on a Mac without Homebrew. Then it runs `mise bootstrap --only packages`, which asks before it installs packages, and `mise install`. When a package fails to install, it still installs the tools and exits 1 at the end. `zsh/.zshrc` activates mise in interactive shells.

On a Mac, `mise/dev.toml` runs Docker with colima instead of Docker Desktop: run `colima start` before the first `docker` command. `docker compose` and `docker buildx` work through the links that `mise install` writes to `~/.docker/cli-plugins`, and `docker login` keeps credentials in the Keychain through `docker-credential-osxkeychain`. On a Mac that ran Docker Desktop, change `"credsStore": "desktop"` to `"credsStore": "osxkeychain"` in `~/.docker/config.json`, or `docker` fails to find `docker-credential-desktop`.

`zsh/.zshrc` also points `GH_PATH` at the mise shim of `gh`, so `gh auth login` and `gh auth setup-git` write a Git credential helper that still works after `mise upgrade`. On a machine where either ran before this setup, run `gh auth setup-git` again.

The links point into the checkout that runs `mise/apply.sh`, so run it from the main checkout and keep `mise/` there: it refuses to run from a worktree. When a link breaks, for example on a branch without `mise/`, new shells print a warning and `./update.sh` skips `mise upgrade` and `mise prune`; run `mise/apply.sh` again.

To add a tool, run `mise use -g <tool>`. It installs the tool and writes it through the link into `mise/global.toml`, so commit the change. For a tool that `NO_DEV` machines skip, add it to `mise/dev.toml`. To add a package, add a `"<manager>:<package>"` entry under `[bootstrap.packages]`, with `os = "macos"` on Homebrew entries. Then run `mise/apply.sh`.

## Update
```console
./update.sh
```

On NixOS this also upgrades the system through `nix/apply.sh --upgrade`. To apply `nix/configuration.nix` without upgrading:
```console
nix/apply.sh
```

tmux plugins update through TPM. Catppuccin is pinned to a tag in `tmux/.tmux.conf`: to upgrade it, change the tag, remove `~/.tmux/plugins/tmux` and press `prefix + I`.

## Ghostty
`./install.sh` links `ghostty/config.ghostty` to `~/.config/ghostty/config.ghostty`. On a machine that is already set up, or on NixOS, run:
```console
ghostty/apply.sh
```

The config keeps the font, colors, window size, cursor, and `TERM` of the iTerm2 profile that Ghostty replaces. Ghostty already sends `ESC b` and `ESC f` for `⌥←` and `⌥→`, so it needs no key mapping. Ghostty reads the file through the link: after a change, press `⌘⇧,` (`ctrl+shift+,` on Linux) to reload it. `ghostty +show-config --default --docs` shows all the options.

The link points into the checkout that runs `ghostty/apply.sh`, so run it from the main checkout: it refuses to run from a worktree. On a branch without `ghostty/`, Ghostty starts with its defaults.

## Claude Code statusline
`./install.sh` sets it up. On a machine that is already set up, or on NixOS, run:
```console
claude/install-statusline.sh
```

It copies `claude/statusline.sh` to `~/.claude/statusline.sh`, installs the pinned `ccusage` into `~/.claude/statusline/` with `npm ci`, and points `statusLine` in `~/.claude/settings.json` (and in `~/.claude-work/settings.json` when that profile exists) at the copy. It needs `jq`. Without `npm`, the statusline uses `ccusage` from `PATH`. The copy does not follow the repo: run the installer again after changing `claude/statusline.sh`, `claude/package.json`, or `claude/package-lock.json`.

To upgrade `ccusage`, run `npm install --prefix claude --save-exact ccusage@<version>` and commit `claude/package.json` and `claude/package-lock.json`.

## herdr
[herdr](https://herdr.dev) runs coding agents in terminal panes that a background server keeps alive, and its sidebar shows which agents are working, blocked, or idle. mise installs it from `mise/global.toml`, and `./install.sh` sets it up. On a machine that is already set up, or on NixOS, run:
```console
herdr/apply.sh
```

It copies `herdr/config.toml` to `~/.config/herdr/config.toml` and installs herdr's Claude Code integration in each Claude profile that exists (`~/.claude` and `~/.claude-work`). It names a profile that it skips: run it again once that profile exists. The integration is a `SessionStart` hook in `settings.json` that runs `hooks/herdr-agent-state.sh`: it lets herdr resume the same Claude session after the herdr server restarts. The hook needs `python3` and does nothing outside a herdr pane.

The server takes its environment from the shell that starts it, and herdr resumes every session in that environment, so a session comes back only when its `CLAUDE_CONFIG_DIR` matches the server's. A session started with `CLAUDE_CONFIG_DIR=~/.claude-work` in a server started without it is looked up in `~/.claude`, where it does not exist: run `claude --resume` with `CLAUDE_CONFIG_DIR=~/.claude-work` to get it back.

The copy does not follow the repo: run the script again after changing `herdr/config.toml`, and press `prefix+shift+r` in a running herdr to reload its config. The script moves an existing config that differs to `config.toml.bak`, so to keep a change made in herdr's Settings screen, copy it into `herdr/config.toml`.

Start herdr with `herdr`. The prefix is `ctrl+b`, as in tmux: `prefix+?` lists the keys, `prefix+q` detaches and leaves the agents running, and `herdr` attaches again. Inside tmux, press `ctrl+b` twice to reach herdr's prefix.

`./update.sh` upgrades herdr through `mise upgrade`; `herdr update` does not update a mise install. A running server stays on the old version until `herdr server stop`, which also stops its panes. Run `herdr/apply.sh` again when `herdr integration status` shows the Claude integration as outdated.

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
- Set a Nerd Font as Terminal font; the SessionX key hints need Nerd Fonts 2.3 or newer, and a `MesloLGS NF` downloaded before April 2023 is older than that

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