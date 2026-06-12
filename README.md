# dotfiles

macOS dotfiles for **zsh**, **bash**, **tmux**, and **Ghostty** — tuned for DevOps and Data Engineering with a unified Catppuccin Mocha theme.

---

## Layout

```
dotfiles/
├── bash/
│   ├── bash_profile   → ~/.bash_profile
│   ├── bashrc         → ~/.bashrc
│   └── bash_aliases   → ~/.bash_aliases
├── zsh/
│   ├── zshrc          → ~/.zshrc
│   └── zsh_aliases    → ~/.zsh_aliases
├── tmux/
│   └── tmux.conf      → ~/.tmux.conf
├── ghostty/
│   └── config         → ~/.config/ghostty/config
├── ssh/
│   └── config         → ~/.ssh/config
├── hushlogin          → ~/.hushlogin
└── README.md
```

---

## Prerequisites

```bash
# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# zsh plugins
brew install zsh-completions zsh-autosuggestions zsh-syntax-highlighting
chmod go-w "$(brew --prefix)/share"

# bash completions
brew install bash-completion@2
```

> **zsh/bash completions** — brew-installed tools with a `_toolname` completion file load automatically via FPATH.
> For other tools that support `tool completion zsh/bash`, add the tool name to the `_zsh_load_completions` / `_bash_load_completions` loop.
> **Ollama** uses a hand-written completion function (both shells) that also resolves live model names for `run`, `show`, `cp`, `rm`, and `push`.

---

## Suggested packages

> **GUI apps** — install from their official websites, not brew. Brew is for CLI tools only.
> Brew cask packages are often outdated and bypass the app's own updater.

### Terminal

