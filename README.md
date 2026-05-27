# dotfiles

macOS shell configuration for **zsh**, **bash**, and **tmux**.
Targets a DevOps + Data Engineering workflow.
Prompt and tmux use the [Catppuccin Mocha](https://github.com/catppuccin/catppuccin) colour palette (24-bit true-colour).

> Designed for **macOS Terminal.app**. Other terminals (iTerm2, Alacritty, Kitty) may need adjustments for true-colour and Option-key bindings.

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
└── README.md
```

---

## Prerequisites

Everything is installed via [Homebrew](https://brew.sh):

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# zsh plugins
brew install zsh-completions zsh-autosuggestions zsh-syntax-highlighting
chmod go-w "$(brew --prefix)/share"

# bash completions
brew install bash-completion@2

# CLI tools
brew install vim wget curl jq btop
```

> **zsh completions**: Tools installed via brew with a `_toolname` file in `site-functions` load automatically.
> For tools installed outside brew (or brew formulas that skip zsh completions), add the tool name to the loop in `.zshrc`:
>
> ```zsh
> for tool in kubectl helm flux kind k3d docker ollama YOUR_TOOL; do
> ```
>
> The tool must support `tool completion zsh` (kubectl, helm, flux, kind, k3d, docker, and **ollama** all do).
> If it uses a different method (e.g., sources a file), add a
> `source /path/to/YOUR_TOOL_completion.zsh` line inside `_zsh_load_completions` instead.

---

## Suggested Packages

Install all at once or pick what you need:

```bash
# System monitoring
brew install btop          # interactive resource monitor (replaces htop)
brew install duf           # disk usage with a pretty table (replaces df)
brew install ncdu          # interactive ncurses disk-usage explorer (replaces du)

# Network tools
brew install sshuttle      # transparent VPN-over-SSH proxy
brew install ipcalc        # IP address / subnet calculator

# Terminal multiplexer
brew install tmux           # required for these dotfiles

# Editors
brew install vim
brew install neovim

# Utilities
brew install unar          # universal unarchiver (rar, 7z, zip, …)
brew install wget
brew install jq            # JSON processor
brew install curl

# AI / LLM
brew install ollama        # run large language models locally
```

One-liner to install all of the above:

```bash
brew install btop duf ncdu sshuttle ipcalc tmux vim neovim unar wget jq curl ollama
```

---

## VSCode

### ARM installer — `code` command missing from PATH

Microsoft's `.pkg` ARM installer for Apple Silicon does **not** automatically add the `code` CLI to your PATH. Fix it from inside VSCode:

1. Open VSCode.
2. Open the Command Palette: `Cmd+Shift+P`
3. Run **Shell Command: Install 'code' command in PATH**

VSCode writes a symlink to `/usr/local/bin/code` and the command works in any new terminal session.

> **Manual fallback** — if the palette command is unavailable, add this to your `~/.zshrc` or `~/.zsh_aliases`:
>
> ```zsh
> export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
> ```
>
> Then `source ~/.zshrc` (or open a new tab).

---

## Deploy

### zsh

```bash
cp zsh/zshrc       ~/.zshrc
cp zsh/zsh_aliases ~/.zsh_aliases
source ~/.zshrc
```

### bash

To test without permanently changing your login shell:

```bash
bash --login
```

Then deploy:

```bash
cp bash/bash_profile ~/.bash_profile
cp bash/bashrc       ~/.bashrc
cp bash/bash_aliases ~/.bash_aliases
source ~/.bashrc
```

Permanently switch: `chsh -s /bin/bash` — revert: `chsh -s /bin/zsh`

### tmux

```bash
cp tmux/tmux.conf ~/.tmux.conf
tmux source-file ~/.tmux.conf
```

---

## Root user

Root gets identical config. The `[shell]` label and username turn **red** as a visual alarm.

macOS defaults root to `/bin/sh` — change it first:

```bash
dscl . -read /Users/root UserShell                    # check
sudo dscl . -create /Users/root UserShell /bin/zsh    # set
dscl . -read /Users/root UserShell                    # confirm: UserShell: /bin/zsh
```

Deploy:

```bash
sudo cp zsh/zshrc         /var/root/.zshrc
sudo cp zsh/zsh_aliases   /var/root/.zsh_aliases
sudo cp bash/bash_profile /var/root/.bash_profile
sudo cp bash/bashrc       /var/root/.bashrc
sudo cp bash/bash_aliases /var/root/.bash_aliases
sudo cp tmux/tmux.conf    /var/root/.tmux.conf
```

Verify: `sudo -i` → prompt shows `[zsh] root@...` in red.

---

## Prompt

Two-line format — command always starts on a clean line:

```
[zsh] user@host:/full/path  Local 2026-05-27 15:30:00  UTC 2026-05-27 13:30:00  k8s:my-cluster
$
```

Root (all in red):

```
[zsh] root@host:/full/path  Local 2026-05-27 15:30:00  UTC 2026-05-27 13:30:00  k8s:disconnected
#
```

`k8s:` reads `kubectl config current-context` on every prompt.
Shows the active cluster in Sky, or `disconnected` in Red when no context is found.

### Colour reference

| Element | Colour |
|---|---|
| `[shell]` + username — regular | Green `#a6e3a1` |
| `[shell]` + username — root | Red `#f38ba8` |
| `@` `:` decorators | Mauve `#cba6f7` |
| Hostname | Yellow `#f9e2af` |
| Path | Blue `#89b4fa` |
| `Local` date/time | Text `#cdd6f4` |
| `UTC` date/time | Teal `#94e2d5` |
| `k8s:` active cluster | Sky `#89dceb` |
| `k8s:disconnected` | Red `#f38ba8` |
| `$` / `#` — last cmd ok | Green `#a6e3a1` |
| `$` / `#` — last cmd failed | Red `#f38ba8` |

---

## tmux

### Key bindings

| Keys | Action |
|---|---|
| `Shift+←` / `Shift+→` | Previous / next window |
| `Option+W/A/S/D` | Move pane focus up / left / down / right |
| `Ctrl+b` + `h/j/k/l` | Same — vim-style fallback with prefix |
| `fn+↑` / `fn+↓` | Enter copy mode and scroll |
| `q` or `Escape` | Exit copy mode |
| `Ctrl+b $` | Rename current session |
| `Ctrl+b @` | Toggle synchronize-panes |
| `Option+1–5` | Switch to named layout |
| `Option+6` / `Option+7` | Cycle layouts forward / backward |

> **Pane navigation**: `Ctrl+Arrow` and `Ctrl+Shift+Arrow` cannot be used — macOS Terminal.app intercepts both before tmux sees them. Option+WASD works because Terminal.app sends unique Unicode chars (`∑ å ß ∂`) that tmux binds directly, exactly like the layout shortcuts.

> **Session name**: the number shown on the left of the status bar (e.g. `8`) is the auto-assigned session name. Rename it with `Ctrl+b $` or `tmux rename-session <name>`.

### Status bar colours

| Element | Colour |
|---|---|
| Background | Base `#1e1e2e` |
| Session name | Mauve `#cba6f7` |
| Active window | Blue `#89b4fa` on Surface0 `#313244` |
| Inactive window | Overlay0 `#6c7086` |
| Active pane border | Mauve `#cba6f7` |
| Hostname | Blue `#89b4fa` |

### Layout reference

| Keys | Layout |
|---|---|
| `Option+1` | even-horizontal |
| `Option+2` | even-vertical |
| `Option+3` | main-horizontal |
| `Option+4` | main-vertical |
| `Option+5` | tiled |

---

## Aliases quick-reference

### General

| Alias | Action |
|---|---|
| `c` | `clear` |
| `b` | `btop` |
| `t` | `tmux` |
| `k` | `kubectl` |
| `reload` | restart shell |
| `myip` | public IP via ipwho.is |
| `password` | random base64-48 password |

### Git

| Alias | Command |
|---|---|
| `gs` / `gaa` | `status` / `add --all` |
| `gc "msg"` / `gca` | `commit -m` / `commit --amend --no-edit` |
| `gco` / `gcob` | `checkout` / `checkout -b` |
| `gl` / `gd` / `gds` | log graph / diff / diff --staged |
| `gp` / `gpl` / `gpr` | push / pull / pull --rebase |
| `gst` / `gstp` / `gstl` | stash / pop / list |
| `gwip` | add all + commit "wip: checkpoint" |
| `gf` / `grb` / `gcp` | fetch --all / rebase / cherry-pick |

### Python / venv

| Alias | Action |
|---|---|
| `py` / `pip` | `python3` / `pip3` |
| `piv` / `va` / `vd` | create `.venv` / activate / deactivate |
| `pipr` / `pipff` | install from requirements / freeze |
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

- `password` — `openssl rand -base64 48`, no install needed.
- `myip` — pretty-prints ipwho.is via `jq`.
- `cp` `mv` `mkdir` — wrapped with `-iv` / `-pv` (verbose + interactive).
- `flush-dns` — uses macOS `dscacheutil`.
- `#` comments work in zsh interactive shells (`setopt INTERACTIVE_COMMENTS` is set).
