# dotfiles

macOS dotfiles for **bash**, **tmux**, **Ghostty**, and **Neovim** — Catppuccin Mocha theme throughout.

---

## Layout

```
dotfiles/
├── bash/
│   ├── bash_profile   → ~/.bash_profile
│   ├── bashrc         → ~/.bashrc
│   └── bash_aliases   → ~/.bash_aliases
├── tmux/
│   └── tmux.conf      → ~/.tmux.conf
├── ghostty/
│   └── config         → ~/.config/ghostty/config
├── nvim/
│   └── init.lua       → ~/.config/nvim/init.lua
├── ssh/
│   └── config         → ~/.ssh/config.d/dotfiles
├── install.sh
└── hushlogin          → ~/.hushlogin
```

---

## Prerequisites

```bash
# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Required tools
brew install bash bash-completion@2 tmux neovim git git-lfs gh vim \
             btop jq yq curl wget tree pyright

# Ghostty — download .dmg from ghostty.org
# Nerd Font (for prompt glyphs)
brew install --cask font-jetbrains-mono-nerd-font
```

---

## Deploy

```bash
./install.sh   # idempotent — safe to re-run
exec bash      # reload current session
```

The script copies every dotfile into place and sets bash as the default shell
for both your user and root. It will ask whether to configure root — enter `y`
and your sudo password, or press Enter to skip root.

SSH settings are written to `~/.ssh/config` — stale blocks from previous installs are replaced automatically, fresh installs append.

> **Remove all zsh customisations** (reverts to macOS defaults — does not uninstall zsh):
> ```bash
> rm -f ~/.zshrc ~/.zsh_aliases ~/.zsh_history
> rm -rf ~/.zsh_sessions
> exec zsh
> ```

---

## Root user

Root prompt turns red. macOS defaults root to `/bin/sh` — change it first:

```bash
sudo dscl . -create /Users/root UserShell /bin/bash
sudo cp bash/bash_profile /var/root/.bash_profile
sudo cp bash/bashrc       /var/root/.bashrc
sudo cp bash/bash_aliases /var/root/.bash_aliases
sudo cp tmux/tmux.conf    /var/root/.tmux.conf
```

---

## Neovim

Minimal plugin config (`nvim/init.lua`). `<leader>` = Space.  
Plugins install automatically on first launch (requires internet + `git`).

**Plugins:** `catppuccin` · `nvim-tree` · `lualine` · `vim-visual-multi` · `gitsigns` · `nvim-lspconfig` · `blink.cmp`

`Space` is the leader key.

**File explorer**

| Keys | Action |
|---|---|
| `Space+e` | Open / close explorer panel |
| `Enter` | Open file or expand folder |
| `Ctrl+h` / `Ctrl+l` | Jump between explorer and editor |
| `a` | New file (`filename`) or folder (`foldername/`) |
| `r` | Rename |
| `d` | Delete |

**Working with files**

| Keys | Action |
|---|---|
| `Space+w` | Save current file |
| `Space+q` | Close current window |
| `Space+Q` | Quit everything |
| `Space+bd` | Close current file (keep window) |
| `Space+bn` / `Space+bp` | Next / previous open file |

**Moving between splits**

| Keys | Action |
|---|---|
| `Ctrl+h/j/k/l` | Focus left / down / up / right window |

**Editing**

| Keys | Action |
|---|---|
| `Esc` | Clear search highlight |
| `Ctrl+n` | Select word under cursor — press again to add next match |
| `Ctrl+↑` / `Ctrl+↓` | Add cursor on line above / below |
| `Esc` (twice) | Exit multi-cursor mode |
| `v` then `<` / `>` | Indent selection (stays in visual mode) |
| `v` then `J` / `K` | Move selected lines down / up |

**Code (LSP — Python)**

| Keys | Action |
|---|---|
| `K` | Show docs for symbol under cursor |
| `gd` | Go to definition |
| `gr` | Show all references |
| `Space+rn` | Rename symbol |
| `Space+ca` | Code actions (quick fixes) |
| `Ctrl+Space` | Trigger autocomplete manually |
| `Enter` | Accept suggestion |
| `Ctrl+n` / `Ctrl+p` | Navigate suggestion list |

Filetype support: Python (pyright LSP + autocomplete), bash/sh, YAML, `.cfg`/`.conf`, `.env`, Dockerfile.

---

## Prompt

```
╭─ [bash]  venv:name  user@host  k8s:cluster  branch*⇡1  ~/path  Local ...  UTC ...
╰─ $
```

Git badge suffixes: `*` unstaged · `+` staged · `⇡N` ahead · `⇣N` behind · `{N}` stashes.  
`k8s:` shows `kubectl config current-context` — red when disconnected.  
`venv:` shows the active virtualenv name, or `venv:inactive` when none is active.

| Segment | Background |
|---|---|
| `venv:name` | Mauve `#52476a` |
| `venv:inactive` | Overlay `#353748` |
| `user@host` | Green `#475950` (Red `#5e3f53` for root) |
| `k8s:` connected | Sky `#3e5767` |
| `k8s:disconnected` | Red `#5e3f53` |
| git branch | Peach `#604b49` |
| not git repo | Overlay `#353748` |
| path | Blue `#3e4b6b` |
| Local time | Lavender `#4b4e6c` |
| UTC time | Teal `#415960` |

---

## tmux

| Keys | Action |
|---|---|
| `Shift+←` / `Shift+→` | Previous / next window |
| `Option+W/A/S/D` | Pane focus (no prefix) |
| `Ctrl+b` + `h/j/k/l` | Pane focus (prefix) |
| `fn+↑` / `fn+↓` | Enter / scroll copy-mode |
| `q` / `Esc` | Exit copy-mode |
| `Ctrl+b @` | Toggle synchronize-panes — borders turn red |
| `Ctrl+b $` | Rename session |
| `Option+1–5` | Even-H / Even-V / Main-H / Main-V / Tiled |
| `Option+6` / `Option+7` | Next / previous layout |
| `F12` | Toggle passthrough for nested tmux over SSH |

---

## Aliases

| Alias | Action |
|---|---|
| `c` / `reload` | clear / restart shell |
| `t` | tmux |
| `v` / `nv` | vim / nvim |
| `pubkey` | print + clipboard first SSH public key |
| `password` | random base64-48 string |
| `pubip` / `privip` | external / private IP |
| `cpy` | pipe filter — `cmd 2>&1 \| cpy` prints and copies output |

**Git:** `g gs ga gaa gc gca gco gcob gb gl gd gds gp gpf gpl gpr gst gstp gstl gf grb gcp gwip`

**Python:** `py pip piv va vd pipi pipr pipff jn jl`

**Docker:** `d dps dpsa di dex dlogs dstop dstart dprune dc dcu dcd dcl dcr dcb`

**Kubernetes:** `k kgp kgpa kgs kgn kgd kdes kdp kds kdn klogs kex kap kdel kctx kuse kns krun`

---

## SSH

`ssh/config` is appended to `~/.ssh/config` (re-running replaces any stale block). Settings: `IdentityFile ~/.ssh/id_ed25519`, `Port 22`, `StrictHostKeyChecking no`, `UserKnownHostsFile /dev/null`, `AddKeysToAgent 5m` (caches passphrase for 5 min, matching `sudo`'s default window).