- **Ghostty** → [ghostty.org](https://ghostty.org) — download the `.dmg`, drag to `/Applications`
- **tmux** → `brew install tmux`

### Version control
```bash
brew install git git-lfs gh pre-commit
```

### Editors
```bash
brew install vim neovim
```

### System monitoring
```bash
brew install btop duf ncdu htop
```

### Network
```bash
brew install sshuttle ipcalc nmap mtr wget curl httpie
```

### File tools
```bash
brew install unar tree
```

### Data / text processing
```bash
brew install jq yq csvkit
```

### Security
```bash
brew install gnupg openssl
```

### AI / LLM

> **Ollama** — install from [ollama.com](https://ollama.com), not brew.
> Drag `Ollama.app` to `/Applications` and run it once. The `ollama` CLI is placed at `/usr/local/bin/ollama` automatically.

### One-liner (excluding casks and Ollama)

```bash
brew install git git-lfs gh pre-commit vim neovim btop duf ncdu htop sshuttle ipcalc nmap mtr wget curl httpie unar tree jq yq csvkit gnupg openssl
```

---

## VSCode

The ARM `.pkg` installer does not register the `code` CLI. Fix from inside VSCode:

1. `Cmd+Shift+P` → **Shell Command: Install 'code' command in PATH**

VSCode writes a symlink to `/usr/local/bin/code`.

> **Manual fallback** — add to `~/.zshrc`:
> ```zsh
> export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
> ```

---

## Deploy

```bash
# Ghostty — requires full quit and relaunch after deploy
mkdir -p ~/.config/ghostty && cp ghostty/config ~/.config/ghostty/config

# zsh
cp zsh/zshrc ~/.zshrc && cp zsh/zsh_aliases ~/.zsh_aliases && source ~/.zshrc

# bash
cp bash/bash_profile ~/.bash_profile && cp bash/bashrc ~/.bashrc && cp bash/bash_aliases ~/.bash_aliases

# tmux
cp tmux/tmux.conf ~/.tmux.conf && tmux source-file ~/.tmux.conf

# ssh
mkdir -p ~/.ssh && cp ssh/config ~/.ssh/config && chmod 600 ~/.ssh/config

# Suppress "Last login" message
cp hushlogin ~/.hushlogin
```

> Switch to bash: `chsh -s /bin/bash` — revert: `chsh -s /bin/zsh`

> **SSH config** — `ssh/config` points every host at `~/.ssh/id_ed25519` on
> port 22 and skips host-key checking (`StrictHostKeyChecking no`,
> `UserKnownHostsFile /dev/null`). If that key has a passphrase,
> `AddKeysToAgent 5m` caches it in `ssh-agent` for 5 minutes after first use —
> the same 5-minute window as macOS `sudo`'s default credential cache — so you
> aren't re-prompted on every connection within that window.

---

## Root user

Root prompt turns **red** as a visual alarm. macOS defaults root to `/bin/sh` — change it first:

```bash
sudo dscl . -create /Users/root UserShell /bin/zsh
```

Deploy:

```bash
sudo cp zsh/zshrc /var/root/.zshrc && sudo cp zsh/zsh_aliases /var/root/.zsh_aliases
sudo cp bash/bash_profile /var/root/.bash_profile && sudo cp bash/bashrc /var/root/.bashrc && sudo cp bash/bash_aliases /var/root/.bash_aliases
sudo cp tmux/tmux.conf /var/root/.tmux.conf
sudo mkdir -p /var/root/.ssh && sudo cp ssh/config /var/root/.ssh/config && sudo chmod 600 /var/root/.ssh/config
```

Verify: `sudo -i` → prompt shows `[zsh] root@...` in red.

---

## Fonts

The prompt uses Powerline glyphs (segment separators  and the git branch icon
) — these require a [Nerd Font](https://www.nerdfonts.com/).

**JetBrainsMono Nerd Font** (open source, SIL OFL):

```bash
brew install --cask font-jetbrains-mono-nerd-font
```

> **Manual install** — download `JetBrainsMono.zip` from the
> [Nerd Fonts releases page](https://github.com/ryanoasis/nerd-fonts/releases),
> unzip, then open each `.ttf` and click **Install Font** (or drop them into
> `~/Library/Fonts/`).

Ghostty is already configured to use the fixed-width variant
(`font-family = JetBrainsMono Nerd Font Mono` in `ghostty/config`) — the plain
"Nerd Font" family is proportional and throws off glyph alignment in a
terminal.

> **Font changes need a full restart** — after installing the font (or editing
> `font-family`), fully quit Ghostty (`Cmd+Q`), not just reload the config
> (`Cmd+Shift+,`). A config reload does not pick up font changes.

> **Why commenting out `font-family` changes nothing** — Ghostty's built-in
> default font *is* JetBrains Mono (bundled with the app), and Ghostty also
> ships an embedded Nerd Font glyph fallback. So with the line commented out
> you still get JetBrains Mono with working powerline glyphs. To verify the
> setting is actually applying, swap in a visually different font (e.g. the
> commented `SF Mono` line in `ghostty/config`) and fully restart — or run
> `ghostty +show-config | grep font` to see the effective value.

---

## Prompt

Two connected lines, joined by a left-edge corner (`╭─`/`╰─`). `[shell]` is
plain text; everything from `user@host` onward is a continuous bar of dark
"badge" segments (Powerline style). Every badge background is its Catppuccin
Mocha accent blended 30% into the Base `#1e1e2e` terminal background — so all
badges share the same undertone and weight — and the badge text is the full
bright accent. The tmux status bar uses the exact same values. Command always
starts on a clean line:

```
╭─ [zsh] user@host  k8s:my-cluster  ~/full/path  main  Local 2026-05-27 15:30:00  UTC 2026-05-27 13:30:00
╰─ $
```

When a Python venv is active, it gets its own badge prepended to the bar:

```
╭─ [zsh] (.venv)  user@host  k8s:my-cluster  ~/full/path  main  Local ...  UTC ...
╰─ $
```

Outside a git repository, the git badge reads `not git repo`. When `HEAD` is
detached, it shows the short commit hash instead of a branch name.

`k8s:` reads `kubectl config current-context` on every prompt — Sky text when connected, Red text `k8s:disconnected` when not.

| Segment | Text | Background (accent @ 30% over Base) |
|---|---|---|
| `╭─` / `╰─` corners | Overlay0 `#6c7086` | — |
| `[shell]` | Green `#a6e3a1` (Red `#f38ba8` for root) | — (plain text) |
| `(.venv)` | Mauve `#cba6f7` | `#52476a` |
| `user@host` | Green `#a6e3a1` | `#475950` |
| `user@host` (root) | Red `#f38ba8` | `#5e3f53` |
| `k8s:` (connected) | Sky `#89dceb` | `#3e5767` |
| `k8s:disconnected` | Red `#f38ba8` | `#5e3f53` |
| Path | Blue `#89b4fa` | `#3e4b6b` |
| `branch` | Peach `#fab387` | `#604b49` |
| `not git repo` | Text `#cdd6f4` | `#353748` |
| `Local` time | Lavender `#b4befe` | `#4b4e6c` |
| `UTC` time | Teal `#94e2d5` | `#415960` |
| `$` / `#` ok | Green `#a6e3a1` | — |
| `$` / `#` failed | Red `#f38ba8` | — |

---

## tmux

### Key bindings

| Keys | Action |
|---|---|
| `Shift+←` / `Shift+→` | Previous / next window |
| `Option+W/A/S/D` | Pane focus up / left / down / right |
| `Ctrl+b` + `h/j/k/l` | Pane focus — vim-style with prefix |
| `fn+↑` / `fn+↓` | Enter copy-mode and scroll |
| `q` / `Escape` | Exit copy-mode |
| `Ctrl+b $` | Rename session |
| `Ctrl+b @` | Toggle synchronize-panes (pane borders turn Red while active) |
| `Option+1–5` | Switch to named layout |
| `Option+6` / `Option+7` | Next / previous layout |
| `F12` | Toggle passthrough mode for nested tmux (SSH → remote tmux) |

> `Option+WASD` works because `macos-option-as-alt = true` in Ghostty sends unique Meta sequences (`M-w/a/s/d`) that tmux binds directly.

> **Nested tmux over SSH** — press `F12` before interacting with the remote tmux session. Local tmux stops intercepting all keys (including `fn+↑` copy-mode, `Shift+←/→`, `Ctrl+b`, etc.) and passes everything straight through. The status bar dims to grey and shows `[passthrough]` as a reminder. Press `F12` again to restore local tmux control.

### Status bar colours

| Element | Colour |
|---|---|
| Background | Mantle `#181825` (one step darker than the Base `#1e1e2e` terminal bg, so the bar recedes) |
| Session name | Mauve `#cba6f7` text on `#4e4364` badge (Mauve blended 30% into the bar's Mantle `#181825` background) |
| Active window | Green `#a6e3a1` text on `#43554a` badge (Green blended 30% into Mantle `#181825`) |
| Active window (pane zoomed) | `Z` indicator in Red `#f38ba8` appended to window title |
| Inactive window | Overlay1 `#7f849c` on Mantle `#181825` |
| Active pane border | Mauve `#cba6f7` (Red `#f38ba8` while synchronize-panes is on) |
| Inactive pane border | Surface0 `#313244` (Red `#f38ba8` while synchronize-panes is on) |
| Hostname | Blue `#89b4fa` |

---

## Aliases

### General

| Alias | Action |
|---|---|
| `c` | `clear` |
| `b` | `btop` |
| `t` | `tmux` |
| `reload` | restart shell |
| `pubip` | external IP via ipwho.is |
| `privip` | all private IPs (all interfaces) |
| `pubkey` | print + copy first SSH public key (ed25519 › ecdsa › rsa) |
| `pubkeys` | print all `~/.ssh/*.pub` |
| `password` | random base64-48 password |

### Git

| Alias | Command |
|---|---|
| `gs` / `gaa` | `status` / `add --all` |
| `gc "msg"` / `gca` | `commit -m` / `commit --amend --no-edit` |
| `gco` / `gcob` | `checkout` / `checkout -b` |
| `gl` / `gd` / `gds` | log graph / diff / diff --staged |
| `gp` / `gpf` / `gpl` / `gpr` | push / push --force-with-lease / pull / pull --rebase |
| `gst` / `gstp` / `gstl` | stash / pop / list |
| `gwip` | add all + commit "wip: checkpoint" |
| `gf` / `grb` / `gcp` | fetch --all / rebase / cherry-pick |

### Python / venv

| Alias | Action |
|---|---|
| `py` / `pip` | `python3` / `pip3` |
| `piv` / `va` / `vd` | create `.venv` / activate / deactivate |
| `pipr` / `pipff` | install from requirements / freeze to file |
| `jn` / `jl` | `jupyter notebook` / `jupyter lab` |

### Docker

| Alias | Command |
|---|---|
| `d` / `dps` / `dpsa` | `docker` / `ps` / `ps -a` |
| `dex` / `dlogs` | `exec -it` / `logs -f` |
| `dcu` / `dcd` / `dcl` | `compose up -d` / `down` / `logs -f` |
| `dprune` | `system prune -af --volumes` |

### Kubernetes

| Alias | Command |
|---|---|
| `k` / `kgp` / `kgpa` | `kubectl` / get pods / all namespaces |
| `kgs` / `kgn` / `kgd` | get services / nodes / deployments |
| `klogs` / `kex` | `logs -f` / `exec -it` |
| `kap` / `kdel` | `apply -f` / `delete -f` |
| `kctx` / `kuse` / `kns` | get contexts / use context / set namespace |
| `kdes` / `kdp` | `describe` / `describe pod` |

---

## Notes

- **History** — both shells deduplicate globally, not just consecutive commands. Prefix a command with a space to skip recording it.
- **Ghostty title bar** — `macos-titlebar-style = hidden` requires a full quit and relaunch; config reload alone does not apply it.
- **Ghostty Cmd+D** — ignored (`keybind = cmd+d=ignore`); tmux handles all splits.
- **Ghostty padding** — `window-padding-x/y = 12` clears macOS rounded corners.
- **Ghostty auto-tmux** — `$GHOSTTY_RESOURCES_DIR` is only set inside Ghostty; the shell uses it to auto-attach or create a tmux session on open without affecting other terminals.
- **Ghostty app icon** — `macos-icon = paper` applies to the dock at runtime only; the `/Applications` icon is part of the app bundle and cannot be changed via config.
- **Ghostty scrollback** — disabled (`scrollback-limit = 0`); use tmux copy-mode (`fn+↑`) instead.
- **`macos-option-as-alt`** — Option dead-key characters (`å ß ∂ …`) are unavailable inside Ghostty as a side-effect.
- `cp` `mv` `mkdir` — wrapped with `-iv` / `-pv` (verbose + interactive).
- `flush-dns` — uses macOS `dscacheutil`.

---

## Testing

Smoke-test checklist after deploying the dotfiles to a new machine.

### Prompt

| # | Test | Expected |
|---|---|---|
| 1 | Open a new shell | Two lines joined by a left corner: `╭─ [zsh]` plain text, then a continuous bar of dark hue-tinted badges with `user@host` (green) → `k8s:...` (sky/red) → path (blue) → git (peach/grey) → `Local ...` (lavender) → `UTC ...` (teal) text; `╰─ $` on line 2 |
| 1a | Powerline glyphs (separators, git icon, corners) render as solid shapes, not boxes/`?` | Nerd Font is installed and active in Ghostty |
| 2 | Run `false` | `$` turns **red** on next prompt |
| 3 | Run `true` | `$` returns **green** |
| 4 | `sudo -i` | `[zsh]` text and `user@host` text turn **red**, shows `[zsh] root@...`, `#` symbol |
| 5 | `piv && va` (create + activate venv) | New **mauve** badge text appears before the user@host badge |
| 6 | `vd` (deactivate) | venv badge disappears immediately |
| 6a | `cd` into a git repo | Git badge text shows ` <branch>` in **Peach** |
| 6b | `cd` into a non-git directory | Git badge text shows `not git repo` in **Overlay2/grey** |
| 6c | Checkout a detached HEAD (e.g. `git checkout HEAD~1`) | Git badge shows `<short-hash>` instead of branch name |

### SSH public key

| # | Test | Expected |
|---|---|---|
| 7 | `pubkey` | Key printed to terminal; `pbpaste` returns the same key without a trailing newline |
| 8 | `pubkey` with only `id_rsa.pub` present | Falls back to `id_rsa.pub`, prints `[copied to clipboard: id_rsa.pub]` |
| 9 | `pubkey` with no keys in `~/.ssh/` | Error message: `No public key found ...` |

### Tab completion

| # | Test | Expected |
|---|---|---|
| 10 | `ollama <Tab>` | Subcommands listed: `serve`, `run`, `pull`, `list`, etc. |
| 11 | `ollama run <Tab>` | Locally installed model names from `ollama list` |
| 12 | `kubectl <Tab>` | kubectl subcommands |
| 13 | `k <Tab>` | Same as kubectl (alias completion) |
| 14 | `docker <Tab>` | docker subcommands |

### tmux key bindings

| # | Test | Expected |
|---|---|---|
| 15 | Open Ghostty | tmux session named `main` starts or re-attaches automatically |
| 16 | `Ctrl+b c` → `Shift+←` / `Shift+→` | Cycles between windows without prefix |
| 17 | `Ctrl+b "` → `Option+S` | Focus moves to lower pane |
| 18 | `fn+↑` | Enters copy-mode and scrolls up |
| 19 | `q` or `Escape` | Exits copy-mode |
| 20 | `Ctrl+b z` | Pane zooms to full window; active window tab shows `Z` in peach |
| 21 | `Ctrl+b z` again | Pane un-zooms; `Z` disappears from the tab |
| 22 | `Ctrl+b @` | All panes in window sync input; repeat to turn off |
| 23 | `Option+1` | Switches to even-horizontal layout |

### Nested tmux over SSH

| # | Test | Expected |
|---|---|---|
| 24 | SSH to a server, start tmux there, press `fn+↑` | Local tmux intercepts — remote copy-mode does **not** activate |
| 25 | Press `F12` | Local status bar dims to grey, shows `[passthrough]` |
| 26 | Press `fn+↑` again | Remote tmux enters copy-mode |
| 27 | Press `Ctrl+b c` | New window opens in the **remote** tmux session |
| 28 | Press `F12` again | Local status bar returns to normal colours; local tmux resumes control |

### History

| # | Test | Expected |
|---|---|---|
| 29 | Run `echo test` twice | Only one `echo test` entry in `history` output |
| 30 | Run ` secret` (leading space) | Command is not recorded in history |
