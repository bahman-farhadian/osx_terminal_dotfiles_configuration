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

# Suppress "Last login" message
cp hushlogin ~/.hushlogin
```

> Switch to bash: `chsh -s /bin/bash` — revert: `chsh -s /bin/zsh`

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
```

Verify: `sudo -i` → prompt shows `[zsh] root@...` in red.

---

## Prompt

Two-line format — command always starts on a clean line:

```
[zsh] user@host:/full/path  Local 2026-05-27 15:30:00  UTC 2026-05-27 13:30:00  k8s:my-cluster
$
```

When a Python venv is active, the environment name is prepended on the first line:

```
(.venv) [zsh] user@host:/full/path  Local ...  UTC ...  k8s:...
$
```

`k8s:` reads `kubectl config current-context` on every prompt — Sky when connected, Red `disconnected` when not.

| Element | Colour |
|---|---|
| `(.venv)` venv indicator | Mauve `#cba6f7` |
| `[shell]` + username | Green `#a6e3a1` |
| `[shell]` + username (root) | Red `#f38ba8` |
| `@` `:` decorators | Mauve `#cba6f7` |
| Hostname | Yellow `#f9e2af` |
| Path | Blue `#89b4fa` |
| `Local` date/time | Text `#cdd6f4` |
| `UTC` date/time | Teal `#94e2d5` |
| `k8s:` active | Sky `#89dceb` |
| `k8s:disconnected` | Red `#f38ba8` |
| `$` / `#` ok | Green `#a6e3a1` |
| `$` / `#` failed | Red `#f38ba8` |

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
| `Ctrl+b @` | Toggle synchronize-panes |
| `Option+1–5` | Switch to named layout |
| `Option+6` / `Option+7` | Next / previous layout |

> `Option+WASD` works because `macos-option-as-alt = true` in Ghostty sends unique Meta sequences (`M-w/a/s/d`) that tmux binds directly.

### Status bar colours

| Element | Colour |
|---|---|
| Background | Base `#1e1e2e` |
| Session name | Mauve `#cba6f7`, no background |
| Active window | Blue `#89b4fa` on Surface0 `#313244` |
| Inactive window | Overlay0 `#6c7086` |
| Active pane border | Mauve `#cba6f7` |
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
